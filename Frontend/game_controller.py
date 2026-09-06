class GameController:
    """Gestiona el estado del juego, historial de respuestas y estadísticas."""
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

    def obtener_siguiente_paso(self):
        peticion = {
            "accion": "inferir",
            "respuestas": self.respuestas,
            "preguntadas": self.preguntadas
        }
        resultado = self.bridge.enviar_mensaje(peticion)
        
        if resultado.get("tipo") == "pregunta":
            self.caracteristica_actual = resultado["caracteristica"]
            self.preguntadas.append(self.caracteristica_actual)
            
        return resultado

    def registrar_respuesta(self, valor_respuesta: str):
        if self.caracteristica_actual:
            self.respuestas.append([self.caracteristica_actual, valor_respuesta])

    def registrar_resultado(self, acerto: bool):
        self.partidas_totales += 1
        if acerto:
            self.aciertos_totales += 1

    def obtener_estadisticas(self) -> str:
        return f"Partidas: {self.partidas_totales} | Aciertos: {self.aciertos_totales}"