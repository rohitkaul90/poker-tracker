-- Add source tracking and unique constraint for scraper
alter table tournament_listings
  add column if not exists source text not null default 'manual',
  add column if not exists source_url text;

alter table tournament_listings
  drop constraint if exists tournament_listings_name_start_date_key;

alter table tournament_listings
  add constraint tournament_listings_name_start_date_key
  unique (name, start_date);

grant all privileges on table tournament_listings to service_role;
grant all privileges on table tournament_listings to postgres;
grant select on table tournament_listings to anon, authenticated;
