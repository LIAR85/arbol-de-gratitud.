-- Árbol de Gratitud: limpieza ADMINISTRATIVA (ejecutar UNA VEZ en Supabase SQL Editor).
-- 1. Cambia SOLO el valor de clave_admin en el bloque DO por una clave PRIVADA de 16+ caracteres.
-- 2. NO guardes tu clave en GitHub ni en config.js.
-- 3. Ejecuta este archivo en SQL Editor con tu usuario propietario del proyecto.
--
-- El botón de la app pide dos confirmaciones, y la función SQL vuelve a validar
-- la clave en la base de datos. Usuarios normales NO obtienen permisos DELETE.

create extension if not exists pgcrypto with schema extensions;

create schema if not exists private;
revoke all on schema private from public, anon, authenticated;

create table if not exists private.arbol_admin_config (
  id integer primary key default 1 check (id = 1),
  clave_hash text not null
);
revoke all on private.arbol_admin_config from public, anon, authenticated;

do $setup$
declare
  clave_admin text := 'REEMPLAZA_ESTA_FRASE_POR_TU_CLAVE_PRIVADA';
begin
  if clave_admin = 'REEMPLAZA_ESTA_FRASE_POR_TU_CLAVE_PRIVADA'
     or char_length(clave_admin) < 16 then
    raise exception 'Antes de ejecutar, elige una clave privada de al menos 16 caracteres en clave_admin';
  end if;
  insert into private.arbol_admin_config(id,clave_hash)
  values (1, extensions.crypt(clave_admin, extensions.gen_salt('bf', 10)))
  on conflict (id) do update set clave_hash = excluded.clave_hash;
end $setup$;

-- Una revisión pública para avisar a todas las pantallas después del borrado.
create table if not exists public.arbol_control (
  id boolean primary key default true check (id = true),
  revision bigint not null default 0,
  actualizado_en timestamptz not null default now()
);
insert into public.arbol_control (id) values (true) on conflict (id) do nothing;
alter table public.arbol_control enable row level security;
revoke all on public.arbol_control from anon, authenticated;
grant select on public.arbol_control to anon, authenticated;
drop policy if exists "Leer revision del arbol" on public.arbol_control;
create policy "Leer revision del arbol" on public.arbol_control
  for select to anon, authenticated using (true);

-- Actualizar la publicación de Realtime con la tabla de control.
do $realtime$
begin
  if not exists (
    select 1 from pg_publication_tables
    where pubname='supabase_realtime' and schemaname='public' and tablename='arbol_control'
  ) then
    alter publication supabase_realtime add table public.arbol_control;
  end if;
end $realtime$;

-- Solo esta función con clave puede borrar los registros.
create or replace function public.limpiar_arbol_seguro(clave text)
returns integer
language plpgsql
security definer
set search_path = ''
as $fn$
declare
  guardada text;
  eliminadas integer;
begin
  select clave_hash into guardada
    from private.arbol_admin_config where id=1;
  if guardada is null or clave is null
     or extensions.crypt(clave,guardada) is distinct from guardada then
    raise exception 'Clave administrativa incorrecta' using errcode='P0001';
  end if;

  delete from public.agradecimientos;
  get diagnostics eliminadas = row_count;

  update public.arbol_control
    set revision=revision+1, actualizado_en=now()
    where id=true;

  return eliminadas;
end;
$fn$;

revoke all on function public.limpiar_arbol_seguro(text) from public, anon, authenticated;
grant execute on function public.limpiar_arbol_seguro(text) to anon, authenticated;
