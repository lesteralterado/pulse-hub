-- One-time backfill: any auth.users row created before 0001's
-- on_auth_user_created trigger existed has no matching public.profiles /
-- public.user_roles row, since that trigger only fires on new signups. Every
-- insert that references profiles(id) (groups.created_by, posts.author_id,
-- etc.) fails its foreign key check for those accounts until backfilled.
-- Safe to run more than once: both inserts skip rows that already exist.

insert into public.profiles (id, username)
select u.id, split_part(u.email, '@', 1)
from auth.users u
left join public.profiles p on p.id = u.id
where p.id is null;

insert into public.user_roles (user_id, role)
select u.id, 'investor'
from auth.users u
left join public.user_roles r on r.user_id = u.id and r.role = 'investor'
where r.user_id is null;
