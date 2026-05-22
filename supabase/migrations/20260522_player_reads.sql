-- Player read profiles (one per opponent)
create table if not exists player_reads (
  id          uuid default gen_random_uuid() primary key,
  user_id     uuid references auth.users not null,
  player_label text not null,
  tags        text[] default '{}' not null,
  created_at  timestamptz default now() not null,
  updated_at  timestamptz default now() not null
);

alter table player_reads enable row level security;

create policy "Users manage own reads"
  on player_reads for all
  using  (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- Individual observations attached to a player
create table if not exists player_read_notes (
  id          uuid default gen_random_uuid() primary key,
  read_id     uuid references player_reads(id) on delete cascade not null,
  note_text   text,
  position    text,   -- UTG / BTN / SB / etc.
  action      text,   -- open / limp / 3-bet / etc.
  sizing      text,   -- "4x", "75%", etc.
  street      text,   -- preflop / flop / turn / river
  cards_shown text,   -- "45o", "AKs", etc.
  created_at  timestamptz default now() not null
);

alter table player_read_notes enable row level security;

create policy "Users manage notes for their reads"
  on player_read_notes for all
  using (
    exists (
      select 1 from player_reads
       where player_reads.id      = player_read_notes.read_id
         and player_reads.user_id = auth.uid()
    )
  )
  with check (
    exists (
      select 1 from player_reads
       where player_reads.id      = player_read_notes.read_id
         and player_reads.user_id = auth.uid()
    )
  );

create index if not exists player_reads_user_updated_idx on player_reads(user_id, updated_at desc);
create index if not exists player_read_notes_read_id_idx  on player_read_notes(read_id);
