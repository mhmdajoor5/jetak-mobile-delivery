import '../helpers/custom_trace.dart';

class Faq {
  String? id;
  String? question;
  String? answer;

  Faq();

  Faq.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      id = jsonMap['id'].toString();
      question = jsonMap['question'] ?? '';
      answer = jsonMap['answer'] ?? '';
    } catch (e) {
      id = '';
      question = '';
      answer = '';
      print(CustomTrace(StackTrace.current, message: e.toString()));
    }
  }
}
