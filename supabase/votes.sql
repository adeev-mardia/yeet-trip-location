-- Voting tables for yeet-trip-location. Lives in the same Supabase project as yeet-trip-dates
-- and reuses its public._is_admin(password) check.

create table public.votes (
  name text not null check (name in ('Aarav','Adeev','Aryan','Darseel','Prithvi','Rajveer','Vivan')),
  poll text not null,
  choice text not null,
  updated_at timestamptz not null default now(),
  primary key (name, poll),
  check (
    (poll = 'course' and choice in ('intro','scuba','openwater')) or
    (poll = 'andaman_hotel' and choice in ('seashell','silversand')) or
    (poll = 'goa_hotel' and choice in ('ronil','hardrock','hyatt','fairfield')) or
    (poll = 'destination' and choice in ('andaman','goa'))
  )
);
alter table public.votes enable row level security;
revoke all on public.votes from anon, authenticated;

-- a person's own votes (Adeev's need the password)
create or replace function public.get_my_votes(p_name text, p_password text default null)
returns table(poll text, choice text)
language plpgsql security definer set search_path = '' as $$
begin
  if p_name = 'Adeev' and not public._is_admin(p_password) then raise exception 'wrong password'; end if;
  return query select v.poll, v.choice from public.votes v where v.name = p_name;
end $$;

-- cast or change a vote
create or replace function public.cast_vote(p_name text, p_poll text, p_choice text, p_password text default null)
returns void
language plpgsql security definer set search_path = '' as $$
begin
  if p_name not in ('Aarav','Adeev','Aryan','Darseel','Prithvi','Rajveer','Vivan') then raise exception 'unknown name'; end if;
  if p_name = 'Adeev' and not public._is_admin(p_password) then raise exception 'wrong password'; end if;
  insert into public.votes(name, poll, choice, updated_at) values (p_name, p_poll, p_choice, now())
  on conflict (name, poll) do update set choice = excluded.choice, updated_at = now();
end $$;

-- everyone's votes, admin password only
create or replace function public.get_vote_results(p_password text)
returns table(name text, poll text, choice text, updated_at timestamptz)
language plpgsql security definer set search_path = '' as $$
begin
  if not public._is_admin(p_password) then raise exception 'wrong password'; end if;
  return query select v.name, v.poll, v.choice, v.updated_at from public.votes v order by v.poll, v.name;
end $$;

revoke all on function public.get_my_votes(text,text) from public;
revoke all on function public.cast_vote(text,text,text,text) from public;
revoke all on function public.get_vote_results(text) from public;
grant execute on function public.get_my_votes(text,text) to anon, authenticated;
grant execute on function public.cast_vote(text,text,text,text) to anon, authenticated;
grant execute on function public.get_vote_results(text) to anon, authenticated;
