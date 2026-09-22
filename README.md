# Stardew Akinator - Rule-Based Expert System

> An Akinator-inspired character guessing expert system set in the universe of *Stardew Valley*. Developed as an academic project for the Programming Paradigms course.

![Python](https://img.shields.io/badge/Python-3.x-3776AB?style=for-the-badge&logo=python&logoColor=white)
![Racket](https://img.shields.io/badge/Racket-Scheme-9F1D20?style=for-the-badge&logo=racket&logoColor=white)
![Tkinter](https://img.shields.io/badge/GUI-Tkinter-orange?style=for-the-badge)
![Status](https://img.shields.io/badge/Status-Portfolio%20Project-blue?style=for-the-badge)

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

## Portfolio Evidence

This project demonstrates more than a graphical prototype. It provides evidence
of the following engineering practices:

| Area | Evidence in the repository |
| --- | --- |
| Architecture | Python/Tkinter presentation layer separated from the Racket inference engine |
| Integration | Real JSON Lines communication test between Python and Racket |
| Reliability | Bridge timeout, process termination, invalid JSON, stderr capture, and restart handling |
| Data quality | Automated validation of duplicate entities, characteristics, values, images, and contradictions |
| Explainability | Confidence score and matching characteristics returned with each verdict |
| Testing | Python unit tests, end-to-end integration tests, and Racket `rackunit` tests |
| Maintainability | Typed Python modules, Ruff checks, reproducible packaging, and a versioned protocol |
| Automation | GitHub Actions runs tests, coverage, linting, formatting, type checking, and Racket validation |

### Main design decisions

- **Two-language boundary:** Racket keeps the rule engine and knowledge
  representation close to the functional-programming requirements, while Python
  handles the desktop interface and operating-system process management.
- **Explicit protocol:** JSON Lines with `version: 1` makes the process boundary
  testable and allows future protocol changes to be introduced deliberately.
- **Failure visibility:** communication failures raise explicit exceptions and are
  logged instead of being converted into a false game result.
- **Focused scope:** the project intentionally remains a desktop expert system;
  it does not add an unnecessary web API, database, authentication layer, or
  deployment stack.

The most relevant files for reviewing the implementation are
[`Frontend/scheme_bridge.py`](Frontend/scheme_bridge.py),
[`Frontend/game_controller.py`](Frontend/game_controller.py),
[`Backend/motor.rkt`](Backend/motor.rkt), and
[`Backend/validador.rkt`](Backend/validador.rkt).

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
The CI workflow currently uses the stable Racket distribution. The exact minimum
Racket version is intentionally not hard-coded until it is validated against the
same runtime on every supported operating system.

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
python -m pip install -e ".[dev]"
```

#### Linux or macOS

```bash
python3 -m venv .venv
source .venv/bin/activate
python -m pip install --upgrade pip
python -m pip install -e ".[dev]"
```

### Run the application

Run the application from the repository root:

```bash
python -m Frontend.app
```

Direct execution is also supported from the repository root:

```bash
python Frontend/app.py
```

Running it as a module is still recommended because it follows the `Frontend`
package structure.

The application starts the Racket engine automatically. Use the **Restart Game**
button to begin a new round without restarting the application.

### Windows executable

The repository includes a PyInstaller specification for producing a portable
Windows executable:

```powershell
python -m pip install -e ".[dev]"
pyinstaller --clean --noconfirm stardew-akinator.spec
```

The executable is generated at `dist/stardew-akinator.exe`. The distribution
still requires Racket installed on the target machine because the application
starts `Backend/motor.rkt` as a separate process. The build includes the Racket
source and the character images, and the bridge resolves those files correctly
when running from a frozen PyInstaller bundle.

GitHub Actions also builds the archive
`stardew-akinator-windows.zip` for manual runs and version tags such as `v1.0.0`.

### Test coverage

The test suite includes coverage measurement for the controller, process bridge,
and logging configuration:

```bash
pytest --cov-fail-under=75
```

The command prints missing lines and generates `coverage.xml` for CI tooling.
The CI pipeline requires at least 75% coverage for the covered backend-facing
Python modules.
Tkinter UI rendering is intentionally excluded because it requires a graphical
session; the application startup and Python–Racket integration remain covered
through the bridge tests.

### Security checks

The development toolchain includes two security checks:

```bash
pip-audit
bandit -r Frontend -ll
```

`pip-audit` checks installed Python dependencies against published
vulnerability advisories. Bandit scans the Python source for common insecure
patterns. Both checks run automatically in GitHub Actions and fail the build
when a high-confidence issue is detected.

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
  "version": 1,
  "accion": "inferir",
  "respuestas": [["es-mujer", "si"], ["es-nino", "no"]],
  "preguntadas": ["es-mujer", "es-nino"]
}
```

The backend responds with a question:

```json
{
  "version": 1,
  "tipo": "pregunta",
  "caracteristica": "le-gusta-mineria",
  "candidatos": 8
}
```

Or with a verdict:

```json
{
  "version": 1,
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

To run the Racket unit tests:

```bash
racket Backend/tests/test-motor.rkt
```

The test suite uses Racket's built-in `rackunit` library and validates the
knowledge base, rule application, inference questions, explanations, and reset
behavior.

To run the complete Python quality gate locally:

```bash
python -m unittest discover -s tests -v
pytest --cov-fail-under=75
ruff check .
ruff format --check .
mypy Frontend tests
```

---

## Documentation

Additional diagrams are available in [`Documents/`](Documents/):

- [Architecture diagram](Documents/Diagrama%20de%20Arquitectura.png)
- [Inference flow diagram](Documents/Diagrama%20de%20Flujo%20de%20Inferencia.png)

The maintained architecture reference, including component responsibilities,
runtime sequence, and failure handling, is available in
[`docs/architecture.md`](docs/architecture.md).

---

## Known Limitations

- The game is currently a desktop application and requires Python, Tkinter, and
  Racket to be installed locally.
- The packaged Windows executable also requires Racket because the inference
  engine runs as a separate process.
- Statistics are kept for the current application session only.
- The knowledge base is maintained as Racket source data rather than through an
  external database or editor.
