# 🚀 Inicio Rápido - Message Search

## ✅ Proyecto Actualizado

El proyecto ha sido completamente renombrado de `sermon_search` a `message_search`.
Todos los archivos, clases y variables ahora usan la terminología "message/mensaje".

## 📂 Ubicación de Archivos

Tu proyecto está en: `/mnt/user-data/outputs/message_search`

Debes copiarlo a: `~/develop/message_search`

## 🎯 Pasos para Empezar

### 1. Copiar el proyecto

```bash
# Desde donde descargaste los archivos
cp -r message_search ~/develop/

# O si lo descargaste de otra ubicación:
# mv /path/de/descarga/message_search ~/develop/
```

### 2. Navegar al proyecto

```bash
cd ~/develop/message_search
```

### 3. Verificar estructura (opcional)

```bash
ls -la lib/
# Deberías ver:
# main.dart
# models/
# screens/
# widgets/
```

### 4. Instalar dependencias

```bash
flutter pub get
```

Deberías ver:
```
Running "flutter pub get" in message_search...
Resolving dependencies...
✓ Success!
```

### 5. Ejecutar la aplicación

```bash
flutter run -d linux
```

## 🎨 Qué Esperar

Al ejecutar verás:
1. **Pantalla de Bienvenida**
   - Toggle para tema claro/oscuro
   - Botón "Iniciar"

2. **Pantalla Principal**
   - Mensaje más antiguo cargado ("El Fundamento de Nuestra Fe")
   - Barra de búsqueda arriba
   - Íconos ☰ (izquierda) y ≡ (derecha) para abrir paneles

3. **Panel Izquierdo (☰)**
   - Lista de 5 mensajes dummy
   - Búsqueda por título o fecha
   - Clic para cambiar de mensaje

4. **Panel Derecho (≡)**
   - Búsqueda global
   - Resultados con snippets
   - Contador de coincidencias

## 🧪 Pruebas Rápidas

### Probar búsqueda en mensaje actual
1. En la barra superior, escribe: `Él`
2. Ve cómo se resalta en amarillo
3. Prueba sin acento: `el` (también funciona!)

### Probar búsqueda global
1. Abre panel derecho (≡)
2. Busca: `amor de Dios`
3. Ve los 3 resultados con snippets

### Probar navegación
1. Abre panel izquierdo (☰)
2. Busca por título: `gracia`
3. Clic en "La Gracia Transformadora..."
4. Ve el mensaje completo

## ❌ Solución de Problemas

### Error: "flutter: command not found"
```bash
# Verifica instalación
which flutter

# Si no está, agrega al PATH:
export PATH="$HOME/develop/flutter/bin:$PATH"
source ~/.bashrc
```

### Error: "No devices found"
```bash
# Verifica dispositivos disponibles
flutter devices

# Deberías ver "Linux (desktop)"
# Si no, verifica:
flutter doctor
```

### Error en dependencias
```bash
# Limpia y reinstala
flutter clean
flutter pub get
```

## 📚 Documentación Incluida

- **README.md** - Documentación completa
- **RESUMEN.md** - Overview del proyecto
- **INTERFAZ.md** - Guía visual
- **ROADMAP.md** - Próximos pasos
- **CAMBIOS.md** - Registro de cambios sermon→message
- **setup.sh** - Script automatizado

## 🎯 Siguiente Paso

Después de probar la UI, el siguiente paso es:
**Implementar la base de datos SQLite y extracción de PDFs**

Pero primero, ¡prueba la aplicación y asegúrate de que te gusta el diseño! 🎨

## 💬 ¿Necesitas ayuda?

Si algo no funciona o quieres hacer cambios, avísame y continuamos desde donde te quedaste.

---

**¡El proyecto está 100% actualizado y listo para usar!** ✨
