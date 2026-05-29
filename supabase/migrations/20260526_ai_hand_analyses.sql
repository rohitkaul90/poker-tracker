create table if not exists ai_hand_analyses (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade not null,
  hand_id uuid references hands(id) on delete cascade not null,
  analysis_json jsonb not null,
  model_used text not null default 'claude-sonnet-4-6',
  tokens_used integer,
  created_at timestamptz default now(),
  unique(user_id, hand_id)
);

alter table ai_hand_analyses enable row level security;

drop policy if exists "Users manage own hand analyses" on ai_hand_analyses;
create policy "Users manage own hand analyses" on ai_hand_analyses
  for all using (auth.uid() = user_id)
  with check (auth.uid() = user_id);
