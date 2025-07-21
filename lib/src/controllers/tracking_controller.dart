import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../models/order.dart';
import '../models/order_status.dart';
import '../models/order_status_history.dart';
import '../network/api_client.dart';
import '../repository/order_repository.dart';

class TrackingController extends ControllerMVC {
  // Track if the controller has been disposed
  bool _isDisposed = false;
  // Current order being tracked
  Order? order;
  
  // List of possible order statuses
  List<OrderStatus> orderStatus = <OrderStatus>[];
  
  // Detailed status history for the current order
  OrderStatusHistory? orderStatusHistory;
  
  // Scaffold key for showing snackbars
  late GlobalKey<ScaffoldState> scaffoldKey;
  
  // Timer for auto-refreshing order status
  Timer? _refreshTimer;
  
  // Stream subscriptions
  StreamSubscription<Order>? _orderSubscription;
  StreamSubscription<OrderStatus>? _orderStatusSubscription;
  
  // Loading state
  bool isLoading = false;
  
  // Error state (kept for future use)
  // ignore: unused_field
  String? _errorMessage;

  TrackingController() {
    scaffoldKey = GlobalKey<ScaffoldState>();
  }

  @override
  void dispose() {
    log('♻️ Disposing TrackingController', name: 'TrackingController');
    
    // Mark as disposed
    _isDisposed = true;
    
    // Cancel all subscriptions and timers
    _orderSubscription?.cancel();
    _orderStatusSubscription?.cancel();
    _refreshTimer?.cancel();
    
    super.dispose();
  }

  /// Listens for order updates and manages the order tracking state
  /// 
  /// [orderId] The ID of the order to track
  /// [message] Optional message to show in a snackbar when order is loaded
  void listenForOrder({String? orderId, String? message}) async {
    if (orderId == null || orderId.isEmpty) {
      log('⚠️ Order ID is null or empty', name: 'TrackingController');
      return;
    }
    
    log('🔍 Listening for order updates: $orderId', name: 'TrackingController');
    
    setState(() {
      isLoading = true;
    });

    try {
      final stream = await getOrder(orderId);
      
      // Cancel any existing subscription
      _orderSubscription?.cancel();
      
      _orderSubscription = stream.listen(
        (Order order) {
          log('🔄 Order data received: ${order.id}', name: 'TrackingController');
          setState(() {
            this.order = order;
            isLoading = false;
          });
          
          // Load status history when order data is received
          loadOrderStatusHistory(orderId);
        },
        onError: (error) {
          log('❌ Error listening for order: $error', 
              name: 'TrackingController', 
              error: error,
              stackTrace: StackTrace.current);
              
          setState(() {
            isLoading = false;
          });
          
          if (scaffoldKey.currentContext != null && state != null) {
            ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
              SnackBar(
                content: Text(S.of(state!.context).verify_your_internet_connection),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        onDone: () {
          log('✅ Order stream completed', name: 'TrackingController');
          
          // Start auto-refresh only if not already started
          if (_refreshTimer == null || !_refreshTimer!.isActive) {
            _startAutoRefresh(orderId);
          }
          
          // Show success message if provided
          if (message != null && scaffoldKey.currentContext != null && state != null) {
            ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
              SnackBar(
                content: Text(message),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        cancelOnError: false,
      );
      
    } catch (e, stackTrace) {
      log('❌ Exception in listenForOrder', 
          name: 'TrackingController', 
          error: e, 
          stackTrace: stackTrace);
          
      setState(() {
        isLoading = false;
      });
      
      if (scaffoldKey.currentContext != null && state != null) {
        ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
          SnackBar(
            content: Text('Failed to load order: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Listens for order status updates
  void listenForOrderStatus() async {
    try {
      final stream = await getOrderStatus();
      
      // Cancel any existing subscription
      _orderStatusSubscription?.cancel();
      
      _orderStatusSubscription = stream.listen(
        (OrderStatus status) {
          log('🔄 Order status received: ${status.status}', 
              name: 'TrackingController');
              
          setState(() {
            // Only update if the status is different
            if (!orderStatus.any((s) => s.id == status.id)) {
              orderStatus.add(status);
            }
          });
        },
        onError: (error) {
          log('❌ Error listening for order status: $error', 
              name: 'TrackingController',
              error: error);
        },
        onDone: () {
          log('✅ Order status stream completed', name: 'TrackingController');
        },
      );
    } catch (e, stackTrace) {
      log('❌ Exception in listenForOrderStatus', 
          name: 'TrackingController', 
          error: e, 
          stackTrace: stackTrace);
    }
  }

  /// Loads the detailed status history for an order
  /// 
  /// [orderId] The ID of the order to load history for
  Future<void> loadOrderStatusHistory(String orderId) async {
    if (orderId.isEmpty) {
      log('⚠️ Cannot load status history: Order ID is empty', 
          name: 'TrackingController');
      return;
    }
    
    log('🔄 Loading detailed order status history for order: $orderId', 
        name: 'TrackingController');
    
    try {
      final history = await getOrderStatusHistory(orderId);
      
      if (history != null && history.statusHistory.isNotEmpty) {
        log('✅ Order status history loaded: ${history.statusHistory.length} status changes',
            name: 'TrackingController');
        
        // Sort history by timestamp (newest first for display)
        history.statusHistory.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        
        setState(() {
          orderStatusHistory = history;
        });
      } else {
        log('⚠️ No order status history available for order: $orderId', 
            name: 'TrackingController');
      }
    } catch (e, stackTrace) {
      log('❌ Error loading order status history', 
          name: 'TrackingController',
          error: e,
          stackTrace: stackTrace);
          
      if (scaffoldKey.currentContext != null && state != null) {
        ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
          SnackBar(
            content: Text('Failed to load order history'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  /// Starts an auto-refresh timer to periodically update the order status
  /// 
  /// [orderId] The ID of the order to auto-refresh
  void _startAutoRefresh(String orderId) {
    log('⏱️ Starting auto-refresh for order: $orderId', name: 'TrackingController');
    
    // Cancel any existing timer
    _refreshTimer?.cancel();
    
    // Set up a new timer to refresh every 30 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (!isLoading && !_isDisposed) {
        log('🔄 Auto-refreshing order status for order: $orderId', 
            name: 'TrackingController');
        
        // Refresh both the order and its status history
        loadOrderStatusHistory(orderId);
        
        // Also refresh the main order data
        if (order?.id != null) {
          listenForOrder(orderId: order!.id);
        }
      }
    });
  }

  Future<void> refreshOrder() async {
    if (order?.id != null && order!.id!.isNotEmpty) {
      print('🔄 Manual refresh requested for order: ${order!.id}');
      orderStatusHistory = null; // Clear existing history
      listenForOrder(
        orderId: order!.id!,
        message: S.of(state!.context).order_refreshed_successfuly,
      );
    }
  }

  List<Step> getTrackingSteps(BuildContext context) {
    List<Step> orderStatusSteps = [];
    
    // Use detailed status history if available
    if (orderStatusHistory != null && orderStatusHistory!.statusHistory.isNotEmpty) {
      for (int i = 0; i < orderStatusHistory!.statusHistory.length; i++) {
        final historyItem = orderStatusHistory!.statusHistory[i];
        final isActive = i == 0; // Latest status is active
        final isCompleted = i > 0; // Previous statuses are completed
        
        orderStatusSteps.add(Step(
          state: isActive 
              ? StepState.indexed 
              : isCompleted 
                  ? StepState.complete 
                  : StepState.disabled,
          isActive: isActive,
          title: Text(
            historyItem.statusName,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              color: isActive ? Colors.blue[800] : Colors.black87,
            ),
          ),
          content: Container(
            width: double.infinity,
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isActive ? Colors.blue[50] : Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isActive ? Colors.blue[200]! : Colors.grey[300]!,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    SizedBox(width: 6),
                    Text(
                      DateFormat('dd/MM/yyyy - HH:mm').format(historyItem.timestamp),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                if (historyItem.notes != null && historyItem.notes!.isNotEmpty) ...[
                  SizedBox(height: 8),
                  Text(
                    historyItem.notes!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                ],
                if (historyItem.updatedBy != null && historyItem.updatedBy!.isNotEmpty) ...[
                  SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.person,
                        size: 14,
                        color: Colors.grey[500],
                      ),
                      SizedBox(width: 4),
                      Text(
                        'تم بواسطة: ${historyItem.updatedBy}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ));
      }
    } else {
      // Fallback to basic order status if no detailed history available
      if (order?.orderStatus != null) {
        orderStatusSteps.add(Step(
          state: StepState.indexed,
          isActive: true,
          title: Text(
            order!.orderStatus!.status ?? 'Unknown Status',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
            ),
          ),
          content: Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                    SizedBox(width: 6),
                    Text(
                      DateFormat('dd/MM/yyyy - HH:mm').format(order!.dateTime ?? DateTime.now()),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  'آخر تحديث للطلب',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ));
      }
    }

    return orderStatusSteps;
  }

  String getEstimatedDeliveryTime() {
    if (orderStatusHistory != null && orderStatusHistory!.statusHistory.isNotEmpty) {
      final latestStatus = orderStatusHistory!.statusHistory.first;
      
      // Calculate estimated delivery based on current status
      DateTime estimatedTime = latestStatus.timestamp;
      
      switch (latestStatus.status) {
        case '1': // Order received
          estimatedTime = estimatedTime.add(Duration(minutes: 45));
          break;
        case '2': // Preparing
          estimatedTime = estimatedTime.add(Duration(minutes: 25));
          break;
        case '3': // Ready for pickup
          estimatedTime = estimatedTime.add(Duration(minutes: 15));
          break;
        case '4': // On the way
          estimatedTime = estimatedTime.add(Duration(minutes: 10));
          break;
        case '5': // Delivered
          return 'تم التوصيل';
        default:
          estimatedTime = estimatedTime.add(Duration(minutes: 30));
      }
      
      return DateFormat('HH:mm').format(estimatedTime);
    }
    
    return 'غير محدد';
  }

  Color getStatusColor() {
    if (orderStatusHistory != null && orderStatusHistory!.statusHistory.isNotEmpty) {
      final latestStatus = orderStatusHistory!.statusHistory.first;
      
      switch (latestStatus.status) {
        case '1':
          return Colors.orange[600]!; // Order received
        case '2':
          return Colors.blue[600]!; // Preparing
        case '3':
          return Colors.purple[600]!; // Ready for pickup
        case '4':
          return Colors.indigo[600]!; // On the way
        case '5':
          return Colors.green[600]!; // Delivered
        default:
          return Colors.grey[600]!;
      }
    }
    
    return Colors.grey[600]!;
  }

  /// Updates the order status to 'On The Way'
  /// 
  /// [order] The order to update
  Future<void> doOnTheWayOrder(Order order) async {
    if (order.id == null || order.id!.isEmpty) {
      log('⚠️ Cannot update status: Order ID is null or empty', 
          name: 'TrackingController');
      return;
    }
    
    log('🚚 Updating order ${order.id} to On The Way', name: 'TrackingController');
    
    try {
      setState(() {
        isLoading = true;
      });
      
      final updatedOrder = await onTheWayOrder(order);
      
      setState(() {
        this.order = updatedOrder;
        isLoading = false;
      });
      
      // Refresh status history
      loadOrderStatusHistory(order.id!);
      
      // Show success message
      if (scaffoldKey.currentContext != null && state != null) {
        ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
          const SnackBar(
            content: Text('Order status updated to On The Way'),
            backgroundColor: Colors.green,
          ),
        );
      }
      
    } catch (e, stackTrace) {
      log('❌ Error updating order to On The Way', 
          name: 'TrackingController',
          error: e,
          stackTrace: stackTrace);
          
      setState(() {
        isLoading = false;
        _errorMessage = 'Failed to update order status: ${e.toString()}';
      });
      
      if (scaffoldKey.currentContext != null && state != null) {
        ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Updates the order status to 'Delivered'
  /// 
  /// [order] The order to update
  Future<void> doDeliveredOrder(Order order) async {
    if (order.id == null || order.id!.isEmpty) {
      log('⚠️ Cannot update status: Order ID is null or empty', 
          name: 'TrackingController');
      return;
    }
    
    log('✅ Updating order ${order.id} to Delivered', name: 'TrackingController');
    
    try {
      setState(() {
        isLoading = true;
      });
      
      final updatedOrder = await deliveredOrder(order);
      
      setState(() {
        this.order = updatedOrder;
        isLoading = false;
      });
      
      // Refresh status history
      loadOrderStatusHistory(order.id!);
      
      // Show success message
      if (scaffoldKey.currentContext != null && state != null) {
        ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
          const SnackBar(
            content: Text('Order marked as Delivered'),
            backgroundColor: Colors.green,
          ),
        );
      }
      
    } catch (e, stackTrace) {
      log('❌ Error marking order as Delivered', 
          name: 'TrackingController',
          error: e,
          stackTrace: stackTrace);
          
      setState(() {
        isLoading = false;
        _errorMessage = 'Failed to update order status: ${e.toString()}';
      });
      
      if (scaffoldKey.currentContext != null && state != null) {
        ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
