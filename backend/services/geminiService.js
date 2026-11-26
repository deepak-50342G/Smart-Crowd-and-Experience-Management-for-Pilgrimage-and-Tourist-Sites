import { GoogleGenAI } from '@google/genai';

const systemInstruction =
  'You are YatraFlow travel assistant. Help travelers with clear, concise travel and pilgrimage-site guidance. Do not invent live availability, safety alerts, or official rules; direct users to local authorities for urgent or current safety information.';

export function createGeminiService({ apiKey, model, client } = {}) {
  if (!apiKey) {
    throw new Error('GEMINI_API_KEY is required to create the Gemini service.');
  }
  if (!model) {
    throw new Error('GEMINI_MODEL is required to create the Gemini service.');
  }

  const ai = client ?? new GoogleGenAI({ apiKey });

  return async function generateReply({ message, history }) {
    const contents = [
      ...history.map((entry) => ({
        role: entry.role === 'assistant' ? 'model' : 'user',
        parts: [{ text: entry.text }],
      })),
      { role: 'user', parts: [{ text: message }] },
    ];

    const result = await ai.models.generateContent({
      model,
      contents,
      config: { systemInstruction },
    });

    return result.text ?? '';
  };
}
