-- Phase 7 (Meetings): scheduling, RSVP, host controls, and meeting chat.
-- Mirrors the Meetings section of the DB structure in the brief
-- (section 39) and the states/RSVP flow in section 12.
--
-- Scope deliberately narrowed for this pass (documented in the app): no
-- co-host promotion UI (the role column supports it, nothing sets it to
-- 'co_host' yet), no granular speaker permissions, no reminders (needs
-- push notifications, not built), and no meeting_recordings table (needs
-- LiveKit Egress, which needs a LiveKit deployment this project doesn't
-- have yet -- see LiveKitService in the app for the video-call side of
-- that same gap).
--
-- "Starting Soon" (section 12's 4-state flow) is computed client-side
-- from scheduled_start rather than stored -- it's a display concern, not
-- state a host or participant ever explicitly sets.

create table if not exists public.meetings (
  id uuid primary key default gen_random_uuid(),
  host_id uuid not null references public.profiles (id) on delete cascade,
  title text not null,
  description text,
  scheduled_start timestamptz not null,
  scheduled_end timestamptz not null,
  status text not null default 'scheduled' check (
    status in ('scheduled', 'live', 'ended', 'cancelled')
  ),
  locked boolean not null default false,
  created_at timestamptz not null default now(),
  check (scheduled_end > scheduled_start)
);

alter table public.meetings enable row level security;

create policy "Authenticated users can view meetings"
  on public.meetings for select
  to authenticated
  using (true);

create policy "Authenticated users can schedule a meeting"
  on public.meetings for insert
  to authenticated
  with check (host_id = auth.uid());

create policy "Hosts can update their own meeting"
  on public.meetings for update
  to authenticated
  using (host_id = auth.uid())
  with check (host_id = auth.uid());

create table if not exists public.meeting_participants (
  id uuid primary key default gen_random_uuid(),
  meeting_id uuid not null references public.meetings (id) on delete cascade,
  user_id uuid not null references public.profiles (id) on delete cascade,
  role text not null default 'participant' check (
    role in ('host', 'co_host', 'participant')
  ),
  rsvp_status text not null default 'going' check (rsvp_status in ('going', 'not_going')),
  joined_at timestamptz,
  created_at timestamptz not null default now(),
  unique (meeting_id, user_id)
);

alter table public.meeting_participants enable row level security;

create policy "Authenticated users can view meeting participants"
  on public.meeting_participants for select
  to authenticated
  using (true);

create policy "Users can RSVP as themselves"
  on public.meeting_participants for insert
  to authenticated
  with check (user_id = auth.uid());

create policy "Users can update their own participation"
  on public.meeting_participants for update
  to authenticated
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

create policy "Users can cancel their own RSVP; hosts can remove others"
  on public.meeting_participants for delete
  to authenticated
  using (
    user_id = auth.uid()
    or exists (
      select 1 from public.meetings m
      where m.id = meeting_participants.meeting_id and m.host_id = auth.uid()
    )
  );

-- Membership check needs a SECURITY DEFINER helper for the same reason
-- as chat's is_conversation_member(): a USING clause on
-- meeting_participants that subqueries meeting_participants itself is
-- the classic Postgres RLS self-reference recursion trap.
create or replace function public.is_meeting_participant(
  target_meeting_id uuid,
  target_user_id uuid
)
returns boolean
language sql
security definer
stable
set search_path = public
as $$
  select exists (
    select 1 from public.meeting_participants
    where meeting_id = target_meeting_id and user_id = target_user_id
  );
$$;

create table if not exists public.meeting_messages (
  id uuid primary key default gen_random_uuid(),
  meeting_id uuid not null references public.meetings (id) on delete cascade,
  sender_id uuid not null references public.profiles (id) on delete cascade,
  content text not null check (char_length(content) between 1 and 2000),
  created_at timestamptz not null default now()
);

alter table public.meeting_messages enable row level security;

create policy "Meeting participants can view its chat"
  on public.meeting_messages for select
  to authenticated
  using (public.is_meeting_participant(meeting_id, auth.uid()));

create policy "Meeting participants can send chat messages"
  on public.meeting_messages for insert
  to authenticated
  with check (
    sender_id = auth.uid()
    and public.is_meeting_participant(meeting_id, auth.uid())
  );

create policy "Users can delete their own meeting messages"
  on public.meeting_messages for delete
  to authenticated
  using (sender_id = auth.uid());

alter publication supabase_realtime add table public.meeting_messages;

-- Read model: one query per screen instead of the app doing per-row
-- host-profile/participant-count/my-RSVP lookups.
create or replace view public.meeting_summary
with (security_invoker = true) as
select
  m.id,
  m.host_id,
  m.title,
  m.description,
  m.scheduled_start,
  m.scheduled_end,
  m.status,
  m.locked,
  m.created_at,
  p.username as host_username,
  p.full_name as host_full_name,
  coalesce(going_counts.participant_count, 0) as participant_count,
  my_rsvp.rsvp_status as my_rsvp_status
from public.meetings m
join public.profiles p on p.id = m.host_id
left join lateral (
  select count(*) as participant_count
  from public.meeting_participants mp
  where mp.meeting_id = m.id and mp.rsvp_status = 'going'
) going_counts on true
left join lateral (
  select rsvp_status
  from public.meeting_participants mp2
  where mp2.meeting_id = m.id and mp2.user_id = auth.uid()
) my_rsvp on true;
