# REGLAS DE DESIGN SYSTEM, UI & UX MOBILE: NEOBRUTALISMO RESPONSIVE

## 1. PRINCIPIOS GENERALES & LAYOUT MOBILE
- **Mobile First Focus:** Todo componente debe ser diseñado pensando primero en pantallas de 360px a 430px de ancho antes que en versión Desktop.
- **Sin Overflow Horizontal:** `overflow-x: hidden` obligatorio en el contenedor raíz. Las sombras neobrutalistas rígidas NO deben provocar scroll horizontal.
- **Unidades de Pantalla Completa:** Usa `dvh` (Dynamic Viewport Height) en lugar de `vh` o `100%` para evitar cierres o solapamientos con la barra del navegador o teclado virtual en iOS/Android.
- **Padding Lateral Seguro:** Mantén un padding lateral constante de 16px (`px-4`) a 20px (`px-5`) en la pantalla principal para dar espacio a los bordes y sombras de las cards.

## 2. ADAPTACIÓN NEOBRUTALISTA PARA MOBILE
- **Escalado de Sombras:** Reducir el offset de las sombras paralelas respecto a Desktop.
  - Desktop: `box-shadow: 5px 5px 0px #000;`
  - Mobile: `box-shadow: 2px 2px 0px #000;` o `3px 3px 0px #000;`
- **Grosor de Bordes:** Usar bordes sólidos negros de 2px (`border-2 border-black`) en mobile para mantener legibilidad sin recargar visualmente la pantalla.
- **Paleta de Colores y Contraste:**
  - Fondos de pantalla neutrales o pastel suave.
  - Colores de acento saturados (amarillo, cian, magenta, verde lima) para elementos interactivos primarios.
  - El texto siempre debe ser negro puro (`#000000`) sobre fondos claros, asegurando un contraste WCAG AA mínimo de 4.5:1.

## 3. ACCESIBILIDAD, TOUCH TARGETS & ZONA DEL PULGAR
- **Tamaño Mínimo Táctil:** Todo botón, input, checkbox o icono clicleable DEBE tener un área de contacto mínima de 48x48px (`min-h-[48px] min-w-[48px]`).
- **Estados Activos (Reemplazo de Hover):** Eliminar la dependencia de `:hover`. Implementar estados `:active` visualmente fuertes para mobile:
  - Al hacer Tap/Press: `transform: translate(2px, 2px); box-shadow: 0px 0px 0px #000;` (Efecto de botón presionado).
- **Thumb Zone Strategy:**
  - Acciones clave (FABs, botones principales) deben situarse en el tercio inferior de la pantalla.
  - Usar una barra de navegación inferior fija (`Bottom Navigation Bar`) en lugar de menús desplegables superiores.

## 4. TIPOGRAFÍA Y COMPONENTES
- **Prevenir Auto-Zoom en iOS:** Los inputs de formulario deben tener una tipografía base de **16px mínimo** (`text-base`).
- **Manejo de Títulos Largos:** Prever truncation (`text-ellipsis overflow-hidden whitespace-nowrap`) o permitir saltos de línea sin que las fuentes gruesas (Sans-serif pesadas/Display) rompan los contenedores.
- **Inputs & Formularios:**
  - Bordes de 2px color negro.
  - Al enfocar (`:focus`), cambiar el fondo a un color pastel de acento o incrementar la sombra a 4px.
  - Botón de envío fijo en la parte inferior o flotante arriba del teclado.
- **Cards & Paneles:**
  - Padding interno de 12px a 16px.
  - Evitar meter más de 2 columnas en mobile. Las listas o grillas de cards deben colapsar a 1 sola columna (`grid-cols-1`).

## 5. REGLAS TÉCNICAS Y RESTRICCIONES PARA CÓDIGO
- Usar clases utilitarias de Tailwind o CSS limpio.
- Garantizar que los modales, bottom sheets y drawers tengan un área de cierre táctil clara (`X` superior derecha de al menos 48px).
- Deshabilitar el highlighting azul por defecto en navegadores mobile: `-webkit-tap-highlight-color: transparent;`.