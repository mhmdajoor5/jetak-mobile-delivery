import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import '../../controllers/user_controller.dart';
import '../../helpers/validation_helper.dart';
import 'DrivingLicenseWidget.dart';
import 'AccountingCertificateWidget.dart';

class BusinessLicenseWidget extends StatefulWidget {
  const BusinessLicenseWidget({super.key});

  @override
  _BusinessLicenseWidgetState createState() => _BusinessLicenseWidgetState();
}

class _BusinessLicenseWidgetState extends StateMVC<BusinessLicenseWidget> {
  late UserController _con;
  File? selectedFile;
  String? fileError;

  _BusinessLicenseWidgetState() : super(UserController.instance) {
    _con = UserController.instance;
  }

  // Helper function to get text based on current locale
  String getText(String hebrew, String arabic, String english) {
    final locale = Localizations.localeOf(context).languageCode;
    switch (locale) {
      case 'he':
        return hebrew;
      case 'ar':
        return arabic;
      default:
        return english;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: FocusScope(
          autofocus: true,
          child: GestureDetector(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              physics: ClampingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      getText('תעודת עסק / תעודת בעל עסק מורשה', 'شهادة مصلحة / شهادة صاحب مصلحة مرخصة', 'Business Certificate / Licensed Business Owner Certificate'),
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
                              getText('תעודת עסק / תעודת בעל עסק מורשה', 'شهادة مصلحة / شهادة صاحب مصلحة مرخصة', 'Business Certificate / Licensed Business Owner Certificate'),
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
                                  try {
                                    FilePickerResult? result = await FilePicker.platform.pickFiles(
                                      type: FileType.custom,
                                      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
                                    );

                                    if (result != null && result.files.single.path != null) {
                                      String filePath = result.files.single.path!;
                                      String? error = ValidationHelper.validateFile(filePath);

                                      setState(() {
                                        if (error == null) {
                                          selectedFile = File(filePath);
                                          _con.user.businessLicense = filePath;
                                          fileError = null;
                                        } else {
                                          selectedFile = null;
                                          _con.user.businessLicense = null;
                                          fileError = error;
                                        }
                                      });
                                    }
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(getText(
                                          'שגיאה בבחירת קובץ: $e',
                                          'خطأ في اختيار الملف: $e',
                                          'Error selecting file: $e'
                                        )),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
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
                                              : getText('בחר קובץ תעודת עסק', 'اختر ملف شهادة المصلحة', 'Choose business certificate file'),
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
                            if (selectedFile != null) ...[
                              SizedBox(height: 8),
                              Text(
                                'File size: ${ValidationHelper.formatFileSize(selectedFile!.path)}',
                                style: TextStyle(color: Colors.green, fontSize: 12),
                              ),
                            ],
                            if (fileError != null) ...[
                              SizedBox(height: 8),
                              Text(
                                fileError!,
                                style: TextStyle(color: Colors.red, fontSize: 12),
                              ),
                            ],
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
                                getText('קודם', 'السابق', 'Previous'),
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
                              onPressed: (selectedFile != null && fileError == null) ? () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AccountingCertificateWidget(),
                                  ),
                                );
                              } : null,
                              child: Text(
                                getText('הבא', 'التالي', 'Next'),
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
        ),
      ),
    );
  }
}
