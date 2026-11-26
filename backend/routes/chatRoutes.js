import { Router } from 'express';

import { createChatController } from '../controllers/chatController.js';

export function createChatRouter({ generateReply }) {
  const router = Router();
  router.post('/', createChatController({ generateReply }));
  return router;
}
