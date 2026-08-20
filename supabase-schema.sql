-- Doraemon House Ajmer — orders table
-- Run this once in the Supabase SQL Editor (Project → SQL Editor → New query → Run).
-- This replaces whatever 'orders' table currently exists (confirmed empty) with the
-- structure the dashboard needs.

drop table if exists public.orders cascade;

create table public.orders (
  id bigint generated always as identity primary key,
  order_number text generated always as ('DH' || lpad(id::text, 4, '0')) stored,
  customer_name text not null,
  items jsonb not null,
  total numeric(10,2) not null,
  created_at timestamptz not null default now()
);

create index orders_created_at_idx on public.orders (created_at desc);

-- Row Level Security: the app talks to Supabase using the public "publishable" key,
-- so RLS must explicitly allow the actions the dashboard needs (read + insert).
alter table public.orders enable row level security;

create policy "Public can read orders"
  on public.orders
  for select
  to anon
  using (true);

create policy "Public can insert orders"
  on public.orders
  for insert
  to anon
  with check (true);

-- Enable realtime updates so the dashboard refreshes live when any device places an order.
alter publication supabase_realtime add table public.orders;

-- Force the API layer to pick up the new structure immediately.
notify pgrst, 'reload schema';
