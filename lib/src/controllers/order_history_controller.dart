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
        //  stream = await orderRepo.getOrdersHistory();
      } else {
        print('📋 Using default delivered orders (status 5)');
        stream = await orderRepo.getOrdersHistory();
      }
      
      final List<Order> orders = await stream.toList();
      print('📋 OrderHistoryController: Received ${orders.length} orders from repository');
      
      // تحويل Order objects إلى OrderHistoryModel objects
      final List<OrderHistoryModel> historyModels = orders.map((order) {
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
          foodTotal: totalAmount,
          deliveryFee: order.deliveryFee ?? 0,
          tax: order.tax ?? 0,
          hint: order.hint,
          payment: order.payment,
          userId: int.tryParse( order.user?.id ?? '0' )?? 0,
          
          id: int.tryParse( order.id ?? '0' )?? 0,
          user: order.user,
          deliveryAddress: order.deliveryAddress ,
          date: order.dateTime ?? DateTime.now(),
          amount: totalAmount,
          status: order.orderStatus?.status ?? 'غير محدد',
          foodOrders: order.foodOrders,
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
  'delivered': ['5'],           // Delivered orders
  'completed': ['5'],           // Alias for delivered
  'pending': ['1'],             // Order Received (pending)
  'order_received': ['1'],      // Order Received
  'accepted': ['6'],            // Accepted orders
  'preparing': ['2'],           // Preparing/In preparation
  'ready': ['3'],               // Ready for pickup
  'on_the_way': ['4'],          // On the way
  'on the way': ['4'],          // Alternative spelling
  'cancelled': ['7'],           // Rejected/Cancelled orders
  'rejected': ['7'],            // Rejected orders
  'all_completed': ['5'],       // Only delivered is truly completed
  'all_active': ['1', '2', '3', '4', '6'], // All active statuses (not delivered/rejected)
  'in_progress': ['2', '3', '4'], // Orders being processed
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
        order.date?.isAfter(thirtyDaysAgo) ?? false
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
      
      double totalEarnings = deliveredOrders.fold(0.0, (sum, order) => sum + (order.amount ?? 0.0));
      
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