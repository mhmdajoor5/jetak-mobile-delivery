import 'package:flutter/material.dart';

import '../../generated/l10n.dart';
import '../models/user.dart';

class ProfileSettingsDialog extends StatefulWidget {
  final User user;
  final VoidCallback onChanged;

  const ProfileSettingsDialog({super. key,required this.user,required this.onChanged}) ;

  @override
  _ProfileSettingsDialogState createState() => _ProfileSettingsDialogState();
}

class _ProfileSettingsDialogState extends State<ProfileSettingsDialog> {
  final GlobalKey<FormState> _profileSettingsFormKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      elevation: 0,
      focusElevation: 0,
      highlightElevation: 0,
      onPressed: () {
        showDialog(
            context: context,
            builder: (context) {
              return SimpleDialog(
                contentPadding: EdgeInsets.symmetric(horizontal: 20),
                titlePadding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                title: Row(
                  children: <Widget>[
                    Icon(Icons.person),
                    SizedBox(width: 10),
                    Text(
                      S.of(context).profile_settings,
                      style: Theme.of(context).textTheme.bodyMedium,
                    )
                  ],
                ),
                children: <Widget>[
                  Form(
                    key: _profileSettingsFormKey,
                    child: Column(
                      children: <Widget>[
                        TextFormField(
                          style: TextStyle(color: Theme.of(context).hintColor),
                          keyboardType: TextInputType.text,
                          decoration: getInputDecoration(hintText: S.of(context).john_doe, labelText: S.of(context).full_name),
                          initialValue: widget.user.name,
                          validator: (input) => input!.trim().length < 3 ? S.of(context).not_a_valid_full_name : null,
                          onSaved: (input) => widget.user.name = input,
                        ),
                        TextFormField(
                          style: TextStyle(color: Theme.of(context).hintColor),
                          keyboardType: TextInputType.emailAddress,
                          decoration: getInputDecoration(hintText: 'johndo@gmail.com', labelText: S.of(context).email_address),
                          initialValue: widget.user.email,
                          validator: (input) => !input!.contains('@') ? S.of(context).not_a_valid_email : null,
                          onSaved: (input) => widget.user.email = input,
                        ),
                        TextFormField(
                          style: TextStyle(color: Theme.of(context).hintColor),
                          keyboardType: TextInputType.text,
                          decoration: getInputDecoration(hintText: '+136 269 9765', labelText: S.of(context).phone),
                          initialValue: widget.user.phone,
                          validator: (input) => input!.trim().length < 3 ? S.of(context).not_a_valid_phone : null,
                          onSaved: (input) => widget.user.phone = input,
                        ),
                        TextFormField(
                          style: TextStyle(color: Theme.of(context).hintColor),
                          keyboardType: TextInputType.text,
                          decoration: getInputDecoration(hintText: S.of(context).your_address, labelText: S.of(context).address),
                          initialValue: widget.user.address,
                          validator: (input) => input!.trim().length < 3 ? S.of(context).not_a_valid_address : null,
                          onSaved: (input) => widget.user.address = input,
                        ),
                        TextFormField(
                          style: TextStyle(color: Theme.of(context).hintColor),
                          keyboardType: TextInputType.text,
                          decoration: getInputDecoration(hintText: S.of(context).your_biography, labelText: S.of(context).about),
                          initialValue: widget.user.bio,
                          validator: (input) => input!.trim().length < 3 ? S.of(context).not_a_valid_biography : null,
                          onSaved: (input) => widget.user.bio = input,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      MaterialButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(S.of(context).cancel),
                      ),
                      MaterialButton(
                        onPressed: _submit,
                        child: Text(
                          S.of(context).save,
                          style: TextStyle(color: Theme.of(context).cardColor),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                ],
              );
            });
      },
      child: Text(
        S.of(context).edit,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }

  InputDecoration getInputDecoration({required String hintText,required String labelText}) {
    return InputDecoration(
      hintText: hintText,
      labelText: labelText,
      hintStyle:
            TextStyle(color: Theme.of(context).focusColor),

      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).hintColor.withOpacity(0.2))),
      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).hintColor)),
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      labelStyle:
            TextStyle(color: Theme.of(context).hintColor),

    );
  }

  void _submit() {
    if (_profileSettingsFormKey.currentState!.validate()) {
      _profileSettingsFormKey.currentState!.save();
      widget.onChanged();
      Navigator.pop(context);
    }
  }
}
