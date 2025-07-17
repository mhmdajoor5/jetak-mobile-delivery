import '../models/order_history_model.dart';
import '../models/order.dart';
import '../repository/order_repository.dart' as orderRepo;

class OrderHistoryController {
  Future<List<OrderHistoryModel>> getOrdersHistory({List<String>? statusIds}) async {
    try {
      print('📋 OrderHistoryController: Starting to fetch orders history...');
      
      // Debug order statuses first
      await orderRepo.debugOrderStatuses();
      
      // Use specific status IDs if provided, otherwise default to delivered orders
      Stream<Order> stream;
      if (statusIds != null && statusIds.isNotEmpty) {
        print('📋 Using custom status IDs: ${statusIds.join(', ')}');
        stream = await orderRepo.getOrdersByStatuses(statusIds);
      } else {
        print('📋 Using default delivered orders (status 5)');
        stream = await orderRepo.getOrdersHistory();
      }
      
      final orders = await stream.toList();
      print('📋 OrderHistoryController: Received ${orders.length} orders from repository');
      
      // تحويل Order objects إلى OrderHistoryModel objects
      final historyModels = orders.map((order) {
        print('📋 Processing order ${order.id}: status=${order.orderStatus?.status}');
        
        // حساب المبلغ الإجمالي
        double totalAmount = 0;
        if (order.foodOrders != null) {
          for (var foodOrder in order.foodOrders!) {
            totalAmount += (foodOrder.price ?? 0) * (foodOrder.quantity ?? 1);
          }
        }
        
        // إضافة الضرائب ورسوم التوصيل
        totalAmount += (order.tax ?? 0) + (order.deliveryFee ?? 0);
        
        return OrderHistoryModel(
          orderNumber: order.id ?? 'غير محدد',
          clientName: order.user?.name ?? 'عميل غير محدد',
          phoneNumber: order.user?.phone ?? 'غير محدد',
          deliveryAddress: order.deliveryAddress?.address ?? 'عنوان غير محدد',
          date: order.dateTime ?? DateTime.now(),
          amount: totalAmount,
          status: order.orderStatus?.status ?? 'غير محدد',
        );
      }).toList();
      
      print('📋 OrderHistoryController: Converted ${historyModels.length} orders to history models');
      
      return historyModels;
    } catch (e) {
      print('❌ OrderHistoryController Error: $e');
      return [];
    }
  }

  // Get orders by specific status names
  Future<List<OrderHistoryModel>> getOrdersByStatus(String statusName) async {
    try {
      // Map common status names to IDs
      Map<String, List<String>> statusMapping = {
        'delivered': ['5'], // Delivered orders
        'completed': ['5'], // Alias for delivered
        'pending': ['1'], // Pending orders
        'accepted': ['2'], // Accepted orders
        'preparing': ['3'], // In preparation
        'ready': ['4'], // Ready for pickup
        'on_the_way': ['6'], // On the way
        'cancelled': ['7'], // Cancelled orders
        'all_completed': ['5', '6'], // All completed statuses
      };
      
      List<String>? statusIds = statusMapping[statusName.toLowerCase()];
      
      if (statusIds == null) {
        print('❌ Unknown status name: $statusName');
        return [];
      }
      
      return await getOrdersHistory(statusIds: statusIds);
    } catch (e) {
      print('❌ Error getting orders by status: $e');
      return [];
    }
  }

  // Get recent orders (last 30 days)
  Future<List<OrderHistoryModel>> getRecentOrders() async {
    try {
      final allOrders = await getOrdersHistory();
      final thirtyDaysAgo = DateTime.now().subtract(Duration(days: 30));
      
      return allOrders.where((order) => 
        order.date.isAfter(thirtyDaysAgo)
      ).toList();
    } catch (e) {
      print('❌ Error getting recent orders: $e');
      return [];
    }
  }

  // Get orders statistics
  Future<Map<String, dynamic>> getOrdersStatistics() async {
    try {
      final deliveredOrders = await getOrdersByStatus('delivered');
      final pendingOrders = await getOrdersByStatus('pending');
      final cancelledOrders = await getOrdersByStatus('cancelled');
      
      double totalEarnings = deliveredOrders.fold(0.0, (sum, order) => sum + order.amount);
      
      return {
        'total_delivered': deliveredOrders.length,
        'total_pending': pendingOrders.length,
        'total_cancelled': cancelledOrders.length,
        'total_earnings': totalEarnings,
        'average_order_value': deliveredOrders.isNotEmpty 
            ? totalEarnings / deliveredOrders.length 
            : 0.0,
      };
    } catch (e) {
      print('❌ Error getting statistics: $e');
      return {};
    }
  }
} 