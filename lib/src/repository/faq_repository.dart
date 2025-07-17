import 'dart:convert';

import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;

import '../helpers/helper.dart';
import '../models/faq_category.dart';
import '../models/user.dart';
import '../repository/user_repository.dart';

Future<Stream<FaqCategory>> getFaqCategories() async {
  User user = currentUser.value;
  final String apiToken = 'api_token=${user.apiToken}&';
  final String url = '${GlobalConfiguration().getString('api_base_url')}faq_categories?${apiToken}with=faqs';

  final client = http.Client();
  final streamedRest = await client.send(http.Request('get', Uri.parse(url)));

  return streamedRest.stream.transform(utf8.decoder).transform(json.decoder).map((data) => Helper.getData(data as Map<String,dynamic>)).expand((data) => (data as List)).map((data) {
    return FaqCategory.fromJSON(data);
  });
}
