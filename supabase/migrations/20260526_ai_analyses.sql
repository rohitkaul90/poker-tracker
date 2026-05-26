create table ai_analyses (
  id           uuid primary key default gen_random_uuid(),
  user_id      uuid references auth.users(id) on delete cascade not null,
  session_id   uuid references sessions(id) on delete cascade not null,
  analysis_json jsonb not null,
  model_used   text not null default 'claude-sonnet-4-6',
  tokens_used  integer,
  created_at   timestamptz default now(),
  unique(user_id, session_id)
);

alter table ai_analyses enable row level security;

create policy "Users manage own analyses"
  on ai_analyses for all
  using  (auth.uid() = user_id)
  with check (auth.uid() = user_id);
