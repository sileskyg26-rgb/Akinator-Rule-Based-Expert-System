import tkinter as tk
from tkinter import messagebox

if __package__ in (None, ""):
    from Frontend.game_controller import GameController
    from Frontend.logging_config import configurar_logging
    from Frontend.scheme_bridge import SchemeBridge
    from Frontend.ui_components import QuestionView, ResultView, StardewTheme
else:
    from .game_controller import GameController
    from .logging_config import configurar_logging
    from .scheme_bridge import SchemeBridge
    from .ui_components import QuestionView, ResultView, StardewTheme

logger = configurar_logging()


class StardewAkinatorApp:
    def __init__(self, root):
        self.root = root
        self.root.title("Akinator: Stardew Valley Edition")
        self.root.geometry("780x680")
        self.root.config(bg=StardewTheme.BG_WOOD)
        self.root.resizable(False, False)
        logger.info("Aplicación gráfica iniciada.")

        # Inicialización de dependencias (Principios SOLID / Modularidad)
        try:
            self.bridge = SchemeBridge()
        except Exception as e:
            logger.exception("No se pudo inicializar la aplicación.")
            messagebox.showerror("Error", str(e))
            self.root.destroy()
            return

        self.controller = GameController(self.bridge)

        self._construir_interfaz()
        self.iniciar_juego()

    def _construir_interfaz(self):
        # Título superior
        titulo_frame = tk.Frame(self.root, bg="#3e2723", bd=4, relief="ridge")
        titulo_frame.pack(fill="x", padx=20, pady=15)

        tk.Label(
            titulo_frame,
            text="Akinator: Stardew Valley",
            font=("Georgia", 18, "bold"),
            bg="#3e2723",
            fg=StardewTheme.TEXT_LIGHT,
        ).pack(pady=8)

        # Contenedor central modular
        self.container_principal = tk.Frame(self.root, bg=StardewTheme.BG_WOOD)
        self.container_principal.pack(fill="both", expand=True, padx=20, pady=5)

        self.question_view = QuestionView(
            self.container_principal, self.procesar_respuesta
        )
        self.question_view.pack(fill="both", expand=True)

        self.result_view = ResultView(self.container_principal)
        # Se empaquetará solo al finalizar la partida

        # Pie de página / Estadísticas y controles
        footer_frame = tk.Frame(self.root, bg=StardewTheme.BG_WOOD)
        footer_frame.pack(fill="x", padx=20, pady=10)

        self.lbl_stats = tk.Label(
            footer_frame,
            text=self.controller.obtener_estadisticas(),
            font=("Arial", 10),
            bg=StardewTheme.BG_WOOD,
            fg="#d7ccc8",
        )
        self.lbl_stats.pack(side="left")

        tk.Button(
            footer_frame,
            text="Reiniciar partida",
            font=("Arial", 10, "bold"),
            bg=StardewTheme.BTN_BROWN,
            fg="white",
            command=self.reiniciar_partida,
        ).pack(side="right")

    def formatear_pregunta(self, car_str):
        mapeo = {
            "es-npc": "¿Es un personaje no jugable (NPC) del pueblo?",
            "es-soltero": "¿Es un candidato/a apto para matrimonio?",
            "es-mujer": "¿Es de género femenino?",
            "es-nino": "¿Es un niño o niña?",
            "es-anciano": "¿Es un adulto mayor?",
            "vive-en-la-montana": "¿Su casa o zona habitual queda en el área de la montaña?",
            "tiene-tienda": "¿Es dueño o administra un negocio o tienda?",
            "trabaja-en-joja": "¿Trabaja para la Corporación Joja?",
            "le-gusta-pescar": "¿Tiene la pesca como afición u oficio marcado?",
            "le-gusta-mineria": "¿Le gusta explorar las minas o trabajar con minerales?",
            "le-gusta-arte": "¿Practica música, costurería, pintura, fotografía, escritura o artesanía?",
            "cria-animales": "¿Cría o cuida animales de granja?",
            "trabaja-en-medicina": "¿Trabaja en la clínica del pueblo (médico/enfermera)?",
            "esta-casado": "¿Está casado o casada dentro del pueblo?",
            "tiene-hijos": "¿Tiene hijos o hijastros?",
            "trabaja-en-saloon": "¿Trabaja en el Stardrop Saloon?",
            "es-forastero": "¿Es forastero (no nació en Pelican Town y se mudó después)?",
            "le-gusta-cocinar": "¿Le gusta cocinar o preparar recetas gastronómicas?",
            "usa-silla-de-ruedas": "¿Usa silla de ruedas?",
            "es-magico-o-misterioso": "¿Tiene un aire mágico, místico o misterioso?",
            "es-hijo-unico": "¿Es hijo/a único/a (sin hermanos)?",
        }
        return mapeo.get(car_str, f"¿Tiene la característica '{car_str}'?")

    def iniciar_juego(self):
        self.controller.reiniciar()
        self.result_view.pack_forget()
        self.question_view.pack(fill="both", expand=True)
        self.siguiente_turno()

    def siguiente_turno(self):
        try:
            resultado = self.controller.obtener_siguiente_paso()
        except (ConnectionError, TimeoutError, ValueError) as error:
            messagebox.showerror("Error de comunicación", str(error))
            return

        if resultado.get("tipo") == "pregunta":
            caracteristica = resultado["caracteristica"]
            candidatos = resultado["candidatos"]
            num_pregunta = len(self.controller.respuestas) + 1

            texto_p = self.formatear_pregunta(caracteristica)
            estado = f"Pregunta #{num_pregunta} | Candidatos posibles: {candidatos}"
            self.question_view.actualizar(texto_p, estado)

        elif resultado.get("tipo") == "veredicto":
            self.mostrar_veredicto(resultado)

    def procesar_respuesta(self, valor_respuesta):
        self.controller.registrar_respuesta(valor_respuesta)
        self.siguiente_turno()

    def mostrar_veredicto(self, resultado):
        self.question_view.pack_forget()
        self.result_view.pack(fill="both", expand=True)

        entidad = resultado.get("entidad")
        confianza = resultado.get("confianza", 0.0) * 100
        explicacion = resultado.get("explicacion", [])

        self.result_view.mostrar(entidad, confianza, explicacion)

        if entidad:
            nombre_limpio = entidad.replace("-", " ").title()
            acerto = messagebox.askyesno(
                "Verificación", f"¿Es {nombre_limpio} el personaje en el que pensabas?"
            )
            self.controller.registrar_resultado(acerto)
        else:
            self.controller.registrar_resultado(False)

        self.lbl_stats.config(text=self.controller.obtener_estadisticas())

    def reiniciar_partida(self):
        self.iniciar_juego()

    def cerrar(self):
        logger.info("Cierre de la aplicación solicitado.")
        self.bridge.cerrar()
        self.root.destroy()


def main():
    root = tk.Tk()
    app = StardewAkinatorApp(root)
    root.protocol("WM_DELETE_WINDOW", app.cerrar)
    root.mainloop()


if __name__ == "__main__":
    main()
