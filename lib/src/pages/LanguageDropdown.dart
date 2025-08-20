import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../../generated/l10n.dart';

class Language {
  final String code;
  final String name;
  Language({required this.code, required this.name});
  factory Language.fromJson(Map<String, dynamic> json) {
    return Language(code: json['code'], name: json['name']);
  }
}

class LanguageDropdown extends StatefulWidget {
  final Function(String) onChanged;
  final String? selectedCode;
  final InputDecoration? decoration;

  const LanguageDropdown({Key? key, required this.onChanged, this.selectedCode,this.decoration,}) : super(key: key);

  @override
  _LanguageDropdownState createState() => _LanguageDropdownState();
}

class _LanguageDropdownState extends State<LanguageDropdown> {
  List<Language> _languages = [];
  String? _selectedCode;

  @override
  void initState() {
    super.initState();
    _selectedCode = widget.selectedCode;
    _loadLanguages();
  }

  Future<void> _loadLanguages() async {
    final String jsonString = await rootBundle.loadString('assets/langs.json');
    final List<dynamic> jsonResponse = json.decode(jsonString);
    setState(() {
      _languages = jsonResponse.map((e) => Language.fromJson(e)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      decoration: widget.decoration ??
          InputDecoration(
            labelText: S.of(context).languages_spoken_label,
            labelStyle: TextStyle(color: Colors.black54),
            contentPadding: EdgeInsets.all(12),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.2)),
            ),
          ),
      icon: Icon(Icons.arrow_drop_down),
      items: _languages
          .map((lang) => DropdownMenuItem<String>(
        value: lang.code,
        child: Text(lang.name),
      ))
          .toList(),
      value: _selectedCode,
      onChanged: (value) {
        setState(() {
          _selectedCode = value;
        });
        if (value != null) {
          widget.onChanged(value);
        }
      },
      validator: (value) => value == null ? S.of(context).please_specify_languages : null,
    );
  }
}
