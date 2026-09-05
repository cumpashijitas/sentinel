-- Sentinel V2 — pgTAP
--
-- Enables the pgTAP extension used by `supabase test db` (see
-- supabase/tests/database/*.sql). pgTAP adds only test-assertion functions
-- (plan/ok/is/throws_ok/finish/…) — no tables, no attack surface — so it is
-- harmless to keep enabled in any environment; it is listed here rather
-- than only in a test fixture so `supabase db reset` always has it ready.
create extension if not exists pgtap with schema extensions;
