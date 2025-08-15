import 'dart:developer';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';



import 'package:intl/intl.dart';
import '../../../generated/l10n.dart';
import '../../controllers/user_controller.dart';
import '../../elements/BlockButtonWidget.dart';
import '../../helpers/app_config.dart' as config;
import '../../models/triple.dart';
import '../../repository/user_repository.dart';
import '../LanguageDropdown.dart';

class SignUpWidget extends StatefulWidget {
  @override
  _SignUpWidgetState createState() => _SignUpWidgetState();
}

class _SignUpWidgetState extends StateMVC<SignUpWidget> {
  late UserController _con;
  bool agree = false;
  Map<String, Triple<bool, File, String>> files = {};
  final TextEditingController _dateController = TextEditingController();

  _SignUpWidgetState() : super(UserController()) {
    _con = (controller as UserController?)!;

  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        key: _con.scaffoldKey,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Text
                Container(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        S.of(context).sentence1,
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold, 
                          fontSize: 24
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        S.of(context).sentence2,
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 16
                        ),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 30),
                
                // Form Container
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 10,
                        color: Colors.black.withOpacity(0.1),
                      )
                    ]
                  ),
                  padding: EdgeInsets.symmetric(vertical: 30, horizontal: 27),
                  child: Form(
                    key: _con.loginFormKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        // First Name
                        TextFormField(
                          keyboardType: TextInputType.name,
                          onSaved: (input) => _con.user.firstName = input,
                          validator: (input) => input == null || input.isEmpty
                              ? 'First name is required'
                              : null,
                          decoration: InputDecoration(
                            labelText: 'First name (as in passport)',
                            labelStyle: TextStyle(color: Colors.black54),
                            contentPadding: EdgeInsets.all(12),
                            hintText: 'John',
                            hintStyle: TextStyle(color: Theme.of(context).focusColor.withOpacity(0.7)),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.2)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.5)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.2)),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),

                        // Last Name
                        TextFormField(
                          keyboardType: TextInputType.name,
                          onSaved: (input) => _con.user.lastName = input,
                          validator: (input) => input == null || input.isEmpty
                              ? 'Last name is required'
                              : null,
                          decoration: InputDecoration(
                            labelText: 'Last name (as in passport)',
                            labelStyle: TextStyle(color: Colors.black54),
                            contentPadding: EdgeInsets.all(12),
                            hintText: 'Doe',
                            hintStyle: TextStyle(color: Theme.of(context).focusColor.withOpacity(0.7)),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.2)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.5)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.2)),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),

                        // Email
                        TextFormField(
                          keyboardType: TextInputType.emailAddress,
                          onSaved: (input) => _con.user.email = input,
                          validator: (input) => input == null || !input.contains('@')
                              ? 'Please enter a valid email'
                              : null,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            labelStyle: TextStyle(color: Colors.black54),
                            contentPadding: EdgeInsets.all(12),
                            hintText: 'johndoe@gmail.com',
                            hintStyle: TextStyle(color: Theme.of(context).focusColor.withOpacity(0.7)),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.2)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.5)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.2)),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),

                        // Password
                        TextFormField(
                          obscureText: true,
                          onSaved: (input) => _con.user.password = input,
                          validator: (input) => input == null || input.length < 6
                              ? 'Password must be at least 6 characters'
                              : null,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle: TextStyle(color: Colors.black54),
                            contentPadding: EdgeInsets.all(12),
                            hintText: 'Enter your password',
                            hintStyle: TextStyle(color: Theme.of(context).focusColor.withOpacity(0.7)),
                            prefixIcon: Icon(Icons.lock, color: Colors.black54),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.2)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.5)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.2)),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),

                        // Confirm Password
                        TextFormField(
                          obscureText: true,
                          onSaved: (input) => _con.user.passwordConfirmation = input,
                          validator: (input) {
                            if (input == null || input.isEmpty) {
                              return 'Please confirm your password';
                            }
                            // We'll validate password match in a separate validator
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: 'Confirm Password',
                            labelStyle: TextStyle(color: Colors.black54),
                            contentPadding: EdgeInsets.all(12),
                            hintText: 'Confirm your password',
                            hintStyle: TextStyle(color: Theme.of(context).focusColor.withOpacity(0.7)),
                            prefixIcon: Icon(Icons.lock_outline, color: Colors.black54),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.2)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.5)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.2)),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),

                        // Phone Number
                        TextFormField(
                          keyboardType: TextInputType.phone,
                          onSaved: (input) => _con.user.phone = input,
                          validator: (input) => input == null || input.isEmpty
                              ? 'Phone number is required'
                              : null,
                          decoration: InputDecoration(
                            labelText: 'Phone number (international format)',
                            labelStyle: TextStyle(color: Colors.black54),
                            contentPadding: EdgeInsets.all(12),
                            hintText: '+972 5XXXXXXXX',
                            hintStyle: TextStyle(color: Theme.of(context).focusColor.withOpacity(0.7)),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.2)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.5)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.2)),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        // Languages Spoken
                        LanguageDropdown(
                          selectedCode: _con.user.languagesSpokenCode,
                          onChanged: (val) {
                            setState(() {
                              _con.user.languagesSpokenCode = val;
                              _con.user.languagesSpoken = val;
                            });
                          },
                          decoration: InputDecoration(
                            labelText: 'Languages spoken',
                            labelStyle: TextStyle(color: Colors.black54),
                            contentPadding: EdgeInsets.all(12),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.2)),
                            ),
                          ),
                        ),

                        SizedBox(height: 20),

                        // Date of Birth
                        TextFormField(
                          controller: _dateController, // TextEditingController
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: 'Date of birth',
                            labelStyle: TextStyle(color: Colors.black54),
                            contentPadding: EdgeInsets.all(12),
                            suffixIcon: Icon(Icons.calendar_today),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.2)),
                            ),
                          ),
                          onTap: () async {
                            DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime(2000),
                              firstDate: DateTime(1900),
                              lastDate: DateTime.now(),
                            );
                            if (picked != null) {
                              _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
                              _con.user.dateOfBirth = _dateController.text;
                            }
                          },
                          validator: (input) => input == null || input.isEmpty ? 'Date of birth is required' : null,
                        ),

                        SizedBox(height: 10),

                        // Informational Text under Date of Birth
                        Text(
                          'Depending on your city, you must be over 16 or 18 years old to deliver Carry.',
                          style: TextStyle(color: Colors.black54, fontSize: 14),
                        ),


                        // Delivery City
                        TextFormField(
                          keyboardType: TextInputType.text,
                          onSaved: (input) => _con.user.deliveryCity = input,
                          decoration: InputDecoration(
                            labelText: 'Delivery city',
                            labelStyle: TextStyle(color: Colors.black54),
                            contentPadding: EdgeInsets.all(12),
                            prefixIcon: Icon(Icons.location_city, color: Colors.black54),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.2)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.5)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.2)),
                            ),
                          ),
                          validator: (value) => value == null || value.isEmpty ? 'Delivery city is required' : null,
                        ),

                        SizedBox(height: 20),

                        DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: 'Vehicle type',
                            labelStyle: TextStyle(color: Colors.black54),
                            contentPadding: EdgeInsets.all(12),
                            prefixIcon: Icon(Icons.directions_car, color: Colors.black54),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.2)),
                            ),
                          ),
                          icon: Icon(Icons.arrow_drop_down),
                          items: ['Motorcycle', 'Electric Motorcycle',]
                              .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _con.user.vehicleType = value!;
                            });
                          },
                          validator: (input) => input == null ? 'Please enter vehicle type' : null,
                        ),


                        SizedBox(height: 30),

                        // Courier partner referral code (optional)
                        TextFormField(
                          keyboardType: TextInputType.text,
                          onSaved: (input) => _con.user.referralCode = input,
                          decoration: InputDecoration(
                            labelText: 'Courier partner referral code (optional)',
                            labelStyle: TextStyle(color: Colors.black54),
                            contentPadding: EdgeInsets.all(12),
                            prefixIcon: Icon(Icons.card_giftcard, color: Colors.black54),
                            border: OutlineInputBorder(
                                borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.2))),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.5))),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.2))),
                          ),
                        ),

                        SizedBox(height: 20),

                        StatefulBuilder(
                          builder: (context, setStateCheckbox) {
                            bool agree = false;
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Checkbox(
                                  value: agree,
                                  onChanged: (value) {
                                    setStateCheckbox(() {
                                      agree = value!;
                                      _con.agreedToPrivacy = agree;
                                    });
                                  },
                                  activeColor: Colors.blue[900],
                                ),
                                Expanded(
                                  child: CheckboxListTile(
                                    title: RichText(
                                      text: TextSpan(
                                        text: 'I agree for my personal data to be collected and processed in accordance with the ',
                                        style: TextStyle(color: Colors.white),
                                        children: <TextSpan>[
                                          TextSpan(
                                            text: 'Carry Courier Partner Privacy Statement.',
                                            style: TextStyle(color: Colors.blue[900]),
                                          ),
                                        ],
                                      ),
                                    ),
                                    value: agree,
                                    onChanged: (value) {
                                      setState(() {
                                        agree = value ?? false;
                                        _con.agreedToPrivacy = agree;
                                      });
                                    },
                                    activeColor: Colors.blue[900],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),

                        SizedBox(height: 30),

                        Center(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () async {
                              if (!_con.agreedToPrivacy) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Please agree to the privacy statement')),
                                );
                                return;
                              }
                              
                              // Validate password match
                              if (_con.user.password != _con.user.passwordConfirmation) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Passwords do not match')),
                                );
                                return;
                              }
                              
                              var result = await Navigator.of(_con.scaffoldKey.currentContext!).pushNamed('/Complete-profile');

                              Map<String, Triple<bool, File, String>> filesMap = result as Map<String, Triple<bool, File, String>>;
                              await _con.register(filesMap);
                            },
                            child: Text(
                              'Send Application',
                              style: TextStyle(color: Colors.white, fontSize: 18),
                            ),
                          ),
                            ),

                          SizedBox(height: 30),

                        // BlockButtonWidget(
                        //   text: Text(
                        //     S.of(context).register,
                        //     overflow: TextOverflow.ellipsis,
                        //     style: TextStyle(color: Colors.black54),
                        //   ),
                        //   color: Colors.black54,
                        //   onPressed: () async {
                        //     var result = await Navigator.of(_con.scaffoldKey.currentContext!).pushNamed('/Complete-profile');
                        //
                        //     print(result as Map<String, Triple<bool, File, String>>);
                        //     Map<String, Triple<bool, File, String>> filesMap = result as Map<String, Triple<bool, File, String>>;
                        //     await _con.register(filesMap);
                        //   },
                        //   // onPressed: () async {
                        //   //   await _con.submitApplication(files);
                        //   // },
                        // ),
                      ],
                    ),
                  ),
                ),
                
                SizedBox(height: 20),
                
                // Back to login button
                Center(
                  child: MaterialButton(
                    elevation: 0,
                    focusElevation: 0,
                    highlightElevation: 0,
                    onPressed: () {
                      Navigator.of(context).pushNamed('/Login');
                    },
                    textColor: Colors.blue,
                    child: Text(S.of(context).i_have_account_back_to_login),
                  ),
                ),
              ],
            ),
          ),
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
              S.of(context as BuildContext).upload,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ));
  }
}
