import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:deliveryboy/src/constants/const/api_endpoints.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A class that handles all API requests with retry, token refresh, and error handling
class ApiClient {
  static const _maxRetryAttempts = 3;
  static const _initialRetryDelay = Duration(seconds: 1);
  static const _maxRetryDelay = Duration(seconds: 10);
  static const _tokenRefreshEndpoint = '/auth/refresh-token';
  static const _tokenKey = 'auth_token';
  static const _refreshTokenKey = 'refresh_token';

  static final ApiClient _instance = ApiClient._internal();
  late final Dio _dio;
  bool _isRefreshingToken = false;
  final List<_QueuedRequest> _requestQueue = [];
  final Completer<String?> _tokenRefreshCompleter = Completer<String?>();

  /// Factory constructor to return the same instance
  factory ApiClient() => _instance;

  /// Private constructor for singleton
  ApiClient._internal() {
    _initDio();
    _addInterceptors();
  }

  /// Get the Dio instance
  Dio get dio => _dio;

  void _initDio() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    // Configure SSL certificate verification (only for development)
    if (!_isProduction()) {
      (_dio.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate = (HttpClient client) {
        client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
        return client;
      };
    }
  }

  String _getBaseUrl() {
    try {
      return GlobalConfiguration().getValue('api_base_url') ?? 
             GlobalConfiguration().getValue('base_url') ??
             'https://your-api-base-url.com';
    } catch (e) {
      return 'https://your-api-base-url.com';
    }
  }

  void _addInterceptors() {
    // Add request interceptor for auth token
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        try {
          final token = await _getAuthToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
        } catch (e) {
          print('Error getting auth token: $e');
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        // Handle 401 Unauthorized errors (token expired)
        if (error.response?.statusCode == 401) {
          try {
            final newToken = await _handleTokenRefresh();
            if (newToken != null) {
              // Update the token in the request and retry
              error.requestOptions.headers['Authorization'] = 'Bearer $newToken';
              final response = await _dio.fetch(error.requestOptions);
              return handler.resolve(response);
            } else {
              // Token refresh failed, clear auth
              await _clearAuth();
            }
          } catch (e) {
            print('Token refresh error: $e');
            await _clearAuth();
          }
        }
        handler.next(error);
      },
    ));

    // Add logging interceptor (only in debug mode)
    if (!_isProduction()) {
      _dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          error: true,
          compact: true,
          maxWidth: 90,
        ),
      );
    }
  }

  // Simplified token refresh handling
  Future<String?> _handleTokenRefresh() async {
    if (_isRefreshingToken) {
      // Wait for the ongoing refresh to complete
      return _tokenRefreshCompleter.future;
    }

    _isRefreshingToken = true;
    try {
      final newToken = await _refreshToken();
      if (!_tokenRefreshCompleter.isCompleted) {
        _tokenRefreshCompleter.complete(newToken);
      }
      return newToken;
    } catch (e) {
      if (!_tokenRefreshCompleter.isCompleted) {
        _tokenRefreshCompleter.completeError(e);
      }
      rethrow;
    } finally {
      _isRefreshingToken = false;
    }
  }

  // Token management
  Future<String?> _getAuthToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    } catch (e) {
      return null;
    }
  }

  Future<void> _saveAuthData(String token, String refreshToken) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      await prefs.setString(_refreshTokenKey, refreshToken);
    } catch (e) {
      print('Error saving auth: $e');
    }
  }

  Future<void> _clearAuth() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_refreshTokenKey);
    } catch (e) {
      print('Error clearing auth: $e');
    }
  }

  Future<String?> _refreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString(_refreshTokenKey);
      
      if (refreshToken == null) return null;
      
      final response = await _dio.post<Map<String, dynamic>>(
        _tokenRefreshEndpoint,
        data: {'refresh_token': refreshToken},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );
      
      if (response.statusCode == 200 && response.data != null) {
        final newToken = response.data!['token'] as String?;
        final newRefreshToken = response.data!['refresh_token'] as String?;
        
        if (newToken != null && newRefreshToken != null) {
          await _saveAuthData(newToken, newRefreshToken);
          return newToken;
        }
      }
      
      return null;
    } catch (e) {
      print('Token refresh failed: $e');
      return null;
    }
  }

  // Error handling helpers
  String? _extractErrorMessage(dynamic data) {
    if (data == null) return null;
    
    try {
      if (data is Map) {
        return data['message']?.toString() ?? 
               data['error']?.toString() ?? 
               data['detail']?.toString();
      } else if (data is String) {
        try {
          final jsonData = jsonDecode(data);
          if (jsonData is Map) {
            return jsonData['message']?.toString() ?? 
                   jsonData['error']?.toString() ?? 
                   jsonData['detail']?.toString();
          }
        } catch (_) {
          return data;
        }
      }
      return data.toString();
    } catch (_) {
      return data.toString();
    }
  }

  ApiException _handleDioError(DioException error) {
    if (error.response != null) {
      final statusCode = error.response!.statusCode ?? 0;
      final errorMessage = _extractErrorMessage(error.response?.data) ??
          'Request failed with status $statusCode';
      
      switch (statusCode) {
        case 400:
          return ApiException('Bad request: $errorMessage', statusCode);
        case 401:
          return ApiException('Authentication failed: $errorMessage', statusCode);
        case 403:
          return ApiException('Access denied: $errorMessage', statusCode);
        case 404:
          return ApiException('Resource not found: $errorMessage', statusCode);
        case 422:
          return ApiException('Validation error: $errorMessage', statusCode);
        case 429:
          return ApiException('Too many requests: $errorMessage', statusCode);
        case 500:
          return ApiException('Server error: $errorMessage', statusCode);
        case 502:
          return ApiException('Bad gateway: $errorMessage', statusCode);
        case 503:
          return ApiException('Service unavailable: $errorMessage', statusCode);
        default:
          if (statusCode >= 400 && statusCode < 500) {
            return ApiException('Client error: $errorMessage', statusCode);
          } else if (statusCode >= 500) {
            return ApiException('Server error: $errorMessage', statusCode);
          }
          return ApiException('Request failed: $errorMessage', statusCode);
      }
    } else if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return ApiException('Connection timeout. Please check your internet connection.', 0);
    } else if (error.type == DioExceptionType.cancel) {
      return ApiException('Request was cancelled', 0);
    } else if (error.error is SocketException) {
      return ApiException('No internet connection. Please check your network settings.', 0);
    }
    
    return ApiException('Network error: ${error.message}', 0);
  }

  // Request methods with retry logic
  Future<Response<T>> request<T>(
    String method,
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
    int maxRetries = _maxRetryAttempts,
  }) async {
    int attempt = 0;
    Duration delay = _initialRetryDelay;
    
    while (true) {
      try {
        final response = await _dio.request<T>(
          path,
          data: data,
          queryParameters: queryParameters,
          options: _mergeOptions(options, method: method),
          cancelToken: cancelToken,
          onSendProgress: onSendProgress,
          onReceiveProgress: onReceiveProgress,
        );
        
        return response;
      } on DioException catch (e) {
        // Handle the error
        final handledError = _handleDioError(e);
        
        // Don't retry on client errors (4xx) except for specific cases
        if (e.response?.statusCode != null) {
          final statusCode = e.response!.statusCode!;
          if (statusCode >= 400 && statusCode < 500 &&
              statusCode != 408 && // Request Timeout
              statusCode != 429) { // Too Many Requests
            throw handledError;
          }
        }
        
        // Don't retry on cancellation or when max retries are reached
        if (e.type == DioExceptionType.cancel || attempt >= maxRetries) {
          throw handledError;
        }
        
        // Exponential backoff with jitter
        attempt++;
        final jitter = Duration(milliseconds: DateTime.now().millisecondsSinceEpoch % 1000);
        await Future.delayed(delay + jitter);
        
        // Increase delay for next attempt
        delay = Duration(milliseconds: (delay.inMilliseconds * 2).clamp(
          _initialRetryDelay.inMilliseconds,
          _maxRetryDelay.inMilliseconds,
        ));
      } catch (e) {
        throw ApiException('Unexpected error: $e', 0);
      }
    }
  }

  // Convenience methods
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onReceiveProgress,
  }) {
    return request<T>(
      'GET',
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
    );
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  }) {
    return request<T>(
      'POST',
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  }) {
    return request<T>(
      'PUT',
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return request<T>(
      'DELETE',
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  // Multipart request for file uploads
  Future<Response<T>> uploadFile<T>(
    String path, {
    required Map<String, dynamic> fields,
    required Map<String, dynamic> files,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
  }) async {
    try {
      final formData = FormData.fromMap(fields);
      
      // Add files to form data
      for (final entry in files.entries) {
        final key = entry.key;
        final value = entry.value;
        
        if (value is List) {
          // Handle multiple files
          for (var file in value) {
            if (file is File) {
              formData.files.add(MapEntry(
                key,
                await MultipartFile.fromFile(
                  file.path,
                  filename: file.path.split('/').last,
                ),
              ));
            }
          }
        } else if (value is File) {
          // Handle single file
          formData.files.add(MapEntry(
            key,
            await MultipartFile.fromFile(
              value.path,
              filename: value.path.split('/').last,
            ),
          ));
        }
      }

      return await request<T>(
        'POST',
        path,
        data: formData,
        queryParameters: queryParameters,
        options: (options ?? Options()).copyWith(
          contentType: 'multipart/form-data',
        ),
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
      );
    } catch (e) {
      throw ApiException('Failed to upload file: $e', 0);
    }
  }

  // Helper methods
  Options _mergeOptions(Options? options, {String? method}) {
    return (options ?? Options()).copyWith(
      method: method,
      headers: {
        ..._dio.options.headers,
        ...?options?.headers,
      },
    );
  }

  bool _isProduction() {
    return const bool.fromEnvironment('dart.vm.product');
  }

  // Public methods for auth management
  Future<void> setAuthToken(String token, String refreshToken) async {
    await _saveAuthData(token, refreshToken);
  }

  Future<void> clearAuthToken() async {
    await _clearAuth();
  }

  Future<bool> isAuthenticated() async {
    final token = await _getAuthToken();
    return token != null;
  }

  // Cleanup
  void dispose() {
    _dio.close(force: true);
  }
}

// Custom exception class for API errors
class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException(this.message, this.statusCode);

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

// Internal class for queued requests
class _QueuedRequest {
  final RequestOptions requestOptions;
  final Function(Response<dynamic>) onResolve;
  final Function(DioException) onReject;

  _QueuedRequest({
    required this.requestOptions,
    required this.onResolve,
    required this.onReject,
  });
}