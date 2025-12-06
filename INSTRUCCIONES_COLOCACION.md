# 📂 Guía de Colocación de Archivos

## 🎯 Instrucciones

Después de descargar todos los archivos, debes colocarlos en la siguiente estructura dentro de `~/develop/message_search/`

## 📁 Estructura Completa

```
~/develop/message_search/
│
├── lib/                                # Carpeta principal de código
│   ├── main.dart                       # ⬇️ DESCARGA: lib/main.dart
│   │
│   ├── models/                         # Carpeta de modelos
│   │   └── message.dart                # ⬇️ DESCARGA: lib/models/message.dart
│   │
│   ├── screens/                        # Carpeta de pantallas
│   │   ├── welcome_screen.dart         # ⬇️ DESCARGA: lib/screens/welcome_screen.dart
│   │   └── main_screen.dart            # ⬇️ DESCARGA: lib/screens/main_screen.dart
│   │
│   └── widgets/                        # Carpeta de widgets
│       ├── message_list_drawer.dart    # ⬇️ DESCARGA: lib/widgets/message_list_drawer.dart
│       └── global_search_drawer.dart   # ⬇️ DESCARGA: lib/widgets/global_search_drawer.dart
│
├── README.md                           # ⬇️ DESCARGA: README.md
├── RESUMEN.md                          # ⬇️ DESCARGA: RESUMEN.md
├── INTERFAZ.md                         # ⬇️ DESCARGA: INTERFAZ.md
├── ROADMAP.md                          # ⬇️ DESCARGA: ROADMAP.md
├── CAMBIOS.md                          # ⬇️ DESCARGA: CAMBIOS.md
├── INICIO_RAPIDO.md                    # ⬇️ DESCARGA: INICIO_RAPIDO.md
└── setup.sh                            # ⬇️ DESCARGA: setup.sh
```

## 🚀 Pasos de Instalación

### Opción 1: Manualmente (si descargaste archivos individuales)

```bash
# 1. Crear estructura de carpetas
mkdir -p ~/develop/message_search/lib/models
mkdir -p ~/develop/message_search/lib/screens
mkdir -p ~/develop/message_search/lib/widgets

# 2. Mover archivos a sus ubicaciones
# Desde la carpeta donde descargaste, ejecuta:

# Código Dart
mv main.dart ~/develop/message_search/lib/
mv message.dart ~/develop/message_search/lib/models/
mv welcome_screen.dart ~/develop/message_search/lib/screens/
mv main_screen.dart ~/develop/message_search/lib/screens/
mv message_list_drawer.dart ~/develop/message_search/lib/widgets/
mv global_search_drawer.dart ~/develop/message_search/lib/widgets/

# Documentación
mv *.md ~/develop/message_search/
mv setup.sh ~/develop/message_search/

# 3. Hacer ejecutable el setup
chmod +x ~/develop/message_search/setup.sh
```

### Opción 2: Usando el proyecto completo

Si descargaste la carpeta `message_search` completa:

```bash
# Simplemente mueve la carpeta
mv message_search ~/develop/

# Hacer ejecutable el setup
chmod +x ~/develop/message_search/setup.sh
```

## ✅ Verificación

Para verificar que todo está en su lugar:

```bash
cd ~/develop/message_search

# Ver estructura
tree -L 3 -I 'build|.dart_tool'

# O con find:
find . -name "*.dart" -o -name "*.md" -o -name "*.sh" | sort
```

Deberías ver:
```
./CAMBIOS.md
./INICIO_RAPIDO.md
./INTERFAZ.md
./README.md
./RESUMEN.md
./ROADMAP.md
./lib/main.dart
./lib/models/message.dart
./lib/screens/main_screen.dart
./lib/screens/welcome_screen.dart
./lib/widgets/global_search_drawer.dart
./lib/widgets/message_list_drawer.dart
./setup.sh
```

## 📦 Falta el pubspec.yaml

**IMPORTANTE:** Necesitas crear el archivo `pubspec.yaml` en la raíz del proyecto.

Crea el archivo: `~/develop/message_search/pubspec.yaml`

Con este contenido:

```yaml
name: message_search
description: Aplicación de búsqueda de mensajes en PDF
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  sqflite_common_ffi: ^2.3.0+1
  path_provider: ^2.1.1
  path: ^1.8.3
  file_picker: ^6.1.1
  syncfusion_flutter_pdf: ^24.1.41

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0

flutter:
  uses-material-design: true
```

## 🎯 Después de Colocar los Archivos

```bash
# 1. Instalar dependencias
cd ~/develop/message_search
flutter pub get

# 2. Ejecutar
flutter run -d linux
```

## 📋 Lista de Archivos (13 total)

### Código Dart (7 archivos)
1. ✅ lib/main.dart
2. ✅ lib/models/message.dart
3. ✅ lib/screens/welcome_screen.dart
4. ✅ lib/screens/main_screen.dart
5. ✅ lib/widgets/message_list_drawer.dart
6. ✅ lib/widgets/global_search_drawer.dart

### Documentación (6 archivos)
7. ✅ README.md
8. ✅ RESUMEN.md
9. ✅ INTERFAZ.md
10. ✅ ROADMAP.md
11. ✅ CAMBIOS.md
12. ✅ INICIO_RAPIDO.md
13. ✅ setup.sh

### Por crear manualmente (1 archivo)
14. ⚠️ pubspec.yaml (ver contenido arriba)

---

¡Sigue estos pasos y tendrás el proyecto funcionando! 🚀
