-- Sentinel V2 — aviso fijado del grupo.
--
-- Un solo texto por grupo, editable por cualquier admin (ver
-- back/src/services/group.service.ts::setPinnedNote) — cubre "avisale
-- algo a todo el grupo" sin el costo de un feed de múltiples notas con su
-- propia tabla/paginación/autoría. `null` = sin aviso fijado.

alter table public.ride_groups
  add column pinned_note text;
