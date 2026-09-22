import subprocess
import json
import logging
import os
import queue
import shutil
import threading
import time

PROTOCOL_VERSION = 1
DEFAULT_TIMEOUT_SECONDS = 5.0
logger = logging.getLogger("stardew_akinator.scheme_bridge")


def _encontrar_racket():
    """Busca automáticamente el ejecutable de Racket en el sistema o rutas comunes de Windows."""
    # 1. Intentar si está disponible globalmente en el PATH
    if shutil.which("racket"):
        return "racket"

    # 2. Rutas comunes de instalación en Windows
    rutas_comunes = [
        r"C:\Program Files\Racket\racket.exe",
        r"C:\Program Files (x86)\Racket\racket.exe",
        os.path.expanduser(r"~\AppData\Local\Programs\Racket\racket.exe"),
    ]

    for ruta in rutas_comunes:
        if os.path.exists(ruta):
            return ruta

    return None


class SchemeBridge:
    """Responsable exclusivo de la comunicación bidireccional con el backend de Scheme."""

    def __init__(
        self, engine_path="Backend/motor.rkt", timeout=DEFAULT_TIMEOUT_SECONDS
    ):
        if timeout <= 0:
            raise ValueError("El timeout debe ser mayor que cero.")

        self.timeout = timeout
        self.engine_path = engine_path
        # Construir la ruta absoluta basada en la ubicación real del archivo actual
        ruta_actual = os.path.dirname(os.path.abspath(__file__))
        ruta_raiz = os.path.dirname(ruta_actual)
        self.script_motor = os.path.join(ruta_raiz, engine_path)

        if not os.path.exists(self.script_motor):
            raise FileNotFoundError(
                f"No se encontró el archivo de Scheme en la ruta: {self.script_motor}"
            )

        # Encontrar Racket automáticamente
        self.racket_ejecutable = _encontrar_racket()
        if not self.racket_ejecutable:
            raise RuntimeError(
                "No se pudo encontrar Racket en el sistema. Asegúrate de tenerlo instalado en una ruta estándar."
            )

        self.proc: subprocess.Popen[str] | None = None
        self._stdout_queue: queue.Queue[str | None] | None = None
        self._stderr_lines: list[str] = []
        self._stderr_lock = threading.Lock()
        self._iniciar_proceso()

    def _iniciar_proceso(self):
        try:
            self.proc = subprocess.Popen(
                [self.racket_ejecutable, self.script_motor],
                stdin=subprocess.PIPE,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True,
                encoding="utf-8",
            )
            self._stdout_queue = queue.Queue()
            self._stderr_lines = []
            threading.Thread(
                target=self._leer_stdout,
                daemon=True,
                name="scheme-stdout-reader",
            ).start()
            threading.Thread(
                target=self._leer_stderr,
                daemon=True,
                name="scheme-stderr-reader",
            ).start()
            logger.info("Motor Scheme iniciado (pid=%s).", self.proc.pid)
        except Exception as e:
            logger.exception("No se pudo iniciar el motor Scheme.")
            raise RuntimeError(f"Error crítico al iniciar el backend de Scheme: {e}")

    def _leer_stdout(self):
        proceso = self.proc
        salida = self._stdout_queue
        if proceso is None or proceso.stdout is None or salida is None:
            return
        try:
            for linea in iter(proceso.stdout.readline, ""):
                salida.put(linea)
        except (OSError, ValueError):
            logger.debug("La lectura de stdout terminó durante el cierre del motor.")
        finally:
            salida.put(None)

    def _leer_stderr(self):
        proceso = self.proc
        if proceso is None or proceso.stderr is None:
            return
        try:
            for linea in iter(proceso.stderr.readline, ""):
                logger.warning("stderr del motor Scheme: %s", linea.rstrip())
                with self._stderr_lock:
                    self._stderr_lines.append(linea.rstrip())
        except (OSError, ValueError):
            logger.debug("La lectura de stderr terminó durante el cierre del motor.")

    def _obtener_stderr(self):
        with self._stderr_lock:
            return "\n".join(self._stderr_lines).strip() or "Sin detalles del backend."

    def _respuesta_error(self, mensaje):
        return {
            "version": PROTOCOL_VERSION,
            "tipo": "error",
            "mensaje": mensaje,
        }

    def _asegurar_lector(self):
        if self._stdout_queue is None:
            self._stdout_queue = queue.Queue()
            threading.Thread(target=self._leer_stdout, daemon=True).start()

    def enviar_mensaje(self, accion: dict) -> dict:
        proceso = self.proc
        if not proceso or proceso.poll() is not None:
            logger.error(
                "Se intentó enviar un mensaje con el motor inactivo. Detalle: %s",
                self._obtener_stderr(),
            )
            raise ConnectionError(
                f"El proceso de Scheme no está activo. Error: {self._obtener_stderr()}"
            )

        try:
            mensaje = json.dumps(accion)
            logger.debug("Mensaje enviado al motor: %s", mensaje)
            inicio = time.perf_counter()
            if proceso.stdin is None:
                raise ConnectionError(
                    "El backend no tiene un canal de entrada disponible."
                )
            proceso.stdin.write(mensaje + "\n")
            proceso.stdin.flush()
        except (BrokenPipeError, OSError) as error:
            logger.exception("Falló el envío de un mensaje al motor.")
            raise ConnectionError(
                f"No se pudo enviar el mensaje al backend de Scheme: {error}. "
                f"Detalle: {self._obtener_stderr()}"
            ) from error

        self._asegurar_lector()
        respuesta_queue = self._stdout_queue
        if respuesta_queue is None:
            raise ConnectionError(
                "El backend no tiene un lector de respuestas disponible."
            )
        try:
            respuesta_linea = respuesta_queue.get(timeout=self.timeout)
        except queue.Empty as error:
            logger.error(
                "Timeout esperando respuesta del motor después de %.3f segundos.",
                self.timeout,
            )
            raise TimeoutError(
                f"El backend de Scheme no respondió en {self.timeout:g} segundos. "
                f"Detalle: {self._obtener_stderr()}"
            ) from error

        if respuesta_linea is None or not respuesta_linea.strip():
            logger.error("El motor cerró stdout sin devolver una respuesta.")
            raise ConnectionError(
                "El backend de Scheme cerró la salida sin responder. "
                f"Detalle: {self._obtener_stderr()}"
            )

        try:
            respuesta = json.loads(respuesta_linea)
        except json.JSONDecodeError as error:
            logger.error(
                "El motor devolvió JSON inválido: %s", respuesta_linea.rstrip()
            )
            raise ValueError(
                f"El backend devolvió JSON inválido: {error.msg}. "
                f"Detalle: {self._obtener_stderr()}"
            ) from error

        if respuesta.get("version") != PROTOCOL_VERSION:
            logger.error(
                "Versión de protocolo incompatible recibida: %s",
                respuesta.get("version"),
            )
            raise ValueError(
                f"Versión de protocolo incompatible: "
                f"{respuesta.get('version')!r}; se esperaba {PROTOCOL_VERSION}."
            )
        logger.debug(
            "Respuesta recibida del motor en %.3f segundos: %s",
            time.perf_counter() - inicio,
            respuesta_linea.rstrip(),
        )
        if respuesta.get("tipo") == "error":
            logger.error("Error de protocolo recibido: %s", respuesta.get("mensaje"))
        return respuesta

    def reiniciar(self):
        """Cierra el proceso actual y arranca una instancia limpia del motor."""
        logger.info("Reinicio solicitado para el motor Scheme.")
        self.cerrar()
        self._iniciar_proceso()

    def cerrar(self):
        proceso = self.proc
        if not proceso:
            logger.debug("Cierre solicitado sin un proceso Scheme activo.")
            return

        self.proc = None
        try:
            if proceso.poll() is None:
                proceso.terminate()
                try:
                    proceso.wait(timeout=self.timeout)
                except subprocess.TimeoutExpired:
                    proceso.kill()
                    proceso.wait(timeout=self.timeout)
                    logger.warning("El motor Scheme requirió cierre forzado.")
        except (OSError, subprocess.TimeoutExpired) as error:
            logger.exception("No se pudo cerrar correctamente el motor Scheme.")
            raise ConnectionError(
                f"No se pudo cerrar correctamente el backend de Scheme: {error}"
            ) from error
        else:
            logger.info("Motor Scheme cerrado.")
        finally:
            for stream in (proceso.stdin, proceso.stdout, proceso.stderr):
                if stream is not None:
                    stream.close()
