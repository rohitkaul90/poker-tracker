-- Tournament listings: public read, admin-write only
create table if not exists tournament_listings (
  id          uuid primary key default gen_random_uuid(),
  name        text not null,
  venue       text not null,
  city        text not null,
  country     text not null,
  start_date  date not null,
  end_date    date,
  buy_in      numeric,
  currency    text not null default 'USD',
  guarantee   numeric,
  series      text,
  url         text,
  notes       text,
  created_at  timestamptz not null default now()
);

alter table tournament_listings enable row level security;

create policy "public_read_tournament_listings"
  on tournament_listings for select
  using (true);
