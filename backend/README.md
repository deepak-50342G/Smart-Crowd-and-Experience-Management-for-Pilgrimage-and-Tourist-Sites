# YatraFlow Gemini Backend

The backend uses Express and Google's official `@google/genai` SDK. Its API key
is loaded from this folder's `.env`; it is never included in Flutter source.

## Configure and run (Windows PowerShell)

1. Open `backend\.env` and replace only `YOUR_NEW_API_KEY` with a newly
   generated Gemini API key. Do not commit or share the `.env` file.
2. From the backend directory, install dependencies and start the server:

```powershell
cd "C:\Team-9 app\YATRA-FLOW\backend"
npm install
npm start
```

The server listens on port `3000` and prints:

```text
YatraFlow Gemini Backend Started
Server running on port 3000
```

`GET /` and `GET /health` return a health response. `POST /api/chat` accepts a
message and optional conversation history. The default model is
`gemini-3.5-flash-lite`; it is listed as a stable model in Google's model docs.
You can change `GEMINI_MODEL` in `.env`.

## Flutter development URLs

- Chrome: `http://localhost:3000/api/chat`
- Android emulator: `http://10.0.2.2:3000/api/chat`
- Physical Android: pass your computer's LAN address, for example
  `--dart-define=CHAT_API_URL=http://192.168.1.25:3000/api/chat`

The server binds to all network interfaces for emulator/device access. Use it
only on a trusted development network and allow Node.js through Windows
Firewall only if your device needs to connect.

## Tests

```powershell
npm test
```

The backend tests use a mock Gemini client and do not require a key or make
external API requests.
