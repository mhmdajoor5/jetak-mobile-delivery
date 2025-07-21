import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../controllers/user_controller.dart';
import '../elements/BlockButtonWidget.dart';
import '../helpers/app_config.dart' as config;
import '../models/triple.dart';

class SignUpWidget extends StatefulWidget {
  const SignUpWidget({super.key});

  @override
  _SignUpWidgetState createState() => _SignUpWidgetState();
}

class _SignUpWidgetState extends StateMVC<SignUpWidget> {
   late UserController _con;

  _SignUpWidgetState() : super(UserController()) {
    _con = (controller as UserController?)!;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        key: _con.scaffoldKey,
        resizeToAvoidBottomInset: false,
        body: Stack(
          alignment: AlignmentDirectional.topCenter,
          children: <Widget>[
            Positioned(
              top: 0,
              child: Container(
                width: config.App(context).appWidth(100),
                height: config.App(context).appHeight(29.5),
                decoration: BoxDecoration(color: Colors.black54),
              ),
            ),
            Positioned(
              top: config.App(context).appHeight(29.5) - 140,
              child: SizedBox(
                width: config.App(context).appWidth(84),
                height: config.App(context).appHeight(29.5),
                child: Text(
                  S.of(context).lets_start_with_register,
                  style:  TextStyle(color: Colors.black54),
                ),
              ),
            ),
            Positioned(
              top: config.App(context).appHeight(29.5) - 50,
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 50,
                        color: Theme.of(context).hintColor.withOpacity(0.2),
                      )
                    ]),
                margin: EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                padding: EdgeInsets.symmetric(vertical: 50, horizontal: 27),
                width: config.App(context).appWidth(88),
//              height: config.App(context).appHeight(55),
                child: Form(
                  key: _con.loginFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      TextFormField(
                        keyboardType: TextInputType.text,
                        onSaved: (input) => _con.user.name = input,
                        validator: (input) => input!.length < 3
                            ? S.of(context).should_be_more_than_3_letters
                            : null,
                        decoration: InputDecoration(
                          labelText: S.of(context).full_name,
                          labelStyle:
                              TextStyle(color: Colors.black54),
                          contentPadding: EdgeInsets.all(12),
                          hintText: S.of(context).john_doe,
                          hintStyle: TextStyle(
                              color: Theme.of(context)
                                  .focusColor
                                  .withOpacity(0.7)),
                          prefixIcon: Icon(Icons.person_outline,
                              color: Colors.black54),
                          border: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context)
                                      .focusColor
                                      .withOpacity(0.2))),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context)
                                      .focusColor
                                      .withOpacity(0.5))),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context)
                                      .focusColor
                                      .withOpacity(0.2))),
                        ),
                      ),
                      SizedBox(height: 30),
                      TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        onSaved: (input) => _con.user.email = input,
                        validator: (input) => !input!.contains('@')
                            ? S.of(context).should_be_a_valid_email
                            : null,
                        decoration: InputDecoration(
                          labelText: S.of(context).email,
                          labelStyle:
                              TextStyle(color: Colors.black54),
                          contentPadding: EdgeInsets.all(12),
                          hintText: 'johndoe@gmail.com',
                          hintStyle: TextStyle(
                              color: Theme.of(context)
                                  .focusColor
                                  .withOpacity(0.7)),
                          prefixIcon: Icon(Icons.alternate_email,
                              color: Colors.black54),
                          border: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context)
                                      .focusColor
                                      .withOpacity(0.2))),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context)
                                      .focusColor
                                      .withOpacity(0.5))),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context)
                                      .focusColor
                                      .withOpacity(0.2))),
                        ),
                      ),
                      SizedBox(height: 30),
                      TextFormField(
                        obscureText: _con.hidePassword,
                        onSaved: (input) => _con.user.password = input,
                        validator: (input) => input!.length < 6
                            ? S.of(context).should_be_more_than_6_letters
                            : null,
                        decoration: InputDecoration(
                          labelText: S.of(context).password,
                          labelStyle:
                              TextStyle(color: Colors.black54),
                          contentPadding: EdgeInsets.all(12),
                          hintText: '••••••••••••',
                          hintStyle: TextStyle(
                              color: Theme.of(context)
                                  .focusColor
                                  .withOpacity(0.7)),
                          prefixIcon: Icon(Icons.lock_outline,
                              color: Colors.black54),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _con.hidePassword = !_con.hidePassword;
                              });
                            },
                            color: Theme.of(context).focusColor,
                            icon: Icon(_con.hidePassword
                                ? Icons.visibility
                                : Icons.visibility_off),
                          ),
                          border: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context)
                                      .focusColor
                                      .withOpacity(0.2))),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context)
                                      .focusColor
                                      .withOpacity(0.5))),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context)
                                      .focusColor
                                      .withOpacity(0.2))),
                        ),
                      ),
                      SizedBox(height: 30),
                      BlockButtonWidget(
                        text: Text(
                          S.of(context).register,
                          overflow: TextOverflow.ellipsis,
                          style:
                              TextStyle(color: Colors.black54),
                        ),
                        color: Colors.black54,

                        onPressed: () async {
                         var result =
                              await Navigator.of(
                                      _con.scaffoldKey.currentContext!)
                                  .pushNamed('/Complete-profile');

                          print(result as  Map<String, Triple<bool, File, String>> );
                          Map<String, Triple<bool, File, String>> filesMap = result;
                         await _con.register(filesMap);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 10,
              child: MaterialButton(
                elevation: 0,
                focusElevation: 0,
                highlightElevation: 0,
                onPressed: () {
                  Navigator.of(context).pushNamed('/Login');
                },
                textColor: Theme.of(context).hintColor,
                child: Text(S.of(context).i_have_account_back_to_login),
              ),
            )
          ],
        ),
      ),
    );
  }

  SizedBox _buildPickFileRow() {
    return SizedBox(
        width: 90,
        height: 30,
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                  color: Colors.blueGrey.withOpacity(0.4),
                  blurRadius: 40,
                  offset: Offset(0, 15)),
              BoxShadow(
                  color: Colors.blueGrey.withOpacity(0.4),
                  blurRadius: 13,
                  offset: Offset(0, 3))
            ],
            borderRadius: BorderRadius.all(Radius.circular(100)),
          ),
          child: MaterialButton(
            elevation: 0,
            focusElevation: 0,
            highlightElevation: 0,
            onPressed: () async {
              FilePickerResult? result = await FilePicker.platform.pickFiles(
                type: FileType.custom,
                allowedExtensions: ['jpg', 'png'],
              );
              if (result != null) {
                _con.setRegistrationDocument(File(result.files.single.path!));
              } else {
                // ignore: User canceled the picker
              }
            },
            // padding: EdgeInsets.symmetric(
            //     horizontal: 66, vertical: 14),
            color: Colors.blueGrey,
            shape: StadiumBorder(),
            child: Text(
              "Upload",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ));
  }
}
