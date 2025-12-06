# 🔄 Actualización UI → Base de Datos

## 📦 Archivos Actualizados (3)

He actualizado 3 archivos para conectar la UI con la base de datos:

### 1. `lib/screens/main_screen.dart` (REEMPLAZAR)
**Cambios principales:**
- ✅ Carga mensajes desde base de datos
- ✅ Usa datos dummy si la DB está vacía
- ✅ Botón flotante "Importar PDFs"
- ✅ Banner naranja cuando usa datos dummy
- ✅ Estado de carga con CircularProgressIndicator
- ✅ Pantalla vacía cuando no hay mensajes

### 2. `lib/widgets/message_list_drawer.dart` (REEMPLAZAR)
**Cambios principales:**
- ✅ Búsqueda por título en base de datos
- ✅ Búsqueda por fecha en base de datos
- ✅ Indicador de carga durante búsqueda
- ✅ Badge "Datos de prueba" cuando usa dummy data

### 3. `lib/widgets/global_search_drawer.dart` (REEMPLAZAR)
**Cambios principales:**
- ✅ Búsqueda FTS5 en base de datos
- ✅ Badge "FTS5" cuando usa DB real
- ✅ Snippets y conteo de coincidencias desde DB
- ✅ Fallback a búsqueda en memoria para dummy data

---

## 📂 Dónde Colocar

```bash
# REEMPLAZAR estos 3 archivos existentes:
~/develop/message_search/lib/screens/main_screen.dart
~/develop/message_search/lib/widgets/message_list_drawer.dart
~/develop/message_search/lib/widgets/global_search_drawer.dart
```

---

## 🚀 Instrucciones

### 1. Descargar archivos actualizados

De `/archivos_individuales/`:
1. `lib/screens/main_screen.dart`
2. `lib/widgets/message_list_drawer.dart`
3. `lib/widgets/global_search_drawer.dart`

### 2. Reemplazar archivos existentes

```bash
cd ~/develop/message_search

# Hacer backup (opcional pero recomendado)
cp lib/screens/main_screen.dart lib/screens/main_screen.dart.backup
cp lib/widgets/message_list_drawer.dart lib/widgets/message_list_drawer.dart.backup
cp lib/widgets/global_search_drawer.dart lib/widgets/global_search_drawer.dart.backup

# Reemplazar con los nuevos (arrastra los archivos descargados)
```

### 3. Verificar que compile

```bash
cd ~/develop/message_search
flutter run -d linux
```

---

## ✨ Nuevas Funcionalidades

### 🔵 Modo Automático Dummy/DB

La app ahora detecta automáticamente:
- **Si DB está vacía** → Usa datos dummy + banner naranja
- **Si DB tiene mensajes** → Usa datos reales + badge FTS5

### 🔘 Botón de Importación

Botón flotante en la pantalla principal:
- Abre la pantalla de importación
- Después de importar, recarga automáticamente

### 🔍 Búsquedas Inteligentes

**Panel Izquierdo (Lista):**
- Búsqueda en DB si hay datos reales
- Búsqueda en memoria si usa dummy

**Panel Derecho (Global):**
- Búsqueda FTS5 rápida si hay DB
- Búsqueda en memoria si usa dummy
- Badge verde "FTS5" cuando usa la DB

### 📊 Indicadores Visuales

- Banner naranja: "Mostrando datos de prueba"
- Badge "Datos de prueba" en panel izquierdo
- Badge verde "FTS5" en resultados de búsqueda
- Estado de carga en búsquedas

---

## 🧪 Cómo Probar

### Paso 1: Ejecutar con datos dummy

```bash
flutter run -d linux
```

**Deberías ver:**
- ✅ Banner naranja "Mostrando datos de prueba"
- ✅ 5 mensajes dummy
- ✅ Botón flotante "Importar PDFs"
- ✅ Badge "Datos de prueba" en panel izquierdo

### Paso 2: Importar PDFs de prueba

1. Renombra 2-3 PDFs con formato: `Título-DD-MM-AAAA.pdf`
2. Haz clic en el botón "Importar PDFs"
3. Selecciona tus PDFs
4. Haz clic en "Importar"

### Paso 3: Ver mensajes reales

Después de importar:
- ✅ El banner naranja desaparece
- ✅ Ves tus mensajes importados
- ✅ Badge verde "FTS5" en búsqueda global
- ✅ Búsquedas usan la base de datos

---

## 📋 Formato de PDFs (Recordatorio)

```
Título del mensaje-DD-MM-AAAA.pdf
```

**Ejemplos:**
- `El amor de Dios-15-03-2010.pdf` ✅
- `La gracia transformadora-22-08-2024.pdf` ✅
- `Viviendo en el Espíritu-03-11-2013.pdf` ✅

**Incorrectos:**
- `mensaje.pdf` ❌
- `El amor-2010-03-15.pdf` ❌ (orden incorrecto)
- `El amor_15_03_2010.pdf` ❌ (guiones bajos)

---

## 🎯 Resumen de Cambios

| Archivo | Antes | Ahora |
|---------|-------|-------|
| `main_screen.dart` | Solo dummy data | DB automática + fallback |
| `message_list_drawer.dart` | Búsqueda en memoria | Búsqueda en DB |
| `global_search_drawer.dart` | Búsqueda manual | Búsqueda FTS5 |

---

## ⚠️ Notas Importantes

1. **Los datos dummy siguen disponibles**: Si la DB está vacía, la app funciona con datos de prueba automáticamente.

2. **La DB se crea sola**: No necesitas crear nada manualmente, se inicializa al importar el primer PDF.

3. **Ubicación de la DB**: `~/Documentos/MessageSearchDB/messages.db`

4. **Prueba con pocos PDFs primero**: 2-3 PDFs para verificar que todo funciona antes de importar todos.

---

## 🐛 Solución de Problemas

### Error: "package:xxx/xxx.dart not found"

```bash
flutter clean
flutter pub get
```

### La app no compila

Verifica que tengas todos los archivos del backend:
- `lib/database/database_helper.dart`
- `lib/services/pdf_service.dart`
- `lib/screens/import_screen.dart`
- `lib/models/message.dart` (actualizado)

### No aparece el botón de importar

Verifica que reemplazaste `main_screen.dart` correctamente.

---

¿Listo para probarlo? 🚀
