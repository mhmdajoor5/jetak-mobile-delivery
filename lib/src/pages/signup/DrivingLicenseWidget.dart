import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import '../../controllers/user_controller.dart';
import '../../helpers/validation_helper.dart';
import 'BusinessLicenseWidget.dart';

class DrivingLicenseWidget extends StatefulWidget {
  const DrivingLicenseWidget({super.key});

  @override
  _DrivingLicenseWidgetState createState() => _DrivingLicenseWidgetState();
}

class _DrivingLicenseWidgetState extends StateMVC<DrivingLicenseWidget> {
  late UserController _con;
  File? selectedFile;
  String? fileError;

  _DrivingLicenseWidgetState() : super(UserController.instance) {
    _con = UserController.instance;
    
    // Print user data for debugging
    print('🔍 DrivingLicenseWidget - User data:');
    print('  name: ${_con.user.name}');
    print('  email: ${_con.user.email}');
    print('  firstName: ${_con.user.firstName}');
    print('  lastName: ${_con.user.lastName}');
    print('  phone: ${_con.user.phone}');
    print('  deliveryCity: ${_con.user.deliveryCity}');
    print('  vehicleType: ${_con.user.vehicleType}');
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
                      getText('רישיון נהיגה', 'رخصة قيادة', 'Driving License'),
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
                              getText('רישיון נהיגה', 'رخصة قيادة', 'Driving License'),
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

                                      // Validate file
                                      String? error = ValidationHelper.validateFile(filePath);

                                      setState(() {
                                        if (error == null) {
                                          selectedFile = File(filePath);
                                          _con.user.drivingLicense = filePath;
                                          fileError = null;
                                        } else {
                                          selectedFile = null;
                                          _con.user.drivingLicense = null;
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
                                              : getText('בחר קובץ רישיון נהיגה', 'اختر ملف رخصة القيادة', 'Choose driving license file'),
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
                            // Display file info or error
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
                        
                        // Next Button
                        Center(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: (selectedFile != null && fileError == null) ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BusinessLicenseWidget(),
                                ),
                              );
                            } : null,
                            child: Text(
                              getText('הבא', 'التالي', 'Next'),
                              style: TextStyle(color: Colors.white, fontSize: 18),
                            ),
                          ),
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
