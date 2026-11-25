import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileData {
  const ProfileData({
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.homeCity,
    required this.language,
    required this.travelStyle,
    required this.notificationsEnabled,
    required this.isProfilePublic,
    required this.emergencyContactName,
    required this.emergencyContactPhone,
    required this.userId,
    this.photoBase64,
  });

  final String fullName;
  final String email;
  final String phoneNumber;
  final String homeCity;
  final String language;
  final String travelStyle;
  final bool notificationsEnabled;
  final bool isProfilePublic;
  final String emergencyContactName;
  final String emergencyContactPhone;
  final String userId;
  final String? photoBase64;

  String get username =>
      '@${fullName.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '.')}';

  ProfileData copyWith({
    String? fullName,
    String? email,
    String? phoneNumber,
    String? homeCity,
    String? language,
    String? travelStyle,
    String? emergencyContactName,
    String? emergencyContactPhone,
    bool? notificationsEnabled,
    bool? isProfilePublic,
    String? photoBase64,
  }) {
    return ProfileData(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      homeCity: homeCity ?? this.homeCity,
      language: language ?? this.language,
      travelStyle: travelStyle ?? this.travelStyle,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      isProfilePublic: isProfilePublic ?? this.isProfilePublic,
      emergencyContactName: emergencyContactName ?? this.emergencyContactName,
      emergencyContactPhone:
          emergencyContactPhone ?? this.emergencyContactPhone,
      userId: userId,
      photoBase64: photoBase64 ?? this.photoBase64,
    );
  }

  Map<String, Object?> toJson() => {
    'fullName': fullName,
    'email': email,
    'phoneNumber': phoneNumber,
    'homeCity': homeCity,
    'language': language,
    'travelStyle': travelStyle,
    'notificationsEnabled': notificationsEnabled,
    'isProfilePublic': isProfilePublic,
    'emergencyContactName': emergencyContactName,
    'emergencyContactPhone': emergencyContactPhone,
    'userId': userId,
    'photoBase64': photoBase64,
  };

  factory ProfileData.fromJson(
    Object? source, {
    required String fallbackPhoneNumber,
  }) {
    if (source is! Map<String, dynamic>) {
      throw const FormatException('Saved profile data is invalid.');
    }

    final defaults = ProfileData.defaults(phoneNumber: fallbackPhoneNumber);
    String readString(String key, String fallback) {
      final value = source[key];
      return value is String ? value : fallback;
    }

    bool readBool(String key, bool fallback) {
      final value = source[key];
      return value is bool ? value : fallback;
    }

    final photoBase64 = source['photoBase64'];
    return ProfileData(
      fullName: readString('fullName', defaults.fullName),
      email: readString('email', defaults.email),
      phoneNumber: readString('phoneNumber', defaults.phoneNumber),
      homeCity: readString('homeCity', defaults.homeCity),
      language: readString('language', defaults.language),
      travelStyle: readString('travelStyle', defaults.travelStyle),
      notificationsEnabled: readBool(
        'notificationsEnabled',
        defaults.notificationsEnabled,
      ),
      isProfilePublic: readBool('isProfilePublic', defaults.isProfilePublic),
      emergencyContactName: readString(
        'emergencyContactName',
        defaults.emergencyContactName,
      ),
      emergencyContactPhone: readString(
        'emergencyContactPhone',
        defaults.emergencyContactPhone,
      ),
      userId: readString('userId', defaults.userId),
      photoBase64: photoBase64 is String ? photoBase64 : null,
    );
  }

  factory ProfileData.defaults({required String phoneNumber}) {
    return ProfileData(
      fullName: 'Aarav Sharma',
      email: 'aarav.sharma@example.com',
      phoneNumber: phoneNumber,
      homeCity: 'New Delhi, India',
      language: 'English, Hindi',
      travelStyle: 'Culture & Nature',
      notificationsEnabled: true,
      isProfilePublic: true,
      emergencyContactName: 'Priya Sharma',
      emergencyContactPhone: '+91 98765 43211',
      userId: 'YF102849',
    );
  }
}

class ProfilePersistenceException implements Exception {
  const ProfilePersistenceException();
}

class ProfileStorage {
  static const _key = 'yatra_flow.profile.v1';

  static Future<ProfileData> load({required String fallbackPhoneNumber}) async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final savedProfile = preferences.getString(_key);
      if (savedProfile == null) {
        return ProfileData.defaults(phoneNumber: fallbackPhoneNumber);
      }

      return ProfileData.fromJson(
        jsonDecode(savedProfile),
        fallbackPhoneNumber: fallbackPhoneNumber,
      );
    } on PlatformException {
      throw const ProfilePersistenceException();
    } on MissingPluginException {
      throw const ProfilePersistenceException();
    }
  }

  static Future<void> save(ProfileData profile) async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final saved = await preferences.setString(
        _key,
        jsonEncode(profile.toJson()),
      );
      if (!saved) throw const ProfilePersistenceException();
    } on PlatformException {
      throw const ProfilePersistenceException();
    } on MissingPluginException {
      throw const ProfilePersistenceException();
    }
  }
}
