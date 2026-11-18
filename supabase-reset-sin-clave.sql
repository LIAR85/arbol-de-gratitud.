-- ÁRBOL DE GRATITUD v2: limpieza con dos confirmaciones, SIN contraseña.
-- Se utiliza el nombre NUEVO limpiar_arbol_v2() para evitar ejecutar una función antigua almacenada.
-- Ejecutar o VOLVER A EJECUTAR en Supabase > SQL Editor > New query > Run.
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

create or replace function public.limpiar_arbol_v2()
returns integer
language plpgsql
security definer
set search_path = ''
as $fn$
declare eliminadas integer;
begin
  -- TRUNCATE no utiliza DELETE, por lo que evita la protección que exige WHERE.
  -- Conserva la tabla, sus políticas RLS y su configuración Realtime.
  select count(*)::integer into eliminadas from public.agradecimientos;
  truncate table public.agradecimientos restart identity;
  update public.arbol_control
    set revision = revision + 1, actualizado_en = now()
    where id = true;
  return eliminadas;
end;
$fn$;

revoke all on function public.limpiar_arbol_v2() from public, anon, authenticated;
grant execute on function public.limpiar_arbol_v2() to anon, authenticated;

-- Comprobación opcional de la instalación, SIN borrar datos:
-- select pg_get_functiondef('public.limpiar_arbol_v2()'::regprocedure);
-- El resultado debe contener: TRUNCATE TABLE public.agradecimientos.
