create table public.admins (
  user_id uuid primary key references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);

create table public.forums (
  id uuid primary key default gen_random_uuid(),
  nama text not null,
  slug text not null unique,
  kategori text not null check (kategori in ('provinsi','kabupaten_kota','kl','profesi','bumn','perpaksinas')),
  wilayah text,
  dikukuhkan_oleh text,
  tanggal_pengukuhan date,
  masa_bakti_mulai date,
  masa_bakti_selesai date,
  status text not null default 'aktif' check (status in ('aktif','tidak_aktif')),
  sumber_url text,
  logo_path text,
  updated_at timestamptz not null default now()
);

create table public.pengurus (
  id uuid primary key default gen_random_uuid(),
  forum_id uuid references public.forums(id) on delete cascade,
  nama text not null,
  jabatan text not null,
  bidang text,
  masa_bakti_mulai date,
  masa_bakti_selesai date,
  urutan int not null default 0
);

create table public.penyuluh (
  id uuid primary key default gen_random_uuid(),
  forum_id uuid not null references public.forums(id) on delete cascade,
  nama text not null,
  foto_path text,
  consent_publik boolean not null default false
);

create table public.perpaksinas_info (
  id int primary key default 1 check (id = 1),
  sejarah text,
  tagline text,
  visi text,
  misi text,
  kontak text,
  updated_at timestamptz not null default now()
);

create table public.berita (
  id uuid primary key default gen_random_uuid(),
  judul text not null,
  slug text not null unique,
  isi text,
  forum_id uuid references public.forums(id) on delete set null,
  published_at timestamptz,
  status text not null default 'draft' check (status in ('draft','terbit'))
);

alter table public.admins enable row level security;
alter table public.forums enable row level security;
alter table public.pengurus enable row level security;
alter table public.penyuluh enable row level security;
alter table public.perpaksinas_info enable row level security;
alter table public.berita enable row level security;

create or replace function public.is_admin() returns boolean
language sql stable security definer set search_path = public as $$
  select exists (select 1 from public.admins where user_id = auth.uid());
$$;

create policy "admins hanya admin baca" on public.admins for select to authenticated using (public.is_admin());

create policy "forum publik baca" on public.forums for select to anon, authenticated using (status = 'aktif' or public.is_admin());
create policy "forum admin tulis" on public.forums for all to authenticated using (public.is_admin()) with check (public.is_admin());

create policy "pengurus publik baca" on public.pengurus for select to anon, authenticated using (true);
create policy "pengurus admin tulis" on public.pengurus for all to authenticated using (public.is_admin()) with check (public.is_admin());

create policy "penyuluh publik baca" on public.penyuluh for select to anon, authenticated using (consent_publik = true or public.is_admin());
create policy "penyuluh admin tulis" on public.penyuluh for all to authenticated using (public.is_admin()) with check (public.is_admin());

create policy "info publik baca" on public.perpaksinas_info for select to anon, authenticated using (true);
create policy "info admin tulis" on public.perpaksinas_info for all to authenticated using (public.is_admin()) with check (public.is_admin());

create policy "berita publik baca" on public.berita for select to anon, authenticated using (status = 'terbit' or public.is_admin());
create policy "berita admin tulis" on public.berita for all to authenticated using (public.is_admin()) with check (public.is_admin());

revoke all on public.admins from anon;
grant select on public.forums, public.pengurus, public.penyuluh, public.perpaksinas_info, public.berita to anon;
