-- Upvotes on audience questions.
create table public.question_votes (
  question_id bigint not null references public.questions (id) on delete cascade,
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (question_id, user_id)
);

create index question_votes_user_id_idx on public.question_votes (user_id);

alter table public.question_votes enable row level security;

-- Who voted for what stays private, everyone only sees their own votes.
create policy "Users see their own votes"
  on public.question_votes for select
  to authenticated
  using (user_id = (select auth.uid()));

-- Signed in, non-anonymous users vote as themselves, not on their own questions.
create policy "Users upvote other people's questions"
  on public.question_votes for insert
  to authenticated
  with check (
    user_id = (select auth.uid())
    and coalesce((select auth.jwt() ->> 'is_anonymous')::boolean, false) = false
    and not exists (
      select 1 from public.questions q
      where q.id = question_id and q.user_id = (select auth.uid())
    )
  );

create policy "Users remove their own votes"
  on public.question_votes for delete
  to authenticated
  using (user_id = (select auth.uid()));

-- The vote count lives on the question, so the slide gets it through the same
-- realtime stream as the questions and nobody can read the individual votes.
alter table public.questions add column vote_count integer not null default 0;

-- Clients cannot pick their own count when asking a question.
drop policy "Signed in users ask as themselves" on public.questions;
create policy "Signed in users ask as themselves"
  on public.questions for insert
  to authenticated
  with check (
    user_id = (select auth.uid())
    and vote_count = 0
    and coalesce((select auth.jwt() ->> 'is_anonymous')::boolean, false) = false
  );

create function public.update_question_vote_count()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if tg_op = 'INSERT' then
    update public.questions set vote_count = vote_count + 1 where id = new.question_id;
  else
    update public.questions set vote_count = vote_count - 1 where id = old.question_id;
  end if;
  return null;
end;
$$;

revoke execute on function public.update_question_vote_count() from public, anon, authenticated;

create trigger question_votes_count
  after insert or delete on public.question_votes
  for each row execute function public.update_question_vote_count();

-- Lets the audience page keep its upvote buttons in sync.
alter publication supabase_realtime add table public.question_votes;
