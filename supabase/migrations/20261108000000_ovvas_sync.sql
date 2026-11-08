-- Ovvas cloud backup and sync.
--
-- Each phone keeps its own database and syncs with these tables:
-- - updated_at: when the row last changed on a phone (ms since epoch). The
--   newer copy always wins; an older upload is ignored.
-- - deleted: rows are marked deleted rather than removed, so deletions reach
--   other phones.
-- - synced_at: set by the server on every write. Phones download rows with a
--   synced_at newer than their last download.

create table public.habits (
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  id text not null,
  name text not null,
  icon_index int not null,
  color_index int not null,
  goal_type text not null,
  target int not null,
  unit text not null,
  repeat text not null,
  weekdays text not null,       -- e.g. '1,2,3,4,5' (1 = Monday)
  times_per_week int not null,
  reminders text not null,      -- minutes of the day, e.g. '540,1080'
  start_date date not null,
  end_date date,
  note text not null,
  archived boolean not null,
  updated_at bigint not null,
  deleted boolean not null default false,
  synced_at timestamptz not null default clock_timestamp(),
  primary key (user_id, id)
);

create table public.entries (
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  habit_id text not null,
  day date not null,
  value int not null,
  skipped boolean not null,
  note text not null,
  updated_at bigint not null,
  deleted boolean not null default false,
  synced_at timestamptz not null default clock_timestamp(),
  primary key (user_id, habit_id, day)
);

create table public.widget_configs (
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  id text not null,
  position int not null,
  data text not null,           -- widget settings as JSON
  updated_at bigint not null,
  deleted boolean not null default false,
  synced_at timestamptz not null default clock_timestamp(),
  primary key (user_id, id)
);

create index habits_sync_idx on public.habits (user_id, synced_at);
create index entries_sync_idx on public.entries (user_id, synced_at);
create index widget_configs_sync_idx on public.widget_configs (user_id, synced_at);

-- Keep the newer copy, and stamp every accepted write.
create function public.ovvas_before_write() returns trigger
language plpgsql set search_path = '' as $$
begin
  if tg_op = 'UPDATE' and new.updated_at < old.updated_at then
    return null; -- an older edit arrived late: keep what is stored
  end if;
  new.synced_at := clock_timestamp();
  return new;
end;
$$;

create trigger habits_before_write before insert or update on public.habits
  for each row execute function public.ovvas_before_write();
create trigger entries_before_write before insert or update on public.entries
  for each row execute function public.ovvas_before_write();
create trigger widget_configs_before_write before insert or update on public.widget_configs
  for each row execute function public.ovvas_before_write();

-- When a habit is deleted, its check-ins go with it.
create function public.ovvas_habit_deleted() returns trigger
language plpgsql set search_path = '' as $$
begin
  delete from public.entries where user_id = new.user_id and habit_id = new.id;
  return null;
end;
$$;

create trigger habits_after_delete_mark after insert or update of deleted on public.habits
  for each row when (new.deleted) execute function public.ovvas_habit_deleted();

-- Each user can only see and change their own rows.
alter table public.habits enable row level security;
alter table public.entries enable row level security;
alter table public.widget_configs enable row level security;

create policy "own habits" on public.habits for all to authenticated
  using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));
create policy "own entries" on public.entries for all to authenticated
  using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));
create policy "own widgets" on public.widget_configs for all to authenticated
  using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));

grant select, insert, update, delete on public.habits, public.entries, public.widget_configs to authenticated;
