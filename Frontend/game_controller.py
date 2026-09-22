import logging


logger = logging.getLogger("stardew_akinator.game_controller")


class GameController:
    """Gestiona el estado del juego, historial de respuestas y estadísticas."""
    PROTOCOL_VERSION = 1

    def __init__(self, bridge):
        self.bridge = bridge
        self.respuestas = []
        self.preguntadas = []
        self.caracteristica_actual = None
        self.partidas_totales = 0
        self.aciertos_totales = 0

    def reiniciar(self):
        self.respuestas = []
        self.preguntadas = []
        self.caracteristica_actual = None
        logger.info("Partida reiniciada.")

    def obtener_siguiente_paso(self):
        peticion = {
            "version": self.PROTOCOL_VERSION,
            "accion": "inferir",
            "respuestas": list(self.respuestas),
            "preguntadas": list(self.preguntadas)
        }
        resultado = self.bridge.enviar_mensaje(peticion)
        logger.info(
            "Respuesta de inferencia recibida: tipo=%s, preguntas=%d.",
            resultado.get("tipo"),
            len(self.preguntadas),
        )
        
        if resultado.get("tipo") == "pregunta":
            self.caracteristica_actual = resultado["caracteristica"]
            self.preguntadas.append(self.caracteristica_actual)
            
        return resultado

    def registrar_respuesta(self, valor_respuesta: str):
        if self.caracteristica_actual:
            self.respuestas.append([self.caracteristica_actual, valor_respuesta])
            logger.info(
                "Respuesta registrada para %s; total de respuestas=%d.",
                self.caracteristica_actual,
                len(self.respuestas),
            )

    def registrar_resultado(self, acerto: bool):
        self.partidas_totales += 1
        if acerto:
            self.aciertos_totales += 1
        logger.info(
            "Partida finalizada: acierto=%s, preguntas=%d, partidas=%d.",
            acerto,
            len(self.preguntadas),
            self.partidas_totales,
        )

    def obtener_estadisticas(self) -> str:
        return f"Partidas: {self.partidas_totales} | Aciertos: {self.aciertos_totales}"