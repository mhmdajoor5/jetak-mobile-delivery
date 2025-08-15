import 'dart:async';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../helpers/helper.dart';
import '../models/document.dart';
import '../models/user.dart';
import '../models/triple.dart';
import '../repository/user_repository.dart' as repository;

class UserController extends ControllerMVC {
  User user = User();
  bool hidePassword = true;
  bool loading = false;
  bool agreedToPrivacy = false;
 late GlobalKey<FormState> loginFormKey;
  late GlobalKey<ScaffoldState> scaffoldKey;
 late FirebaseMessaging _firebaseMessaging;
 late OverlayEntry loader;
 late File registrationDocument;

  UserController() {
    loginFormKey = GlobalKey<FormState>();
    scaffoldKey = GlobalKey<ScaffoldState>();
    _firebaseMessaging = FirebaseMessaging.instance;
    _firebaseMessaging.getToken().then((deviceToken) {
      user.deviceToken = deviceToken;
    });
  }

  Future<void> submitApplication(Map<String, Triple<bool, File, String>> uploadedFiles) async {
    if (!agreedToPrivacy) {
      ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
        SnackBar(content: Text("You must agree to the privacy policy.")),
      );
      return;
    }

    FocusScope.of(state!.context).unfocus();
    loader = Helper.overlayLoader(state!.context);
    Overlay.of(state!.context).insert(loader);

    if (loginFormKey.currentState!.validate()) {
      loginFormKey.currentState!.save();


      user.document1 = uploadedFiles["document1"]!.third;
      user.document2 = uploadedFiles["document2"]!.third;
      user.document3 = uploadedFiles["document3"]!.third;
      user.document4 = uploadedFiles["document4"]!.third;
      user.document5 = uploadedFiles["document5"]!.third;

      repository.register(user).then((value) async {
        if (value != null && value.apiToken != null) {
          Navigator.of(scaffoldKey.currentContext!).pushReplacementNamed('/Pages', arguments: 1);
        } else {
          ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
            SnackBar(content: Text(S.of(state!.context).wrong_email_or_password)),
          );
        }
      }).catchError((e) {
        ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
          SnackBar(content: Text(S.of(state!.context).thisAccountNotExist)),
        );
      }).whenComplete(() {
        files.clear();
        Helper.hideLoader(loader);
      });
    } else {
      Helper.hideLoader(loader);
    }
  }

  void showLoader() {
    loader = Helper.overlayLoader(state!.context);
  }

  void hideLoader() {
    Helper.hideLoader(loader);
  }

  void login() async {
    loader = Helper.overlayLoader(state!.context);
    FocusScope.of(state!.context).unfocus();
    if (loginFormKey.currentState!.validate()) {
      loginFormKey.currentState!.save();
      Overlay.of(state!.context).insert(loader);
      repository.login(user).then((value) {
        if (value.apiToken != null) {
          Navigator.of(scaffoldKey.currentContext!)
              .pushReplacementNamed('/Pages', arguments: 1);
        } else {
          ScaffoldMessenger.of(scaffoldKey.currentContext!)
              .showSnackBar(SnackBar(
            content: Text(S.of(state!.context).wrong_email_or_password),
          ));
        }
      }).catchError((e) {
        loader.remove();
        ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(SnackBar(
          content: Text(S.of(state!.context).thisAccountNotExist),
        ));
      }).whenComplete(() {
        Helper.hideLoader(loader);
      });
    }
  }

  Map<String, Triple<bool, File, String>> files = {};

  void uploadIndexedDocument(int index, String docKey, File file) async {
    loader = Helper.overlayLoader(state!.context);
    Overlay.of(state!.context).insert(loader);
    if (files.containsKey(docKey)) {
      files.remove(docKey);
    }
    String uuid = Uuid().generateV4();
    files.putIfAbsent(docKey, () => Triple(false, file, uuid));
    setState(() {});

    repository
        .upload(Document(
            uuid: files[docKey]!.third,
            field: docKey,
            file: files[docKey]!.second))
        .then((value) async {
      print(value);
      if (value != null && value.statusCode == 200) {
        print("success");
        files[docKey] = Triple(true, files[docKey]!.second, uuid);
        setState(() {});
        print("Success");
      }
    }).catchError((err) {
      ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(SnackBar(
        content: Text(err.toString()),
      ));
      print("error");
    }).whenComplete(() {
      print("complete");
      // hideLoader();
      Helper.hideLoader(loader);
    });
  }

  File? getFile(key) {
    return files[key]?.second;
  }

  void uploadDocument() async {
    Navigator.of(scaffoldKey.currentContext!)
        .pushNamed('/Complete-profile', arguments: user);
    // loader = Helper.overlayLoader(state!.context);
    // Overlay.of(state!.context).insert(loader);
    //
    // String uuid = Uuid().generateV4();
    // if(registrationDocument == null) {
    //   register(uuid);
    //   return;
    // }
    // repository
    //     .upload(DocumentBody(
    //         document: Document(
    //             uuid: uuid,
    //             field: "document",
    //             file: registrationDocument.readAsBytesSync())))
    //     .then((value) async {
    //   if (value != null && value.statusCode == 200) {
    //     await register(uuid);
    //     registrationDocument = null;
    //   } else {
    //     ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(SnackBar(
    //       content: Text(S.of(state!.context).wrong_email_or_password),
    //     ));
    //   }
    // }).catchError((e) {
    //   Helper.hideLoader(loader);
    //   print(e);
    // }).whenComplete(() {
    //   loader?.remove();
    //   Helper.hideLoader(loader);
    // });
  }

  Future<void> register(Map<String, Triple<bool, File, String>> uploadedFiles) async {

    FocusScope.of(state!.context).unfocus();
    loader = Helper.overlayLoader(state!.context);
    Overlay.of(state!.context).insert(loader);

    if (loginFormKey.currentState!.validate()) {
      loginFormKey.currentState!.save();
      user.document1 = uploadedFiles["document1"]!.third;
      user.document2 = uploadedFiles["document2"]!.third;
      user.document3 = uploadedFiles["document3"]!.third;
      user.document4 = uploadedFiles["document4"]!.third;
      user.document5 = uploadedFiles["document5"]!.third;

      repository.register(user).then((value) async {
        if (value.apiToken != null) {
          Navigator.of(scaffoldKey.currentContext!)
              .pushReplacementNamed('/Pages', arguments: 1);
        } else {
          ScaffoldMessenger.of(scaffoldKey.currentContext!)
              .showSnackBar(SnackBar(
            content: Text(S.of(state!.context).wrong_email_or_password),
          ));
        }
      }).catchError((e) {
        ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(SnackBar(
          content: Text(S.of(state!.context).thisAccountNotExist),
        ));
      }).whenComplete(() {
        files.clear();
        Helper.hideLoader(loader);
      });
    }
  }

  void resetPassword() {
    loader = Helper.overlayLoader(state!.context);
    FocusScope.of(state!.context).unfocus();
    if (loginFormKey.currentState!.validate()) {
      loginFormKey.currentState!.save();
      Overlay.of(state!.context).insert(loader);
      repository.resetPassword(user).then((value) {
        if (value == true) {
          ScaffoldMessenger.of(scaffoldKey.currentContext!)
              .showSnackBar(SnackBar(
            content: Text(S
                .of(state!.context)
                .your_reset_link_has_been_sent_to_your_email),
            action: SnackBarAction(
              label: S.of(state!.context).login,
              onPressed: () {
                Navigator.of(scaffoldKey.currentContext!)
                    .pushReplacementNamed('/Login');
              },
            ),
            duration: Duration(seconds: 10),
          ));
        } else {
          loader.remove();
          ScaffoldMessenger.of(scaffoldKey.currentContext!)
              .showSnackBar(SnackBar(
            content: Text(S.of(state!.context).error_verify_email_settings),
          ));
        }
      }).whenComplete(() {
        Helper.hideLoader(loader);
      });
    }
  }

  void setRegistrationDocument(File file) {
    registrationDocument = file;
    setState(() {});
  }
}
