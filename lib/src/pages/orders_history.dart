import 'package:flutter/material.dart';
import '../controllers/order_history_controller.dart';
import '../models/order_history_model.dart';

class OrderHistoryPage extends StatelessWidget {
  final OrderHistoryController controller = OrderHistoryController();

  OrderHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('سجل الطلبات'),
        ),
        body: FutureBuilder<List<OrderHistoryModel>>(
          future: controller.getOrdersHistory(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('حدث خطأ أثناء جلب البيانات'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('لا يوجد طلبات'));
            }
            final orders = snapshot.data!;
            return ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(order.orderId.replaceAll('#', '')),
                    ),
                    title: Text(order.client),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('رقم الهاتف: ${order.phone}'),
                        Text('حالة الطلب: ${order.status}'),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
