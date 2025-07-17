import 'package:deliveryboy/src/models/pending_order_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../generated/l10n.dart';
import '../helpers/helper.dart';
import '../models/order.dart';
import '../models/route_argument.dart';
import '../controllers/order_controller.dart';
import 'FoodOrderItemWidget.dart';



class OrderItemWidget extends StatefulWidget {
  final bool expanded;
  final Order order;
  final OrderController? orderController;

  OrderItemWidget({
    super.key,
    required this.expanded,
    required this.order,
    this.orderController,
  });

  @override
  _OrderItemWidgetState createState() => _OrderItemWidgetState();
}

class _OrderItemWidgetState extends State<OrderItemWidget> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    // Add debugging for the widget data
    if (widget.order != null) {
      print('🖼️ OrderItemWidget Debug:');
      print('  - Order ID: ${widget.order.id}');
      print('  - User object: ${widget.order.user}');
      print('  - Customer name: ${widget.order.user?.name}');
      print('  - Customer phone: ${widget.order.user?.phone}');
      print('  - Delivery Address object: ${widget.order.deliveryAddress}');
      print('  - Address text: ${widget.order.deliveryAddress?.address}');
    }

    final theme = Theme.of(context).copyWith(dividerColor: Colors.transparent);
    final isNewOrder =
        widget.order.orderStatus?.id == '1' ||
            widget.order.orderStatus?.id == '2' ||
            widget.order.orderStatus?.id == '3';

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 20,
            offset: Offset(0, 8),
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
        border:
        isNewOrder
            ? Border.all(color: Colors.green[400]!, width: 2.5)
            : null,
      ),
      child: Column(
        children: [
          // Enhanced Header with NEW badge
          if (isNewOrder)
            AnimatedContainer(
              duration: Duration(milliseconds: 1000),
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF4CAF50),
                    Color(0xFF66BB6A),
                    Color(0xFF81C784),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(17),
                  topRight: Radius.circular(17),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.4),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.flash_on, color: Colors.white, size: 18),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'NEW ORDER',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      letterSpacing: 1.5,
                    ),
                  ),
                  SizedBox(width: 12),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange[400],
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.3),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      '🔥 HOT',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order ID and Date
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Order ID: #${widget.order.id ?? '-'}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      widget.order.dateTime != null
                          ? DateFormat(
                        'dd-MM-yyyy | HH:mm',
                      ).format(widget.order.dateTime!)
                          : '-',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),

                // Price and Payment
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (widget.order.foodOrders != null &&
                            widget.order.foodOrders!.isNotEmpty)
                          Helper.getPrice(
                            Helper.getTotalOrdersPrice(widget.order),
                            context,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700],
                            ),
                          )
                        else
                          Text(
                            '-',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        Text(
                          widget.order.payment?.method ?? 'Cash',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                SizedBox(height: 12),
                Divider(height: 1, color: Colors.grey[300]),
                SizedBox(height: 12),

                // Food Items
                if (widget.order.foodOrders != null &&
                    widget.order.foodOrders!.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...widget.order.foodOrders!
                          .map(
                            (foodOrder) => Padding(
                          padding: EdgeInsets.only(bottom: 4),
                          child: Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${foodOrder.quantity}x ${foodOrder.food?.name ?? 'Unknown'}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                              Flexible(
                                child: Helper.getPrice(
                                  foodOrder.price ?? 0.0,
                                  context,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                          .toList(),

                      SizedBox(height: 12),
                      Divider(height: 1, color: Colors.grey[300]),
                      SizedBox(height: 8),

                      // Pricing Details
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Delivery Fee:',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          Helper.getPrice(
                            widget.order.deliveryFee ?? 0.0,
                            context,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Tax (${widget.order.tax}%):',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          Helper.getPrice(
                            Helper.getTaxOrder(widget.order),
                            context,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total:',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Helper.getPrice(
                            Helper.getTotalOrdersPrice(widget.order),
                            context,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                SizedBox(height: 16),

                // Customer Information
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.person, size: 16, color: Colors.blue[600]),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Customer: ${widget.order.user?.name ?? 'Unknown'}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                      if (widget.order.user?.phone != null) ...[
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.phone,
                              size: 16,
                              color: Colors.green[600],
                            ),
                            SizedBox(width: 6),
                            Text(
                              widget.order.user!.phone!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (widget.order.deliveryAddress?.address != null) ...[
                        SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 16,
                              color: Colors.red[600],
                            ),
                            SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                widget.order.deliveryAddress!.address!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (widget.order.hint != null &&
                          widget.order.hint!.isNotEmpty) ...[
                        SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.note,
                              size: 16,
                              color: Colors.orange[600],
                            ),
                            SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Note: ${widget.order.hint}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                SizedBox(height: 16),

                // Enhanced Action Buttons
                if (isNewOrder) ...[
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        // Modern Reject Button
                        Expanded(
                          child: Container(
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFFE57373), Color(0xFFD32F2F)],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.red.withOpacity(0.4),
                                  blurRadius: 12,
                                  offset: Offset(0, 6),
                                ),
                                BoxShadow(
                                  color: Colors.red.withOpacity(0.2),
                                  blurRadius: 20,
                                  offset: Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap:
                                _isProcessing
                                    ? null
                                    : () async {
                                  try {
                                    setState(
                                          () => _isProcessing = true,
                                    );
                                    if (widget.orderController !=
                                        null) {
                                      int orderId =
                                          int.tryParse(
                                            widget.order.id ?? '0',
                                          ) ??
                                              0;
                                      if (orderId > 0) {
                                        widget.orderController!
                                            .rejectOrder(orderId.toString());
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Row(
                                              children: [
                                                Container(
                                                  padding:
                                                  EdgeInsets.all(6),
                                                  decoration:
                                                  BoxDecoration(
                                                    color: Colors
                                                        .white
                                                        .withOpacity(
                                                      0.2,
                                                    ),
                                                    shape:
                                                    BoxShape
                                                        .circle,
                                                  ),
                                                  child: Icon(
                                                    Icons
                                                        .cancel_rounded,
                                                    color: Colors.white,
                                                    size: 16,
                                                  ),
                                                ),
                                                SizedBox(width: 12),
                                                Expanded(
                                                  child: Text(
                                                    '❌ Order #${widget.order.id} Rejected',
                                                    style: TextStyle(
                                                      fontWeight:
                                                      FontWeight
                                                          .w500,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            backgroundColor: Color(
                                              0xFFD32F2F,
                                            ),
                                            duration: Duration(
                                              seconds: 3,
                                            ),
                                            behavior:
                                            SnackBarBehavior
                                                .floating,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                              BorderRadius.circular(
                                                12,
                                              ),
                                            ),
                                          ),
                                        );
                                      } else {
                                        throw Exception(
                                          'Invalid order ID',
                                        );
                                      }
                                    }
                                  } catch (e) {
                                    print('Error rejecting order: $e');
                                    ScaffoldMessenger.of(
                                      context,
                                    ).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          '❌ Error rejecting order',
                                        ),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  } finally {
                                    if (mounted) {
                                      setState(
                                            () => _isProcessing = false,
                                      );
                                    }
                                  }
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 16,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.15),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.close_rounded,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Text(
                                        'REJECT',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.8,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        SizedBox(width: 16),

                        // Modern Accept Button
                        Expanded(
                          child: Container(
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFF81C784), Color(0xFF388E3C)],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.green.withOpacity(0.4),
                                  blurRadius: 12,
                                  offset: Offset(0, 6),
                                ),
                                BoxShadow(
                                  color: Colors.green.withOpacity(0.2),
                                  blurRadius: 20,
                                  offset: Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap:
                                _isProcessing
                                    ? null
                                    : () async {
                                  try {
                                    setState(
                                          () => _isProcessing = true,
                                    );
                                    if (widget.orderController !=
                                        null) {
                                      int orderId =
                                          int.tryParse(
                                            widget.order.id ?? '0',
                                          ) ??
                                              0;
                                      if (orderId > 0) {
                                        widget.orderController!
                                            .acceptOrder(orderId.toString());
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Row(
                                              children: [
                                                Container(
                                                  padding:
                                                  EdgeInsets.all(6),
                                                  decoration:
                                                  BoxDecoration(
                                                    color: Colors
                                                        .white
                                                        .withOpacity(
                                                      0.2,
                                                    ),
                                                    shape:
                                                    BoxShape
                                                        .circle,
                                                  ),
                                                  child: Icon(
                                                    Icons
                                                        .check_circle_rounded,
                                                    color: Colors.white,
                                                    size: 16,
                                                  ),
                                                ),
                                                SizedBox(width: 12),
                                                Expanded(
                                                  child: Text(
                                                    '✅ Order #${widget.order.id} Accepted Successfully!',
                                                    style: TextStyle(
                                                      fontWeight:
                                                      FontWeight
                                                          .w500,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            backgroundColor: Color(
                                              0xFF388E3C,
                                            ),
                                            duration: Duration(
                                              seconds: 3,
                                            ),
                                            behavior:
                                            SnackBarBehavior
                                                .floating,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                              BorderRadius.circular(
                                                12,
                                              ),
                                            ),
                                          ),
                                        );
                                        // Navigate to order details after successful accept
                                        await Future.delayed(
                                          Duration(milliseconds: 800),
                                        );
                                        if (mounted) {
                                          Navigator.of(
                                            context,
                                          ).pushNamed(
                                            '/OrderDetails',
                                            arguments: RouteArgument(
                                              id: widget.order.id,
                                            ),
                                          );
                                        }
                                      } else {
                                        throw Exception(
                                          'Invalid order ID',
                                        );
                                      }
                                    }
                                  } catch (e) {
                                    print('Error accepting order: $e');
                                    ScaffoldMessenger.of(
                                      context,
                                    ).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          '❌ Error accepting order: ${e.toString()}',
                                        ),
                                        backgroundColor: Colors.red,
                                        duration: Duration(seconds: 3),
                                      ),
                                    );
                                  } finally {
                                    if (mounted) {
                                      setState(
                                            () => _isProcessing = false,
                                      );
                                    }
                                  }
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(3),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.15),
                                          shape: BoxShape.circle,
                                        ),
                                        child:
                                        _isProcessing
                                            ? SizedBox(
                                          width: 16,
                                          height: 16,
                                          child:
                                          CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                            backgroundColor: Colors
                                                .white
                                                .withOpacity(0.3),
                                          ),
                                        )
                                            : Icon(
                                          Icons.check_circle_rounded,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                      SizedBox(width: 6),
                                      Flexible(
                                        child: Text(
                                          _isProcessing
                                              ? 'ACCEPTING...'
                                              : 'ACCEPT',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.5,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  // Enhanced View Details Button for accepted orders
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF64B5F6), Color(0xFF1976D2)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.4),
                            blurRadius: 12,
                            offset: Offset(0, 6),
                          ),
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.2),
                            blurRadius: 20,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () {
                            Navigator.of(context).pushNamed(
                              '/OrderDetails',
                              arguments: RouteArgument(id: widget.order.id),
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.visibility_rounded,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    'VIEW DETAILS',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                SizedBox(width: 6),
                                Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  color: Colors.white,
                                  size: 12,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Enhanced Status Badge at bottom
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _getStatusColor(widget.order.orderStatus?.id),
                  _getStatusColor(
                    widget.order.orderStatus?.id,
                  ).withOpacity(0.8),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              boxShadow: [
                BoxShadow(
                  color: _getStatusColor(
                    widget.order.orderStatus?.id,
                  ).withOpacity(0.3),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getStatusIcon(widget.order.orderStatus?.id),
                    color: Colors.white,
                    size: 12,
                  ),
                ),
                SizedBox(width: 6),
                Flexible(
                  child: Text(
                    '${widget.order.orderStatus?.status ?? 'Unknown'}',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      letterSpacing: 0.3,
                    ),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String? statusId) {
    switch (statusId) {
      case '1':
        return Colors.orange[600]!; // Pending
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

  IconData _getStatusIcon(String? statusId) {
    switch (statusId) {
      case '1':
        return Icons.schedule; // Pending
      case '2':
        return Icons.restaurant; // Preparing
      case '3':
        return Icons.shopping_bag; // Ready for pickup
      case '4':
        return Icons.delivery_dining; // On the way
      case '5':
        return Icons.check_circle; // Delivered
      default:
        return Icons.info;
    }
  }
}





class OrderItemWidget2 extends StatefulWidget {
  final bool expanded;
  final PendingOrderModel pendingOrderModel;
  final OrderController? orderController;

  const OrderItemWidget2({
    super.key,
    required this.expanded,
    required this.pendingOrderModel,
    this.orderController,
  });

  @override
  _OrderItemWidgetState2 createState() => _OrderItemWidgetState2();
}

class _OrderItemWidgetState2 extends State<OrderItemWidget2> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).copyWith(dividerColor: Colors.transparent);
    // final isNewOrder =
    //     widget.order.orderStatus?.id == '1' ||
    //         widget.order.orderStatus?.id == '2' ||
    //         widget.order.orderStatus?.id == '3';

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 20,
            offset: Offset(0, 8),
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
        border:
         Border.all(color: Colors.green[400]!, width: 2.5)
        ,
      ),
      child: Column(
        children: [
          // Enhanced Header with NEW badge
            AnimatedContainer(
              duration: Duration(milliseconds: 1000),
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF4CAF50),
                    Color(0xFF66BB6A),
                    Color(0xFF81C784),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(17),
                  topRight: Radius.circular(17),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.4),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.flash_on, color: Colors.white, size: 18),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'NEW ORDER',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      letterSpacing: 1.5,
                    ),
                  ),
                  SizedBox(width: 12),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange[400],
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.3),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      '🔥 HOT',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order ID and Date
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Order ID: #${widget.pendingOrderModel.orderId ?? '-'}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      "Not Found Date Yet",
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),

                // Price and Payment
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                          Text(
                            '-',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        Text(
                          "Payment Method",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                SizedBox(height: 12),
                Divider(height: 1, color: Colors.grey[300]),
                SizedBox(height: 12),


                SizedBox(height: 16),

                // Customer Information
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.person, size: 16, color: Colors.blue[600]),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Customer: ${widget.pendingOrderModel.customerName ?? 'Unknown'}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                      // if (widget.order.user?.phone != null) ...[
                      //   SizedBox(height: 4),
                      //   Row(
                      //     children: [
                      //       Icon(
                      //         Icons.phone,
                      //         size: 16,
                      //         color: Colors.green[600],
                      //       ),
                      //       SizedBox(width: 6),
                      //       Text(
                      //         widget.order.user!.phone!,
                      //         style: TextStyle(
                      //           fontSize: 12,
                      //           color: Colors.grey[700],
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // ],
                      // if (widget.order.deliveryAddress?.address != null) ...[
                      //   SizedBox(height: 4),
                      //   Row(
                      //     crossAxisAlignment: CrossAxisAlignment.start,
                      //     children: [
                      //       Icon(
                      //         Icons.location_on,
                      //         size: 16,
                      //         color: Colors.red[600],
                      //       ),
                      //       SizedBox(width: 6),
                      //       Expanded(
                      //         child: Text(
                      //           widget.pendingOrderModel.address,
                      //           style: TextStyle(
                      //             fontSize: 12,
                      //             color: Colors.grey[700],
                      //           ),
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // ],
                      // if (widget.order.hint != null &&
                      //     widget.order.hint!.isNotEmpty) ...[
                      //   SizedBox(height: 4),
                      //   Row(
                      //     crossAxisAlignment: CrossAxisAlignment.start,
                      //     children: [
                      //       Icon(
                      //         Icons.note,
                      //         size: 16,
                      //         color: Colors.orange[600],
                      //       ),
                      //       SizedBox(width: 6),
                      //       Expanded(
                      //         child: Text(
                      //           'Note: ${widget.order.hint}',
                      //           style: TextStyle(
                      //             fontSize: 12,
                      //             color: Colors.grey[700],
                      //           ),
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // ],
                    ],
                  ),
                ),

                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      // Modern Reject Button
                      Expanded(
                        child: Container(
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFFE57373), Color(0xFFD32F2F)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.red.withOpacity(0.4),
                                blurRadius: 12,
                                offset: Offset(0, 6),
                              ),
                              BoxShadow(
                                color: Colors.red.withOpacity(0.2),
                                blurRadius: 20,
                                offset: Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap:
                              _isProcessing
                                  ? null
                                  : () async {
                                try {
                                  setState(
                                        () => _isProcessing = true,
                                  );
                                  if (widget.orderController !=
                                      null) {
                                    int orderId =
                                        int.tryParse(
                                          widget.pendingOrderModel.orderId.toString() ?? '0',
                                        ) ??
                                            0;
                                    if (orderId > 0) {
                                      widget.orderController!
                                          .rejectOrder(orderId.toString());
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Row(
                                            children: [
                                              Container(
                                                padding:
                                                EdgeInsets.all(6),
                                                decoration:
                                                BoxDecoration(
                                                  color: Colors
                                                      .white
                                                      .withOpacity(
                                                    0.2,
                                                  ),
                                                  shape:
                                                  BoxShape
                                                      .circle,
                                                ),
                                                child: Icon(
                                                  Icons
                                                      .cancel_rounded,
                                                  color: Colors.white,
                                                  size: 16,
                                                ),
                                              ),
                                              SizedBox(width: 12),
                                              Expanded(
                                                child: Text(
                                                  '❌ Order #${widget.pendingOrderModel.orderId} Rejected',
                                                  style: TextStyle(
                                                    fontWeight:
                                                    FontWeight
                                                        .w500,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          backgroundColor: Color(
                                            0xFFD32F2F,
                                          ),
                                          duration: Duration(
                                            seconds: 3,
                                          ),
                                          behavior:
                                          SnackBarBehavior
                                              .floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                      );
                                    } else {
                                      throw Exception(
                                        'Invalid order ID',
                                      );
                                    }
                                  }
                                } catch (e) {
                                  print('Error rejecting order: $e');
                                  ScaffoldMessenger.of(
                                    context,
                                  ).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '❌ Error rejecting order',
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                } finally {
                                  if (mounted) {
                                    setState(
                                          () => _isProcessing = false,
                                    );
                                  }
                                }
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 16,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.15),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.close_rounded,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      'REJECT',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(width: 16),

                      // Modern Accept Button
                      Expanded(
                        child: Container(
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF81C784), Color(0xFF388E3C)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.green.withOpacity(0.4),
                                blurRadius: 12,
                                offset: Offset(0, 6),
                              ),
                              BoxShadow(
                                color: Colors.green.withOpacity(0.2),
                                blurRadius: 20,
                                offset: Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap:
                              _isProcessing
                                  ? null
                                  : () async {
                                try {
                                  setState(
                                        () => _isProcessing = true,
                                  );
                                  if (widget.orderController !=
                                      null) {
                                    int orderId =
                                        int.tryParse(
                                          widget.pendingOrderModel.orderId.toString() ?? '0',
                                        ) ??
                                            0;
                                    if (orderId > 0) {
                                      widget.orderController!
                                          .acceptOrder(orderId.toString());
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Row(
                                            children: [
                                              Container(
                                                padding:
                                                EdgeInsets.all(6),
                                                decoration:
                                                BoxDecoration(
                                                  color: Colors
                                                      .white
                                                      .withOpacity(
                                                    0.2,
                                                  ),
                                                  shape:
                                                  BoxShape
                                                      .circle,
                                                ),
                                                child: Icon(
                                                  Icons
                                                      .check_circle_rounded,
                                                  color: Colors.white,
                                                  size: 16,
                                                ),
                                              ),
                                              SizedBox(width: 12),
                                              Expanded(
                                                child: Text(
                                                  '✅ Order #${widget.pendingOrderModel.orderId} Accepted Successfully!',
                                                  style: TextStyle(
                                                    fontWeight:
                                                    FontWeight
                                                        .w500,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          backgroundColor: Color(
                                            0xFF388E3C,
                                          ),
                                          duration: Duration(
                                            seconds: 3,
                                          ),
                                          behavior:
                                          SnackBarBehavior
                                              .floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                      );
                                      // Navigate to order details after successful accept
                                      await Future.delayed(
                                        Duration(milliseconds: 800),
                                      );
                                      if (mounted) {
                                        Navigator.of(
                                          context,
                                        ).pushNamed(
                                          '/OrderDetails',
                                          arguments: RouteArgument(
                                            id: widget.pendingOrderModel.orderId.toString(),
                                          ),
                                        );
                                      }
                                    } else {
                                      throw Exception(
                                        'Invalid order ID',
                                      );
                                    }
                                  }
                                } catch (e) {
                                  print('Error accepting order: $e');
                                  ScaffoldMessenger.of(
                                    context,
                                  ).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '❌ Error accepting order: ${e.toString()}',
                                      ),
                                      backgroundColor: Colors.red,
                                      duration: Duration(seconds: 3),
                                    ),
                                  );
                                } finally {
                                  if (mounted) {
                                    setState(
                                          () => _isProcessing = false,
                                    );
                                  }
                                }
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(3),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.15),
                                        shape: BoxShape.circle,
                                      ),
                                      child:
                                      _isProcessing
                                          ? SizedBox(
                                        width: 16,
                                        height: 16,
                                        child:
                                        CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                          backgroundColor: Colors
                                              .white
                                              .withOpacity(0.3),
                                        ),
                                      )
                                          : Icon(
                                        Icons.check_circle_rounded,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                    SizedBox(width: 6),
                                    Flexible(
                                      child: Text(
                                        _isProcessing
                                            ? 'ACCEPTING...'
                                            : 'ACCEPT',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Enhanced Action Buttons
                // if (isNewOrder) ...[
                // ] else ...[
                //   // Enhanced View Details Button for accepted orders
                //   Container(
                //     padding: EdgeInsets.symmetric(vertical: 4),
                //     child: Container(
                //       height: 56,
                //       decoration: BoxDecoration(
                //         gradient: LinearGradient(
                //           colors: [Color(0xFF64B5F6), Color(0xFF1976D2)],
                //           begin: Alignment.topCenter,
                //           end: Alignment.bottomCenter,
                //         ),
                //         borderRadius: BorderRadius.circular(20),
                //         boxShadow: [
                //           BoxShadow(
                //             color: Colors.blue.withOpacity(0.4),
                //             blurRadius: 12,
                //             offset: Offset(0, 6),
                //           ),
                //           BoxShadow(
                //             color: Colors.blue.withOpacity(0.2),
                //             blurRadius: 20,
                //             offset: Offset(0, 10),
                //           ),
                //         ],
                //       ),
                //       child: Material(
                //         color: Colors.transparent,
                //         child: InkWell(
                //           borderRadius: BorderRadius.circular(20),
                //           onTap: () {
                //             Navigator.of(context).pushNamed(
                //               '/OrderDetails',
                //               arguments: RouteArgument(id: widget.pendingOrderModel.orderId),
                //             );
                //           },
                //           child: Container(
                //             padding: EdgeInsets.symmetric(
                //               horizontal: 16,
                //               vertical: 12,
                //             ),
                //             child: Row(
                //               mainAxisAlignment: MainAxisAlignment.center,
                //               mainAxisSize: MainAxisSize.min,
                //               children: [
                //                 Container(
                //                   padding: EdgeInsets.all(4),
                //                   decoration: BoxDecoration(
                //                     color: Colors.white.withOpacity(0.15),
                //                     shape: BoxShape.circle,
                //                   ),
                //                   child: Icon(
                //                     Icons.visibility_rounded,
                //                     color: Colors.white,
                //                     size: 16,
                //                   ),
                //                 ),
                //                 SizedBox(width: 8),
                //                 Flexible(
                //                   child: Text(
                //                     'VIEW DETAILS',
                //                     style: TextStyle(
                //                       color: Colors.white,
                //                       fontSize: 13,
                //                       fontWeight: FontWeight.bold,
                //                       letterSpacing: 0.5,
                //                     ),
                //                     overflow: TextOverflow.ellipsis,
                //                   ),
                //                 ),
                //                 SizedBox(width: 6),
                //                 Icon(
                //                   Icons.arrow_forward_ios_rounded,
                //                   color: Colors.white,
                //                   size: 12,
                //                 ),
                //               ],
                //             ),
                //           ),
                //         ),
                //       ),
                //     ),
                //   ),
                // ],
              ],
            ),
          ),

          // Enhanced Status Badge at bottom
          // Container(
          //   width: double.infinity,
          //   padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          //   decoration: BoxDecoration(
          //     gradient: LinearGradient(
          //       colors: [
          //         _getStatusColor(widget.order.orderStatus?.id),
          //         _getStatusColor(
          //           widget.order.orderStatus?.id,
          //         ).withOpacity(0.8),
          //       ],
          //       begin: Alignment.centerLeft,
          //       end: Alignment.centerRight,
          //     ),
          //     borderRadius: BorderRadius.only(
          //       bottomLeft: Radius.circular(16),
          //       bottomRight: Radius.circular(16),
          //     ),
          //     boxShadow: [
          //       BoxShadow(
          //         color: _getStatusColor(
          //           widget.order.orderStatus?.id,
          //         ).withOpacity(0.3),
          //         blurRadius: 8,
          //         offset: Offset(0, 4),
          //       ),
          //     ],
          //   ),
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.center,
          //     mainAxisSize: MainAxisSize.min,
          //     children: [
          //       Container(
          //         padding: EdgeInsets.all(3),
          //         decoration: BoxDecoration(
          //           color: Colors.white.withOpacity(0.2),
          //           shape: BoxShape.circle,
          //         ),
          //         child: Icon(
          //           _getStatusIcon(widget.order.orderStatus?.id),
          //           color: Colors.white,
          //           size: 12,
          //         ),
          //       ),
          //       SizedBox(width: 6),
          //       Flexible(
          //         child: Text(
          //           '${widget.order.orderStatus?.status ?? 'Unknown'}',
          //           style: TextStyle(
          //             color: Colors.white,
          //             fontWeight: FontWeight.bold,
          //             fontSize: 12,
          //             letterSpacing: 0.3,
          //           ),
          //           overflow: TextOverflow.ellipsis,
          //           textAlign: TextAlign.center,
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }

  Color _getStatusColor(String? statusId) {
    switch (statusId) {
      case '1':
        return Colors.orange[600]!; // Pending
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

  IconData _getStatusIcon(String? statusId) {
    switch (statusId) {
      case '1':
        return Icons.schedule; // Pending
      case '2':
        return Icons.restaurant; // Preparing
      case '3':
        return Icons.shopping_bag; // Ready for pickup
      case '4':
        return Icons.delivery_dining; // On the way
      case '5':
        return Icons.check_circle; // Delivered
      default:
        return Icons.info;
    }
  }
}
