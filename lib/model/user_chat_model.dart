// To parse this JSON data, do
//
//     final userChat = userChatFromJson(jsonString);

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_chat_messenger/constants/firestore_constants.dart';

UserChat userChatFromJson(String str) =>
    UserChat.fromDocument(json.decode(str));

String userChatToJson(UserChat data) => json.encode(data.toJson());

class UserChat {
  final String id;
  final String photoUrl;
  final String displayName;
  final String phoneNumber;
  final String aboutMe;

  UserChat({
    required this.id,
    required this.photoUrl,
    required this.displayName,
    required this.phoneNumber,
    required this.aboutMe,
  });

  UserChat copyWith({
    String? id,
    String? photoUrl,
    String? displayName,
    String? phoneNumber,
    String? aboutMe,
  }) =>
      UserChat(
        id: id ?? this.id,
        photoUrl: photoUrl ?? this.photoUrl,
        displayName: displayName ?? this.displayName,
        phoneNumber: phoneNumber ?? this.phoneNumber,
        aboutMe: aboutMe ?? this.aboutMe,
      );

  factory UserChat.fromDocument(DocumentSnapshot snapshot) {
    String photoUrl = "";
    String nickname = "";
    String phoneNumber = "";
    String aboutMe = "";

    try {
      photoUrl = snapshot.get(FireStoreConstants.photoUrl);
      nickname = snapshot.get(FireStoreConstants.displayName);
      phoneNumber = snapshot.get(FireStoreConstants.phoneNumber);
      aboutMe = snapshot.get(FireStoreConstants.aboutMe);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    return UserChat(
        id: snapshot.id,
        photoUrl: photoUrl,
        displayName: nickname,
        phoneNumber: phoneNumber,
        aboutMe: aboutMe);
  }

  Map<String, dynamic> toJson() => {
        FireStoreConstants.displayName: displayName,
        FireStoreConstants.photoUrl: photoUrl,
        FireStoreConstants.phoneNumber: phoneNumber,
        FireStoreConstants.aboutMe: aboutMe,
      };
}
