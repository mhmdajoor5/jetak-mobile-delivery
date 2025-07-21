import '../helpers/custom_trace.dart';

class ExtraGroup {
  String? id;
  String? name;

  ExtraGroup();

  ExtraGroup.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      id = jsonMap['id'].toString();
      name = jsonMap['name'];
    } catch (e) {
      id = '';
      name = '';
      print(CustomTrace(StackTrace.current, message: e.toString()));
    }
  }

  Map toMap() {
    var map = <String, dynamic>{};
    map["id"] = id;
    map["name"] = name;
    return map;
  }

  @override
  String toString() {
    return toMap().toString();
  }

  @override
  bool operator ==(dynamic other) {
    return other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
