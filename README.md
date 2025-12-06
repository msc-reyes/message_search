# Búsqueda de Mensajes - App Flutter

## 📋 Descripción
Aplicación de escritorio para buscar y visualizar mensajes/sermones en PDF.

## 🎨 Características Implementadas

### Pantalla de Bienvenida
- Selector de tema (Claro/Oscuro)
- Botón para iniciar la aplicación

### Pantalla Principal
- **Visualizador central**: Muestra el mensaje más antiguo por defecto
- **Panel izquierdo (☰)**: Lista de mensajes con búsqueda por título o fecha
- **Panel derecho (≡)**: Búsqueda global en todos los mensajes
- **Barra de búsqueda superior**: Búsqueda dentro del mensaje actual con resaltado

### Funcionalidades
- ✅ Búsqueda normalizada (ignora acentos y mayúsculas)
- ✅ Resaltado de texto en búsqueda local
- ✅ Contador de coincidencias en búsqueda global
- ✅ Snippets de contexto en resultados
- ✅ Temas claro y oscuro
- ✅ Datos dummy para pruebas

## 🚀 Instrucciones de Ejecución

### 1. Navegar al proyecto
```bash
cd ~/develop/message_search
```

### 2. Instalar dependencias
```bash
flutter pub get
```

### 3. Ejecutar en Linux (para desarrollo)
```bash
flutter run -d linux
```

### 4. Compilar para Windows
```bash
flutter build windows
```

El ejecutable estará en: `build/windows/runner/Release/`

## 📦 Dependencias Actuales

```yaml
dependencies:
  flutter:
    sdk: flutter
  sqflite_common_ffi: ^2.3.0+1  # Para cuando conectemos la DB
  path_provider: ^2.1.1
  path: ^1.8.3
  file_picker: ^6.1.1          # Para cuando carguemos PDFs
  syncfusion_flutter_pdf: ^24.1.41  # Para extraer texto de PDFs
```

## 📁 Estructura del Proyecto

```
message_search/
├── lib/
│   ├── main.dart                    # Punto de entrada
│   ├── models/
│   │   └── message.dart             # Modelo de datos + datos dummy
│   ├── screens/
│   │   ├── welcome_screen.dart      # Pantalla de bienvenida
│   │   └── main_screen.dart         # Pantalla principal
│   └── widgets/
│       ├── message_list_drawer.dart  # Panel izquierdo
│       └── global_search_drawer.dart # Panel derecho
```

## 🎯 Próximos Pasos

### Fase 2: Integración de Base de Datos
1. Implementar SQLite con FTS5
2. Crear sistema de indexación
3. Extraer texto de PDFs reales
4. Cargar PDFs a la base de datos

### Fase 3: Funcionalidades Adicionales
1. Abrir PDF original desde el visualizador
2. Exportar resultados de búsqueda
3. Marcadores/favoritos
4. Historial de búsquedas

### Fase 4: Empaquetado
1. Crear instalador para Windows
2. Incluir base de datos inicial
3. Sistema de importación de PDFs

## 🧪 Cómo Probar

1. **Pantalla de Bienvenida**:
   - Cambia entre tema claro y oscuro
   - Presiona "Iniciar"

2. **Lista de Mensajes (Panel Izquierdo)**:
   - Haz clic en el ícono ☰ (arriba izquierda)
   - Busca por título escribiendo "amor" o "fe"
   - Cambia a búsqueda por fecha y escribe "2010"
   - Haz clic en cualquier mensaje para verlo

3. **Búsqueda Global (Panel Derecho)**:
   - Haz clic en el ícono ≡ (arriba derecha)
   - Busca "amor de Dios" o "gracia"
   - Ve los snippets y contador de coincidencias
   - Haz clic en un resultado para ver el mensaje completo

4. **Búsqueda en Mensaje Actual**:
   - En la barra superior, busca "Él"
   - Nota cómo se resalta el texto en el visualizador
   - Prueba sin acentos: "el" también encuentra "Él"

## 💡 Notas Técnicas

### Normalización de Búsqueda
La búsqueda ignora:
- Acentos (á, é, í, ó, ú → a, e, i, o, u)
- Mayúsculas/minúsculas
- La letra ñ se normaliza a n

### Datos Dummy
Actualmente hay 5 mensajes de prueba con fechas entre 2010-2013.
El mensaje más antiguo ("El Fundamento de Nuestra Fe" - 5 Mar 2010) se carga por defecto.

## 🐛 Problemas Conocidos

Ninguno por el momento. Si encuentras algún bug, por favor repórtalo.

## 📝 Licencia

Proyecto personal para uso eclesiástico.
