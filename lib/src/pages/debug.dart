import 'dart:convert';
import 'dart:math' as Math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;

import '../repository/order_repository.dart' as orderRepo;
import '../repository/user_repository.dart' as userRepo;
import '../models/user.dart';

class DebugScreen extends StatefulWidget {
  const DebugScreen({super.key});

  @override
  _DebugScreenState createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
  Map<String, dynamic>? testResult;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('🔍 API Debug Info'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Info Card
            _buildUserInfoCard(),
            SizedBox(height: 16),
            
            // Configuration Card
            _buildConfigCard(),
            SizedBox(height: 16),
            
            // Test Connection Button
            _buildTestButton(),
            SizedBox(height: 12),
            
            // Test Login Button
            _buildLoginTestButton(),
            SizedBox(height: 16),
            
            // Test Results
            if (testResult != null) _buildResultsCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfoCard() {
    User currentUser = userRepo.currentUser.value;
    
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person, color: Colors.blue),
                SizedBox(width: 8),
                Text('User Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            Divider(),
            _buildInfoRow('User ID', currentUser.id ?? 'null'),
            _buildInfoRow('Name', currentUser.name ?? 'null'),
            _buildInfoRow('Email', currentUser.email ?? 'null'),
            _buildInfoRow('Phone', currentUser.phone ?? 'null'),
            _buildInfoRow('Has Token', '${currentUser.apiToken != null}'),
            _buildInfoRow('Token Length', '${currentUser.apiToken?.length ?? 0}'),
            if (currentUser.apiToken != null)
              _buildInfoRow('Token Preview', '${currentUser.apiToken!.substring(0, Math.min(20, currentUser.apiToken!.length))}...'),
            
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: currentUser.apiToken != null ? Colors.green[100] : Colors.red[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    currentUser.apiToken != null ? Icons.check_circle : Icons.error,
                    color: currentUser.apiToken != null ? Colors.green : Colors.red,
                  ),
                  SizedBox(width: 8),
                  Text(
                    currentUser.apiToken != null ? 'User is authenticated' : 'User NOT authenticated',
                    style: TextStyle(
                      color: currentUser.apiToken != null ? Colors.green[800] : Colors.red[800],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfigCard() {
    String baseUrl = GlobalConfiguration().getString('base_url');
    String apiBaseUrl = GlobalConfiguration().getString('api_base_url');
    
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.settings, color: Colors.orange),
                SizedBox(width: 8),
                Text('Configuration', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            Divider(),
            _buildInfoRow('Base URL', baseUrl),
            _buildInfoRow('API Base URL', apiBaseUrl),
            _buildInfoRow('Orders Endpoint', '$baseUrl/api/orders'),
            _buildInfoRow('Pending Orders', '$baseUrl/api/orders/pending'),
          ],
        ),
      ),
    );
  }

  Widget _buildTestButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : _runConnectionTest,
        icon: isLoading 
          ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
          : Icon(Icons.network_check),
        label: Text(isLoading ? 'Testing...' : 'Test API Connection'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue[600],
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 16),
          textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildLoginTestButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : _testLoginEndpoints,
        icon: isLoading 
          ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
          : Icon(Icons.login),
        label: Text(isLoading ? 'Testing Login...' : 'Test Login Endpoints'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange[600],
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 16),
          textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildResultsCard() {
    if (testResult == null) return SizedBox();
    
    bool success = testResult!['success'] ?? false;
    String issue = testResult!['issue'] ?? 'unknown';
    
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  success ? Icons.check_circle : Icons.error,
                  color: success ? Colors.green : Colors.red,
                ),
                SizedBox(width: 8),
                Text('Test Results', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            Divider(),
            
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: success ? Colors.green[100] : Colors.red[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    testResult!['message'] ?? 'No message',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: success ? Colors.green[800] : Colors.red[800],
                    ),
                  ),
                  if (!success && issue != 'unknown')
                    Text(
                      'Issue Type: $issue',
                      style: TextStyle(color: Colors.red[600], fontSize: 12),
                    ),
                ],
              ),
            ),
            
            SizedBox(height: 12),
            
            if (testResult!['status_code'] != null)
              _buildInfoRow('Status Code', '${testResult!['status_code']}'),
            if (testResult!['content_type'] != null)
              _buildInfoRow('Content Type', testResult!['content_type']),
            if (testResult!['url'] != null)
              _buildInfoRow('URL', testResult!['url']),
            
            if (testResult!['suggestions'] != null) ...[
              SizedBox(height: 12),
              Text('Suggestions:', style: TextStyle(fontWeight: FontWeight.w600)),
              SizedBox(height: 4),
              ...((testResult!['suggestions'] as List).map((suggestion) => 
                Padding(
                  padding: EdgeInsets.only(left: 16, top: 2),
                  child: Text('• $suggestion', style: TextStyle(fontSize: 13)),
                )
              )),
            ],
            
            if (testResult!['response_preview'] != null) ...[
              SizedBox(height: 12),
              Text('Response Preview:', style: TextStyle(fontWeight: FontWeight.w600)),
              SizedBox(height: 4),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  testResult!['response_preview'],
                  style: TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),
            ],
            
            // Login Test Details
            if (testResult!['details'] != null && testResult!['details'] is List) ...[
              SizedBox(height: 12),
              Text('Endpoint Test Results:', style: TextStyle(fontWeight: FontWeight.w600)),
              SizedBox(height: 8),
              ...((testResult!['details'] as List).map((detail) => 
                Container(
                  margin: EdgeInsets.only(bottom: 8),
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        detail['url'] ?? 'Unknown URL',
                        style: TextStyle(fontWeight: FontWeight.w600, color: Colors.blue[700]),
                      ),
                      SizedBox(height: 4),
                      Text(
                        detail['status'] ?? 'Unknown Status',
                        style: TextStyle(
                          color: detail['status']?.startsWith('✅') == true ? Colors.green[700] : Colors.red[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (detail['status_code'] != null)
                        Text('Status Code: ${detail['status_code']}', style: TextStyle(fontSize: 12)),
                      if (detail['content_type'] != null)
                        Text('Content Type: ${detail['content_type']}', style: TextStyle(fontSize: 12)),
                      if (detail['error'] != null)
                        Text('Error: ${detail['error']}', style: TextStyle(fontSize: 12, color: Colors.red)),
                    ],
                  ),
                )
              )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey[700]),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: value));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Copied to clipboard')),
                );
              },
              child: Text(
                value,
                style: TextStyle(color: Colors.blue[700]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _runConnectionTest() async {
    setState(() {
      isLoading = true;
      testResult = null;
    });

    try {
      final result = await orderRepo.testConnection();
      setState(() {
        testResult = result;
      });
    } catch (e) {
      setState(() {
        testResult = {
          'success': false,
          'message': 'Test failed: $e',
          'issue': 'error'
        };
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _testLoginEndpoints() async {
    setState(() {
      isLoading = true;
      testResult = null;
    });

    try {
      String baseUrl = GlobalConfiguration().getValue('base_url');
      String apiBaseUrl = GlobalConfiguration().getValue('api_base_url');
      
      List<String> loginUrls = [
        '$baseUrl/api/login',
        '$apiBaseUrl/login',
        '$baseUrl/api/driver/login',
      ];

      Map<String, dynamic> testResults = {
        'success': false,
        'message': 'Testing login endpoints...',
        'issue': 'login_endpoints',
        'details': [],
        'suggestions': []
      };

      final client = http.Client();
      bool foundWorkingEndpoint = false;

      for (String url in loginUrls) {
        try {
          print('🔍 Testing login URL: $url');
          
          final response = await client.post(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: json.encode({
              'email': 'test@test.com',
              'password': 'test123'
            }),
          ).timeout(Duration(seconds: 10));

          String? contentType = response.headers['content-type'];
          bool isJson = contentType != null && contentType.contains('application/json');
          bool isHtml = response.body.trim().startsWith('<!DOCTYPE html>') || 
                       response.body.contains('<html>') || 
                       response.body.contains('<link rel=');

          String preview = response.body.length > 200 
              ? '${response.body.substring(0, 200)}...'
              : response.body;

          Map<String, dynamic> endpointResult = {
            'url': url,
            'status_code': response.statusCode,
            'content_type': contentType ?? 'unknown',
            'is_json': isJson,
            'is_html': isHtml,
            'response_preview': preview,
          };

          if (response.statusCode == 200 && isJson) {
            endpointResult['status'] = '✅ Success - JSON Response';
            foundWorkingEndpoint = true;
          } else if (response.statusCode == 401 && isJson) {
            endpointResult['status'] = '✅ Endpoint Found - Invalid Credentials (Expected)';
            foundWorkingEndpoint = true;
          } else if (response.statusCode == 422 && isJson) {
            endpointResult['status'] = '✅ Endpoint Found - Validation Error (Expected)';
            foundWorkingEndpoint = true;
          } else if (isHtml) {
            endpointResult['status'] = '❌ Returns HTML - Wrong Endpoint';
          } else if (response.statusCode == 404) {
            endpointResult['status'] = '❌ Not Found';
          } else if (response.statusCode == 500) {
            endpointResult['status'] = '❌ Server Error';
          } else {
            endpointResult['status'] = '❌ Unexpected Response';
          }

          testResults['details'].add(endpointResult);

        } catch (e) {
          testResults['details'].add({
            'url': url,
            'status': '❌ Connection Failed',
            'error': e.toString(),
          });
        }
      }

      if (foundWorkingEndpoint) {
        testResults['success'] = true;
        testResults['message'] = '✅ Found working login endpoint(s)';
        testResults['suggestions'] = [
          'Login endpoints are working correctly',
          'Try logging in with valid credentials',
          'If login still fails, check your credentials'
        ];
      } else {
        testResults['message'] = '❌ No working login endpoints found';
        testResults['suggestions'] = [
          'Contact backend developer to configure login API',
          'Check if server is running correctly',
          'Verify API routes are properly configured',
          'Make sure Laravel routes include: Route::post(\'/login\', ...)'
        ];
      }

      setState(() {
        testResult = testResults;
      });

    } catch (e) {
      setState(() {
        testResult = {
          'success': false,
          'message': 'Login test failed: $e',
          'issue': 'error'
        };
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
}
