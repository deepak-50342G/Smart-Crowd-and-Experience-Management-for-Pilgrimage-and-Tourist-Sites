import assert from 'node:assert/strict';
import { afterEach, test } from 'node:test';

import { createApp } from './server.js';
import { createGeminiService } from './services/geminiService.js';

const servers = new Set();

async function startServer(options) {
  const app = createApp(options);
  const server = app.listen(0, '127.0.0.1');
  servers.add(server);
  await new Promise((resolve, reject) => {
    server.once('listening', resolve);
    server.once('error', reject);
  });
  return `http://127.0.0.1:${server.address().port}`;
}

afterEach(async () => {
  await Promise.all(
    [...servers].map(
      (server) =>
        new Promise((resolve, reject) => {
          server.close((error) => (error ? reject(error) : resolve()));
          server.closeAllConnections();
        }),
    ),
  );
  servers.clear();
});

test('GET / reports that the backend is healthy', async () => {
  const baseUrl = await startServer({ generateReply: async () => 'unused' });

  const response = await fetch(`${baseUrl}/`);

  assert.equal(response.status, 200);
  const body = await response.json();
  assert.equal(body.ok, true);
  assert.equal(body.status, 'ok');
  assert.equal(body.message, 'YatraFlow Gemini Backend Started');
  assert.ok(body.port > 0);
});

test('POST /api/chat returns a reply and passes conversation history', async () => {
  let received;
  const baseUrl = await startServer({
    generateReply: async (request) => {
      received = request;
      return 'Try the riverside route.';
    },
  });

  const response = await fetch(`${baseUrl}/api/chat`, {
    method: 'POST',
    headers: {
      origin: 'http://localhost:5300',
      'content-type': 'application/json',
    },
    body: JSON.stringify({
      message: ' Suggest a route ',
      history: [
        { role: 'user', text: 'I am visiting Varanasi.' },
        { role: 'assistant', text: 'What kind of route do you prefer?' },
      ],
    }),
  });

  assert.equal(response.status, 200);
  assert.equal(
    response.headers.get('access-control-allow-origin'),
    'http://localhost:5300',
  );
  assert.deepEqual(await response.json(), { reply: 'Try the riverside route.' });
  assert.deepEqual(received, {
    message: 'Suggest a route',
    history: [
      { role: 'user', text: 'I am visiting Varanasi.' },
      { role: 'assistant', text: 'What kind of route do you prefer?' },
    ],
  });
});

test('rejects invalid chat input before calling Gemini', async () => {
  let serviceCalled = false;
  const baseUrl = await startServer({
    generateReply: async () => {
      serviceCalled = true;
      return 'unexpected';
    },
  });

  const response = await fetch(`${baseUrl}/api/chat`, {
    method: 'POST',
    headers: { 'content-type': 'application/json' },
    body: JSON.stringify({ message: '  ' }),
  });

  assert.equal(response.status, 400);
  assert.equal(serviceCalled, false);
});

test('rejects requests from non-local browser origins', async () => {
  const baseUrl = await startServer({ generateReply: async () => 'unused' });

  const response = await fetch(`${baseUrl}/api/chat`, {
    method: 'POST',
    headers: {
      origin: 'https://example.com',
      'content-type': 'application/json',
    },
    body: JSON.stringify({ message: 'Hello' }),
  });

  assert.equal(response.status, 403);
  assert.deepEqual(await response.json(), { error: 'Origin is not allowed.' });
});

test('uses the official GenAI SDK with model and mapped history', async () => {
  let request;
  const client = {
    models: {
      generateContent: async (options) => {
        request = options;
        return { text: 'A generated reply' };
      },
    },
  };
  const generateReply = createGeminiService({
    apiKey: 'test-only-key',
    model: 'gemini-3.5-flash-lite',
    client,
  });

  const reply = await generateReply({
    message: 'Suggest a route',
    history: [
      { role: 'user', text: 'I am visiting Varanasi.' },
      { role: 'assistant', text: 'What kind of route do you prefer?' },
    ],
  });

  assert.equal(reply, 'A generated reply');
  assert.equal(request.model, 'gemini-3.5-flash-lite');
  assert.deepEqual(request.contents, [
    { role: 'user', parts: [{ text: 'I am visiting Varanasi.' }] },
    { role: 'model', parts: [{ text: 'What kind of route do you prefer?' }] },
    { role: 'user', parts: [{ text: 'Suggest a route' }] },
  ]);
  assert.equal(typeof request.config.systemInstruction, 'string');
});
