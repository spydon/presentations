-- The names of the people with a passkey, for the ticker along the bottom of
-- the Q&A slide.
--
-- The name is the display name picked on the audience page, which is already
-- shown next to that person's questions. Passkeys live in
-- auth.webauthn_credentials and names in auth.users, which clients cannot
-- read, so triggers keep this table in sync with them.
create table public.passkey_creators (
  user_id uuid primary key references auth.users (id) on delete cascade,
  display_name text not null,
  created_at timestamptz not null default now()
);

alter table public.passkey_creators enable row level security;

-- There are no write policies, only the triggers below change it.
create policy "Passkey creators are public"
  on public.passkey_creators for select
  to anon, authenticated
  using (true);

create function public.add_passkey_creator()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  -- The display name the audience page stores in the user metadata, at most
  -- as long as the name of a question's author.
  insert into public.passkey_creators (user_id, display_name)
  select u.id, left(coalesce(nullif(trim(u.raw_user_meta_data ->> 'display_name'), ''), 'Anonymous'), 40)
  from auth.users u
  where u.id = new.user_id
  on conflict (user_id) do nothing;
  return null;
end;
$$;

-- Removes someone once their last passkey is gone. Deleting a user cascades
-- to their passkeys and to this table, so that is covered too.
create function public.remove_passkey_creator()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  delete from public.passkey_creators c
  where c.user_id = old.user_id
    and not exists (
      select 1 from auth.webauthn_credentials w where w.user_id = old.user_id
    );
  return null;
end;
$$;

revoke execute on function public.add_passkey_creator() from public, anon, authenticated;
revoke execute on function public.remove_passkey_creator() from public, anon, authenticated;

create trigger passkey_creators_add
  after insert on auth.webauthn_credentials
  for each row execute function public.add_passkey_creator();

create trigger passkey_creators_remove
  after delete on auth.webauthn_credentials
  for each row execute function public.remove_passkey_creator();

insert into public.passkey_creators (user_id, display_name)
select u.id, left(coalesce(nullif(trim(u.raw_user_meta_data ->> 'display_name'), ''), 'Anonymous'), 40)
from auth.users u
where exists (select 1 from auth.webauthn_credentials w where w.user_id = u.id);

alter publication supabase_realtime add table public.passkey_creators;
