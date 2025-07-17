import 'dart:convert';
import 'dart:io';

import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;

import '../helpers/helper.dart';
import '../models/notification.dart';
import '../models/user.dart';
import '../repository/user_repository.dart' as userRepo;

Future<Stream<Notification>> getNotifications() async {
  User user = userRepo.currentUser.value;
  if (user.apiToken == null) {
    return Stream.value(Notification());
  }
  final String apiToken = 'api_token=${user.apiToken}&';
  final String url =
      '${GlobalConfiguration().getString('api_base_url')}notifications?${apiToken}search=notifiable_id:${user.id}&searchFields=notifiable_id:=&orderBy=created_at&sortedBy=desc&limit=10';

  final client = http.Client();
  final streamedRest = await client.send(http.Request('get', Uri.parse(url)));

  return streamedRest.stream.transform(utf8.decoder).transform(json.decoder).map((data) => Helper.getData(data as Map<String,dynamic>)).expand((data) => (data as List)).map((data) {
    return Notification.fromJSON(data);
  });
}

Future<Notification> markAsReadNotifications(Notification notification) async {
  User user = userRepo.currentUser.value;
  if (user.apiToken == null) {
    return Notification();
  }
  final String apiToken = 'api_token=${user.apiToken}';
  final String url = '${GlobalConfiguration().getString('api_base_url')}notifications/${notification.id}?$apiToken';
  final client = http.Client();
  final response = await client.put(
    Uri.parse(url),
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    body: json.encode(notification.markReadMap()),
  );
  print("[${response.statusCode}] NotificationRepository markAsReadNotifications");
  return Notification.fromJSON(json.decode(response.body)['data']);
}

Future<Notification> removeNotification(Notification cart) async {
  User user = userRepo.currentUser.value;
  if (user.apiToken == null) {
    return Notification();
  }
  final String apiToken = 'api_token=${user.apiToken}';
  final String url = '${GlobalConfiguration().getString('api_base_url')}notifications/${cart.id}?$apiToken';
  final client = http.Client();
  final response = await client.delete(
    Uri.parse(url),
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
  );
  print("[${response.statusCode}] NotificationRepository removeCart");
  return Notification.fromJSON(json.decode(response.body)['data']);
}
