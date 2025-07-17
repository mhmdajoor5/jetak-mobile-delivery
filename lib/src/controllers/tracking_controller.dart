import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../helpers/helper.dart';
import '../models/order.dart';
import '../models/order_status.dart';
import '../models/order_status_history.dart';
import '../repository/order_repository.dart';

class TrackingController extends ControllerMVC {
  Order? order;
  List<OrderStatus> orderStatus = <OrderStatus>[];
  OrderStatusHistory? orderStatusHistory;
  late GlobalKey<ScaffoldState> scaffoldKey;
  Timer? _refreshTimer;
  bool isLoading = false;

  TrackingController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void listenForOrder({String? orderId, String? message}) async {
    if (orderId == null) return;
    
    setState(() {
      isLoading = true;
    });

    try {
      final Stream<Order> stream = await getOrder(orderId);
      stream.listen((Order _order) {
        setState(() {
          order = _order;
          isLoading = false;
        });
      }, onError: (a) {
        print('❌ Error listening for order: $a');
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(SnackBar(
          content: Text(S.of(state!.context).verify_your_internet_connection),
        ));
      }, onDone: () {
        listenForOrderStatus();
        // Load detailed status history
        if (orderId != null) {
          loadOrderStatusHistory(orderId);
          _startAutoRefresh(orderId);
        }
        if (message != null) {
          ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(SnackBar(
            content: Text(message),
          ));
        }
      });
    } catch (e) {
      print('❌ Exception in listenForOrder: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void listenForOrderStatus() async {
    final Stream<OrderStatus> stream = await getOrderStatus();
    stream.listen((OrderStatus _orderStatus) {
      setState(() {
        orderStatus.add(_orderStatus);
      });
    }, onError: (a) {}, onDone: () {});
  }

  Future<void> loadOrderStatusHistory(String orderId) async {
    print('🔄 Loading detailed order status history for order: $orderId');
    
    try {
      final history = await getOrderStatusHistory(orderId);
      if (history != null) {
        setState(() {
          orderStatusHistory = history;
        });
        print('✅ Order status history loaded: ${history.statusHistory.length} status changes');
        
        // Sort history by timestamp (newest first for display)
        orderStatusHistory!.statusHistory.sort((a, b) => 
          b.timestamp.compareTo(a.timestamp));
      } else {
        print('⚠️ No order status history available for order: $orderId');
      }
    } catch (e) {
      print('❌ Error loading order status history: $e');
    }
  }

  void _startAutoRefresh(String orderId) {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      if (!isLoading) {
        print('🔄 Auto-refreshing order status for order: $orderId');
        loadOrderStatusHistory(orderId);
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
    List<Step> _orderStatusSteps = [];
    
    // Use detailed status history if available
    if (orderStatusHistory != null && orderStatusHistory!.statusHistory.isNotEmpty) {
      for (int i = 0; i < orderStatusHistory!.statusHistory.length; i++) {
        final historyItem = orderStatusHistory!.statusHistory[i];
        final isActive = i == 0; // Latest status is active
        final isCompleted = i > 0; // Previous statuses are completed
        
        _orderStatusSteps.add(Step(
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
        _orderStatusSteps.add(Step(
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

    return _orderStatusSteps;
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

  void doOnTheWayOrder(Order _order) async {
    onTheWayOrder(_order).then((value) {
      setState(() {
        order = value;
      });
      // Refresh status history after updating
      if (_order.id != null) {
        loadOrderStatusHistory(_order.id!);
      }
    });
  }

  void doDeliveredOrder(Order _order) async {
    deliveredOrder(_order).then((value) {
      setState(() {
        order = value;
      });
      // Refresh status history after updating
      if (_order.id != null) {
        loadOrderStatusHistory(_order.id!);
      }
    });
  }
}
