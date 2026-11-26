export function createChatController({ generateReply }) {
  return async function handleChat(request, response, next) {
    const { message, history = [] } = request.body ?? {};
    if (
      typeof message !== 'string' ||
      message.trim().length === 0 ||
      message.length > 4000
    ) {
      response.status(400).json({
        error: 'message must contain 1 to 4000 characters.',
      });
      return;
    }

    if (!Array.isArray(history) || history.length > 20) {
      response.status(400).json({
        error: 'history must be an array containing at most 20 messages.',
      });
      return;
    }

    const cleanHistory = [];
    for (const entry of history) {
      if (
        entry === null ||
        typeof entry !== 'object' ||
        !['user', 'assistant'].includes(entry.role) ||
        typeof entry.text !== 'string' ||
        entry.text.trim().length === 0 ||
        entry.text.length > 4000
      ) {
        response.status(400).json({
          error: 'Each history item needs a valid user/assistant role and text.',
        });
        return;
      }
      cleanHistory.push({ role: entry.role, text: entry.text.trim() });
    }

    try {
      const reply = await generateReply({
        message: message.trim(),
        history: cleanHistory,
      });
      if (typeof reply !== 'string' || reply.trim().length === 0) {
        response.status(502).json({ error: 'Gemini returned an empty response.' });
        return;
      }
      response.json({ reply: reply.trim() });
    } catch (error) {
      next(error);
    }
  };
}
