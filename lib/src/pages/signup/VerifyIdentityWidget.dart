import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import '../../../generated/l10n.dart';
import 'package:country_picker/country_picker.dart';
import '../../controllers/user_controller.dart';
import 'CompleteverifyIdentityWidget.dart';

class VerifyIdentityWidget extends StatefulWidget {
  const VerifyIdentityWidget({super.key});

  @override
  _VerifyIdentityWidgetState createState() =>
      _VerifyIdentityWidgetState();
}

class _VerifyIdentityWidgetState extends StateMVC<VerifyIdentityWidget> {
  _VerifyIdentityWidgetState() : super(UserController());

  bool agree = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Verify your identity",
              style: TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Rest assured your data is handled in a secure manner during the verification process",
              style: TextStyle(
                color: Colors.black,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListTile(
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: () {
                  showCountryPicker(
                    context: context,
                    showPhoneCode: false,
                    onSelect: (Country country) {
                      print(
                          'Selected country: ${country.name}, flag: ${country.flagEmoji}');
                    },
                  );
                },
              ),
            ),
            Spacer(),
            // Checkbox
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: agree,
                  onChanged: (value) {
                    setState(() {
                      agree = value ?? false;
                    });
                  },
                  activeColor: Colors.blue[900],
                ),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      text:
                      'I agree for my personal data to be collected and processed in accordance with the ',
                      style: TextStyle(color: Colors.black),
                      children: <TextSpan>[
                        TextSpan(
                          text: 'Carry Courier Partner Privacy Statement.',
                          style: TextStyle(color: Colors.blue[900]),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: agree
                    ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CompleteVerifyIdentityWidget(),
                    ),
                  );
                }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  "Send Verification",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
