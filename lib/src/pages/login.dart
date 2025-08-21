import 'package:deliveryboy/src/constants/theme/colors_manager.dart';
import 'package:deliveryboy/src/constants/theme/sizes_manager.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../controllers/user_controller.dart';
import '../elements/BlockButtonWidget.dart';
import '../helpers/app_config.dart' as config;
import '../repository/user_repository.dart' as userRepo;

class LoginWidget extends StatefulWidget {
  const LoginWidget({super.key});

  @override
  _LoginWidgetState createState() => _LoginWidgetState();
}

class _LoginWidgetState extends StateMVC<LoginWidget> {
  late UserController _con;
  late final GlobalKey<FormState> _loginFormKey;

  _LoginWidgetState() : super(UserController.instance) {
    _con = UserController.instance;
    _loginFormKey = GlobalKey<FormState>();
  }

  @override
  void initState() {
    super.initState();
    if (userRepo.currentUser.value.apiToken != null) {
      Navigator.of(context).pushReplacementNamed('/Pages', arguments: 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          alignment: AlignmentDirectional.topCenter,
          children: <Widget>[
            Positioned(
              top: 0,
              child: Container(
                width: config.App(context).appWidth(100),
                height: config.App(context).appHeight(37),
                decoration: BoxDecoration(color: Colors.black54),
              ),
            ),
            Positioned(
              top: config.App(context).appHeight(37) - 140,
              child: SizedBox(
                width: config.App(context).appWidth(84),
                height: config.App(context).appHeight(37),
                child: Text(
                  S.of(context).lets_start_with_login,
                  style: TextStyle(color: Colors.white60, fontSize: Sizes.size20),
                ),
              ),
            ),
            Positioned(
              top: config.App(context).appHeight(37) - 50,
              child: Container(
                decoration: BoxDecoration(
                  color: ColorsManager.charcoal,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 50,
                      color: Theme.of(context).hintColor.withOpacity(0.2),
                    ),
                  ],
                ),
                margin: EdgeInsets.symmetric(horizontal: 20),
                padding: EdgeInsets.symmetric(vertical: 50, horizontal: 27),
                width: config.App(context).appWidth(88),
                //              height: config.App(context).appHeight(55),
                child: Form(
                  key: _loginFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      TextFormField(
                           style: TextStyle(color: Colors.white),

                        keyboardType: TextInputType.emailAddress,
                        onChanged: (input) => _con.user.email = input,
                        onSaved: (input) => _con.user.email = input!,
                        validator:
                            (input) =>
                                !input!.contains('@')
                                    ? S.of(context).should_be_a_valid_email
                                    : null,
                        decoration: InputDecoration(
                          labelText: S.of(context).email,
                          labelStyle: TextStyle(color: Colors.white60),
                          contentPadding: EdgeInsets.all(12),
                         
                          hintText: 'johndoe@gmail.com',
                          hintStyle: TextStyle(
                            color: Theme.of(
                              context,
                            ).focusColor,
                          ),
                          prefixIcon: Icon(
                            Icons.alternate_email,
                            color: Colors.white60,
                          ),
                          
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(
                                context,
                              ).focusColor,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(
                                context,
                              ).focusColor,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(
                                context,
                              ).focusColor,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 30),
                      TextFormField(
                        keyboardType: TextInputType.text,
                        onChanged: (input) => _con.user.password = input,
                        onSaved: (input) => _con.user.password = input!,
                        validator:
                            (input) =>
                                input!.length < 3
                                    ? S
                                        .of(context)
                                        .should_be_more_than_3_characters
                                    : null,
                        obscureText: _con.hidePassword,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: S.of(context).password,
                          labelStyle: TextStyle(color: Colors.white60),
                          contentPadding: EdgeInsets.all(12),
                          hintText: '••••••••••••',
                          hintStyle: TextStyle(
                            color: Theme.of(
                              context,
                            ).focusColor,
                          ),
                          prefixIcon: Icon(
                            Icons.lock_outline,
                            color: Colors.white60,
                          ),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _con.hidePassword = !_con.hidePassword;
                              });
                            },
                            color: Theme.of(context).focusColor,
                            icon: Icon(
                              _con.hidePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(
                                context,
                              ).focusColor,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(
                                context,
                              ).focusColor,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(
                                context,
                              ).focusColor,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 30),
                      BlockButtonWidget(
                        text: Text(
                          S.of(context).login,
                          style: TextStyle(color: Colors.white70),
                        ),
                        color: Colors.black,
                        onPressed: () {
                          _con.login();
                        },
                      ),
                      SizedBox(height: 25),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 10,
              child: Column(
                children: <Widget>[
                  MaterialButton(
                    elevation: 0,
                    focusElevation: 0,
                    highlightElevation: 0,
                    onPressed: () {
                      Navigator.of(
                        context,
                      ).pushReplacementNamed('/ForgetPassword');
                    },
                    textColor: Theme.of(context).hintColor,
                    child: Text(S.of(context).i_forgot_password),
                  ),
                  MaterialButton(
                    elevation: 0,
                    focusElevation: 0,
                    highlightElevation: 0,
                    onPressed: () {
                      Navigator.of(context).pushReplacementNamed('/SignUp');
                    },
                    textColor: Theme.of(context).hintColor,
                    child: Text(S.of(context).i_dont_have_an_account),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
