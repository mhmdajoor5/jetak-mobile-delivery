import 'dart:async';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../helpers/helper.dart';
import '../helpers/FirebaseUtils.dart';
import '../models/document.dart';
import '../models/user.dart';
import '../models/triple.dart';
import '../repository/user_repository.dart' as repository;
import '../helpers/intercom_helper.dart';

class UserController extends ControllerMVC {
  static UserController? _instance;
  
  static UserController get instance {
    _instance ??= UserController._internal();
    return _instance!;
  }
  
  User user = User();
  bool hidePassword = true;
  bool loading = false;
  bool agreedToPrivacy = false;
  late GlobalKey<FormState> loginFormKey;
  late FirebaseMessaging _firebaseMessaging;
  late OverlayEntry loader;
  late File registrationDocument;
  
  UserController._internal() {
    loginFormKey = GlobalKey<FormState>();
  }

  Future<void> submitApplication(Map<String, Triple<bool, File, String>> uploadedFiles) async {
    if (!agreedToPrivacy) {
      ScaffoldMessenger.of(state!.context).showSnackBar(
        SnackBar(content: Text("You must agree to the privacy policy.")),
      );
      return;
    }

    // Use the new register method
    await register();
  }

  void showLoader() {
    loader = Helper.overlayLoader(state!.context);
  }

  void hideLoader() {
    Helper.hideLoader(loader);
  }

  Future<void> register() async {
    try {
      // Print user data for debugging
      print('🔍 User data before registration:');
      print('  name: ${user.name}');
      print('  email: ${user.email}');
      print('  password: ${user.password}');
      print('  firstName: ${user.firstName}');
      print('  lastName: ${user.lastName}');
      print('  phone: ${user.phone}');
      print('  deliveryCity: ${user.deliveryCity}');
      print('  vehicleType: ${user.vehicleType}');
      print('  languagesSpoken: ${user.languagesSpoken}');
      print('  dateOfBirth: ${user.dateOfBirth}');
      print('  referralCode: ${user.referralCode}');
      print('  bankName: ${user.bankName}');
      print('  accountNumber: ${user.accountNumber}');
      print('  branchNumber: ${user.branchNumber}');
      print('  drivingLicense: ${user.drivingLicense}');
      print('  businessLicense: ${user.businessLicense}');
      print('  accountingCertificate: ${user.accountingCertificate}');
      print('  taxCertificate: ${user.taxCertificate}');
      print('  accountManagementCertificate: ${user.accountManagementCertificate}');
      print('  bankAccountDetails: ${user.bankAccountDetails}');
      
      loader = Helper.overlayLoader(state!.context);
      Overlay.of(state!.context).insert(loader);
      
      User registeredUser = await repository.register(user);

      // Save FCM token immediately after successful registration
      print('💾 Saving FCM token after registration...');
      try {
        await FirebaseUtil.saveFCMTokenForUser(registeredUser);
      } catch (e) {
        print('⚠️ Warning: Failed to save FCM token after registration: $e');
        // Don't block registration flow if FCM token save fails
      }

      // Check if user is active
      if (registeredUser.isActive == 1) {
        // User is inactive, show contract page
        print('🔍 User is inactive (isActive: ${registeredUser.isActive}), showing contract page');
        Navigator.of(state!.context).pushReplacementNamed('/CarryContract');
      } else {
        // User is active, show normal pages
        print('🔍 User is active (isActive: ${registeredUser.isActive}), navigating to main app');
        Navigator.of(state!.context).pushReplacementNamed('/Pages', arguments: 1);
      }
      
    } catch (e) {
      ScaffoldMessenger.of(state!.context).showSnackBar(
        SnackBar(content: Text('Registration failed: ${e.toString()}')),
      );
    } finally {
      Helper.hideLoader(loader);
    }
  }

  void login() async {
    loader = Helper.overlayLoader(state!.context);
    FocusScope.of(state!.context).unfocus();
    
    // Manual validation since form validation is disabled
    if (user.email == null || user.email!.isEmpty) {
      ScaffoldMessenger.of(state!.context).showSnackBar(SnackBar(
        content: Text('يرجى إدخال البريد الإلكتروني'),
      ));
      return;
    }
    
    if (user.password == null || user.password!.isEmpty) {
      ScaffoldMessenger.of(state!.context).showSnackBar(SnackBar(
        content: Text('يرجى إدخال كلمة المرور'),
      ));
      return;
    }
    
    if (!user.email!.contains('@')) {
      ScaffoldMessenger.of(state!.context).showSnackBar(SnackBar(
        content: Text('يرجى إدخال بريد إلكتروني صحيح'),
      ));
      return;
    }
    
    Overlay.of(state!.context).insert(loader);
    
    // Debug logging
    print('🔍 Login attempt with:');
    print('   - Email: ${user.email}');
    print('   - Password length: ${user.password?.length ?? 0}');
    print('   - Password preview: ${user.password?.substring(0, user.password!.length > 3 ? 3 : user.password!.length)}***');
    
    repository.login(user).then((value) async {
      print('🔍 Login successful - User ID: ${value.id}, isActive: ${value.isActive}');
      if (value.apiToken != null) {
        // Save FCM token immediately after successful login
        print('💾 Saving FCM token after login...');
        try {
          await FirebaseUtil.saveFCMTokenForUser(value);
        } catch (e) {
          print('⚠️ Warning: Failed to save FCM token after login: $e');
          // Don't block login flow if FCM token save fails
        }

        // تسجيل المستخدم في Intercom
        await IntercomHelper.loginUser(
          userId: value.id.toString(),
          email: value.email ?? '',
          name: value.name ?? value.firstName ?? '',
          attributes: {
            'phone': value.phone ?? '',
            'is_active': value.isActive == 1,
            'user_type': 'driver',
          },
        );

        // Check if user is active (is_active = 1 means active, 0 means inactive)
        if (value.isActive == 0) {
          print('🔍 User is inactive (isActive: ${value.isActive}), showing contract page');
          // User is inactive, show contract page
          Navigator.of(state!.context).pushReplacementNamed('/CarryContract');
        } else {
          print('🔍 User is active (isActive: ${value.isActive}), navigating to main app');
          // User is active, go to main app
          Navigator.of(state!.context)
              .pushReplacementNamed('/Pages', arguments: 1);
        }
      } else {
        ScaffoldMessenger.of(state!.context)
            .showSnackBar(SnackBar(
          content: Text(S.of(state!.context).wrong_email_or_password),
        ));
      }
    }).catchError((e) {
      loader.remove();
      ScaffoldMessenger.of(state!.context).showSnackBar(SnackBar(
        content: Text(S.of(state!.context).thisAccountNotExist),
      ));
    }).whenComplete(() {
      Helper.hideLoader(loader);
    });
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
      ScaffoldMessenger.of(state!.context).showSnackBar(SnackBar(
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
    Navigator.of(state!.context)
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

  Future<void> registerWithFiles(Map<String, Triple<bool, File, String>> uploadedFiles) async {

    FocusScope.of(state!.context).unfocus();
    loader = Helper.overlayLoader(state!.context);
    Overlay.of(state!.context).insert(loader);

    // Skip validation for now to avoid null check error
    // TODO: Pass form key from widget or implement proper validation
    user.document1 = uploadedFiles["document1"]!.third;
    user.document2 = uploadedFiles["document2"]!.third;
    user.document3 = uploadedFiles["document3"]!.third;
    user.document4 = uploadedFiles["document4"]!.third;
    user.document5 = uploadedFiles["document5"]!.third;

    repository.register(user).then((value) async {
      print('🔍 Registration successful - User ID: ${value.id}, isActive: ${value.isActive}');
      if (value.apiToken != null) {
        // Save FCM token immediately after successful registration
        print('💾 Saving FCM token after registration with files...');
        try {
          await FirebaseUtil.saveFCMTokenForUser(value);
        } catch (e) {
          print('⚠️ Warning: Failed to save FCM token after registration: $e');
          // Don't block registration flow if FCM token save fails
        }

        // Check if user is active (is_active = 1 means active, 0 means inactive)
        if (value.isActive == 0) {
          print('🔍 User is inactive (isActive: ${value.isActive}), showing contract page');
          // User is inactive, show contract page
          Navigator.of(state!.context).pushReplacementNamed('/CarryContract');
        } else {
          print('🔍 User is active (isActive: ${value.isActive}), navigating to main app');
          // User is active, go to main app
          Navigator.of(state!.context)
              .pushReplacementNamed('/Pages', arguments: 1);
        }
      } else {
        ScaffoldMessenger.of(state!.context)
            .showSnackBar(SnackBar(
          content: Text(S.of(state!.context).wrong_email_or_password),
        ));
      }
    }).catchError((e) {
      ScaffoldMessenger.of(state!.context).showSnackBar(SnackBar(
        content: Text(S.of(state!.context).thisAccountNotExist),
      ));
    }).whenComplete(() {
      files.clear();
      Helper.hideLoader(loader);
    });
  }

  void resetPassword() {
    loader = Helper.overlayLoader(state!.context);
    FocusScope.of(state!.context).unfocus();
    // Skip validation for now to avoid null check error
    // TODO: Pass form key from widget or implement proper validation
    Overlay.of(state!.context).insert(loader);
    repository.resetPassword(user).then((value) {
      if (value == true) {
        ScaffoldMessenger.of(state!.context)
            .showSnackBar(SnackBar(
          content: Text(S
              .of(state!.context)
              .your_reset_link_has_been_sent_to_your_email),
          action: SnackBarAction(
            label: S.of(state!.context).login,
            onPressed: () {
              Navigator.of(state!.context)
                  .pushReplacementNamed('/Login');
            },
          ),
          duration: Duration(seconds: 10),
        ));
      } else {
        loader.remove();
        ScaffoldMessenger.of(state!.context)
            .showSnackBar(SnackBar(
          content: Text(S.of(state!.context).error_verify_email_settings),
        ));
      }
    }).whenComplete(() {
      Helper.hideLoader(loader);
    });
  }

  void setRegistrationDocument(File file) {
    registrationDocument = file;
    setState(() {});
  }
  
  void resetUserData() {
    user = User();
    agreedToPrivacy = false;
    setState(() {});
  }
}
