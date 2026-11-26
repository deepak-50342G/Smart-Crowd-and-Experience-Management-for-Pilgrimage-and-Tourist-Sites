import cors from 'cors';
import dotenv from 'dotenv';
import express from 'express';
import { rateLimit } from 'express-rate-limit';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

import { createChatRouter } from './routes/chatRoutes.js';
import { createGeminiService } from './services/geminiService.js';

const backendDirectory = dirname(fileURLToPath(import.meta.url));
dotenv.config({ path: resolve(backendDirectory, '.env') });

function isLocalDevelopmentOrigin(origin) {
  let url;
  try {
    url = new URL(origin);
  } catch {
    return false;
  }
  if (url.protocol !== 'http:') return false;

  const hostname = url.hostname.replace(/^\[|\]$/g, '').toLowerCase();
  if (
    hostname === 'localhost' ||
    hostname === '::1' ||
    hostname === '10.0.2.2'
  ) {
    return true;
  }

  const octets = hostname.split('.').map(Number);
  if (
    octets.length !== 4 ||
    octets.some((octet) => !Number.isInteger(octet) || octet < 0 || octet > 255)
  ) {
    return false;
  }

  return (
    octets[0] === 127 ||
    octets[0] === 10 ||
    (octets[0] === 192 && octets[1] === 168) ||
    (octets[0] === 172 && octets[1] >= 16 && octets[1] <= 31)
  );
}

function healthResponse(request, response) {
  response.json({
    ok: true,
    status: 'ok',
    message: 'YatraFlow Gemini Backend Started',
    port: request.socket.localPort,
  });
}

export function createApp({ generateReply } = {}) {
  if (typeof generateReply !== 'function') {
    throw new TypeError('A Gemini reply service must be provided.');
  }

  const app = express();

  app.use((request, response, next) => {
    const origin = request.get('origin');
    if (origin && !isLocalDevelopmentOrigin(origin)) {
      response.status(403).json({ error: 'Origin is not allowed.' });
      return;
    }
    next();
  });
  app.use(
    cors({
      origin: (origin, callback) =>
        callback(null, !origin || isLocalDevelopmentOrigin(origin)),
      methods: ['GET', 'POST', 'OPTIONS'],
      allowedHeaders: ['Content-Type'],
    }),
  );
  app.use(express.json({ limit: '32kb' }));

  app.get('/', healthResponse);
  app.get('/health', healthResponse);

  const chatRateLimit = rateLimit({
    windowMs: 15 * 60 * 1000,
    limit: 30,
    standardHeaders: true,
    legacyHeaders: false,
    message: { error: 'Too many chat requests. Please try again later.' },
  });
  app.use('/api/chat', chatRateLimit, createChatRouter({ generateReply }));

  app.use((_request, response) => {
    response.status(404).json({ error: 'Endpoint not found.' });
  });

  app.use((error, _request, response, _next) => {
    if (response.headersSent) return;

    if (error.type === 'entity.too.large') {
      response.status(413).json({ error: 'Request body is too large.' });
      return;
    }
    if (error instanceof SyntaxError && 'body' in error) {
      response.status(400).json({ error: 'Request body must be valid JSON.' });
      return;
    }

    const status = Number(error.status);
    if (status === 429) {
      response.status(429).json({
        error: 'Gemini quota exceeded. Check your API plan and try again later.',
      });
      return;
    }
    if (status === 401 || status === 403) {
      response.status(502).json({
        error: 'Gemini authentication failed. Check GEMINI_API_KEY.',
      });
      return;
    }
    if (status === 400 || status === 404) {
      response.status(502).json({
        error: 'Gemini rejected the request. Check GEMINI_MODEL and the request configuration.',
      });
      return;
    }

    console.error(`Request failed (${error.code ?? 'internal_error'}).`);
    response.status(502).json({
      error: 'Gemini request failed. Check backend configuration and try again.',
    });
  });

  return app;
}

function validateConfiguration() {
  const apiKey = process.env.GEMINI_API_KEY?.trim();
  if (!apiKey || /^(YOUR_|REPLACE_|<)/i.test(apiKey)) {
    throw new Error(
      'GEMINI_API_KEY is missing or still a placeholder. Set it in backend/.env.',
    );
  }

  const model = process.env.GEMINI_MODEL?.trim() || 'gemini-3.5-flash-lite';
  if (!/^[a-zA-Z0-9._-]+$/.test(model)) {
    throw new Error('GEMINI_MODEL contains unsupported characters.');
  }

  const port = Number(process.env.PORT ?? 3000);
  if (!Number.isInteger(port) || port < 1 || port > 65535) {
    throw new Error('PORT must be an integer between 1 and 65535.');
  }

  return { apiKey, model, port, host: process.env.HOST || '0.0.0.0' };
}

async function startServer() {
  const config = validateConfiguration();
  const generateReply = createGeminiService(config);
  const app = createApp({ generateReply });
  const server = app.listen(config.port, config.host, () => {
    console.log('YatraFlow Gemini Backend Started');
    console.log(`Server running on port ${config.port}`);
  });

  server.on('error', (error) => {
    if (error.code === 'EADDRINUSE') {
      console.error(`Port ${config.port} is already in use.`);
    } else {
      console.error(`Backend failed to start (${error.code ?? 'server_error'}).`);
    }
    process.exitCode = 1;
  });
}

if (
  process.argv[1] &&
  resolve(fileURLToPath(import.meta.url)) === resolve(process.argv[1])
) {
  try {
    await startServer();
  } catch (error) {
    console.error(error.message);
    process.exitCode = 1;
  }
}
