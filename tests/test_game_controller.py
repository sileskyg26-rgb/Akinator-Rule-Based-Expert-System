import unittest
from copy import deepcopy
from unittest.mock import Mock

from Frontend.game_controller import GameController


class GameControllerTests(unittest.TestCase):
    def setUp(self):
        self.bridge = Mock()
        self.controller = GameController(self.bridge)

    def test_reiniciar_limpia_el_estado_de_la_partida(self):
        self.controller.respuestas = [["es-mujer", "si"]]
        self.controller.preguntadas = ["es-mujer"]
        self.controller.caracteristica_actual = "es-mujer"

        self.controller.reiniciar()

        self.assertEqual(self.controller.respuestas, [])
        self.assertEqual(self.controller.preguntadas, [])
        self.assertIsNone(self.controller.caracteristica_actual)

    def test_obtener_siguiente_paso_envia_el_estado_actual(self):
        peticiones_enviadas = []

        def capturar_peticion(peticion):
            peticiones_enviadas.append(deepcopy(peticion))
            return {
                "tipo": "pregunta",
                "caracteristica": "es-nino",
                "candidatos": 4,
            }

        self.bridge.enviar_mensaje.side_effect = capturar_peticion
        self.controller.respuestas = [["es-mujer", "si"]]
        self.controller.preguntadas = ["es-mujer"]

        resultado = self.controller.obtener_siguiente_paso()

        self.assertEqual(
            peticiones_enviadas,
            [
                {
                    "accion": "inferir",
                    "respuestas": [["es-mujer", "si"]],
                    "preguntadas": ["es-mujer"],
                }
            ],
        )
        self.assertEqual(resultado["tipo"], "pregunta")
        self.assertEqual(self.controller.caracteristica_actual, "es-nino")
        self.assertEqual(self.controller.preguntadas, ["es-mujer", "es-nino"])

    def test_obtener_siguiente_paso_no_agrega_caracteristica_en_un_veredicto(self):
        self.bridge.enviar_mensaje.return_value = {
            "tipo": "veredicto",
            "entidad": "abigail",
            "confianza": 0.8,
        }

        resultado = self.controller.obtener_siguiente_paso()

        self.assertEqual(resultado["tipo"], "veredicto")
        self.assertIsNone(self.controller.caracteristica_actual)
        self.assertEqual(self.controller.preguntadas, [])

    def test_registrar_respuesta_usa_la_caracteristica_actual(self):
        self.controller.caracteristica_actual = "le-gusta-arte"

        self.controller.registrar_respuesta("probablemente")

        self.assertEqual(
            self.controller.respuestas,
            [["le-gusta-arte", "probablemente"]],
        )

    def test_registrar_respuesta_no_agrega_respuestas_sin_pregunta(self):
        self.controller.registrar_respuesta("si")

        self.assertEqual(self.controller.respuestas, [])

    def test_registrar_resultado_actualiza_las_estadisticas(self):
        self.controller.registrar_resultado(True)
        self.controller.registrar_resultado(False)

        self.assertEqual(self.controller.partidas_totales, 2)
        self.assertEqual(self.controller.aciertos_totales, 1)
        self.assertEqual(
            self.controller.obtener_estadisticas(),
            "Partidas: 2 | Aciertos: 1",
        )


if __name__ == "__main__":
    unittest.main()
