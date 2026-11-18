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


## Botón de limpieza administrativa (nuevo)

Hay un botón discreto ⚙ en la esquina inferior derecha de la página. No borra nada sin pasar por **dos confirmaciones** y validar una clave privada en Supabase.

**Configuración obligatoria, una sola vez:**

1. Abre [supabase-admin-setup.sql](./supabase-admin-setup.sql) en GitHub.
2. Copia su contenido a **Supabase Dashboard → SQL Editor → New query**.
3. Antes de ejecutarlo, cambia la cadena `REEMPLAZA_ESTA_FRASE_POR_TU_CLAVE_PRIVADA` por **tu clave privada larga** (mínimo 16 caracteres).
4. Presiona **Run**. Guarda la clave en un lugar seguro. **Nunca la pongas en GitHub, config.js ni en los chats públicos**.
5. Abre Netlify, pulsa ⚙ → confirma → escribe **BORRAR TODO**, ingresa tu clave y pulsa **Borrar las hojas**.

La función `limpiar_arbol_seguro` ejecuta el DELETE exclusivamente en Supabase después de validar la clave con un hash. Ninguna página pública recibe privilegios directos para borrar registros. Cuando se limpia, la tabla de control emite una actualización en tiempo real para vaciar los árboles abiertos en otros dispositivos. También se sincroniza al volver a la página.

**Aviso:** una clave débil podría ser adivinada, así que utiliza una frase larga y aleatoria. No existe protección anti-fuerza-bruta integrada en esta versión. El icono discreto no es una medida de seguridad por sí mismo.

**No ejecutes el archivo SQL de administrador sin reemplazar la clave de ejemplo.** Si ejecutas de nuevo el SQL con otra clave, cambiarás la clave de administración.
