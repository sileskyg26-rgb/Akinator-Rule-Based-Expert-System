import tkinter as tk
import logging
import os
from typing import Callable

from PIL import Image, ImageTk

logger = logging.getLogger("stardew_akinator.ui")


class StardewTheme:
    BG_WOOD = "#2c1e11"
    PANEL_PARCHMENT = "#f4e3c1"
    TEXT_DARK = "#212121"
    TEXT_LIGHT = "#ffecb3"
    BTN_GREEN = "#4caf50"
    BTN_LIGHT_GREEN = "#8bc34a"
    BTN_ORANGE = "#ff9800"
    BTN_RED = "#ff5722"
    BTN_DARK_RED = "#f44336"
    BTN_BROWN = "#795548"


class QuestionView(tk.Frame):
    """Componente modular para mostrar la pregunta y opciones de respuesta temáticas."""

    def __init__(self, parent, on_answer_callback: Callable[[str], None]):
        super().__init__(parent, bg=StardewTheme.PANEL_PARCHMENT, bd=5, relief="solid")
        self.on_answer_callback = on_answer_callback
        self._construir_widgets()

    def _construir_widgets(self):
        self.lbl_estado = tk.Label(
            self,
            text="",
            font=("Arial", 11, "italic"),
            bg=StardewTheme.PANEL_PARCHMENT,
            fg="#5d4037",
        )
        self.lbl_estado.pack(pady=10)

        self.lbl_pregunta = tk.Label(
            self,
            text="",
            font=("Georgia", 15, "bold"),
            bg=StardewTheme.PANEL_PARCHMENT,
            fg=StardewTheme.TEXT_DARK,
            wraplength=650,
            justify="center",
        )
        self.lbl_pregunta.pack(pady=20, padx=20)

        self.botones_frame = tk.Frame(self, bg=StardewTheme.PANEL_PARCHMENT)
        self.botones_frame.pack(pady=20)

        opciones = [
            ("Sí", "si", StardewTheme.BTN_GREEN),
            ("Probablemente", "probablemente", StardewTheme.BTN_LIGHT_GREEN),
            ("No sé", "no-se", StardewTheme.BTN_ORANGE),
            ("Probablemente no", "probablemente-no", StardewTheme.BTN_RED),
            ("No", "no", StardewTheme.BTN_DARK_RED),
        ]

        for texto, valor, color in opciones:

            def responder(valor_respuesta: str = valor) -> None:
                self.on_answer_callback(valor_respuesta)

            btn = tk.Button(
                self.botones_frame,
                text=texto,
                font=("Arial", 10, "bold"),
                bg=color,
                fg="white",
                width=14,
                height=2,
                bd=3,
                relief="raised",
                command=responder,
            )
            btn.pack(side="left", padx=4)

    def actualizar(self, texto_pregunta, estado_texto):
        self.lbl_estado.config(text=estado_texto)
        self.lbl_pregunta.config(text=texto_pregunta)
        self.botones_frame.pack(pady=20)


class ResultView(tk.Frame):
    """Componente modular para mostrar el resultado, imagen del personaje y explicabilidad."""

    def __init__(self, parent):
        super().__init__(parent, bg=StardewTheme.PANEL_PARCHMENT)
        self.img_tk = None
        self._construir_widgets()

    def _construir_widgets(self):
        self.lbl_imagen = tk.Label(self, bg=StardewTheme.PANEL_PARCHMENT)
        self.lbl_imagen.pack(pady=5)

        self.lbl_resultado = tk.Label(
            self,
            text="",
            font=("Georgia", 14, "bold"),
            bg=StardewTheme.PANEL_PARCHMENT,
            fg=StardewTheme.TEXT_DARK,
            justify="center",
        )
        self.lbl_resultado.pack(pady=10, padx=20)

    def _cargar_imagen_segura(self, personaje_id):
        """Busca de forma flexible la imagen del personaje manejando mayúsculas y nombres especiales."""
        if not personaje_id:
            return None

        carpeta_imgs = os.path.join(os.path.dirname(__file__), "images")

        # Generar candidatos de nombres de archivos basados en el ID devuelto por Scheme
        candidatos = [
            f"{personaje_id}.png",
            f"{personaje_id.capitalize()}.png",
            f"{personaje_id.lower()}.png",
            f"{personaje_id.title()}.png",
        ]

        # Casos especiales en español/inglés si el ID difiere
        id_lower = personaje_id.lower()
        if id_lower in ["enano", "dwarf"]:
            candidatos.insert(0, "Enano.png")

        for nombre_archivo in candidatos:
            ruta_img = os.path.abspath(os.path.join(carpeta_imgs, nombre_archivo))
            if os.path.exists(ruta_img):
                try:
                    pil_img = Image.open(ruta_img).resize(
                        (110, 110), Image.Resampling.LANCZOS
                    )
                    logger.debug(
                        "Imagen cargada para %s desde %s.", personaje_id, ruta_img
                    )
                    return ImageTk.PhotoImage(pil_img)
                except (OSError, ValueError) as error:
                    logger.warning(
                        "No se pudo cargar la imagen %s: %s", ruta_img, error
                    )
                    continue
        logger.warning("No se encontró imagen para el personaje %s.", personaje_id)
        return None

    def mostrar(self, entidad, confianza, explicacion):
        if entidad:
            nombre_limpio = entidad.replace("-", " ").title()
            texto = f"He pensado en {nombre_limpio}.\n(Confianza: {confianza:.1f}%)"

            # Cargar imagen de forma robusta
            self.img_tk = self._cargar_imagen_segura(entidad)
            if self.img_tk:
                self.lbl_imagen.config(image=self.img_tk)
            else:
                self.lbl_imagen.config(image="")

            if explicacion:
                texto += "\n\nRazones principales:"
                for exp in explicacion[:3]:
                    feat = exp[0].replace("-", " ")
                    val = exp[1]
                    texto += f"\n• {feat} = {val}"

            self.lbl_resultado.config(text=texto)
        else:
            self.lbl_imagen.config(image="")
            self.lbl_resultado.config(
                text="No pude identificar con certeza al personaje o se agotó el límite de preguntas."
            )

    def limpiar(self):
        self.lbl_imagen.config(image="")
        self.lbl_resultado.config(text="")
