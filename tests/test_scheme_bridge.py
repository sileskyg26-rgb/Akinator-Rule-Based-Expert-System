import json
import queue
import threading
import unittest
from unittest.mock import Mock, patch

from Frontend.scheme_bridge import SchemeBridge


class SchemeBridgeTests(unittest.TestCase):
    def test_enviar_mensaje_serializa_y_parsea_json(self):
        process = Mock()
        process.poll.return_value = None
        process.stdout.readline.return_value = (
            '{"version":1,"tipo":"pregunta","caracteristica":"es-nino","candidatos":4}\n'
        )
        bridge = SchemeBridge.__new__(SchemeBridge)
        bridge.proc = process
        bridge.timeout = 1
        bridge._stdout_queue = queue.Queue()
        bridge._stdout_queue.put(
            '{"version":1,"tipo":"pregunta","caracteristica":"es-nino","candidatos":4}\n'
        )
        bridge._stderr_lines = []
        bridge._stderr_lock = threading.Lock()
        mensaje = {
            "version": 1,
            "accion": "inferir",
            "respuestas": [],
            "preguntadas": [],
        }

        resultado = bridge.enviar_mensaje(mensaje)

        process.stdin.write.assert_called_once_with(json.dumps(mensaje) + "\n")
        process.stdin.flush.assert_called_once_with()
        self.assertEqual(resultado["tipo"], "pregunta")

    def test_enviar_mensaje_rechaza_una_version_incompatible(self):
        process = Mock()
        process.poll.return_value = None
        process.stdout.readline.return_value = (
            '{"version":2,"tipo":"pregunta","caracteristica":"es-nino","candidatos":4}\n'
        )
        bridge = SchemeBridge.__new__(SchemeBridge)
        bridge.proc = process
        bridge.timeout = 1
        bridge._stdout_queue = queue.Queue()
        bridge._stdout_queue.put(
            '{"version":2,"tipo":"pregunta","caracteristica":"es-nino","candidatos":4}\n'
        )
        bridge._stderr_lines = []
        bridge._stderr_lock = threading.Lock()

        with self.assertRaisesRegex(ValueError, "incompatible"):
            bridge.enviar_mensaje({"version": 1, "accion": "inferir"})

    def test_enviar_mensaje_falla_si_el_proceso_termino(self):
        process = Mock()
        process.poll.return_value = 1
        process.stderr.read.return_value = "backend detenido"
        bridge = SchemeBridge.__new__(SchemeBridge)
        bridge.proc = process
        bridge.timeout = 1
        bridge._stderr_lines = ["backend detenido"]
        bridge._stderr_lock = threading.Lock()

        with self.assertRaises(ConnectionError):
            bridge.enviar_mensaje({"accion": "inferir"})

    def test_enviar_mensaje_devuelve_error_sin_respuesta(self):
        process = Mock()
        process.poll.return_value = None
        process.stdout.readline.return_value = ""
        bridge = SchemeBridge.__new__(SchemeBridge)
        bridge.proc = process
        bridge.timeout = 1
        bridge._stdout_queue = queue.Queue()
        bridge._stdout_queue.put(None)
        bridge._stderr_lines = []
        bridge._stderr_lock = threading.Lock()

        with self.assertRaises(ConnectionError):
            bridge.enviar_mensaje({"accion": "inferir"})

    def _bridge_with_queue(self, response, timeout=0.01):
        process = Mock()
        process.poll.return_value = None
        bridge = SchemeBridge.__new__(SchemeBridge)
        bridge.proc = process
        bridge.timeout = timeout
        bridge._stdout_queue = queue.Queue()
        if response is not None:
            bridge._stdout_queue.put(response)
        bridge._stderr_lines = ["diagnóstico de prueba"]
        bridge._stderr_lock = __import__("threading").Lock()
        return bridge

    def test_enviar_mensaje_falla_por_timeout(self):
        bridge = self._bridge_with_queue(None)

        with self.assertRaisesRegex(TimeoutError, "no respondió"):
            bridge.enviar_mensaje({"accion": "inferir"})

    def test_enviar_mensaje_rechaza_json_invalido(self):
        bridge = self._bridge_with_queue("respuesta rota\n")

        with self.assertRaisesRegex(ValueError, "JSON inválido"):
            bridge.enviar_mensaje({"accion": "inferir"})

    def test_reiniciar_cierra_y_arranca_un_proceso_nuevo(self):
        bridge = self._bridge_with_queue(None)

        with patch.object(bridge, "cerrar") as cerrar, patch.object(
            bridge, "_iniciar_proceso"
        ) as iniciar:
            bridge.reiniciar()

        cerrar.assert_called_once_with()
        iniciar.assert_called_once_with()
