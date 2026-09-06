// Sentinel back/ — /groups
//
// Ver `services/group.service.ts` para la lógica portada de las funciones
// SQL originales.

import { Router } from 'express';
import { z } from 'zod';
import { asyncHandler } from '../lib/http.js';
import * as groupService from '../services/group.service.js';

export const groupRoutes = Router();

groupRoutes.get(
  '/groups',
  asyncHandler(async (req, res) => {
    res.json(await groupService.fetchMyGroups(req.userId));
  }),
);

const createGroupSchema = z.object({
  name: z.string(),
  description: z.string().nullable().optional(),
});

groupRoutes.post(
  '/groups',
  asyncHandler(async (req, res) => {
    const body = createGroupSchema.parse(req.body);
    const group = await groupService.createGroup(
      req.userId,
      body.name,
      body.description ?? null,
    );
    res.status(201).json(group);
  }),
);

const joinGroupSchema = z.object({ invite_code: z.string().min(1) });

groupRoutes.post(
  '/groups/join',
  asyncHandler(async (req, res) => {
    const body = joinGroupSchema.parse(req.body);
    const groupId = await groupService.joinGroupByCode(req.userId, body.invite_code);
    res.json({ group_id: groupId });
  }),
);

groupRoutes.post(
  '/groups/:id/leave',
  asyncHandler(async (req, res) => {
    await groupService.leaveGroup(req.userId, req.params.id);
    res.status(204).send();
  }),
);

groupRoutes.get(
  '/groups/:id',
  asyncHandler(async (req, res) => {
    res.json(await groupService.fetchGroup(req.userId, req.params.id));
  }),
);

groupRoutes.get(
  '/groups/:id/members',
  asyncHandler(async (req, res) => {
    res.json(await groupService.fetchMembers(req.userId, req.params.id));
  }),
);
