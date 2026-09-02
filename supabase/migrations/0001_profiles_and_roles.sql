-- Phase 2 (Authentication): profiles + user_roles, auto-provisioned on
-- signup. Mirrors the Authentication section of the DB structure in the
-- project brief (section 39) and the RBAC roles in section 26.
--
-- Deliberately NOT included here: `investor_profiles` (section 39) — that
-- table holds investment-specific data and belongs with the CaryPact
-- integration work (a later phase), not basic account registration.
--
-- Broader read policies (e.g. public profile lookups for the Community
-- feed) are intentionally left out of this migration; add them alongside
-- the feature that needs them rather than opening access early.

create table if not exists public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  username text unique,
  full_name text,
  avatar_url text,
  bio text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.profiles enable row level security;

create policy "Users can view their own profile"
  on public.profiles for select
  using (auth.uid() = id);

create policy "Users can update their own profile"
  on public.profiles for update
  using (auth.uid() = id)
  with check (auth.uid() = id);

create table if not exists public.user_roles (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  role text not null check (
    role in (
      'investor',
      'moderator',
      'instructor',
      'community_manager',
      'admin',
      'super_admin'
    )
  ),
  created_at timestamptz not null default now(),
  unique (user_id, role)
);

alter table public.user_roles enable row level security;

create policy "Users can view their own roles"
  on public.user_roles for select
  using (auth.uid() = user_id);

-- No insert/update/delete policy for regular users: role changes are only
-- made by the signup trigger below (as the table owner) or, later, by an
-- admin-only path once the Admin Dashboard (Phase 11) exists.

-- Auto-create a profile + default "investor" role whenever a new auth user
-- is created, so the client can never forget to do it (or skip it).
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, username)
  values (new.id, split_part(new.email, '@', 1));

  insert into public.user_roles (user_id, role)
  values (new.id, 'investor');

  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- Keep updated_at current on every profile change.
create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists set_profiles_updated_at on public.profiles;
create trigger set_profiles_updated_at
  before update on public.profiles
  for each row execute function public.set_updated_at();
