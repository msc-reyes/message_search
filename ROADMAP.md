# 🚧 Próximos Pasos - Roadmap de Implementación

## Estado Actual ✅
- ✅ Interfaz completa con datos dummy
- ✅ Tema claro/oscuro
- ✅ Búsqueda normalizada (sin acentos/mayúsculas)
- ✅ Panel de lista de mensajes con filtros
- ✅ Panel de búsqueda global
- ✅ Búsqueda en mensaje actual con resaltado
- ✅ Navegación entre mensajes

## Fase 2: Base de Datos y PDFs 🔄

### 2.1 Configurar SQLite con FTS5

**Archivo**: `lib/database/database_helper.dart`

```dart
// Estructura propuesta:
CREATE TABLE sermons (
  id INTEGER PRIMARY KEY,
  title TEXT NOT NULL,
  date TEXT NOT NULL,
  pdf_path TEXT NOT NULL,
  created_at TEXT NOT NULL
);

CREATE VIRTUAL TABLE sermons_fts USING fts5(
  title, 
  content,
  tokenize='unicode61 remove_diacritics 2'
);
```

**Tareas**:
- [ ] Crear DatabaseHelper class
- [ ] Implementar inicialización de DB
- [ ] Crear tabla de mensajes
- [ ] Crear tabla FTS5 para búsqueda
- [ ] Métodos CRUD básicos

### 2.2 Extracción de Texto de PDFs

**Librería**: `syncfusion_flutter_pdf`

**Archivo**: `lib/services/pdf_service.dart`

```dart
class PDFService {
  Future<String> extractText(String pdfPath) async {
    // Cargar PDF
    // Extraer todo el texto
    // Limpiar y normalizar
    // Retornar texto completo
  }
}
```

**Tareas**:
- [ ] Implementar extracción de texto
- [ ] Manejar errores de PDFs corruptos
- [ ] Optimizar para PDFs grandes
- [ ] Normalizar texto extraído

### 2.3 Sistema de Importación

**Archivo**: `lib/screens/import_screen.dart`

**Funcionalidad**:
- Seleccionar carpeta con PDFs
- Mostrar progreso de importación
- Extraer metadata (fecha del nombre de archivo?)
- Indexar en SQLite + FTS5

**Tareas**:
- [ ] UI de selección de archivos
- [ ] Barra de progreso
- [ ] Validación de PDFs
- [ ] Extracción de metadata
- [ ] Indexación en lote

### 2.4 Integrar DB con UI Existente

**Archivos a modificar**:
- `lib/screens/main_screen.dart`
- `lib/widgets/sermon_list_drawer.dart`
- `lib/widgets/global_search_drawer.dart`

**Cambios**:
```dart
// De:
_sermons = DummyData.getSermons();

// A:
_sermons = await DatabaseHelper.instance.getAllSermons();
```

**Tareas**:
- [ ] Reemplazar datos dummy con queries reales
- [ ] Implementar búsqueda FTS5 en drawer derecho
- [ ] Cargar mensajes de forma asíncrona
- [ ] Manejar estados de carga

## Fase 3: Funcionalidades Avanzadas 🎯

### 3.1 Visor de PDF Original

**Librería**: `pdfx` o `syncfusion_flutter_pdfviewer`

**Funcionalidad**:
- Botón en visualizador: "Abrir PDF Original"
- Ventana nueva o panel para ver PDF
- Navegación de páginas
- Zoom

**Tareas**:
- [ ] Implementar visor de PDF
- [ ] Botón de apertura
- [ ] Controles de navegación

### 3.2 Exportar Resultados

**Formatos**:
- TXT: Lista simple de resultados
- CSV: Para análisis
- PDF: Reporte formateado

**Tareas**:
- [ ] Botón de exportar en búsqueda global
- [ ] Generación de reportes
- [ ] Selección de formato

### 3.3 Favoritos/Marcadores

**Base de datos**:
```sql
CREATE TABLE bookmarks (
  id INTEGER PRIMARY KEY,
  sermon_id INTEGER,
  position INTEGER,
  note TEXT,
  created_at TEXT
);
```

**Tareas**:
- [ ] Sistema de marcadores
- [ ] Lista de favoritos
- [ ] Notas personales

### 3.4 Historial de Búsquedas

**Funcionalidad**:
- Guardar últimas 20 búsquedas
- Sugerencias de autocompletado
- Búsquedas frecuentes

**Tareas**:
- [ ] Guardar historial
- [ ] Dropdown de sugerencias
- [ ] Limpiar historial

## Fase 4: Optimización y Empaquetado 📦

### 4.1 Optimización de Performance

**Áreas**:
- Lazy loading de mensajes
- Cache de búsquedas
- Índices de base de datos
- Scroll virtualization

**Tareas**:
- [ ] Implementar paginación
- [ ] Sistema de cache
- [ ] Optimizar queries SQL
- [ ] Profile de performance

### 4.2 Compilación para Windows

**Comandos**:
```bash
flutter build windows --release
```

**Resultado**:
```
build/windows/runner/Release/
├── sermon_search.exe
├── flutter_windows.dll
└── data/
```

**Tareas**:
- [ ] Compilar versión release
- [ ] Probar en Windows limpio
- [ ] Optimizar tamaño del ejecutable

### 4.3 Instalador para Windows

**Herramienta**: Inno Setup

**Incluir**:
- Ejecutable y DLLs
- Base de datos vacía (schema)
- Ícono de la aplicación
- Shortcuts de escritorio/menú inicio

**Script de Inno Setup** (`installer.iss`):
```pascal
[Setup]
AppName=Búsqueda de Mensajes
AppVersion=1.0
DefaultDirName={pf}\SermonSearch
OutputBaseFilename=SermonSearch-Setup
Compression=lzma2
SolidCompression=yes

[Files]
Source: "build\windows\runner\Release\*"; DestDir: "{app}"; Flags: recursesubdirs

[Icons]
Name: "{commondesktop}\Búsqueda de Mensajes"; Filename: "{app}\sermon_search.exe"
```

**Tareas**:
- [ ] Instalar Inno Setup en Windows
- [ ] Crear script de instalador
- [ ] Generar ejecutable de setup
- [ ] Probar instalación/desinstalación

### 4.4 Base de Datos Inicial

**Opciones**:

**Opción A**: Base vacía que se puebla en primera ejecución
- Usuario importa sus PDFs
- Más flexible

**Opción B**: Base pre-poblada incluida
- PDFs convertidos a texto en instalación
- Más rápido para usuario

**Tareas**:
- [ ] Decidir estrategia
- [ ] Implementar primera ejecución
- [ ] Wizard de importación

## Fase 5: Pulido Final ✨

### 5.1 Mejoras de UX

**Lista de mejoras**:
- [ ] Animaciones suaves
- [ ] Feedback visual mejorado
- [ ] Tooltips explicativos
- [ ] Atajos de teclado (Ctrl+F, Ctrl+K, etc.)
- [ ] Modo de presentación (fullscreen)

### 5.2 Manejo de Errores

**Scenarios**:
- PDF corrupto o no legible
- Base de datos corrupta
- Sin permisos de escritura
- Disco lleno

**Tareas**:
- [ ] Try-catch comprehensivos
- [ ] Mensajes de error amigables
- [ ] Logging de errores
- [ ] Recovery automático cuando sea posible

### 5.3 Testing

**Tipos**:
- Unit tests (lógica de negocio)
- Widget tests (UI)
- Integration tests (flujos completos)

**Tareas**:
- [ ] Tests de búsqueda
- [ ] Tests de importación
- [ ] Tests de navegación
- [ ] Tests de database

### 5.4 Documentación

**Para usuarios**:
- [ ] Manual de usuario
- [ ] Video tutorial (opcional)
- [ ] FAQ

**Para desarrollo**:
- [ ] Comentarios de código
- [ ] Documentación de API
- [ ] Diagramas de arquitectura

## Estimación de Tiempo ⏱️

| Fase | Tiempo Estimado |
|------|----------------|
| Fase 2 (DB + PDF) | 2-3 días |
| Fase 3 (Features) | 2-3 días |
| Fase 4 (Package) | 1-2 días |
| Fase 5 (Polish) | 1-2 días |
| **TOTAL** | **6-10 días** |

## Orden de Implementación Sugerido 🎯

1. **Prioridad Alta** (Core functionality):
   - ✅ Base de datos SQLite
   - ✅ Extracción de PDFs
   - ✅ Sistema de importación
   - ✅ Integrar con UI

2. **Prioridad Media** (Nice to have):
   - Visor de PDF
   - Exportar resultados
   - Favoritos

3. **Prioridad Baja** (Polish):
   - Historial
   - Animaciones
   - Testing exhaustivo

## Siguientes Pasos Inmediatos 🚀

Para continuar con el desarrollo, el siguiente paso lógico es:

### Implementar DatabaseHelper

```bash
# Crear archivo
touch lib/database/database_helper.dart
```

¿Quieres que empecemos con la implementación de la base de datos y extracción de PDFs?
