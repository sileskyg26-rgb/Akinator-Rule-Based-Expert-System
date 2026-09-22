import json
import unittest
from unittest.mock import Mock

from Frontend.scheme_bridge import SchemeBridge


class SchemeBridgeTests(unittest.TestCase):
    def test_enviar_mensaje_serializa_y_parsea_json(self):
        process = Mock()
        process.poll.return_value = None
        process.stdout.readline.return_value = (
            '{"tipo":"pregunta","caracteristica":"es-nino","candidatos":4}\n'
        )
        bridge = SchemeBridge.__new__(SchemeBridge)
        bridge.proc = process
        mensaje = {"accion": "inferir", "respuestas": [], "preguntadas": []}

        resultado = bridge.enviar_mensaje(mensaje)

        process.stdin.write.assert_called_once_with(json.dumps(mensaje) + "\n")
        process.stdin.flush.assert_called_once_with()
        self.assertEqual(resultado["tipo"], "pregunta")

    def test_enviar_mensaje_falla_si_el_proceso_termino(self):
        process = Mock()
        process.poll.return_value = 1
        process.stderr.read.return_value = "backend detenido"
        bridge = SchemeBridge.__new__(SchemeBridge)
        bridge.proc = process

        with self.assertRaises(ConnectionError):
            bridge.enviar_mensaje({"accion": "inferir"})

    def test_enviar_mensaje_devuelve_error_sin_respuesta(self):
        process = Mock()
        process.poll.return_value = None
        process.stdout.readline.return_value = ""
        bridge = SchemeBridge.__new__(SchemeBridge)
        bridge.proc = process

        resultado = bridge.enviar_mensaje({"accion": "inferir"})

        self.assertEqual(resultado["tipo"], "error")
