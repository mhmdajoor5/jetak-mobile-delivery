import 'package:flutter/material.dart';

import '../helpers/helper.dart';
import '../models/food_order.dart';
import '../models/order.dart';
import '../models/route_argument.dart';
import 'SafeNetworkImage.dart';

class FoodOrderItemWidget extends StatelessWidget {
  final String? heroTag;
  final FoodOrder? foodOrder;
  final Order? order;

  const FoodOrderItemWidget({super.key, this.foodOrder, this.order, this.heroTag}) ;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.black54,
      focusColor: Colors.black54,
      highlightColor: Colors.black54,
      onTap: () {
        Navigator.of(context).pushNamed('/OrderDetails', arguments: RouteArgument(id: order?.id));
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.9),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Hero(
              tag: '${heroTag}${foodOrder?.id ?? ''}',
              child: SafeNetworkImage(
                height: 60,
                width: 60,
                fit: BoxFit.cover,
                imageUrl: foodOrder?.food?.image?.thumb,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            SizedBox(width: 15),
            Flexible(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          foodOrder?.food?.name ??"",
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Wrap(
                          children: List.generate(foodOrder!.extras!.length, (index) {
                            return Text(
                              foodOrder!.extras!.elementAt(index).name! + ', ',
                              style: Theme.of(context).textTheme.bodyMedium,
                            );
                          }),
                        ),
                        Text(
                          foodOrder?.food?.restaurant?.name ??"",
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Helper.getPrice(Helper.getOrderPrice(foodOrder!), context, style: Theme.of(context).textTheme.bodySmall),
                      Text(
                        " x " + foodOrder!.quantity.toString(),
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
