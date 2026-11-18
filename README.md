# 🌳 Árbol de Gratitud · Friends Giving

Página móvil y modo proyección para una reunión de mujeres. Los agradecimientos anónimos se convierten en hojas del árbol.

## Activar el árbol compartido (Supabase)

1. Crea un proyecto en https://supabase.com/dashboard.
2. Ve a **SQL Editor → New query**. Copia TODO el contenido de [supabase-setup.sql](./supabase-setup.sql), pégalo y pulsa **Run**. Esto crea la tabla `public.agradecimientos`, habilita RLS y añade la tabla a `supabase_realtime`.
3. En Supabase busca **Project URL** y la **Publishable key** (no la Secret key ni `service_role`).
4. Edita [config.js](./config.js) y sustituye `TU_PROJECT_URL` y `TU_PUBLISHABLE_KEY` por los valores públicos del proyecto.
5. Netlify debe publicar la carpeta raíz `.`, sin build command; al recibir el commit se actualizará si tienes despliegue automático activado.
6. Prueba con **dos dispositivos distintos**: envía una hoja desde uno y comprueba que aparece en el otro sin recargar.

### Aviso de privacidad y moderación

**Cualquier persona que tenga el enlace puede ver y publicar mensajes anónimos**, sin inicio de sesión. La política de seguridad (RLS) permite solo lectura e inserción, no modificación ni borrado desde la página. Esta configuración es adecuada para un evento pequeño y privado por enlace, pero **no es una protección contra spam ni abuso**. No pidas datos personales, revisa el contenido antes de proyectarlo si se necesita moderación y desactiva el acceso público al finalizar el evento.

## Si todavía no configuras Supabase

La aplicación usa un modo de demostración local con `localStorage`. Puedes abrir `index.html` directamente o con Live Server, pero las hojas no se comparten entre dispositivos hasta completar los pasos de Supabase.

## Archivos

- `index.html`: aplicación responsive con árbol, formulario, modo proyección y sincronización.
- `config.js`: URL y clave pública de Supabase (se pueden publicar, **nunca** poner aquí claves secretas).
- `supabase-setup.sql`: tabla, políticas RLS y publicación realtime.


## Limpieza del árbol sin contraseña (dos confirmaciones)

El botón ⚙ de la esquina inferior derecha es pequeño y permanece fijo. Al tocarlo:
1. Aparece una primera confirmación: **Continuar**.
2. Aparece la segunda: **Sí, borrar todas las hojas**.
3. Si confirma, se eliminan todos los agradecimientos y se avisa a las pantallas abiertas a través de Supabase Realtime.

### Activación obligatoria en Supabase (una vez)

Abre [supabase-reset-sin-clave.sql](./supabase-reset-sin-clave.sql), copia todo su contenido y ejecútalo desde **Supabase Dashboard → SQL Editor → New query → Run**. La app llama a `limpiar_arbol_v2()`. Sin ese paso, el botón mostrará un error y no borrará los registros.

**ADVERTENCIA DE SEGURIDAD:** La doble confirmación previene borrados accidentales, **no autoriza al usuario**. Como la función SQL está disponible a usuarios anónimos, **cualquier persona con acceso al sitio puede borrar toda la tabla**, incluso invocándola sin usar el botón. Usa esta configuración solo si aceptas ese riesgo. Para una protección real se necesita autenticación de administrador o un servicio con autorización del lado del servidor.

No es necesario ejecutar el anterior `supabase-admin-setup.sql` para esta versión. Este se conserva solo por historial.

### Si aparece «DELETE requires a WHERE clause»
La versión nueva utiliza la función `public.limpiar_arbol_v2()` para evitar una versión antigua de la función SQL que ejecutaba DELETE. Debes volver a ejecutar **todo** [supabase-reset-sin-clave.sql](./supabase-reset-sin-clave.sql) en el SQL Editor y asegurarte de que Netlify publique el commit actualizado. Puedes comprobar la función sin borrar ningún dato con `select pg_get_functiondef('public.limpiar_arbol_v2()'::regprocedure);` y confirmar que contiene `truncate table public.agradecimientos`. Si la función no existe, el script no se ejecutó correctamente.
