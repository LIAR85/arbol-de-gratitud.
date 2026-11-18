-- ÁRBOL DE GRATITUD: limpieza con dos confirmaciones, SIN contraseña.
-- Ejecutar UNA SOLA VEZ en Supabase > SQL Editor > New query > Run.
-- ADVERTENCIA: cualquier persona que tenga el enlace puede invocar esta función
-- y borrar todos los agradecimientos, incluso sin usar el botón.

-- Eliminar permiso del antiguo procedimiento con contraseña (si existe).
do $$
begin
  if to_regprocedure('public.limpiar_arbol_seguro(text)') is not null then
    revoke execute on function public.limpiar_arbol_seguro(text) from public, anon, authenticated;
  end if;
end $$;

create table if not exists public.arbol_control (
  id boolean primary key default true check(id = true),
  revision bigint not null default 0,
  actualizado_en timestamptz not null default now()
);
insert into public.arbol_control(id) values(true) on conflict(id) do nothing;
alter table public.arbol_control enable row level security;
revoke all on public.arbol_control from anon, authenticated;
grant select on public.arbol_control to anon, authenticated;
drop policy if exists "Leer revision del arbol" on public.arbol_control;
create policy "Leer revision del arbol" on public.arbol_control
  for select to anon, authenticated using (true);

do $$
begin
  if not exists (
    select 1 from pg_publication_tables
    where pubname='supabase_realtime'
    and schemaname='public'
    and tablename='arbol_control'
  ) then
    alter publication supabase_realtime add table public.arbol_control;
  end if;
end $$;

create or replace function public.limpiar_arbol_confirmado()
returns integer
language plpgsql
security definer
set search_path = ''
as $fn$
declare eliminadas integer;
begin
  -- Supabase puede exigir WHERE para operaciones DELETE.
  -- El ID de esta tabla es identity bigint y sus valores son positivos.
  delete from public.agradecimientos where id > 0;
  get diagnostics eliminadas = row_count;
  update public.arbol_control
    set revision = revision + 1, actualizado_en = now()
    where id = true;
  return eliminadas;
end;
$fn$;

revoke all on function public.limpiar_arbol_confirmado() from public, anon, authenticated;
grant execute on function public.limpiar_arbol_confirmado() to anon, authenticated;
