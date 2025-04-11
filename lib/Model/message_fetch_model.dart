// To parse this JSON data, do
//
//     final messageFetchModel = messageFetchModelFromJson(jsonString);

import 'dart:convert';

List<MessageFetchModel> messageFetchModelFromJson(String str) => List<MessageFetchModel>.from(json.decode(str).map((x) => MessageFetchModel.fromJson(x)));

String messageFetchModelToJson(List<MessageFetchModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class MessageFetchModel {
  String id;
  String msgId;
  String message;
  String messageTime;

  MessageFetchModel({
    required this.id,
    required this.msgId,
    required this.message,
    required this.messageTime,
  });

  factory MessageFetchModel.fromJson(Map<String, dynamic> json) => MessageFetchModel(
    id: json["id"],
    msgId: json["msg_id"],
    message: json["message"],
    messageTime: json["message_time"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "msg_id": msgId,
    "message": message,
    "message_time": messageTime,
  };
}
