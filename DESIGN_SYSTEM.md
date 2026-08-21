# Papeeta — Documentación del diseño actual

> **Para qué sirve este documento:** es el *brief* de entrada para pedirle a Claude Design
> (claude.ai/design) un design system mejorado y luego un rediseño completo de la app.
> Describe lo que **hoy existe** en el código (`lib/`), extraído widget por widget,
> más las inconsistencias que el nuevo sistema debería resolver.
>
> Estado del código al momento de la auditoría: 116 archivos Dart, 11 rutas,
> 11 widgets compartidos, Flutter + Material 3, BLoC/Cubit, go_router.

---

## 0. Estado — este documento ya fue ejecutado

**La auditoría de abajo describe el diseño *anterior*.** El rediseño se diseñó en Claude Design
(proyecto "Papeeta design system fase 1", archivos `Papeeta Design System.dc.html` y
`Papeeta Fase 2.dc.html`) y **ya está implementado en el repo**:

| Dónde | Qué |
|---|---|
| `lib/core/theme/` | Tokens y los dos `ThemeData`. `ColorScheme` explícito claro y oscuro, `TextTheme` de 7 roles sobre Quicksand, espaciado base 4, 5 radios, 5 elevaciones, 6 tokens de movimiento. |
| `lib/widgets/ds/` | Biblioteca de componentes: botones (4 variantes × 5 estados), campo de texto, búsqueda, chips, avatar, tarjetas de receta y grupo, skeletons, empty/error states, bottom sheet, snackbars. |
| `fonts/Quicksand/` | La familia nueva, 4 pesos, como asset del repo. |
| Las 11 pantallas | Migradas a los tokens. Ningún color literal fuera de `lib/core/theme/`. |

Lo resuelto respecto de la sección 6: roles de color corregidos (`onPrimary` volvió a ser blanco),
una sola generación visual, el teal con un rol único, escala tipográfica nombrada, familia de botones
completa, **modo oscuro activo** (`ThemeMode.system`), skeletons en lugar de spinners a pantalla
completa, y errores con reintento. Se eliminaron `ButtonComponent`, `CustomInput`, `RecipeList`,
`SearchField` y `mostrarAlerta`, todos reemplazados por sus equivalentes del sistema.

Queda pendiente lo que depende de la API, no del diseño: favoritos y tiempo de cocción (el diseño los
muestra; `Recipe` no los tiene), la búsqueda de recetas en Home, y una ruta de edición de receta que el
estado "receta incompleta" querría ofrecer.

---

## 1. Identidad de producto

**Papeeta** es una app móvil de recetas de cocina, en español, con foco social:
guardar recetas propias, descubrir por categorías, y compartirlas en grupos privados
("Recetas de la familia", "Recetas que compartimos en reuniones").

- **Plataforma:** Flutter (iOS + Android). No hay web ni desktop en uso real.
- **Idioma de la UI:** español rioplatense (mezcla "tú/vos": *"Ingresá tu contraseña"*, *"Si salís ahora"*, junto a *"No tienes grupos aún"*). **A unificar en el rediseño.**
- **Tono actual:** cálido y cercano, con emojis ocasionales en copy
  (*"Parece que esta es una receta original, recuerda agradecerle a quien te la envió 😊"*).
- **Densidad visual:** contenido dominado por **fotografía de comida**. Las tarjetas de receta
  dedican ~75% de su alto a la imagen. La foto es el elemento de marca más fuerte, no el color.

---

## 2. Tokens actuales

### 2.1 Color

Definido en `lib/main.dart`:

```dart
ColorScheme.fromSeed(
  seedColor:   const Color(0xFF3C1642),
  onPrimary:   const Color(0xFF3C1642),
  onSecondary: const Color(0XFF086375),
)
```

| Token | Valor | Dónde se usa hoy |
|---|---|---|
| **Púrpura marca** | `#3C1642` | Semilla del tema, fondo del ícono adaptativo Android, fondo de AppBars y FABs, fondo de `ButtonComponent` (hardcodeado) |
| **Teal acento** | `#086375` | Títulos de sección en detalle de receta, avatar de autor, FAB y botones de la feature Grupos, link "Crea una cuenta" |
| **Gris fondo** | `#F2F2F2` | Fondo de Login y Register |
| **Gris tarjeta** | `#F0F0F0` | Fondo de las tarjetas de receta en el listado |
| **Gris texto tenue** | `#999999` | Línea de categorías dentro de la tarjeta de receta |
| **Blanco** | `#FFFFFF` | Fondo de inputs, tarjetas de grupo, texto sobre púrpura (53 usos) |
| Negro α12 / α30 | `black12`, `black.withAlpha(30)` | Sombras |
| `black54` / `black87` | Material | Cuerpo de texto e ingredientes / títulos |
| `grey[100]` `grey[400]` `grey[500]` `grey[600]` | Material | Chips informativos, empty states, handles de bottom sheet |

**Semánticos (Material por defecto, sin token propio):**

| Rol | Color | Uso |
|---|---|---|
| Error | `Colors.red` | SnackBars de error (8 usos) |
| Éxito | `Colors.green` | SnackBar "Perfil actualizado" |
| Advertencia | `Colors.orange` | SnackBar "No realizaste ningún cambio" |
| Link | `Colors.blue` + subrayado | Fuente de la receta |

> ⚠️ **No hay archivo de tokens.** Todos los colores son literales dispersos en los widgets.
> No existe modo oscuro.

### 2.2 Tipografía

Familia única: **Inter** (`fonts/Inter/`), pesos 400 / 500 / 600 / 700.
Declarada como `fontFamily: 'Inter'` en el tema. **No hay `TextTheme` definido** — cada
`TextStyle` se escribe inline en el widget.

Escala real observada (por frecuencia de uso):

| px | Peso más común | Rol de facto |
|---|---|---|
| 30 | 400 | Logo "Papeeta" en Login |
| 28 | 700 | Nombre de app en el header del Drawer |
| 24 | — | Título aislado |
| 22 | 700 | Nombre de usuario en Drawer, título de bottom sheet "Crear Grupo" |
| 20 | — | Título aislado |
| **18** | 500 / 600 / 700 | **El más usado (13 veces)** — títulos de tarjeta, títulos de sección, título del SliverAppBar, empty states |
| 17 | 400 | Texto de `ButtonComponent` |
| 16 | 600 | Subtítulo de formulario ("Cambiar contraseña") |
| 15 | 400 / 300 | Ingredientes, pasos, autor, labels de login |
| 14 | 400 | Descripción de grupo, handle "@usuario" |
| **12** | 500 | Metadatos: categorías en tarjeta, chips de conteo, labels de categoría |

> ⚠️ 11 tamaños distintos sin nombres. El rediseño debería colapsarlos a ~6 roles nombrados.

### 2.3 Radios de esquina

| Radio | Usos | Dónde |
|---|---|---|
| `StadiumBorder` (pill) | — | `ButtonComponent`, chips de categoría en detalle de receta |
| 30 | 4 | `CustomInput`, tarjeta de receta del listado |
| 25 | 1 | Tarjetas de la grilla de categorías |
| 20 | 1 | Bottom sheet "Crear Grupo" |
| 16 | 5 | Tarjeta de grupo, bottom sheet de imagen (solo bordes superiores) |
| 15 | 2 | Imagen dentro de la tarjeta de receta |
| **12** | **10 (el más usado)** | `SearchField`, chips informativos, avatares del Drawer |
| 8 | 4 | Imagen de perfil en Drawer, handle del sheet |

> ⚠️ 8 escalas de radio conviviendo. Coexisten dos lenguajes: **pill/30 (pantallas viejas)** y **12/16 (features nuevas)**.

### 2.4 Espaciado

Valores en uso: `4, 5, 6, 8, 10, 12, 15, 16, 20, 24, 30, 40, 50`.

Se distinguen **dos convenciones**:
- **Legacy** (Login, Home, Recetas): múltiplos de 5 → `5, 10, 15, 20, 30, 40, 50`.
- **Nueva** (Grupos, Perfil): múltiplos de 4 → `4, 8, 12, 16, 24`.

Padding de página más común: `EdgeInsets.all(16)` (6 usos) y `EdgeInsets.all(20)`.
Padding horizontal de listas: `20` en recetas, `15` en el carrusel de categorías, `16` en grupos.

### 2.5 Elevación y sombras

Tres recetas de sombra distintas, ninguna tokenizada:

```dart
// Inputs (Login/Perfil) — sombra difusa y baja
BoxShadow(color: Colors.black.withAlpha(30), offset: Offset(0, 5), blurRadius: 5)

// Tarjeta de grupo — sombra moderna sutil
BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 8, offset: Offset(0, 2))

// Círculos de categoría en Home
BoxShadow(color: Colors.black12, blurRadius: 3, spreadRadius: 0.3, offset: Offset(0, 2))
```

Más `elevation: 2` en `ButtonComponent` y en los `Chip` de categoría; `elevation: 1` en AppBars.

### 2.6 Iconografía

**Material Icons** exclusivamente. Mezcla de variantes rellenas y `_outlined` sin criterio:

- Rellenos: `menu`, `home`, `category`, `group`, `person`, `logout`, `search`, `add`, `post_add`, `close`, `arrow_back`, `arrow_forward`, `camera_alt`, `restaurant_menu`, `broken_image`, `visibility` / `visibility_off`
- Outlined: `mail_outline`, `lock_outline`, `person_outline`, `photo_camera_outlined`, `photo_library_outlined`, `group_outlined`

> `restaurant_menu` funciona como ícono de marca cuando no hay imagen de usuario.

---

## 3. Inventario de componentes

### 3.1 Compartidos — `lib/widgets/`

| Componente | API | Comportamiento visual |
|---|---|---|
| **`ButtonComponent`** | `text: String`, `onPressed: Function` | Botón primario. `ElevatedButton` pill (`StadiumBorder`), fondo `#3C1642` **hardcodeado**, texto blanco 17px, alto fijo **55px**, ancho completo, `elevation: 2`. Sin estados disabled/loading/secundario/destructivo. |
| **`CustomInput`** | `icon: IconData`, `placeholder: String`, `textController`, `keyboardType`, `isPassword: bool` | Input tipo "píldora flotante": fondo blanco, radio 30, sombra `(0,5) blur 5`, ícono prefijo, sin bordes. Con `isPassword` agrega toggle de visibilidad ojo. **Sin estado de error ni label ni texto de ayuda.** |
| **`SearchField`** | `onChanged: ValueChanged<String>` | Input relleno gris `grey.shade100`, radio 12, sin borde, ícono lupa. Hint hardcodeado: `'Buscar categoría...'`. `autofocus: true`. |
| **`RecipeList`** | `recipes: List<Recipe>` | Lista vertical no scrolleable (para anidar). Cada ítem: contenedor **260px de alto**, fondo `#F0F0F0`, radio 30, padding 15. Dentro: imagen expandida con radio 15, luego categorías (`12px/w500/#999999`, unidas por `" \| "`, máx. 2 líneas) y título (`18px/w600/black87`), ambos centrados. Toda la tarjeta navega a `/recipe/:id`. |
| **`CustomDrawer`** | — | Header con **degradado** `primary → primary α80` (topLeft→bottomRight), padding `(20,40,20,20)`: avatar 52px radio 12 (o ícono `restaurant_menu` sobre blanco α20), "Papeeta" 28px bold, alias 22px bold, `@usuario` 14px blanco α70. Luego `ListTile`s: Home, Categorías, Mis Grupos, Perfil. Al pie, tras un `Divider`, "Cerrar sesión". |
| **`Logo`** | `titulo: String` | Ícono de la app (`images/app_icon/launcher_icon.png`) en 170px de ancho + título 30px debajo. Margen superior 50. |
| **`LoginLabels`** | `ruta`, `titulo`, `subtitulo` | Par de textos para cambiar entre Login/Register: pregunta en `black54/15/w300` + acción en teal `#086375/18/bold`. |
| **`MyImageWidget`** | `image: dynamic`, `fit`, `width`, `height`, `borderRadius`, `placeholder`, `errorWidget` | Envoltorio polimórfico de imagen: detecta por tipo si es `RecipeImageUpload` (archivo local), `RecipeImage` o `GroupImage` (remotas, vía `CachedNetworkImage`) y resuelve placeholder y fallback. Es el único punto donde la app decide cómo se ve una imagen que falla. |
| **`ImageSourceSheet`** | `onImageSourceSelected: Function(ImageSource)` | Bottom sheet con handle (40×4, `grey.shade400`, radio 8), radio superior 16, dos `ListTile`: "Tomar foto" / "Elegir de la galería". Se abre con `ImageSourceSheet.show(context, ...)`. |
| **`CategorySelectorSheet`** | — (lee `RecipeFormCubit`) | Sheet de selección múltiple: `SearchField` arriba, luego `ExpansionTile` por grupo de categoría con `CheckboxListTile` dentro, botón "Listo" al pie. |

### 3.2 De feature — `lib/features/groups/presentation/widgets/`

| Componente | API | Comportamiento visual |
|---|---|---|
| **`GroupCard`** | `group: RecipeShareGroup`, `onTap: VoidCallback` | Tarjeta blanca radio 16, sombra α08. Imagen de portada 120px (o bloque de 80px con `primary α10` + ícono `group` 40px si no hay). Cuerpo con padding 16: nombre `18/w600`, descripción `14/grey600` máx. 2 líneas, y fila de dos `_InfoChip`. |
| **`_InfoChip`** (privado) | `icon`, `label` | Píldora `grey[100]` radio 12, padding `(10,4)`, ícono 16px + texto `12/grey600`. Usado para "N miembros" / "N recetas". |
| **`CreateGroupSheet`** | — | Sheet blanco radio superior 20, padding 24 + `viewInsets.bottom`. Título "Crear Grupo" `22/bold` con botón `close` a la derecha. Dos `TextFormField` con `OutlineInputBorder` **estándar de Material** (no `CustomInput`). Botón de ancho completo en teal con spinner inline mientras carga. |

> ⚠️ **Dos vocabularios de formulario coexisten:** `CustomInput` (píldora con sombra) en Login/Perfil,
> y `TextFormField` con `OutlineInputBorder` + `labelText` en Crear Grupo y Agregar Receta.

---

## 4. Inventario de pantallas

Rutas en `lib/core/router/app_router.dart` (go_router con `redirect` de auth):

| Ruta | Pantalla | Estructura visual |
|---|---|---|
| `/loading` | `LoadingPage` | **Pantalla vacía con el texto "Espere..." centrado.** Sin logo ni spinner. Dispara `CheckAuthStatus` y redirige. |
| `/login` | `LoginPage` | Fondo `#F2F2F2`. Columna `spaceBetween` al 90% del alto: `Logo` → formulario (padding horizontal **50**) con dos `CustomInput` separados por 20 y `ButtonComponent` → `LoginLabels`. Errores por diálogo `mostrarAlerta`. |
| `/register` | `RegisterPage` | Espejo de Login (`Logo(titulo: 'Registro')`), más un cuarto elemento al pie: el texto *"Terminos y condiciones de uso"* en `FontWeight.w200` — **no es un link, no navega a ningún lado, y le falta la tilde**. |
| `/` | `HomePage` | AppBar púrpura con hamburguesa + Drawer + FAB `post_add`. Cuerpo con pull-to-refresh: **carrusel horizontal de categorías** (alto 114, `CircleAvatar` radio 35 sobre sombra, label 12px de 88px de ancho, 8 categorías **al azar** + ítem final "Ver todas") y debajo `RecipeList`. |
| `/categories` | `CategoriesPage` | AppBar púrpura. **Grilla de 2 columnas** con tarjetas radio 25, más un listado de grupos de categorías. |
| `/categories/:id` | `RecipeListPage` | AppBar púrpura con el nombre de la categoría. `RecipeList` con pull-to-refresh. Al volver dispara `RestoreHomeRecipes`. |
| `/recipe/:id` | `RecipePage` | **La pantalla insignia.** `CustomScrollView` con `SliverAppBar` de **300px expandido**, `stretch`, `pinned`, parallax: carrusel de fotos a pantalla completa + degradado negro (α0→α180) de centro a abajo + indicadores de puntos animados (10px activo / 8px inactivo). El título interpola su padding al colapsar. Cuerpo (padding 20): chips de categoría pill → "Ingredientes" → lista con viñetas y cantidad en negrita → "Preparación" → pasos numerados en negrita → "Fuente" (link azul subrayado o copy de fallback con emoji) → autor con avatar teal de inicial. Títulos de sección en teal `18/w500`. |
| `/preview` | `RecipePage` (modo preview) | Misma pantalla, alimentada con archivos locales antes de guardar. |
| `/addRecipe` | `AddRecipePage` | **806 líneas — la pantalla más compleja.** Formulario largo: nombre, subtítulo, fuente, miniaturas de imágenes con "Agregar imagen", tarjetas numeradas de ingredientes (cantidad / unidad / nombre), pasos de preparación numerados y reordenables, selector de categorías vía sheet. Diálogo de confirmación "¿Cancelar receta?" al salir. |
| `/groups` | `GroupsPage` | AppBar púrpura, FAB **teal** `add`. Lista de `GroupCard` con padding 16. Empty state ilustrado: ícono `group_outlined` 80px `grey[400]`, título `18/w500`, subtítulo, y botón "Crear Grupo" teal. |
| `/groups/:id` | `GroupDetailPage` | **819 líneas.** Header del grupo, sección de miembros con `_MemberChip`, sección de recetas, diálogos de confirmación y un sheet selector de recetas. |

### Patrones de estado (consistentes en toda la app)

- **Cargando:** `Center(child: CircularProgressIndicator())` a pantalla completa. Sin skeletons.
- **Error:** `Center(child: Text(state.message))` — texto crudo, sin ícono ni acción de reintento.
- **Vacío:** texto plano en la mayoría (*"No se encontraron recetas."*). Solo **Grupos** tiene un empty state ilustrado con acción.
- **Feedback:** `SnackBar` con `behavior: floating` y color semántico (Grupos, Perfil); `showDialog` vía `mostrarAlerta` (Login).

> ⚠️ Tres formas distintas de comunicar lo mismo. Y **el error de red se muestra como mensaje técnico sin salida**.

---

## 5. Modelos de datos

Necesarios para que las pantallas diseñadas tengan contenido realista.

```dart
Recipe {
  int id; String title; String subtitle;
  List<RecipeImage> images;        // .url
  List<Ingredient> ingredients;    // { double? amount, IngredientUnit? unit, String name }
  List<Category> categories;
  List<PreparationStep> steps;     // { int order, String description }
  String? link;                    // URL de la fuente
  User? author;
}

Category { int id; String name; int? groupId; CategoryGroup? group; String? imageUrl; }

RecipeShareGroup {
  int? id; String name; String? description;
  User? owner; List<User> members; List<Recipe> recipes;
  List<GroupImage> images; DateTime? createdAt;
}

// ⚠️ Existen DOS clases User distintas, con el mismo nombre:
// lib/core/domain/entities/user.dart          → SIN foto. La usa Recipe.author.
User { String id; String nombreUsuario; String? alias; String? email; }
// lib/features/auth/domain/entities/user.dart → CON foto. La usan el usuario
//   logueado y —contra lo que sugiere su ubicación— RecipeShareGroup.owner/members.
User { String id; String nombreUsuario; String? alias; String? email; String? imagenPerfil; }
```

> **Implicancia de diseño:** el **autor de una receta** no tiene foto disponible en el modelo, así que
> su avatar sólo puede mostrar la inicial. Los **miembros de un grupo** sí la tienen, porque
> `RecipeShareGroup` importa el `User` de `auth/` aunque la entidad viva en `core/`.
> El componente de avatar tiene que tratar las iniciales como caso principal y la foto como opcional.
>
> Que dos clases distintas compartan nombre es una trampa real: al migrar el detalle de grupo, pasar el
> `User` equivocado dio un error de tipo con dos rutas idénticas salvo por el paquete.

**Reglas de formato observadas** (`lib/helpers/formatters.dart` + `RecipePage`):
- El ingrediente se arma como `• {cantidad} {unidad}(s) de {nombre}` — cantidad y unidad en **negrita**, el resto normal.
- La unidad con `id == 11` es "unidad" y **se omite** del texto.
- Si no hay cantidad ni unidad, el nombre del ingrediente se capitaliza.
- Los pasos se muestran como `{order}. {descripción}` con el número en negrita.

---

## 6. Inconsistencias detectadas → qué debe resolver el nuevo design system

Esta es la sección más importante para el rediseño.

### 6.1 🔴 Los roles de color de Material están invertidos

En `main.dart` se sobreescribe `onPrimary` con el púrpura de marca y `onSecondary` con el teal.
En Material 3, `onPrimary` significa *"el color que va **encima** de primary"* (es decir, texto sobre botón púrpura),
no un color de fondo. Consecuencias reales:

- **8 archivos** usan `colorScheme.onPrimary` como **fondo** de AppBars y FABs → obtienen `#3C1642`.
- Pero `ProfilePage`, `CustomDrawer`, `GroupCard` y `GroupDetailPage` usan `colorScheme.primary`,
  que es el tono **derivado por Material 3 a partir de la semilla** — un púrpura distinto, más claro.
- **Resultado visible:** el AppBar de Perfil y el degradado del Drawer son de otro púrpura que el AppBar de Home.
- `onSecondary` (teal) se usa como color de **texto** para los títulos de sección — que semánticamente
  es lo correcto para un "on", pero está definido como acento, no como contraste.
- `ButtonComponent` esquiva el problema hardcodeando `#3C1642` y `Colors.white`.

**A resolver:** definir un `ColorScheme` explícito con roles correctos (`primary`, `onPrimary`,
`secondary`, `surface`, `surfaceContainer`, `outline`, `error`…) y eliminar todo color literal de los widgets.

### 6.2 🟠 Dos generaciones visuales conviviendo

| | Generación "legacy" | Generación "nueva" |
|---|---|---|
| Pantallas | Login, Register, Home, Recetas | Grupos, Perfil |
| Radios | pill / 30 / 25 | 12 / 16 |
| Espaciado | múltiplos de 5 | múltiplos de 4 |
| Inputs | `CustomInput` (píldora con sombra) | `TextFormField` con `OutlineInputBorder` |
| Feedback | `showDialog` | `SnackBar` flotante |
| Empty state | texto plano | ilustrado con acción |
| Acento | púrpura | teal |

**A resolver:** elegir **una** dirección y aplicarla a todo.

### 6.3 🟠 El acento teal no tiene regla

`#086375` aparece en: títulos de sección de receta, avatar de autor, link de registro, FAB de Grupos,
botones de Grupos, chips seleccionados. No hay criterio de cuándo es teal y cuándo púrpura.

**A resolver:** definir si el teal es *color de la feature Grupos*, *color de acción secundaria*, o eliminarlo.

### 6.4 🟡 Sin sistema tipográfico

11 tamaños sin nombre, escritos inline en cada widget. Un cambio tipográfico global hoy exige tocar ~40 archivos.

**A resolver:** `TextTheme` completo con roles nombrados (display / headline / title / body / label).

### 6.5 🟡 `ButtonComponent` está incompleto

Solo existe la variante primaria. No hay: secundario, terciario/texto, destructivo, disabled, con ícono,
con spinner, ni tamaños. Por eso cada pantalla que necesita algo distinto arma su propio `ElevatedButton`
con `styleFrom` inline (Grupos lo hace 3 veces).

**A resolver:** familia de botones con variantes y estados.

### 6.6 🟡 Otros

- **Sin modo oscuro.** Ni siquiera está declarado `darkTheme`.
- **Sin skeletons** — todo carga con un spinner a pantalla completa, incluso el Home con foto.
- **Errores técnicos expuestos:** `Text(state.message)` sin reintento. `ProfilePage` sí traduce
  códigos (`EMAIL_IN_USE` → *"El correo ya está en uso"*) — ese patrón debería generalizarse.
- **`LoadingPage` dice "Espere..."** sin marca ni spinner: es la primera pantalla que ve el usuario.
- **Home mezcla 8 categorías al azar** en cada build (`filtered.shuffle()`), lo que impide memoria visual.
- **Accesibilidad sin verificar:** texto `black54` sobre `#F0F0F0`, y `#999999` a 12px, quedan cerca o por debajo de AA.
- **Mezcla tú/vos** en el copy.
- **Sin tokens de animación** — la única transición explícita es el `AnimatedContainer` de 250ms de los puntos del carrusel.

---

## 7. Restricciones técnicas para el rediseño

Lo que el nuevo design system **debe** respetar:

1. **Flutter + Material 3.** Los componentes se implementarán como widgets Dart. Todo token debe poder
   expresarse en `ThemeData` (`ColorScheme`, `TextTheme`, `CardTheme`, `ElevatedButtonTheme`, `InputDecorationTheme`…).
2. **Móvil primero**, iOS y Android. Sin diseño de tablet ni web por ahora.
3. **Inter** ya está empaquetada en 4 pesos. Cambiar de familia implica agregar assets.
4. **Íconos Material** — cualquier ícono propuesto debe existir en el set de Material Icons.
5. **Contenido dominado por foto** de comida, con relaciones de aspecto variables y a veces ausente
   (hay que diseñar el estado "sin imagen").
6. **Estado con BLoC/Cubit:** cada pantalla tiene estados discretos `Initial / Loading / Loaded / Error`
   (y en formularios, un `Cubit` de formulario). El diseño debe cubrir los cuatro.
7. **Navegación con go_router**, Drawer lateral + FAB contextual. No hay bottom navigation bar hoy
   — evaluarla es una decisión abierta del rediseño.
8. **Todo el copy en español.**

---

## 8. Prompt sugerido para Claude Design

> Copiar este bloque junto con el documento completo.

```text
Adjunto la documentación del diseño actual de Papeeta, una app móvil de recetas
hecha en Flutter (Material 3).

FASE 1 — Diseñá un design system mejorado, partiendo de lo que ya existe:

- Conservá la identidad: púrpura #3C1642 como color de marca y la fotografía de
  comida como elemento visual dominante. Podés reinterpretar el teal #086375 o
  reemplazarlo, pero justificá la decisión.
- Resolvé las inconsistencias de la sección 6 del documento, en especial:
  los roles de color invertidos, las dos generaciones visuales conviviendo,
  y la ausencia de escala tipográfica.
- Entregá: paleta completa con roles semánticos (claro y oscuro), escala
  tipográfica nombrada sobre Inter, escala de espaciado, escala de radios,
  niveles de elevación, y tokens de movimiento.
- Componentes con todas sus variantes y estados (default, hover/pressed,
  disabled, loading, error): botones, inputs, tarjeta de receta, tarjeta de
  grupo, chip, avatar, bottom sheet, app bar, empty state, skeleton, snackbar.
- Mostrá cada componente con contenido real de recetas en español, no lorem ipsum.

FASE 2 — Una vez aprobado el sistema, rediseñá las 11 pantallas de la app
(sección 4 del documento), cada una en sus cuatro estados: cargando, con
contenido, vacío y con error.

Prioridad de pantallas: Home, Detalle de receta, Agregar receta, Grupos.
```

---

*Documento generado a partir de la auditoría del código en `lib/`.*
