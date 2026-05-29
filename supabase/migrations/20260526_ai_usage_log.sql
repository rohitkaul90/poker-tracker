create table if not exists ai_usage_log (
  id bigserial primary key,
  user_id uuid references auth.users(id) on delete cascade not null,
  function_name text not null,
  called_at timestamptz default now()
);

create index if not exists ai_usage_log_user_fn_time
  on ai_usage_log (user_id, function_name, called_at);

alter table ai_usage_log enable row level security;

drop policy if exists "Users manage own usage log" on ai_usage_log;
create policy "Users manage own usage log" on ai_usage_log
  for all using (auth.uid() = user_id)
  with check (auth.uid() = user_id);
