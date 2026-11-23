create table public.pendaftaran (
  id uuid primary key default gen_random_uuid(),
  nama text not null check (char_length(nama) between 3 and 120),
  provinsi text not null check (char_length(provinsi) between 3 and 60),
  nomor_sertifikat text check (char_length(nomor_sertifikat) <= 60),
  consent_publik boolean not null default false,
  status text not null default 'pending' check (status in ('pending','disetujui','ditolak')),
  created_at timestamptz not null default now()
);

alter table public.pendaftaran enable row level security;

create policy "pendaftaran publik kirim" on public.pendaftaran for insert to anon, authenticated
  with check (status = 'pending' and consent_publik = true);

create policy "pendaftaran admin baca" on public.pendaftaran for select to authenticated using (public.is_admin());
create policy "pendaftaran admin ubah" on public.pendaftaran for update to authenticated using (public.is_admin()) with check (public.is_admin());
create policy "pendaftaran admin hapus" on public.pendaftaran for delete to authenticated using (public.is_admin());

grant insert on public.pendaftaran to anon;
