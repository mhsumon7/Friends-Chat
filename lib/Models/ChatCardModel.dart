import 'package:flutter/material.dart';

class ChatCardModel {
  String? name;
  String? currentMessage;
  String? time;
  String? profilePic;
  bool? isGroup;
  String? uid;
  String? status;

  ChatCardModel({
    required this.uid,
    required this.profilePic,
    required this.name,
    this.currentMessage,
    this.time,
    required this.isGroup,
    this.status,
  });
}
