# 🔧 Backend - Nuevos Archivos Creados

## 📦 Archivos Nuevos (3)

He creado 3 archivos nuevos para el backend:

### 1. `lib/database/database_helper.dart`
**Función:** Manejo de base de datos SQLite con FTS5

**Características:**
- ✅ Tabla `messages` para almacenar mensajes
- ✅ Tabla `messages_fts` con FTS5 para búsqueda full-text
- ✅ Normalización automática (ignora acentos y mayúsculas)
- ✅ Triggers para mantener FTS5 sincronizado
- ✅ Métodos CRUD completos
- ✅ Búsqueda por título, fecha, y contenido
- ✅ Búsqueda global con snippets y conteo de coincidencias

**Ubicación:** `~/develop/message_search/lib/database/database_helper.dart`

### 2. `lib/services/pdf_service.dart`
**Función:** Extracción de texto de PDFs

**Características:**
- ✅ Extrae texto completo de PDFs
- ✅ Limpia y normaliza el texto
- ✅ Parsea nombre de archivo (Título-DD-MM-AAAA.pdf)
- ✅ Valida formato de nombres
- ✅ Procesa múltiples PDFs con callback de progreso
- ✅ Manejo de errores robusto

**Ubicación:** `~/develop/message_search/lib/services/pdf_service.dart`

### 3. `lib/screens/import_screen.dart`
**Función:** Interfaz para importar PDFs

**Características:**
- ✅ Selector de archivos múltiples
- ✅ Validación de nombres en tiempo real
- ✅ Barra de progreso durante importación
- ✅ Manejo de duplicados
- ✅ Reporte de errores detallado
- ✅ Resumen de importación

**Ubicación:** `~/develop/message_search/lib/screens/import_screen.dart`

---

## 📝 Archivo Actualizado (1)

### `lib/models/message.dart` (REEMPLAZAR)
**Cambios:**
- ✅ `id` ahora es nullable (`int?`)
- ✅ Agregado método `toMap()` para SQLite
- ✅ Agregado método `fromMap()` para SQLite
- ✅ Agregado método `copyWith()`
- ✅ Datos dummy siguen disponibles para pruebas

**Ubicación:** `~/develop/message_search/lib/models/message.dart`

---

## 📂 Dónde Colocar los Archivos

```
~/develop/message_search/
├── lib/
│   ├── database/
│   │   └── database_helper.dart       ⬅️ NUEVO (crear carpeta)
│   ├── services/
│   │   └── pdf_service.dart           ⬅️ NUEVO (crear carpeta)
│   ├── screens/
│   │   └── import_screen.dart         ⬅️ NUEVO
│   └── models/
│       └── message.dart               ⬅️ REEMPLAZAR archivo existente
```

---

## 🚀 Instrucciones de Instalación

### 1. Crear las carpetas necesarias

```bash
cd ~/develop/message_search
mkdir -p lib/database
mkdir -p lib/services
```

### 2. Descargar y colocar los archivos

Descarga estos 4 archivos de `/archivos_individuales/`:

1. `lib/database/database_helper.dart` → `~/develop/message_search/lib/database/`
2. `lib/services/pdf_service.dart` → `~/develop/message_search/lib/services/`
3. `lib/screens/import_screen.dart` → `~/develop/message_search/lib/screens/`
4. `lib/models/message.dart` → `~/develop/message_search/lib/models/` (REEMPLAZAR)

### 3. Verificar estructura

```bash
cd ~/develop/message_search
find lib -name "*.dart" | sort
```

Deberías ver:
```
lib/database/database_helper.dart       ← NUEVO
lib/main.dart
lib/models/message.dart                 ← ACTUALIZADO
lib/screens/import_screen.dart          ← NUEVO
lib/screens/main_screen.dart
lib/screens/welcome_screen.dart
lib/services/pdf_service.dart           ← NUEVO
lib/widgets/global_search_drawer.dart
lib/widgets/message_list_drawer.dart
```

---

## 🧪 Próximos Pasos

Después de colocar los archivos:

### Paso 1: Conectar la UI con la Base de Datos

Necesitamos modificar `main_screen.dart` para usar la base de datos real en lugar de datos dummy.

### Paso 2: Agregar botón de importación

En la pantalla principal, agregar un botón para abrir `ImportScreen`.

### Paso 3: Actualizar búsquedas

Conectar los drawers de búsqueda con las queries de SQLite FTS5.

---

## 📋 Formato de Nombres de PDF

**MUY IMPORTANTE:** Los PDFs deben tener este formato:

```
Título del mensaje-DD-MM-AAAA.pdf
```

**Ejemplos válidos:**
- `El amor de Dios-15-03-2010.pdf`
- `La gracia transformadora-22-08-2010.pdf`
- `Viviendo en el Espíritu-03-11-2013.pdf`

**Ejemplos inválidos:**
- `mensaje.pdf` (falta fecha)
- `El amor-2010-03-15.pdf` (orden incorrecto)
- `El amor de Dios_15_03_2010.pdf` (usa guiones bajos)

---

## 🎯 Base de Datos

**Ubicación:** `~/Documentos/MessageSearchDB/messages.db`

La base de datos se crea automáticamente la primera vez que importas mensajes.

**Tablas:**
- `messages` - Información de los mensajes
- `messages_fts` - Índice FTS5 para búsqueda rápida

---

## ⚠️ Notas Importantes

1. **No elimines DummyData todavía**: Los datos dummy siguen en `message.dart` para que la app funcione mientras conectamos todo.

2. **Prueba con pocos PDFs primero**: Renombra 5-10 PDFs y prueba la importación antes de hacer todos.

3. **Backup**: La base de datos es local. Considera hacer backup del archivo `messages.db` regularmente.

---

¿Listo para instalar estos archivos? 🚀
