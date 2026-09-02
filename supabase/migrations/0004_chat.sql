-- Phase 5 (Chat): conversations, conversation_members, messages, with
-- Supabase Realtime powering live message delivery. Mirrors the Chat
-- section of the DB structure in the brief (section 39).
--
-- Scope deliberately narrowed for this pass (documented in the app):
-- text-only messages, no reactions/typing/online-status/search/mentions/
-- push notifications, and no message editing (delete-own only, matching
-- how comments work in Phase 4). message_attachments/message_reactions
-- from the brief's schema are not created here — they belong with the
-- features that need them (Storage-backed attachments, message
-- reactions), not created empty ahead of time.

-- Membership checks need a SECURITY DEFINER helper: a plain USING clause
-- on conversation_members that subqueries conversation_members itself is
-- the classic Postgres RLS self-reference trap (recursive policy
-- evaluation). Routing through this function avoids that.
create or replace function public.is_conversation_member(
  target_conversation_id uuid,
  target_user_id uuid
)
returns boolean
language sql
security definer
stable
set search_path = public
as $$
  select exists (
    select 1 from public.conversation_members
    where conversation_id = target_conversation_id
      and user_id = target_user_id
  );
$$;

create table if not exists public.conversations (
  id uuid primary key default gen_random_uuid(),
  is_group boolean not null default false,
  name text,
  created_by uuid not null references public.profiles (id) on delete cascade,
  created_at timestamptz not null default now()
);

alter table public.conversations enable row level security;

create policy "Members can view their conversations"
  on public.conversations for select
  to authenticated
  using (public.is_conversation_member(id, auth.uid()));

create policy "Authenticated users can start a conversation"
  on public.conversations for insert
  to authenticated
  with check (created_by = auth.uid());

create table if not exists public.conversation_members (
  id uuid primary key default gen_random_uuid(),
  conversation_id uuid not null references public.conversations (id) on delete cascade,
  user_id uuid not null references public.profiles (id) on delete cascade,
  role text not null default 'member' check (role in ('member', 'owner')),
  last_read_at timestamptz,
  joined_at timestamptz not null default now(),
  unique (conversation_id, user_id)
);

alter table public.conversation_members enable row level security;

create policy "Members can view membership of their conversations"
  on public.conversation_members for select
  to authenticated
  using (public.is_conversation_member(conversation_id, auth.uid()));

-- Checked against conversations.created_by (already-committed by the
-- time membership rows are inserted) rather than conversation_members
-- itself, so a single multi-row insert -- the creator's own row plus
-- every other participant -- can succeed in one statement. A self-
-- referencing check here would see the creator's own row as not-yet-
-- existing mid-statement and reject the other rows.
create policy "Self-join or the conversation creator can add members"
  on public.conversation_members for insert
  to authenticated
  with check (
    user_id = auth.uid()
    or exists (
      select 1 from public.conversations c
      where c.id = conversation_members.conversation_id and c.created_by = auth.uid()
    )
  );

create policy "Members can leave; creators can remove others"
  on public.conversation_members for delete
  to authenticated
  using (
    user_id = auth.uid()
    or exists (
      select 1 from public.conversations c
      where c.id = conversation_members.conversation_id and c.created_by = auth.uid()
    )
  );

create policy "Members can update their own read state"
  on public.conversation_members for update
  to authenticated
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

create table if not exists public.messages (
  id uuid primary key default gen_random_uuid(),
  conversation_id uuid not null references public.conversations (id) on delete cascade,
  sender_id uuid not null references public.profiles (id) on delete cascade,
  content text not null check (char_length(content) between 1 and 4000),
  created_at timestamptz not null default now()
);

alter table public.messages enable row level security;

create policy "Members can view messages in their conversations"
  on public.messages for select
  to authenticated
  using (public.is_conversation_member(conversation_id, auth.uid()));

create policy "Members can send messages to their conversations"
  on public.messages for insert
  to authenticated
  with check (
    sender_id = auth.uid()
    and public.is_conversation_member(conversation_id, auth.uid())
  );

create policy "Users can delete their own messages"
  on public.messages for delete
  to authenticated
  using (sender_id = auth.uid());

-- Powers the conversation list: last message preview, unread count, and
-- (for 1:1 chats, which have no `name`) the other participant's profile,
-- all in one query instead of the app doing per-row lookups.
create or replace view public.conversation_summary
with (security_invoker = true) as
select
  c.id,
  c.is_group,
  c.name,
  c.created_by,
  c.created_at,
  cm.last_read_at,
  last_message.content as last_message_content,
  last_message.created_at as last_message_at,
  last_message.sender_id as last_message_sender_id,
  coalesce(unread.unread_count, 0) as unread_count,
  other_member.username as other_member_username,
  other_member.full_name as other_member_full_name,
  other_member.avatar_url as other_member_avatar_url
from public.conversations c
join public.conversation_members cm
  on cm.conversation_id = c.id and cm.user_id = auth.uid()
left join lateral (
  select content, created_at, sender_id
  from public.messages m
  where m.conversation_id = c.id
  order by m.created_at desc
  limit 1
) last_message on true
left join lateral (
  select count(*) as unread_count
  from public.messages m2
  where m2.conversation_id = c.id
    and m2.created_at > coalesce(cm.last_read_at, 'epoch'::timestamptz)
    and m2.sender_id <> auth.uid()
) unread on true
left join lateral (
  select p.username, p.full_name, p.avatar_url
  from public.conversation_members other_cm
  join public.profiles p on p.id = other_cm.user_id
  where other_cm.conversation_id = c.id and other_cm.user_id <> auth.uid()
  limit 1
) other_member on not c.is_group;

-- Live message delivery for the conversation screen.
alter publication supabase_realtime add table public.messages;
