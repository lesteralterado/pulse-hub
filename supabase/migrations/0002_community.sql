-- Phase 4 (Community): groups, posts, comments, reactions, reports.
-- Mirrors the Community section of the DB structure in the project brief
-- (section 39) and the Feed/Groups feature lists (sections 8-9).
--
-- Scope deliberately narrowed for this pass (documented in the app):
-- text-only posts (post_type column still supports the full brief list
-- for later), a single "like" reaction, flat (non-threaded) comments,
-- and no follow graph yet. Group chat/events/announcements/moderation
-- and report review are later phases (Chat, Admin Dashboard).
--
-- author_id/reporter_id/user_id/created_by all reference public.profiles
-- (not auth.users directly) so PostgREST can embed author info in one
-- query (e.g. `select=*,profiles(username,avatar_url)`) — profiles rows
-- always exist because 0001's trigger creates one for every signup.

create table if not exists public.groups (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  description text,
  created_by uuid not null references public.profiles (id) on delete cascade,
  created_at timestamptz not null default now()
);

alter table public.groups enable row level security;

create policy "Any authenticated user can view groups"
  on public.groups for select
  to authenticated
  using (true);

create policy "Any authenticated user can create a group"
  on public.groups for insert
  to authenticated
  with check (created_by = auth.uid());

create table if not exists public.group_members (
  id uuid primary key default gen_random_uuid(),
  group_id uuid not null references public.groups (id) on delete cascade,
  user_id uuid not null references public.profiles (id) on delete cascade,
  role text not null default 'member' check (role in ('member', 'moderator', 'owner')),
  joined_at timestamptz not null default now(),
  unique (group_id, user_id)
);

alter table public.group_members enable row level security;

create policy "Any authenticated user can view group membership"
  on public.group_members for select
  to authenticated
  using (true);

create policy "Users can join a group as themselves"
  on public.group_members for insert
  to authenticated
  with check (user_id = auth.uid());

create policy "Users can leave a group they're in"
  on public.group_members for delete
  to authenticated
  using (user_id = auth.uid());

create table if not exists public.posts (
  id uuid primary key default gen_random_uuid(),
  author_id uuid not null references public.profiles (id) on delete cascade,
  group_id uuid references public.groups (id) on delete cascade,
  post_type text not null default 'text' check (
    post_type in ('text', 'image', 'video', 'announcement', 'event', 'learning')
  ),
  content text not null check (char_length(content) between 1 and 5000),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.posts enable row level security;

create policy "Any authenticated user can view posts"
  on public.posts for select
  to authenticated
  using (true);

create policy "Users can create their own posts"
  on public.posts for insert
  to authenticated
  with check (author_id = auth.uid());

create policy "Users can update their own posts"
  on public.posts for update
  to authenticated
  using (author_id = auth.uid())
  with check (author_id = auth.uid());

create policy "Users can delete their own posts"
  on public.posts for delete
  to authenticated
  using (author_id = auth.uid());

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists set_posts_updated_at on public.posts;
create trigger set_posts_updated_at
  before update on public.posts
  for each row execute function public.set_updated_at();

create table if not exists public.comments (
  id uuid primary key default gen_random_uuid(),
  post_id uuid not null references public.posts (id) on delete cascade,
  author_id uuid not null references public.profiles (id) on delete cascade,
  content text not null check (char_length(content) between 1 and 2000),
  created_at timestamptz not null default now()
);

alter table public.comments enable row level security;

create policy "Any authenticated user can view comments"
  on public.comments for select
  to authenticated
  using (true);

create policy "Users can add their own comments"
  on public.comments for insert
  to authenticated
  with check (author_id = auth.uid());

create policy "Users can delete their own comments"
  on public.comments for delete
  to authenticated
  using (author_id = auth.uid());

create table if not exists public.reactions (
  id uuid primary key default gen_random_uuid(),
  post_id uuid not null references public.posts (id) on delete cascade,
  user_id uuid not null references public.profiles (id) on delete cascade,
  reaction_type text not null default 'like' check (reaction_type in ('like')),
  created_at timestamptz not null default now(),
  unique (post_id, user_id)
);

alter table public.reactions enable row level security;

create policy "Any authenticated user can view reactions"
  on public.reactions for select
  to authenticated
  using (true);

create policy "Users can react as themselves"
  on public.reactions for insert
  to authenticated
  with check (user_id = auth.uid());

create policy "Users can remove their own reaction"
  on public.reactions for delete
  to authenticated
  using (user_id = auth.uid());

create table if not exists public.reports (
  id uuid primary key default gen_random_uuid(),
  post_id uuid not null references public.posts (id) on delete cascade,
  reporter_id uuid not null references public.profiles (id) on delete cascade,
  reason text not null check (char_length(reason) between 1 and 1000),
  created_at timestamptz not null default now()
);

alter table public.reports enable row level security;

-- Reporters can see their own reports; a moderation-queue read policy for
-- admins/moderators is added alongside the Admin Dashboard (Phase 11),
-- not here.
create policy "Users can view their own reports"
  on public.reports for select
  to authenticated
  using (reporter_id = auth.uid());

create policy "Users can report a post"
  on public.reports for insert
  to authenticated
  with check (reporter_id = auth.uid());

-- Feed read model: one query gets each post with its author info and
-- aggregate counts instead of the app doing N+1 lookups per card.
-- security_invoker means it runs with the querying user's own RLS/
-- permissions rather than the view owner's, per Supabase's guidance for
-- views that use auth.uid().
create or replace view public.post_feed
with (security_invoker = true) as
select
  p.id,
  p.author_id,
  p.group_id,
  p.post_type,
  p.content,
  p.created_at,
  p.updated_at,
  pr.username as author_username,
  pr.full_name as author_full_name,
  pr.avatar_url as author_avatar_url,
  coalesce(r.like_count, 0) as like_count,
  coalesce(c.comment_count, 0) as comment_count,
  exists (
    select 1 from public.reactions myr
    where myr.post_id = p.id and myr.user_id = auth.uid()
  ) as liked_by_me
from public.posts p
join public.profiles pr on pr.id = p.author_id
left join (
  select post_id, count(*) as like_count from public.reactions group by post_id
) r on r.post_id = p.id
left join (
  select post_id, count(*) as comment_count from public.comments group by post_id
) c on c.post_id = p.id;

create or replace view public.group_summary
with (security_invoker = true) as
select
  g.id,
  g.name,
  g.description,
  g.created_by,
  g.created_at,
  coalesce(m.member_count, 0) as member_count,
  exists (
    select 1 from public.group_members gm
    where gm.group_id = g.id and gm.user_id = auth.uid()
  ) as is_member
from public.groups g
left join (
  select group_id, count(*) as member_count from public.group_members group by group_id
) m on m.group_id = g.id;
