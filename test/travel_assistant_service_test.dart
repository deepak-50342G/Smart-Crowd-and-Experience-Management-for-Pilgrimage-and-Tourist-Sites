import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:yatra_flow/services/travel_assistant_service.dart';

void main() {
  test('defaults to a supported local development endpoint', () async {
    final service = TravelAssistantService(
      client: MockClient((request) async {
        expect([
          'localhost',
          '127.0.0.1',
          '10.0.2.2',
        ], contains(request.url.host));
        expect(request.url.port, 3000);
        expect(request.url.path, '/api/chat');
        return http.Response(jsonEncode({'reply': 'Hello'}), 200);
      }),
    );
    addTearDown(service.dispose);

    await service.reply(message: 'Hello', history: const []);
  });

  test('sends message and conversation history to the proxy', () async {
    final service = TravelAssistantService(
      endpoint: Uri.parse('http://localhost:3000/api/chat'),
      client: MockClient((request) async {
        expect(request.url.path, '/api/chat');
        expect(request.headers['content-type'], 'application/json');
        expect(jsonDecode(request.body), {
          'message': 'Suggest a route',
          'history': [
            {'role': 'user', 'text': 'I am visiting Varanasi.'},
          ],
        });
        return http.Response(
          jsonEncode({'reply': 'Try the riverside route.'}),
          200,
        );
      }),
    );
    addTearDown(service.dispose);

    final reply = await service.reply(
      message: 'Suggest a route',
      history: [
        {'role': 'user', 'text': 'I am visiting Varanasi.'},
      ],
    );

    expect(reply, 'Try the riverside route.');
  });

  test('surfaces proxy errors to the chat UI', () async {
    final service = TravelAssistantService(
      client: MockClient(
        (_) async => http.Response(
          jsonEncode({
            'error': 'Gemini quota exceeded. Check your API key and quota.',
          }),
          429,
        ),
      ),
    );
    addTearDown(service.dispose);

    await expectLater(
      service.reply(message: 'Hello', history: const []),
      throwsA(
        isA<TravelAssistantException>().having(
          (error) => error.message,
          'message',
          'Gemini quota exceeded. Check your API key and quota.',
        ),
      ),
    );
  });

  test('explains how to start the backend when the connection fails', () async {
    final service = TravelAssistantService(
      client: MockClient((_) async {
        throw http.ClientException('Connection refused');
      }),
    );
    addTearDown(service.dispose);

    await expectLater(
      service.reply(message: 'Hello', history: const []),
      throwsA(
        isA<TravelAssistantException>().having(
          (error) => error.message,
          'message',
          'The chat backend is unreachable. Start it with npm start from the backend folder.',
        ),
      ),
    );
  });
}
