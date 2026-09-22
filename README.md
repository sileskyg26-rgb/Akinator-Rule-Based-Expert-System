# Stardew Akinator - Rule-Based Expert System

> An Akinator-inspired character guessing expert system set in the universe of *Stardew Valley*. Developed as an academic project for the Programming Paradigms course.

![Python](https://img.shields.io/badge/Python-3.x-3776AB?style=for-the-badge&logo=python&logoColor=white)
![Racket](https://img.shields.io/badge/Racket-Scheme-9F1D20?style=for-the-badge&logo=racket&logoColor=white)
![Tkinter](https://img.shields.io/badge/GUI-Tkinter-orange?style=for-the-badge)
![Status](https://img.shields.io/badge/Status-Completed-success?style=for-the-badge)

---

## Demo

<p align="center">
  <img src="Frontend/images/Display.gif" alt="Application Demo" width="600">
</p>

---

## How It Works (Architecture)

The project implements a hybrid architecture that combines functional programming in
Racket with a procedural graphical interface in Python:

1. **Inference Engine and Knowledge Base (Racket/Scheme):** The rules, facts,
   inference functions, scoring model, question selection, and character data are
   implemented in the [`Backend/`](Backend/) directory.
2. **Presentation Layer (Python/Tkinter):** The GUI captures the user's answers,
   displays questions and results, loads character images, and tracks session
   statistics.
3. **Process Communication:** Python launches the Racket engine and exchanges one
   JSON message per line through standard input and output streams.

The backend returns either a new question or a verdict with a confidence value and
an explanation containing the matching characteristics.

---

## Key Features

- **Dynamic rule engine:** Applies symbolic rules to derive additional facts without
  overwriting explicit knowledge-base values.
- **Weighted inference:** Scores candidates using the user's answers and the
  informational value of each characteristic.
- **Dynamic question selection:** Selects unanswered characteristics that best
  separate the active candidates.
- **Flexible answers:** Supports `Yes`, `No`, `Don't know`, `Probably`, and
  `Probably not`.
- **Explainable results:** Shows the characteristics that support the predicted
  character.
- **Themed graphical interface:** A Tkinter GUI styled around *Stardew Valley*.
- **Extensible knowledge base:** Characters and rules are maintained separately from
  the user interface.

---

## Technologies and Tools

- **Languages:** Python 3 and Racket/Scheme.
- **Graphical interface:** Tkinter.
- **Image handling:** Pillow.
- **Communication:** JSON Lines over standard input/output.
- **Version control:** Git and GitHub.

---

## Installation and Execution

### Prerequisites

Install the following software:

- [Python 3](https://www.python.org/downloads/)
- [Racket](https://racket-lang.org/)
- Git

Racket must be available on the system `PATH`, or installed in one of the standard
Windows locations searched by [`Frontend/scheme_bridge.py`](Frontend/scheme_bridge.py).

### Clone the repository

```bash
git clone https://github.com/sileskyg26-rgb/Sistema-Experto-Basado-en-Reglas-tipo-Akinator.git
cd Sistema-Experto-Basado-en-Reglas-tipo-Akinator
```

### Create a Python virtual environment

#### Windows PowerShell

```powershell
py -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install --upgrade pip
python -m pip install Pillow
```

#### Linux or macOS

```bash
python3 -m venv .venv
source .venv/bin/activate
python -m pip install --upgrade pip
python -m pip install Pillow
```

### Run the application

Run the application from the repository root:

```bash
python -m Frontend.app
```

The application starts the Racket engine automatically. Use the **Restart Game**
button to begin a new round without restarting the application.

---

## Project Structure

```text
.
├── Backend/
│   ├── conocimiento.rkt   # Knowledge base
│   ├── reglas.rkt         # Inference rules
│   └── motor.rkt          # Inference engine and JSON server
├── Frontend/
│   ├── app.py             # Tkinter application
│   ├── game_controller.py # Game state and session statistics
│   ├── scheme_bridge.py   # Python/Racket process bridge
│   ├── ui_components.py   # Reusable GUI components
│   └── images/            # Character images and demo
├── Documents/             # Architecture and inference diagrams
├── .gitignore
└── README.md
```

---

## Backend Protocol

The frontend sends one JSON object per line to the Racket process:

```json
{
  "accion": "inferir",
  "respuestas": [["es-mujer", "si"], ["es-nino", "no"]],
  "preguntadas": ["es-mujer", "es-nino"]
}
```

The backend responds with a question:

```json
{
  "tipo": "pregunta",
  "caracteristica": "le-gusta-mineria",
  "candidatos": 8
}
```

Or with a verdict:

```json
{
  "tipo": "veredicto",
  "entidad": "abigail",
  "confianza": 0.83,
  "explicacion": [["es-mujer", "si"]]
}
```

---

## Development Checks

To validate Python syntax without opening the GUI:

```bash
python -m py_compile Frontend/app.py Frontend/game_controller.py Frontend/scheme_bridge.py Frontend/ui_components.py
```

To compile the Racket backend directly:

```bash
racket Backend/motor.rkt
```

The backend is an interactive JSON server, so it remains waiting for input when
started directly. Close it with `Ctrl+C` after verifying that Racket launches
successfully.

---

## Documentation

Additional diagrams are available in [`Documents/`](Documents/):

- [Architecture diagram](Documents/Diagrama%20de%20Arquitectura.png)
- [Inference flow diagram](Documents/Diagrama%20de%20Flujo%20de%20Inferencia.png)

---

## Known Limitations

- The game is currently a desktop application and requires Python, Tkinter, and
  Racket to be installed locally.
- Statistics are kept for the current application session only.
- The knowledge base is maintained as Racket source data rather than through an
  external database or editor.
