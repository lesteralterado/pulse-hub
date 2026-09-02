-- Phase 6 (Learning): courses, modules, lessons, quizzes, progress,
-- achievements. Mirrors the Learning section of the DB structure in the
-- brief (section 39) and the course/module/lesson tree in section 14.
--
-- Scope deliberately narrowed for this pass (documented in the app):
-- text/link lessons only (no image/video/document content, same Storage
-- deferral as posts/messages), single-correct-answer multiple choice
-- quizzes only, and a small fixed achievement set awarded client-side
-- (no general rules engine, no server-side verification of *which*
-- achievement was earned -- see the RLS note on user_achievements).
--
-- Course/module/lesson/quiz authoring has no UI in the mobile app: the
-- brief places "Learning Administration" under the separate Admin
-- Dashboard (Phase 11). This migration seeds one example course so the
-- feature is demoable before that exists.

create table if not exists public.courses (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  description text,
  category text not null check (
    category in (
      'Getting Started',
      'BOT Chain',
      'CaryPact',
      'Blockchain Basics',
      'BOT Token',
      'PulseHub',
      'Security'
    )
  ),
  published boolean not null default true,
  created_at timestamptz not null default now()
);

alter table public.courses enable row level security;

create policy "Authenticated users can view published courses"
  on public.courses for select
  to authenticated
  using (published = true);

create table if not exists public.modules (
  id uuid primary key default gen_random_uuid(),
  course_id uuid not null references public.courses (id) on delete cascade,
  title text not null,
  position int not null default 0,
  created_at timestamptz not null default now()
);

alter table public.modules enable row level security;

create policy "Authenticated users can view modules of published courses"
  on public.modules for select
  to authenticated
  using (
    exists (
      select 1 from public.courses c
      where c.id = modules.course_id and c.published = true
    )
  );

create table if not exists public.lessons (
  id uuid primary key default gen_random_uuid(),
  module_id uuid not null references public.modules (id) on delete cascade,
  title text not null,
  content_type text not null default 'text' check (content_type in ('text', 'link')),
  content text not null,
  position int not null default 0,
  created_at timestamptz not null default now()
);

alter table public.lessons enable row level security;

create policy "Authenticated users can view lessons of published courses"
  on public.lessons for select
  to authenticated
  using (
    exists (
      select 1 from public.modules m
      join public.courses c on c.id = m.course_id
      where m.id = lessons.module_id and c.published = true
    )
  );

create table if not exists public.quizzes (
  id uuid primary key default gen_random_uuid(),
  course_id uuid not null references public.courses (id) on delete cascade,
  -- null = the course's final quiz; non-null = a per-module quiz.
  module_id uuid references public.modules (id) on delete cascade,
  title text not null,
  created_at timestamptz not null default now()
);

alter table public.quizzes enable row level security;

create policy "Authenticated users can view quizzes of published courses"
  on public.quizzes for select
  to authenticated
  using (
    exists (
      select 1 from public.courses c
      where c.id = quizzes.course_id and c.published = true
    )
  );

create table if not exists public.quiz_questions (
  id uuid primary key default gen_random_uuid(),
  quiz_id uuid not null references public.quizzes (id) on delete cascade,
  question_text text not null,
  position int not null default 0
);

alter table public.quiz_questions enable row level security;

create policy "Authenticated users can view quiz questions"
  on public.quiz_questions for select
  to authenticated
  using (true);

-- Deliberately NOT readable by `authenticated` at all (no select policy
-- below means RLS blocks every row): `is_correct` must never reach the
-- client before grading, or a user could just query this table directly
-- to see the answer key. Rendering goes through the quiz_answer_options
-- view (safe columns only); grading goes through grade_quiz_attempt()
-- (SECURITY DEFINER, checks answers server-side).
create table if not exists public.quiz_answers (
  id uuid primary key default gen_random_uuid(),
  question_id uuid not null references public.quiz_questions (id) on delete cascade,
  answer_text text not null,
  is_correct boolean not null default false,
  position int not null default 0
);

alter table public.quiz_answers enable row level security;

create view public.quiz_answer_options as
select id, question_id, answer_text, position
from public.quiz_answers;

grant select on public.quiz_answer_options to authenticated;

create table if not exists public.quiz_attempts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  quiz_id uuid not null references public.quizzes (id) on delete cascade,
  score int not null,
  total_questions int not null,
  completed_at timestamptz not null default now()
);

alter table public.quiz_attempts enable row level security;

create policy "Users can view their own quiz attempts"
  on public.quiz_attempts for select
  to authenticated
  using (user_id = auth.uid());

-- No insert policy for regular users: rows are only ever written by
-- grade_quiz_attempt() below, running as its definer.
create or replace function public.grade_quiz_attempt(
  p_quiz_id uuid,
  p_answers jsonb -- {"<question_id>": "<selected_answer_id>", ...}
)
returns table (score int, total_questions int)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_total int;
  v_score int := 0;
  v_question record;
  v_selected_answer_id uuid;
begin
  select count(*) into v_total from public.quiz_questions where quiz_id = p_quiz_id;

  for v_question in
    select id from public.quiz_questions where quiz_id = p_quiz_id
  loop
    v_selected_answer_id := nullif(p_answers ->> v_question.id::text, '')::uuid;
    if v_selected_answer_id is not null and exists (
      select 1 from public.quiz_answers
      where id = v_selected_answer_id
        and question_id = v_question.id
        and is_correct = true
    ) then
      v_score := v_score + 1;
    end if;
  end loop;

  insert into public.quiz_attempts (user_id, quiz_id, score, total_questions)
  values (auth.uid(), p_quiz_id, v_score, v_total);

  return query select v_score, v_total;
end;
$$;

grant execute on function public.grade_quiz_attempt(uuid, jsonb) to authenticated;

create table if not exists public.user_progress (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  lesson_id uuid not null references public.lessons (id) on delete cascade,
  viewed_at timestamptz,
  completed_at timestamptz,
  unique (user_id, lesson_id)
);

alter table public.user_progress enable row level security;

create policy "Users can view their own progress"
  on public.user_progress for select
  to authenticated
  using (user_id = auth.uid());

create policy "Users can record their own progress"
  on public.user_progress for insert
  to authenticated
  with check (user_id = auth.uid());

create policy "Users can update their own progress"
  on public.user_progress for update
  to authenticated
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

-- Fixed catalog (matching the brief's example list), not a separate
-- achievements table -- see the Phase 6 scoping discussion. Definitions
-- (name/description/icon) live in the app, not the database.
create table if not exists public.user_achievements (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  achievement_code text not null check (
    achievement_code in (
      'first_lesson',
      'blockchain_beginner',
      'bot_explorer',
      'community_member',
      'course_completed'
    )
  ),
  earned_at timestamptz not null default now(),
  unique (user_id, achievement_code)
);

alter table public.user_achievements enable row level security;

create policy "Users can view their own achievements"
  on public.user_achievements for select
  to authenticated
  using (user_id = auth.uid());

-- Client-side awarding (per the Phase 6 scoping discussion) means a
-- determined user could insert an achievement_code they haven't actually
-- earned. Accepted for this pass: achievements here are cosmetic
-- gamification, not tied to subscriptions, rewards, or BOT token
-- balances. Revisit if that changes.
create policy "Users can award themselves an achievement"
  on public.user_achievements for insert
  to authenticated
  with check (user_id = auth.uid());

-- Read models: one query per screen instead of the app computing
-- completion percentages or join order client-side.
create or replace view public.course_summary
with (security_invoker = true) as
select
  c.id,
  c.title,
  c.description,
  c.category,
  c.created_at,
  coalesce(lesson_counts.total_lessons, 0) as total_lessons,
  coalesce(completed_counts.completed_lessons, 0) as completed_lessons
from public.courses c
left join lateral (
  select count(*) as total_lessons
  from public.lessons l
  join public.modules m on m.id = l.module_id
  where m.course_id = c.id
) lesson_counts on true
left join lateral (
  select count(*) as completed_lessons
  from public.user_progress up
  join public.lessons l on l.id = up.lesson_id
  join public.modules m on m.id = l.module_id
  where m.course_id = c.id
    and up.user_id = auth.uid()
    and up.completed_at is not null
) completed_counts on true
where c.published = true;

create or replace view public.lesson_summary
with (security_invoker = true) as
select
  l.id,
  l.module_id,
  l.title,
  l.content_type,
  l.content,
  l.position as lesson_position,
  m.course_id,
  m.title as module_title,
  m.position as module_position,
  up.viewed_at,
  up.completed_at
from public.lessons l
join public.modules m on m.id = l.module_id
left join public.user_progress up
  on up.lesson_id = l.id and up.user_id = auth.uid();

-- Seed content: one example course so Learning is demoable without the
-- (not yet built) Admin Dashboard authoring UI.
do $$
declare
  v_course_id uuid;
  v_module_id uuid;
  v_lesson2_id uuid;
  v_quiz_id uuid;
  v_question_id uuid;
begin
  insert into public.courses (title, description, category)
  values (
    'Getting Started with BOT Chain',
    'A short introduction to BOT Chain: what it is and how transactions work.',
    'BOT Chain'
  )
  returning id into v_course_id;

  insert into public.modules (course_id, title, position)
  values (v_course_id, 'The Basics', 0)
  returning id into v_module_id;

  insert into public.lessons (module_id, title, content_type, content, position)
  values (
    v_module_id,
    'What is BOT Chain?',
    'text',
    'BOT Chain is the blockchain network that powers the PulseHub ecosystem. '
    'It records transactions in a way that is transparent and hard to tamper '
    'with, without relying on a single central authority.',
    0
  );

  insert into public.lessons (module_id, title, content_type, content, position)
  values (
    v_module_id,
    'BOT Chain documentation',
    'link',
    'https://example.com/bot-chain-docs',
    1
  )
  returning id into v_lesson2_id;

  insert into public.quizzes (course_id, module_id, title)
  values (v_course_id, null, 'Getting Started: Final Quiz')
  returning id into v_quiz_id;

  insert into public.quiz_questions (quiz_id, question_text, position)
  values (v_quiz_id, 'What does BOT Chain provide?', 0)
  returning id into v_question_id;

  insert into public.quiz_answers (question_id, answer_text, is_correct, position)
  values
    (v_question_id, 'A transparent, tamper-resistant transaction ledger', true, 0),
    (v_question_id, 'A centralized customer database', false, 1),
    (v_question_id, 'A video streaming service', false, 2);
end $$;
