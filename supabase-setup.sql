-- Árbol de Gratitud · ejecutar una sola vez en Supabase SQL Editor
create table if not exists public.agradecimientos (
  id bigint generated always as identity primary key,
  mensaje text not null check (char_length(btrim(mensaje)) between 3 and 220),
  creado_en timestamptz not null default now()
);

alter table public.agradecimientos enable row level security;
revoke all on public.agradecimientos from anon, authenticated;
grant select, insert (mensaje) on public.agradecimientos to anon, authenticated;
grant usage on schema public to anon, authenticated;

drop policy if exists "Leer agradecimientos" on public.agradecimientos;
create policy "Leer agradecimientos" on public.agradecimientos
for select to anon, authenticated using (true);

drop policy if exists "Enviar agradecimientos" on public.agradecimientos;
create policy "Enviar agradecimientos" on public.agradecimientos
for insert to anon, authenticated with check (char_length(btrim(mensaje)) between 3 and 220);

-- Activar Postgres Changes en tiempo real, sin duplicar la publicación
do $$
begin
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'agradecimientos'
  ) then
    alter publication supabase_realtime add table public.agradecimientos;
  end if;
end $$;
