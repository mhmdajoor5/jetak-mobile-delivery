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

  _CompleteYourProfileWidgetState() : super(UserController()) {
    _con = (controller as UserController?)!;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      key: _con.scaffoldKey,
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: SizedBox(
          height: config.App(context).appHeight(110),
          child: Stack(
            alignment: AlignmentDirectional.topCenter,
            children: <Widget>[
              Positioned(
                top: 0,
                child: Container(
                  width: config.App(context).appWidth(100),
                  height: config.App(context).appHeight(29.5),
                  decoration:
                      BoxDecoration(color: Colors.amberAccent),
                ),
              ),
              Positioned(
                top: config.App(context).appHeight(29.5) - 140,
                child: SizedBox(
                  width: config.App(context).appWidth(84),
                  height: config.App(context).appHeight(29.5),
                  child: Text(
                    S.of(context).another_step,
                    style: TextStyle(color: Colors.black54)),
                ),
              ),
              Positioned(
                top: config.App(context).appHeight(29.5) - 50,
                child: Container(
                  height: size.height * 0.80,
                  decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 50,
                          color: Theme.of(context).hintColor.withOpacity(0.2),
                        )
                      ]),
                  margin: EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
                  padding: EdgeInsets.symmetric(vertical: 40, horizontal: 27),
                  width: config.App(context).appWidth(88),
                  child: Form(
                    key: _con.loginFormKey,
                    child: Column(
                      children: [
                        Expanded(
                          child: _buildDocumentFilesColumn(context),
                        ),
                        SizedBox(height: 30),
                        BlockButtonWidget(
                          text: Text(
                            S.of(context).complete,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: Colors.black54),
                          ),
                          color: Colors.black54,
                          onPressed: () async {
                            bool notAllUploaded = _con.files.values
                                .map((e) => e.first)
                                .toList()
                                .any((element) => !element);
                            if (_con.files.length < 5 || notAllUploaded) {
                              ScaffoldMessenger.of(
                                      _con.scaffoldKey.currentContext!)
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
                    basename(_con.getFile(e.key)!.path)
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
        Text(title),
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
                    Icon(Icons.file_copy, color: Colors.black54),
                suffixIcon: _con.files[key] == null
                    ? SizedBox.shrink()
                    : (_con.files[key]!.first
                        ? Icon(Icons.check, color: Colors.green)
                        : Icon(Icons.refresh,
                            color: Colors.black54)),
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
        if (index < 4) SizedBox(height: 30)
      ],
    );
  }
}
