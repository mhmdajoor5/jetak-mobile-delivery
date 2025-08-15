import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import '../../../generated/l10n.dart';
import '../../controllers/user_controller.dart';
import '../../helpers/app_config.dart' as config;
import 'DrivingLicenseWidget.dart';
import 'AccountingCertificateWidget.dart';

class BusinessLicenseWidget extends StatefulWidget {
  const BusinessLicenseWidget({super.key});

  @override
  _BusinessLicenseWidgetState createState() => _BusinessLicenseWidgetState();
}

class _BusinessLicenseWidgetState extends StateMVC<BusinessLicenseWidget> {
  late UserController _con;
  final ImagePicker _picker = ImagePicker();
  File? selectedFile;

  _BusinessLicenseWidgetState() : super(UserController()) {
    _con = (controller as UserController?)!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _con.scaffoldKey,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  'شهادة مصلحة / شهادة صاحب مصلحة مرخصة',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              
              SizedBox(height: 20),
              
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Document upload section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'شهادة مصلحة / شهادة صاحب مصلحة مرخصة',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 15),
                        Material(
                          child: InkWell(
                            onTap: () async {
                              final XFile? pickedFile = await _picker.pickImage(
                                source: ImageSource.gallery,
                              );
                              if (pickedFile != null) {
                                setState(() {
                                  selectedFile = File(pickedFile.path);
                                  _con.user.businessLicense = pickedFile.path;
                                });
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.file_copy, color: Colors.blue),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      selectedFile != null 
                                          ? selectedFile!.path.split('/').last
                                          : 'اختر ملف شهادة المصلحة',
                                      style: TextStyle(color: Colors.black87),
                                    ),
                                  ),
                                  if (selectedFile != null)
                                    Icon(Icons.check, color: Colors.green),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 30),
                    
                    // Navigation Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Back Button
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            'السابق',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                        
                        // Next Button
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: selectedFile != null ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AccountingCertificateWidget(),
                              ),
                            );
                          } : null,
                          child: Text(
                            'التالي',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
