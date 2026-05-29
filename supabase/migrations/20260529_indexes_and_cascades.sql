-- ── Performance indexes ────────────────────────────────────────────────────────
-- sessions and hands were created in the Supabase dashboard before the
-- migration workflow was established; their DDL lives only in the cloud.
-- These indexes are added here so they are tracked and replayable.

CREATE INDEX IF NOT EXISTS idx_sessions_user_id
  ON sessions(user_id);

CREATE INDEX IF NOT EXISTS idx_sessions_user_date
  ON sessions(user_id, date DESC);

CREATE INDEX IF NOT EXISTS idx_hands_user_id
  ON hands(user_id);

CREATE INDEX IF NOT EXISTS idx_hands_session_id
  ON hands(session_id)
  WHERE session_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_rake_presets_user_id
  ON rake_presets(user_id);

-- tournament_listings is sorted by start_date on every fetch
CREATE INDEX IF NOT EXISTS idx_tournament_listings_start_date
  ON tournament_listings(start_date);

-- ── Cascade deletes ────────────────────────────────────────────────────────────
-- player_reads was originally created with a bare FK (no ON DELETE CASCADE).
-- Add the cascade so deleting a user from auth.users removes all their reads.

ALTER TABLE player_reads
  DROP CONSTRAINT IF EXISTS player_reads_user_id_fkey;

ALTER TABLE player_reads
  ADD CONSTRAINT player_reads_user_id_fkey
  FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;

-- Ensure sessions and hands also have cascade deletes.
-- These are safe no-ops if the constraints already exist with the right definition.

ALTER TABLE sessions
  DROP CONSTRAINT IF EXISTS sessions_user_id_fkey;

ALTER TABLE sessions
  ADD CONSTRAINT sessions_user_id_fkey
  FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;

ALTER TABLE hands
  DROP CONSTRAINT IF EXISTS hands_user_id_fkey;

ALTER TABLE hands
  ADD CONSTRAINT hands_user_id_fkey
  FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;

ALTER TABLE rake_presets
  DROP CONSTRAINT IF EXISTS rake_presets_user_id_fkey;

ALTER TABLE rake_presets
  ADD CONSTRAINT rake_presets_user_id_fkey
  FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;
