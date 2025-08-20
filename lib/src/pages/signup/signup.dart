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
import 'DrivingLicenseWidget.dart';

class SignUpWidget extends StatefulWidget {
  @override
  _SignUpWidgetState createState() => _SignUpWidgetState();
}

class _SignUpWidgetState extends StateMVC<SignUpWidget> {
  late UserController _con;
  bool agree = false;
  Map<String, Triple<bool, File, String>> files = {};
  final TextEditingController _dateController = TextEditingController();
  late final GlobalKey<FormState> _formKey; // Add form key

  _SignUpWidgetState() : super(UserController.instance) {
    _con = UserController.instance;
    _formKey = GlobalKey<FormState>();
  }

  @override
  void dispose() {
    _dateController.dispose();
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
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black54),
            onPressed: () {
              Navigator.of(context).pushNamed('/Login');
            },
          ),
          title: Text(
            getText('הרשמה', 'التسجيل', 'Register'),
            style: TextStyle(color: Colors.black54, fontSize: 20),
          ),
        ),
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
                        getText(
                          'האם אתה מוכן להיות שותף משלוחים ב-Carry?',
                          'هل أنت مستعد لتصبح شريك توصيل مع Carry؟',
                          'Ready to become a Carry courier partner?'
                        ),
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 24
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        getText(
                          'לפני שנתחיל איתך כשותף משלוחים ב-Carry, אנחנו רק צריכים כמה פרטים ממך. מלא את הבקשה המהירה למטה, ואנחנו נתחיל לעבוד!',
                          'قبل أن نبدأ معك كشريك توصيل لدى Carry، نحتاج فقط بعض التفاصيل منك. املأ الطلب السريع أدناه، وسنبدأ الإجراءات فورًا!',
                          'Before we get you started as a Carry courier partner, we just need a few details from you. Fill out the quick application below, and we\'ll get the ball rolling!'
                        ),
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
                    key: _formKey, // Use unique key for this form
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        // First Name
                        TextFormField(
                          keyboardType: TextInputType.name,
                          onSaved: (input) {
                            print('🔍 Saving firstName: $input');
                            _con.user.firstName = input;
                          },
                          validator: (input) => input == null || input.isEmpty
                              ? getText('שם פרטי נדרש', 'الاسم الأول مطلوب', 'First name is required')
                              : null,
                          decoration: InputDecoration(
                            labelText: getText('שם פרטי (כמו בדרכון)', 'الاسم الأول (كما في جواز السفر)', 'First name (as in passport)'),
                            labelStyle: TextStyle(color: Colors.black54),
                            contentPadding: EdgeInsets.all(12),
                            hintText: getText('יוסי', 'أحمد', 'John'),
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
                          onSaved: (input) {
                            print('🔍 Saving lastName: $input');
                            _con.user.lastName = input;
                          },
                          validator: (input) => input == null || input.isEmpty
                              ? getText('שם משפחה נדרש', 'اسم العائلة مطلوب', 'Last name is required')
                              : null,
                          decoration: InputDecoration(
                            labelText: getText('שם משפחה (כמו בדרכון)', 'اسم العائلة (כמו בדרכון)', 'Last name (as in passport)'),
                            labelStyle: TextStyle(color: Colors.black54),
                            contentPadding: EdgeInsets.all(12),
                            hintText: getText('כהן', 'محمد', 'Doe'),
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
                          onSaved: (input) {
                            print('🔍 Saving email: $input');
                            _con.user.email = input;
                          },
                          validator: (input) => input == null || !input.contains('@')
                              ? getText('אנא הכנס כתובת אימייל תקינה', 'يرجى إدخال عنوان بريد إلكتروني صحيح', 'Please enter a valid email address')
                              : null,
                          decoration: InputDecoration(
                            labelText: getText('אימייל', 'البريد الإلكتروني', 'Email'),
                            labelStyle: TextStyle(color: Colors.black54),
                            contentPadding: EdgeInsets.all(12),
                            hintText: getText('yossi@gmail.com', 'ahmed@gmail.com', 'johndoe@gmail.com'),
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
                          onSaved: (input) {
                            print('🔍 Saving password: $input');
                            _con.user.password = input;
                          },
                          validator: (input) => input == null || input.length < 6
                              ? getText('סיסמה חייבת להיות לפחות 6 תווים', 'كلمة المرور يجب أن تكون 6 أحرف على الأقل', 'Password must be at least 6 characters')
                              : null,
                          decoration: InputDecoration(
                            labelText: getText('סיסמה', 'كلمة المرور', 'Password'),
                            labelStyle: TextStyle(color: Colors.black54),
                            contentPadding: EdgeInsets.all(12),
                            hintText: getText('הכנס את הסיסמה שלך', 'أدخل كلمة المرور', 'Enter your password'),
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
                          onSaved: (input) {
                            print('🔍 Saving passwordConfirmation: $input');
                            _con.user.passwordConfirmation = input;
                          },
                          validator: (input) {
                            if (input == null || input.isEmpty) {
                              return getText('אנא אשר את הסיסמה שלך', 'يرجى تأكيد كلمة المرور', 'Please confirm your password');
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: getText('אישור סיסמה', 'تأكيد كلمة المرور', 'Confirm Password'),
                            labelStyle: TextStyle(color: Colors.black54),
                            contentPadding: EdgeInsets.all(12),
                            hintText: getText('אשר את הסיסמה שלך', 'أكد كلمة المرور', 'Confirm your password'),
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
                          onSaved: (input) {
                            print('🔍 Saving phone: $input');
                            _con.user.phone = input;
                          },
                          validator: (input) => input == null || input.isEmpty
                              ? getText('מספר טלפון נדרש', 'رقم الهاتف مطلوب', 'Phone number is required')
                              : null,
                          decoration: InputDecoration(
                            labelText: getText('מספר טלפון (פורמט בינלאומי)', 'رقم الهاتف (صيغة دولية)', 'Phone number (international format)'),
                            labelStyle: TextStyle(color: Colors.black54),
                            contentPadding: EdgeInsets.all(12),
                            hintText: getText('+972 5XXXXXXXX', '+966 5XXXXXXXX', '+1 555-123-4567'),
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
                            labelText: getText('שפות מדוברות', 'اللغات المتحدثة', 'Languages spoken'),
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
                          controller: _dateController,
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: getText('תאריך לידה', 'تاريخ الميلاد', 'Date of birth'),
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
                              print('🔍 Setting dateOfBirth: ${_dateController.text}');
                              _con.user.dateOfBirth = _dateController.text;
                            }
                          },
                          validator: (input) => input == null || input.isEmpty 
                              ? getText('תאריך לידה נדרש', 'تاريخ الميلاد مطلوب', 'Date of birth is required') 
                              : null,
                        ),

                        SizedBox(height: 10),

                        // Informational Text under Date of Birth
                        Text(
                          getText(
                            'בהתאם לעיר שלך, עליך להיות מעל גיל 16 או 18 כדי לספק Carry.',
                            'حسب مدينتك، يجب أن تكون فوق 16 أو 18 عاماً لتوصيل Carry.',
                            'Depending on your city, you must be over 16 or 18 years old to deliver Carry.'
                          ),
                          style: TextStyle(color: Colors.black54, fontSize: 14),
                        ),

                        // Delivery City
                        TextFormField(
                          keyboardType: TextInputType.text,
                          onSaved: (input) {
                            print('🔍 Saving deliveryCity: $input');
                            _con.user.deliveryCity = input;
                          },
                          decoration: InputDecoration(
                            labelText: getText('עיר משלוח', 'مدينة التوصيل', 'Delivery city'),
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
                          validator: (value) => value == null || value.isEmpty 
                              ? getText('עיר משלוח נדרשת', 'مدينة التوصيل مطلوبة', 'Delivery city is required') 
                              : null,
                        ),

                        SizedBox(height: 20),

                        DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: getText('סוג רכב', 'نوع المركبة', 'Vehicle type'),
                            labelStyle: TextStyle(color: Colors.black54),
                            contentPadding: EdgeInsets.all(12),
                            prefixIcon: Icon(Icons.directions_car, color: Colors.black54),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.2)),
                            ),
                          ),
                          icon: Icon(Icons.arrow_drop_down),
                          items: [
                            DropdownMenuItem(
                              value: getText('אופנוע', 'دراجة نارية', 'Motorcycle'), 
                              child: Text(getText('אופנוע', 'دراجة نارية', 'Motorcycle'))
                            ),
                            DropdownMenuItem(
                              value: getText('אופנוע חשמלי', 'دراجة نارية كهربائية', 'Electric Motorcycle'), 
                              child: Text(getText('אופנוע חשמלי', 'دراجة نارية كهربائية', 'Electric Motorcycle'))
                            ),
                          ],
                          onChanged: (value) {
                            print('🔍 Setting vehicleType: $value');
                            setState(() {
                              _con.user.vehicleType = value!;
                            });
                          },
                          validator: (input) => input == null 
                              ? getText('אנא הזן סוג רכב', 'يرجى إدخال نوع المركبة', 'Please enter vehicle type') 
                              : null,
                        ),

                        SizedBox(height: 30),

                        // Courier partner referral code (optional)
                        TextFormField(
                          keyboardType: TextInputType.text,
                          onSaved: (input) {
                            print('🔍 Saving referralCode: $input');
                            _con.user.referralCode = input;
                          },
                          decoration: InputDecoration(
                            labelText: getText('קוד הפניה לשותף שליחים (אופציונלי)', 'رمز الإحالة لشريك التوصيل (اختياري)', 'Courier partner referral code (optional)'),
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
                                        text: getText(
                                          'אני מסכים לכך שנתוני האישיים שלי ייאספו ויטופלו בהתאם ל',
                                          'أوافق على جمع ومعالجة بياناتي الشخصية وفقاً ل',
                                          'I agree for my personal data to be collected and processed in accordance with the '
                                        ) + ' ',
                                        style: TextStyle(color: Colors.white),
                                        children: <TextSpan>[
                                          TextSpan(
                                            text: getText(
                                              'הצהרת הפרטיות של שותף המשלוחים Carry.',
                                              'بيان خصوصية شريك التوصيل Carry.',
                                              'Carry Courier Partner Privacy Statement.'
                                            ),
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
                                  SnackBar(content: Text(getText('אנא הסכם להצהרת הפרטיות', 'يرجى الموافقة على بيان الخصوصية', 'Please agree to the privacy statement'))),
                                );
                                return;
                              }

                              // Validate form
                              if (_formKey.currentState!.validate()) {
                                _formKey.currentState!.save();

                                // Clear any existing name to rebuild it properly
                                _con.user.name = null;
                                
                                // Build name from firstName and lastName
                                String fullName = '';
                                if (_con.user.firstName != null && _con.user.firstName!.isNotEmpty) {
                                  fullName += _con.user.firstName!.trim();
                                }
                                if (_con.user.lastName != null && _con.user.lastName!.isNotEmpty) {
                                  if (fullName.isNotEmpty) fullName += ' ';
                                  fullName += _con.user.lastName!.trim();
                                }
                                _con.user.name = fullName.trim();

                                // Print user data for debugging
                                print('🔍 User data after form save:');
                                print('  name: ${_con.user.name}');
                                print('  email: ${_con.user.email}');
                                print('  password: ${_con.user.password}');
                                print('  firstName: ${_con.user.firstName}');
                                print('  lastName: ${_con.user.lastName}');
                                print('  phone: ${_con.user.phone}');
                                print('  deliveryCity: ${_con.user.deliveryCity}');
                                print('  vehicleType: ${_con.user.vehicleType}');
                                print('  languagesSpoken: ${_con.user.languagesSpoken}');
                                print('  dateOfBirth: ${_con.user.dateOfBirth}');
                                print('  referralCode: ${_con.user.referralCode}');

                                // Validate password match
                                if (_con.user.password != _con.user.passwordConfirmation) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(getText('הסיסמאות אינן תואמות', 'كلمات المرور לא תואמות', 'Passwords do not match'))),
                                  );
                                  return;
                                }

                                // Navigate to the first document upload page
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DrivingLicenseWidget(),
                                  ),
                                );
                              }
                            },
                            child: Text(
                              getText('שלח בקשה', 'إرسال الطلب', 'Send Application'),
                              style: TextStyle(color: Colors.white, fontSize: 18),
                            ),
                          ),
                        ),

                        SizedBox(height: 30),
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
                    child: Text(getText('יש לי חשבון? חזרה להתחברות', 'لدي حساب؟ العودة لتسجيل الدخول', 'I have an account? Back to login')),
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
            color: Colors.blueGrey,
            shape: StadiumBorder(),
            child: Text(
              getText('העלה', 'تحميل', 'Upload'),
              style: TextStyle(color: Colors.white),
            ),
          ),
        ));
  }
}
