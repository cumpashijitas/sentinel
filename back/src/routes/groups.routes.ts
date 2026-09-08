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

const updateGroupSchema = z.object({
  name: z.string(),
  description: z.string().nullable().optional(),
});

groupRoutes.patch(
  '/groups/:id',
  asyncHandler(async (req, res) => {
    const body = updateGroupSchema.parse(req.body);
    const group = await groupService.updateGroup(
      req.userId,
      req.params.id,
      body.name,
      body.description ?? null,
    );
    res.json(group);
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

const setMemberRoleSchema = z.object({ role: z.enum(['admin', 'member']) });

groupRoutes.patch(
  '/groups/:id/members/:userId/role',
  asyncHandler(async (req, res) => {
    const body = setMemberRoleSchema.parse(req.body);
    const member = await groupService.setMemberRole(
      req.userId,
      req.params.id,
      req.params.userId,
      body.role,
    );
    res.json(member);
  }),
);

groupRoutes.delete(
  '/groups/:id/members/:userId',
  asyncHandler(async (req, res) => {
    await groupService.removeMember(req.userId, req.params.id, req.params.userId);
    res.status(204).send();
  }),
);

const setPinnedNoteSchema = z.object({ note: z.string().nullable() });

groupRoutes.patch(
  '/groups/:id/note',
  asyncHandler(async (req, res) => {
    const body = setPinnedNoteSchema.parse(req.body);
    const group = await groupService.setPinnedNote(
      req.userId,
      req.params.id,
      body.note,
    );
    res.json(group);
  }),
);
