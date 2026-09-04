-- Phase 8 (BOT Chain): wallet abstraction. Mirrors the BOT Chain section
-- of the DB structure in the brief (section 39) and the "keep it simple
-- for non-technical users" goals in section 16.
--
-- Scope deliberately narrowed for this pass (documented in the app): no
-- custodial "auto-create a wallet" flow — that needs a real decision on
-- key-custody architecture (a security-sensitive choice the project
-- hasn't made yet), not something to stub. Only "connect an existing
-- wallet" (register a public address, read-only/watch mode) is real.
-- Balance and transaction sync need a live chain RPC endpoint and the
-- BOT token's contract address, neither of which exist yet — see
-- WalletChainService in the app, which mirrors how LiveKitService
-- (Phase 7) handles the same kind of gap.
--
-- One wallet per user for this pass (brief doesn't call for multiple).

create table if not exists public.wallets (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null unique references public.profiles (id) on delete cascade,
  address text not null check (char_length(address) between 10 and 100),
  created_at timestamptz not null default now()
);

alter table public.wallets enable row level security;

create policy "Users can view their own wallet"
  on public.wallets for select
  to authenticated
  using (user_id = auth.uid());

create policy "Users can connect their own wallet"
  on public.wallets for insert
  to authenticated
  with check (user_id = auth.uid());

create policy "Users can update their own wallet"
  on public.wallets for update
  to authenticated
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

create policy "Users can disconnect their own wallet"
  on public.wallets for delete
  to authenticated
  using (user_id = auth.uid());

-- Structurally real (matches the brief's schema) but stays empty until a
-- backend job can actually sync it from the chain — no insert/update
-- policy for regular users, since only such a job (running with the
-- service role, bypassing RLS) should ever write here.
create table if not exists public.transactions (
  id uuid primary key default gen_random_uuid(),
  wallet_id uuid not null references public.wallets (id) on delete cascade,
  tx_hash text not null,
  direction text not null check (direction in ('send', 'receive')),
  amount numeric not null check (amount >= 0),
  counterparty_address text,
  status text not null default 'confirmed' check (
    status in ('pending', 'confirmed', 'failed')
  ),
  created_at timestamptz not null default now()
);

alter table public.transactions enable row level security;

create policy "Users can view their own wallet's transactions"
  on public.transactions for select
  to authenticated
  using (
    exists (
      select 1 from public.wallets w
      where w.id = transactions.wallet_id and w.user_id = auth.uid()
    )
  );
