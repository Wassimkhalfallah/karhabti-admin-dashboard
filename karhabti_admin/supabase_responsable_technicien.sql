-- Role Responsable Technicien - schema + RLS baseline

create table if not exists public.responsables_techniciens (
  id uuid not null references auth.users(id) on delete cascade,
  garage_id uuid references public.garages(id) on delete set null,
  nom_complet text not null,
  telephone text,
  est_actif boolean not null default true,
  created_by uuid references auth.users(id),
  created_at timestamptz default now(),
  updated_at timestamptz default now(),
  constraint responsables_techniciens_pkey primary key (id)
);

create table if not exists public.piece_recommendations (
  id uuid not null default gen_random_uuid(),
  responsable_id uuid not null references public.responsables_techniciens(id),
  immatriculation text not null references public.voiture(immatriculation),
  piece_type text not null,
  piece_id integer,
  recommendation text not null,
  created_at timestamptz default now(),
  updated_at timestamptz default now(),
  constraint piece_recommendations_pkey primary key (id)
);

create unique index if not exists piece_reco_unique_idx
  on public.piece_recommendations (responsable_id, immatriculation, piece_type);

create table if not exists public.piece_validations (
  id uuid not null default gen_random_uuid(),
  responsable_id uuid not null references public.responsables_techniciens(id),
  immatriculation text not null references public.voiture(immatriculation),
  piece_type text not null,
  piece_id integer,
  rendez_vous_id uuid references public.rendez_vous(id),
  date_remplacement timestamptz default now(),
  note text,
  created_at timestamptz default now(),
  constraint piece_validations_pkey primary key (id)
);

alter table public.responsables_techniciens enable row level security;
alter table public.piece_recommendations enable row level security;
alter table public.piece_validations enable row level security;

-- responsables_techniciens policies
drop policy if exists rt_select on public.responsables_techniciens;
create policy rt_select on public.responsables_techniciens
for select to authenticated
using (
  id = auth.uid()
  or exists(select 1 from public.admins a where a.id = auth.uid())
);

drop policy if exists rt_insert on public.responsables_techniciens;
create policy rt_insert on public.responsables_techniciens
for insert to authenticated
with check (
  exists(select 1 from public.admins a where a.id = auth.uid())
);

drop policy if exists rt_update on public.responsables_techniciens;
create policy rt_update on public.responsables_techniciens
for update to authenticated
using (
  id = auth.uid() or exists(select 1 from public.admins a where a.id = auth.uid())
)
with check (
  id = auth.uid() or exists(select 1 from public.admins a where a.id = auth.uid())
);

drop policy if exists rt_delete on public.responsables_techniciens;
create policy rt_delete on public.responsables_techniciens
for delete to authenticated
using (exists(select 1 from public.admins a where a.id = auth.uid()));

-- piece_recommendations policies
drop policy if exists pr_all_owner on public.piece_recommendations;
create policy pr_all_owner on public.piece_recommendations
for all to authenticated
using (
  responsable_id = auth.uid()
  or exists(select 1 from public.admins a where a.id = auth.uid())
)
with check (
  responsable_id = auth.uid()
  or exists(select 1 from public.admins a where a.id = auth.uid())
);

-- piece_validations policies
drop policy if exists pv_all_owner on public.piece_validations;
create policy pv_all_owner on public.piece_validations
for all to authenticated
using (
  responsable_id = auth.uid()
  or exists(select 1 from public.admins a where a.id = auth.uid())
)
with check (
  responsable_id = auth.uid()
  or exists(select 1 from public.admins a where a.id = auth.uid())
);
