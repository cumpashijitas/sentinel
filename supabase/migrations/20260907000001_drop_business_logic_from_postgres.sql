-- Sentinel V2 — retirar de Postgres la lógica de negocio que ahora vive en
-- back/ (Node/TS).
--
-- create_ride_group / join_group_by_code / leave_group / start_ride_session
-- / finish_ride_session (20260827210009_rpc_functions.sql) y el trigger de
-- despacho de alertas (20260828000001_accident_alert_dispatch.sql) quedaron
-- sin ningún llamador: esa lógica se portó a back/src/services/ y
-- back/src/alerts/ — ver docs/architecture.md. El cliente Flutter ya no
-- llama ningún RPC; back/ escribe directo contra Postgres.
--
-- Los helpers de solo lectura is_group_member / is_group_admin /
-- is_session_member (20260827210004/20260827210005) se CONSERVAN — no son
-- lógica de negocio, son control de acceso de storage (RLS), que sigue
-- vigente para lo poco que el front todavía toca directo: la lectura por
-- Realtime de `live_locations` y el canal de broadcast `ride:<session_id>`.

drop trigger if exists accident_events_confirmed_dispatch_alerts on public.accident_events;
drop function if exists public.dispatch_accident_alert_webhook();

drop function if exists public.create_ride_group(text, text);
drop function if exists public.join_group_by_code(text);
drop function if exists public.leave_group(uuid);
drop function if exists public.start_ride_session(uuid, text);
drop function if exists public.finish_ride_session(uuid);
