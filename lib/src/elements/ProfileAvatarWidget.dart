import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/user.dart';

class ProfileAvatarWidget extends StatelessWidget {
  final User user;

  const ProfileAvatarWidget({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 30),
      decoration: BoxDecoration(
        color: Theme.of(context).canvasColor,
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
      ),
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 160,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
//              SizedBox(
//                width: 50,
//                height: 50,
//                child: MaterialButton(
//      elevation: 0, 
//      focusElevation: 0,
//      highlightElevation: 0,
//                  padding: EdgeInsets.all(0),
//                  onPressed: () {},
//                  child: Icon(Icons.add, color: Colors.black54),
//                  color: Theme.of(context).accentColor,
//                  shape: StadiumBorder(),
//                ),
//              ),
                ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(300)),
                  child: CachedNetworkImage(
                    height: 135,
                    width: 135,
                    fit: BoxFit.cover,
                    imageUrl: user.image?.url ?? "",
                    placeholder: (context, url) => Image.asset(
                      'assets/img/loading.gif',
                      fit: BoxFit.cover,
                      height: 135,
                      width: 135,
                    ),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
                ),
//              SizedBox(
//                width: 50,
//                height: 50,
//                child: MaterialButton(
//      elevation: 0,
//      focusElevation: 0,
//      highlightElevation: 0,
//                  padding: EdgeInsets.all(0),
//                  onPressed: () {},
//                  child: Icon(Icons.chat, color: Colors.black54),
//                  color: Theme.of(context).accentColor,
//                  shape: StadiumBorder(),
//                ),
//              ),
              ],
            ),
          ),
          Text(
            user.name ?? "",
            style: TextStyle(color: Colors.black54),
          ),
          Text(
            user.address ?? "",
            style: TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
