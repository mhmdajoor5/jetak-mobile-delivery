import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import '../../../generated/l10n.dart';
import '../../controllers/user_controller.dart';
import '../../helpers/app_config.dart' as config;
import 'BusinessLicenseWidget.dart';

class DrivingLicenseWidget extends StatefulWidget {
  const DrivingLicenseWidget({super.key});

  @override
  _DrivingLicenseWidgetState createState() => _DrivingLicenseWidgetState();
}

class _DrivingLicenseWidgetState extends StateMVC<DrivingLicenseWidget> {
  late UserController _con;
  File? selectedFile;

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
                      'رخصة قيادة',
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
                              'رخصة قيادة',
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
                                      setState(() {
                                        selectedFile = File(result.files.single.path!);
                                        _con.user.drivingLicense = result.files.single.path!;
                                      });
                                    }
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('خطأ في اختيار الملف: $e'),
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
                                              : 'اختر ملف رخصة القيادة',
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
                            onPressed: selectedFile != null ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BusinessLicenseWidget(),
                                ),
                              );
                            } : null,
                            child: Text(
                              'التالي',
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
