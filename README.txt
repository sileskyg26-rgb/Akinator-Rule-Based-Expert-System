# Akinator de Stardew Valley

Un proyecto para adivinar personajes de Stardew Valley combinando la lógica de un motor de inferencia en **Scheme (Racket)** con una interfaz gráfica modular en **Python (Tkinter)**.

---

## 💡 ¿Cómo funciona por dentro?

El sistema se divide en dos partes que se comunican en tiempo real mediante un puente de mensajes por consola (`stdin/stdout` con JSON):

- **Backend (Scheme):** Se encarga de toda la inteligencia. Calcula el peso informativo de las preguntas, maneja probabilidades, descarta entidades que ya no coinciden y evalúa el puntaje de confianza.
- **Frontend (Python):** Levanta la interfaz gráfica usando Tkinter. Muestra las preguntas, procesa los clics de los usuarios y se encarga de buscar y renderizar las imágenes de los personajes de manera flexible (por si hay variaciones en mayúsculas o nombres como `Enano.png`).

---

## Estructura del proyecto

```text
stardew-akinator/
├── backend/
│   ├── main.rkt              # Servidor lógico y manejo de inferencia
│   └── knowledge_base.rkt    # Base de datos con los personajes y sus atributos
├── frontend/
│   ├── app.py                # Ventana principal y control de flujo
│   └── ui_components.py      # Componentes visuales y paleta de colores temática
├── images/                   # Avatares de los personajes (Abigail, Krobus, etc.)
└── informe-tecnico.docx      # Documentación detallada del proyecto