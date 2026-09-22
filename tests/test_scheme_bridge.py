import json
import unittest
from unittest.mock import Mock

from Frontend.scheme_bridge import SchemeBridge


class SchemeBridgeTests(unittest.TestCase):
    def create_bridge_with_process(self, process):
        bridge = SchemeBridge.__new__(SchemeBridge)
        bridge.proc = process
        return bridge

    def test_enviar_mensaje_serializa_la_peticion_y_lee_la_respuesta(self):
        process = Mock()
        process.poll.return_value = None
        process.stdout.readline.return_value = (
            '{"tipo": "pregunta", "caracteristica": "es-nino", "candidatos": 4}\n'
        )
        bridge = self.create_bridge_with_process(process)
        peticion = {
            "accion": "inferir",
            "respuestas": [],
            "preguntadas": [],
        }

        resultado = bridge.enviar_mensaje(peticion)

        process.stdin.write.assert_called_once_with(json.dumps(peticion) + "\n")
        process.stdin.flush.assert_called_once_with()
        self.assertEqual(resultado["tipo"], "pregunta")
        self.assertEqual(resultado["caracteristica"], "es-nino")

    def test_enviar_mensaje_falla_si_el_proceso_no_esta_activo(self):
        process = Mock()
        process.poll.return_value = 1
        process.stderr.read.return_value = "Racket terminó inesperadamente"
        bridge = self.create_bridge_with_process(process)

        with self.assertRaisesRegex(ConnectionError, "Racket terminó"):
            bridge.enviar_mensaje({"accion": "inferir"})

    def test_enviar_mensaje_devuelve_error_si_no_hay_respuesta(self):
        process = Mock()
        process.poll.return_value = None
        process.stdout.readline.return_value = ""
        bridge = self.create_bridge_with_process(process)

        resultado = bridge.enviar_mensaje({"accion": "inferir"})

        self.assertEqual(
            resultado,
            {"tipo": "error", "mensaje": "No se recibió respuesta de Scheme."},
        )

    def test_enviar_mensaje_rechaza_respuestas_no_json(self):
        process = Mock()
        process.poll.return_value = None
        process.stdout.readline.return_value = "respuesta inválida\n"
        bridge = self.create_bridge_with_process(process)

        with self.assertRaises(json.JSONDecodeError):
            bridge.enviar_mensaje({"accion": "inferir"})


if __name__ == "__main__":
    unittest.main()
