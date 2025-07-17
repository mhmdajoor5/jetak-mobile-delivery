// To parse this JSON data, do
//
//     final welcome = welcomeFromJson(jsonString);

import 'dart:io';


class Document {
  final String? uuid;
  final File? file;
  final String? field;

  Document({
    this.uuid,
    this.file,
    this.field,
  });

  factory Document.fromJson(Map<String, dynamic> json) => Document(
        uuid: json["uuid"],
        file: json["file"],
        field: json["field"],
      );

  Map<String, dynamic> toJson() => {
        "uuid": uuid,
        "file": file,
        "field": field,
      };
}
