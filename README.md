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
