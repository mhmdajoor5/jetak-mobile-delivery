import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import '../../controllers/user_controller.dart';
import 'AccountManagementCertificateWidget.dart';

class BankAccountDetailsWidget extends StatefulWidget {
  const BankAccountDetailsWidget({super.key});

  @override
  _BankAccountDetailsWidgetState createState() => _BankAccountDetailsWidgetState();
}

class _BankAccountDetailsWidgetState extends StateMVC<BankAccountDetailsWidget> {
  late UserController _con;
  File? selectedFile;
  final _formKey = GlobalKey<FormState>();
  final _bankNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _branchNumberController = TextEditingController();

  _BankAccountDetailsWidgetState() : super(UserController.instance) {
    _con = UserController.instance;
  }

  @override
  void dispose() {
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _branchNumberController.dispose();
    super.dispose();
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
                      getText('פרטי חשבון בנק', 'تفاصيل الحساب البنكي', 'Bank Account Details'),
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
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Bank Name
                          TextFormField(
                            controller: _bankNameController,
                            onSaved: (input) => _con.user.bankName = input,
                            validator: (input) => input == null || input.isEmpty
                                ? getText('שם הבנק נדרש', 'اسم البنك مطلوب', 'Bank name is required')
                                : null,
                            decoration: InputDecoration(
                              labelText: getText('בנק', 'البنك', 'Bank'),
                              labelStyle: TextStyle(color: Colors.black54),
                              contentPadding: EdgeInsets.all(12),
                              prefixIcon: Icon(Icons.account_balance, color: Colors.black54),
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
                          
                          // Account Number
                          TextFormField(
                            controller: _accountNumberController,
                            onSaved: (input) => _con.user.accountNumber = input,
                            validator: (input) => input == null || input.isEmpty
                                ? getText('מספר חשבון נדרש', 'رقم الحساب مطلوب', 'Account number is required')
                                : null,
                            decoration: InputDecoration(
                              labelText: getText('מספר חשבון', 'رقم الحساب', 'Account Number'),
                              labelStyle: TextStyle(color: Colors.black54),
                              contentPadding: EdgeInsets.all(12),
                              prefixIcon: Icon(Icons.account_circle, color: Colors.black54),
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
                          
                          // Branch Number
                          TextFormField(
                            controller: _branchNumberController,
                            onSaved: (input) => _con.user.branchNumber = input,
                            validator: (input) => input == null || input.isEmpty
                                ? getText('מספר סניף נדרש', 'رقم الفرع مطلوب', 'Branch number is required')
                                : null,
                            decoration: InputDecoration(
                              labelText: getText('מספר סניף', 'رقم الفرع', 'Branch Number'),
                              labelStyle: TextStyle(color: Colors.black54),
                              contentPadding: EdgeInsets.all(12),
                              prefixIcon: Icon(Icons.location_on, color: Colors.black54),
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
                          
                          SizedBox(height: 30),
                          
                          // Document upload section
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                getText('פרטי חשבון בנק', 'تفاصيل الحساب البنكي', 'Bank Account Details'),
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
                                          _con.user.bankAccountDetails = result.files.single.path!;
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
                                                : getText('בחר קובץ פרטי חשבון בנק', 'اختر ملف تفاصيل الحساب البنكي', 'Choose bank account details file'),
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
                                  getText('קודם', 'السابق', 'Previous'),
                                  style: TextStyle(color: Colors.white, fontSize: 16),
                                ),
                              ),
                              
                              // Submit Button
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: (selectedFile != null && _formKey.currentState!.validate()) ? () async {
                                  _formKey.currentState!.save();
                                  await _con.register();
                                } : null,
                                child: Text(
                                  getText('שלח בקשה', 'إرسال الطلب', 'Send Application'),
                                  style: TextStyle(color: Colors.white, fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
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
