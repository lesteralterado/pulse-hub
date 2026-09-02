-- Retroactive fix: 0001's RLS only let a user select their OWN profile
-- row, but Phase 4 already needs to read OTHER users' profiles (tapping a
-- post/comment author), and Phase 5's "start a conversation" search needs
-- to look up users by username. Neither actually worked against real RLS
-- until now — this was missed because the app has been developed and
-- tested against fakes, not a live Supabase project.
--
-- Usernames/bios are meant to be visible within the app (this mirrors
-- how the community feed already broadcasts author info via post_feed),
-- so a broad authenticated-read policy is the right shape here, not a
-- narrower per-feature one.
create policy "Authenticated users can view any profile"
  on public.profiles for select
  to authenticated
  using (true);
