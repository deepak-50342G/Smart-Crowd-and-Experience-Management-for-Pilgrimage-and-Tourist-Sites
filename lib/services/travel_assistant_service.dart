import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class TravelAssistantService {
  TravelAssistantService({http.Client? client, Uri? endpoint})
    : _client = client ?? http.Client(),
      _endpoint = endpoint ?? Uri.parse(_configuredEndpoint);

  static const _customEndpoint = String.fromEnvironment('CHAT_API_URL');
  static final _configuredEndpoint = _customEndpoint.isNotEmpty
      ? _customEndpoint
      : kIsWeb
      ? 'http://localhost:3000/api/chat'
      : defaultTargetPlatform == TargetPlatform.android
      ? 'http://10.0.2.2:3000/api/chat'
      : 'http://127.0.0.1:3000/api/chat';

  final http.Client _client;
  final Uri _endpoint;

  Future<String> reply({
    required String message,
    required List<Map<String, String>> history,
  }) async {
    late final http.Response response;
    try {
      response = await _client
          .post(
            _endpoint,
            headers: const {'content-type': 'application/json'},
            body: jsonEncode({'message': message, 'history': history}),
          )
          .timeout(const Duration(seconds: 35));
    } on TimeoutException {
      throw const TravelAssistantException('The reply timed out.');
    } on http.ClientException {
      throw const TravelAssistantException(
        'The chat backend is unreachable. Start it with npm start from the backend folder.',
      );
    }

    dynamic payload;
    try {
      payload = jsonDecode(response.body);
    } on FormatException {
      throw const TravelAssistantException(
        'The Gemini proxy returned an invalid response.',
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final error = payload is Map<String, dynamic> ? payload['error'] : null;
      throw TravelAssistantException(
        error is String ? error : 'Gemini request failed.',
      );
    }

    final reply = payload is Map<String, dynamic> ? payload['reply'] : null;
    if (reply is! String || reply.trim().isEmpty) {
      throw const TravelAssistantException(
        'Gemini returned an empty response.',
      );
    }
    return reply.trim();
  }

  void dispose() => _client.close();
}

class TravelAssistantException implements Exception {
  const TravelAssistantException(this.message);

  final String message;
}
