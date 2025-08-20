import 'dart:io';

import 'package:deliveryboy/src/elements/BlockButtonWidget.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:path/path.dart';

import '../../generated/l10n.dart';
import '../controllers/user_controller.dart';
import '../helpers/app_config.dart' as config;
import '../models/profile_document_titles.dart';

class CompleteYourProfileWidget extends StatefulWidget {
  const CompleteYourProfileWidget({super.key});

  @override
  _CompleteYourProfileWidgetState createState() =>
      _CompleteYourProfileWidgetState();
}

class _CompleteYourProfileWidgetState
    extends StateMVC<CompleteYourProfileWidget> {
 late UserController  _con;
    late final GlobalKey<FormState> _formKey;

  _CompleteYourProfileWidgetState() : super(UserController.instance) {
    _con = UserController.instance;
    _formKey = GlobalKey<FormState>();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
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
                  S.of(context).another_step,
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
                      children: [
                        _buildDocumentFilesColumn(context),
                        SizedBox(height: 30),
                        BlockButtonWidget(
                          text: Text(
                            S.of(context).complete,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: Colors.white),
                          ),
                          color: Colors.blue,
                          onPressed: () async {
                            bool notAllUploaded = _con.files.values
                                .map((e) => e.first)
                                .toList()
                                .any((element) => !element);
                            if (_con.files.length < 5 || notAllUploaded) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: Text(
                                    "All documents are required to be uploaded!"),
                              ));
                              return;
                            }
                            Navigator.pop(context, _con.files);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
    );
  }

  Column _buildDocumentFilesColumn(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: ProfileDocumentTitles.values
            .map(
              (e) => _buildFileTextFormField(
                  context,
                  e.index,
                  e.key?? "",
                  e.title??"",
                    _con.getFile(e.key) != null ? basename(_con.getFile(e.key)!.path) : ""
                         ),
            )
            .toList());
  }

  final ImagePicker _picker = ImagePicker();
  Column _buildFileTextFormField(
      BuildContext context, int index, String key, String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        Material(
          child: InkWell(
            onTap: () async {

              final XFile? pickedFile = await _picker.pickImage(
                source: ImageSource.gallery,
              );
              //
              // FilePickerResult result = await FilePicker.platform.pickFiles(
              //   type: FileType.custom,
              //   allowedExtensions: ['jpg', 'png'],
              // );
              if (pickedFile != null) {
                _con.uploadIndexedDocument(
                    index, key, File(pickedFile.path));
              } else {
                // ignore: User canceled the picker
              }
            },
            child: TextFormField(
              keyboardType: TextInputType.text,
              enabled: false,
              decoration: InputDecoration(
                labelText: value ?? S.of(context).select_a_file,
                labelStyle: TextStyle(
                    color: config.Colors()
                        .accentColor(value != null ? 1 : 0.6)),
                contentPadding: EdgeInsets.zero,
                prefixIcon:
                    Icon(Icons.file_copy, color: Colors.blue),
                suffixIcon: _con.files[key] == null
                    ? SizedBox.shrink()
                    : (_con.files[key]?.first == true
                        ? Icon(Icons.check, color: Colors.green)
                        : Icon(Icons.refresh,
                            color: Colors.orange)),
                border: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Theme.of(context).focusColor.withOpacity(0.2))),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Theme.of(context).focusColor.withOpacity(0.5))),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Theme.of(context).focusColor.withOpacity(0.2))),
              ),
            ),
          ),
        ),
        if (index < 4) SizedBox(height: 20)
      ],
    );
  }
}
