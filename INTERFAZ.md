# 📱 Guía Visual de la Interfaz

## Pantalla de Bienvenida

```
┌────────────────────────────────────────┐
│                                        │
│           📖 (ícono de libro)          │
│                                        │
│            Bienvenido                  │
│       Búsqueda de Mensajes            │
│                                        │
│    ┌──────────────────────────┐       │
│    │ 🌙 Tema Oscuro  [switch] │       │
│    └──────────────────────────┘       │
│                                        │
│         ┌──────────┐                  │
│         │ Iniciar  │                  │
│         └──────────┘                  │
│                                        │
└────────────────────────────────────────┘
```

## Pantalla Principal - Vista Completa

```
┌─────────────────────────────────────────────────────────────────┐
│ [☰] [🔍 Búsqueda en mensaje actual...]              [≡]        │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   El Fundamento de Nuestra Fe                                  │
│   📅 5 Mar 2010                                                │
│   ─────────────────────────────────────────────                │
│                                                                 │
│   El fundamento de nuestra fe está en Jesucristo.             │
│                                                                 │
│   Él es la roca sobre la cual edificamos nuestra vida          │
│   espiritual. En Mateo 7:24-25 leemos: "Cualquiera,           │
│   pues, que me oye estas palabras, y las hace, le             │
│   compararé a un hombre prudente, que edificó su              │
│   casa sobre la roca."                                         │
│                                                                 │
│   ...resto del contenido...                                    │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Panel Izquierdo (Lista de Mensajes)

```
┌─────────────────────────────┐
│  Lista de Mensajes          │
│  5 mensajes disponibles     │
├─────────────────────────────┤
│  🔍 [Buscar...]             │
│  ◯ Título  ◉ Fecha          │
├─────────────────────────────┤
│                             │
│  ┃ El Fundamento...         │ ← Seleccionado
│  ┃ 5 Mar 2010               │
│                             │
│  │ La Gracia...             │
│  │ 15 Ago 2010              │
│                             │
│  │ El Amor de Dios...       │
│  │ 20 Feb 2011              │
│                             │
│  │ La Fidelidad...          │
│  │ 10 Jun 2012              │
│                             │
│  │ Viviendo en el...        │
│  │ 3 Nov 2013               │
│                             │
└─────────────────────────────┘
```

## Panel Derecho (Búsqueda Global)

```
┌──────────────────────────────────┐
│  Búsqueda Global                 │
│  Buscar en todos los mensajes    │
├──────────────────────────────────┤
│  🔍 [Frase o palabras...]        │
│                                  │
│      [  Buscar  ]                │
├──────────────────────────────────┤
│  Resultados (3)                  │
│                                  │
│  ┌────────────────────────────┐ │
│  │ ▸ El Amor de Dios          │ │
│  │   📅 20 Feb 2011           │ │
│  │   [5 coincidencias]        │ │
│  │   "...el amor de Dios      │ │
│  │   ha sido manifestado..."  │ │
│  └────────────────────────────┘ │
│                                  │
│  ┌────────────────────────────┐ │
│  │ ▸ La Gracia...             │ │
│  │   📅 15 Ago 2010           │ │
│  │   [3 coincidencias]        │ │
│  │   "...amor y gracia..."    │ │
│  └────────────────────────────┘ │
│                                  │
│  ┌────────────────────────────┐ │
│  │ ▸ El Fundamento...         │ │
│  │   📅 5 Mar 2010            │ │
│  │   [2 coincidencias]        │ │
│  │   "...el amor por..."      │ │
│  └────────────────────────────┘ │
│                                  │
└──────────────────────────────────┘
```

## Búsqueda en Mensaje Actual

Cuando escribes en la barra superior, el texto se resalta en amarillo:

```
El fundamento de nuestra fe está en Jesucristo.

Él es la █roca█ sobre la cual edificamos nuestra vida
      ↑ resaltado en amarillo

espiritual. En Mateo 7:24-25 leemos: "Cualquiera,
pues, que me oye estas palabras, y las hace, le
compararé a un hombre prudente, que edificó su
casa sobre la █roca█."
             ↑ también resaltado
```

## Flujo de Uso

### 1️⃣ Inicio
```
Bienvenida → Elegir tema → Iniciar
```

### 2️⃣ Navegar mensajes
```
Pantalla Principal → ☰ → Lista → Clic en mensaje → Ver mensaje
```

### 3️⃣ Buscar en mensaje actual
```
Barra superior → Escribir → Ver resaltados
```

### 4️⃣ Buscar globalmente
```
≡ → Escribir búsqueda → Buscar → Clic en resultado → Ver mensaje
```

## Atajos Visuales

- **☰** = Lista de mensajes (izquierda)
- **≡** = Búsqueda global (derecha)
- **🔍** = Campo de búsqueda
- **📅** = Fecha del mensaje
- **█** = Texto resaltado
- **┃** = Mensaje seleccionado (barra azul)

## Características de Búsqueda

### Búsqueda Normalizada
- "Señor" = "señor" = "SEÑOR" = "senor" ✅
- "fe" encuentra "fé" ✅
- "amor de Dios" encuentra todo junto ✅

### Resultados Ordenados
- Por número de coincidencias (más a menos)
- Con snippets de contexto
- Contador visible de matches
