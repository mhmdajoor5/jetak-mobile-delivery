import 'package:flutter/material.dart';

import '../helpers/helper.dart';
import '../models/faq.dart';

class FaqItemWidget extends StatelessWidget {
  final Faq? faq;

  FaqItemWidget({super.key, this.faq}) ;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(
          color: Theme.of(context).focusColor.withOpacity(0.15),
          offset: Offset(0, 5),
          blurRadius: 15,
        )
      ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(10),
            decoration:
                BoxDecoration(color: Theme.of(context).focusColor, borderRadius: BorderRadius.only(topLeft: Radius.circular(5), topRight: Radius.circular(5))),
            child: Text(
              Helper.skipHtml(this.faq?.question ?? ""),
              style:  TextStyle(color: Colors.black54),
            ),
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: Colors.black54, borderRadius: BorderRadius.only(bottomRight: Radius.circular(5), bottomLeft: Radius.circular(5))),
            child: Text(
              Helper.skipHtml(this.faq?.answer ??""),
              style: Theme.of(context).textTheme.displaySmall,
            ),
          ),
        ],
      ),
    );
  }
}
