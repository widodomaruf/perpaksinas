-- 1. Cabut izin tulis & truncate dari anon dan authenticated (admin tetap lewat RLS)
revoke insert, update, delete, truncate on public.berita, public.forums, public.pengurus, public.penyuluh, public.perpaksinas_info from anon;
revoke truncate on public.berita, public.forums, public.pengurus, public.penyuluh, public.perpaksinas_info, public.pendaftaran from authenticated;

-- 2. Pendaftaran: anon hanya boleh INSERT (baca tetap ditolak RLS)
revoke all on public.pendaftaran from anon;
grant insert on public.pendaftaran to anon;

-- 3. Fungsi utilitas tidak boleh dipanggil lewat API publik
revoke execute on function public.rls_auto_enable() from public, anon, authenticated;

-- 4. Hanya URL https untuk sumber berita
alter table public.berita add constraint berita_sumber_url_https check (sumber_url is null or sumber_url ~ '^https://');
