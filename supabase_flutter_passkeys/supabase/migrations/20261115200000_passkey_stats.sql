-- A live count of the people with a passkey, for the Q&A slide.
--
-- Passkeys live in auth.webauthn_credentials, which clients cannot read, so a
-- trigger keeps this single public row in sync with it.
create table public.passkey_stats (
  id boolean primary key default true check (id),
  passkey_users integer not null default 0,
  updated_at timestamptz not null default now()
);

alter table public.passkey_stats enable row level security;

-- Only the count is exposed, never who has a passkey. There are no write
-- policies, only the trigger below changes it.
create policy "Passkey stats are public"
  on public.passkey_stats for select
  to anon, authenticated
  using (true);

create function public.refresh_passkey_stats()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  update public.passkey_stats
  set passkey_users = (select count(distinct user_id) from auth.webauthn_credentials),
      updated_at = now()
  where id;
  return null;
end;
$$;

revoke execute on function public.refresh_passkey_stats() from public, anon, authenticated;

insert into public.passkey_stats (passkey_users)
select count(distinct user_id) from auth.webauthn_credentials;

-- Deleting a user cascades to their passkeys, so this also covers deleted users.
create trigger passkey_stats_refresh
  after insert or delete on auth.webauthn_credentials
  for each statement execute function public.refresh_passkey_stats();

alter publication supabase_realtime add table public.passkey_stats;
