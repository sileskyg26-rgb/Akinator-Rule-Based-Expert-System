import unittest

from Frontend.scheme_bridge import PROTOCOL_VERSION, SchemeBridge, _encontrar_racket


@unittest.skipUnless(
    _encontrar_racket(),
    "Racket no está instalado; la prueba se ejecuta en el job de integración del CI.",
)
class SchemeBridgeIntegrationTests(unittest.TestCase):
    def setUp(self):
        self.bridge = SchemeBridge(timeout=5)

    def tearDown(self):
        self.bridge.cerrar()

    def test_python_y_racket_intercambian_una_respuesta_del_protocolo(self):
        respuesta = self.bridge.enviar_mensaje(
            {
                "version": PROTOCOL_VERSION,
                "accion": "inferir",
                "respuestas": [],
                "preguntadas": [],
            }
        )

        self.assertEqual(respuesta["version"], PROTOCOL_VERSION)
        self.assertIn(respuesta["tipo"], {"pregunta", "veredicto", "error"})
        if respuesta["tipo"] == "pregunta":
            self.assertIsInstance(respuesta["caracteristica"], str)
            self.assertGreater(respuesta["candidatos"], 0)

    def test_racket_rechaza_una_accion_no_soportada(self):
        respuesta = self.bridge.enviar_mensaje(
            {
                "version": PROTOCOL_VERSION,
                "accion": "accion-inexistente",
                "respuestas": [],
                "preguntadas": [],
            }
        )

        self.assertEqual(respuesta["version"], PROTOCOL_VERSION)
        self.assertEqual(respuesta["tipo"], "error")
        self.assertIn("acción", respuesta["mensaje"])

    def test_motor_completa_una_partida_hasta_emitir_veredicto(self):
        respuestas: list[list[str]] = []
        preguntadas: list[str] = []

        for _ in range(30):
            respuesta = self.bridge.enviar_mensaje(
                {
                    "version": PROTOCOL_VERSION,
                    "accion": "inferir",
                    "respuestas": respuestas,
                    "preguntadas": preguntadas,
                }
            )

            self.assertEqual(respuesta["version"], PROTOCOL_VERSION)
            if respuesta["tipo"] == "veredicto":
                self.assertIn("entidad", respuesta)
                self.assertIn("confianza", respuesta)
                self.assertIsInstance(respuesta["explicacion"], list)
                return

            self.assertEqual(respuesta["tipo"], "pregunta")
            caracteristica = respuesta["caracteristica"]
            self.assertNotIn(caracteristica, preguntadas)
            self.assertGreater(respuesta["candidatos"], 0)
            preguntadas.append(caracteristica)
            respuestas.append([caracteristica, "no-se"])

        self.fail("El motor no emitió un veredicto dentro del límite esperado.")


if __name__ == "__main__":
    unittest.main()
