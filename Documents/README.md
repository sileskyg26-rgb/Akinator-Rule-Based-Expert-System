# Akinator de Stardew Valley - Sistema Experto

Proyecto desarrollado para el curso **EIF400 - Paradigmas de Programación** de la Universidad Nacional (UNA), Costa Rica. Consiste en un sistema experto tipo Akinator que integra un motor de inferencia funcional en **Scheme (Racket)** con una interfaz gráfica modular en **Python (Tkinter)**, comunicándose de forma bidireccional mediante un protocolo de mensajes JSON a través de la entrada y salida estándar (`stdin/stdout`).

## Autores

* Genesis Silesky Araya
* Lausen Paniagua

## Arquitectura y Estructura del Proyecto

El sistema respeta estrictamente la separación de responsabilidades: **Python** maneja exclusivamente la interfaz visual, la captura de interacciones y las estadísticas, mientras que **Scheme** alberga toda la base de conocimiento, la aplicación de reglas y el algoritmo de inferencia probabilística.

```text
stardew-akinator/
├── Backened/
│   ├── motor.rkt             # Motor de inferencia, reglas, heurística y servidor JSON
│   ├── conocimiento.rkt      # Base de conocimiento (32 entidades y 21 características)
│   └── reglas.rkt            # Reglas de inferencia simbólica
├── frontend/
│   ├── app_2.py              # Controlador principal de la interfaz gráfica (Tkinter)
│   ├── scheme_bridge.py      # Puente de comunicación bidireccional por procesos
│   ├── game_controller.py    # Gestión de estado, historial y estadísticas de juego
│   └── ui_components.py      # Vistas modulares, manejo de imágenes y paleta temática
├── images/                   # Avatares gráficos de los personajes de Stardew Valley
└── informe-tecnico.docx      # Documentación formal del proyecto

```

## Dependencias y Requisitos de Instalación

Para asegurar el correcto funcionamiento del sistema, es necesario contar con los siguientes entornos instalados en el equipo:

1. **Racket:** Entorno de ejecución para Scheme (asegúrate de que esté accesible en el sistema o en su ruta estándar de instalación).
2. **Python 3.8 o superior**.
3. **Librería Pillow** (para el procesamiento y renderizado dinámico de las imágenes en la interfaz de Python).

### Instalación de dependencias de Python

Ejecuta el siguiente comando en tu terminal para instalar Pillow:

```bash
pip install Pillow

```

## Guía de Ejecución

1. Clona o descarga el repositorio en tu equipo local.
2. Abre una terminal y colócate en la raíz del proyecto.
3. Ejecuta el script principal de Python para levantar la interfaz y conectar automáticamente el backend de Scheme:
```bash
python Frontend/app.py

```



## Modo de Uso y Casos de Prueba

1. Al iniciar la aplicación, el sistema inicializará el backend en Racket y presentará la ventana con la temática de Stardew Valley.
2. Piensa en un personaje del dominio (por ejemplo, *Abigail*, *Krobus*, *Shane*, etc.).
3. Responde a las preguntas generadas dinámicamente seleccionando una de las 5 opciones de incertidumbre disponibles: **Sí**, **Probablemente**, **No sé**, **Probablemente no** o **No**.
4. El sistema evaluará el puntaje mediante el motor funcional, filtrará candidatos mediante descarte permanente y calculará el porcentaje de confianza.
5. Al llegar al umbral de certeza, se mostrará el avatar oficial del personaje, el nivel de confianza alcanzado y las razones principales de la deducción (explicabilidad).