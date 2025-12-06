#!/bin/bash

# Script de setup rápido para el proyecto

echo "🚀 Configurando proyecto Message Search..."

# Navegar al directorio del proyecto
cd ~/develop/message_search

# Instalar dependencias
echo "📦 Instalando dependencias..."
flutter pub get

# Verificar que todo esté bien
echo "🔍 Verificando instalación..."
flutter doctor

echo ""
echo "✅ Setup completado!"
echo ""
echo "Para ejecutar la aplicación:"
echo "  flutter run -d linux"
echo ""
echo "Para compilar para Windows:"
echo "  flutter build windows"
