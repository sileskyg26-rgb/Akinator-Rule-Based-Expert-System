import unittest
from unittest.mock import Mock

from Frontend.game_controller import GameController


class GameControllerTests(unittest.TestCase):
    def setUp(self):
        self.bridge = Mock()
        self.controller = GameController(self.bridge)

    def test_reiniciar_limpia_el_estado(self):
        self.controller.respuestas = [["es-mujer", "si"]]
        self.controller.preguntadas = ["es-mujer"]
        self.controller.caracteristica_actual = "es-mujer"

        self.controller.reiniciar()

        self.assertEqual(self.controller.respuestas, [])
        self.assertEqual(self.controller.preguntadas, [])
        self.assertIsNone(self.controller.caracteristica_actual)

    def test_obtener_siguiente_paso_registra_la_pregunta(self):
        self.bridge.enviar_mensaje.return_value = {
            "tipo": "pregunta",
            "caracteristica": "es-nino",
            "candidatos": 4,
        }

        resultado = self.controller.obtener_siguiente_paso()

        self.assertEqual(resultado["tipo"], "pregunta")
        self.assertEqual(self.controller.caracteristica_actual, "es-nino")
        self.assertEqual(self.controller.preguntadas, ["es-nino"])

    def test_registrar_respuesta_usa_la_pregunta_actual(self):
        self.controller.caracteristica_actual = "le-gusta-arte"

        self.controller.registrar_respuesta("probablemente")

        self.assertEqual(
            self.controller.respuestas,
            [["le-gusta-arte", "probablemente"]],
        )

    def test_estadisticas_registran_partidas_y_aciertos(self):
        self.controller.registrar_resultado(True)
        self.controller.registrar_resultado(False)

        self.assertEqual(
            self.controller.obtener_estadisticas(),
            "Partidas: 2 | Aciertos: 1",
        )
