import subprocess
import json
import os
import queue
import shutil
import threading

PROTOCOL_VERSION = 1
DEFAULT_TIMEOUT_SECONDS = 5.0

def _encontrar_racket():
    """Busca automáticamente el ejecutable de Racket en el sistema o rutas comunes de Windows."""
    # 1. Intentar si está disponible globalmente en el PATH
    if shutil.which("racket"):
        return "racket"
    
    # 2. Rutas comunes de instalación en Windows
    rutas_comunes = [
        r"C:\Program Files\Racket\racket.exe",
        r"C:\Program Files (x86)\Racket\racket.exe",
        os.path.expanduser(r"~\AppData\Local\Programs\Racket\racket.exe")
    ]
    
    for ruta in rutas_comunes:
        if os.path.exists(ruta):
            return ruta
            
    return None

class SchemeBridge:
    """Responsable exclusivo de la comunicación bidireccional con el backend de Scheme."""
    def __init__(self, engine_path="Backend/motor.rkt", timeout=DEFAULT_TIMEOUT_SECONDS):
        if timeout <= 0:
            raise ValueError("El timeout debe ser mayor que cero.")

        self.timeout = timeout
        self.engine_path = engine_path
        # Construir la ruta absoluta basada en la ubicación real del archivo actual
        ruta_actual = os.path.dirname(os.path.abspath(__file__))
        ruta_raiz = os.path.dirname(ruta_actual)
        self.script_motor = os.path.join(ruta_raiz, engine_path)
        
        if not os.path.exists(self.script_motor):
            raise FileNotFoundError(f"No se encontró el archivo de Scheme en la ruta: {self.script_motor}")

        # Encontrar Racket automáticamente
        self.racket_ejecutable = _encontrar_racket()
        if not self.racket_ejecutable:
            raise RuntimeError(
                "No se pudo encontrar Racket en el sistema. Asegúrate de tenerlo instalado en una ruta estándar."
            )

        self.proc = None
        self._stdout_queue = None
        self._stderr_lines = []
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
                encoding="utf-8"
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
        except Exception as e:
            raise RuntimeError(f"Error crítico al iniciar el backend de Scheme: {e}")

    def _leer_stdout(self):
        try:
            for linea in iter(self.proc.stdout.readline, ""):
                self._stdout_queue.put(linea)
        except (OSError, ValueError):
            pass
        finally:
            self._stdout_queue.put(None)

    def _leer_stderr(self):
        try:
            for linea in iter(self.proc.stderr.readline, ""):
                with self._stderr_lock:
                    self._stderr_lines.append(linea.rstrip())
        except (OSError, ValueError):
            pass

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
        if not self.proc or self.proc.poll() is not None:
            raise ConnectionError(
                f"El proceso de Scheme no está activo. Error: {self._obtener_stderr()}"
            )

        try:
            mensaje = json.dumps(accion)
            self.proc.stdin.write(mensaje + "\n")
            self.proc.stdin.flush()
        except (BrokenPipeError, OSError) as error:
            raise ConnectionError(
                f"No se pudo enviar el mensaje al backend de Scheme: {error}. "
                f"Detalle: {self._obtener_stderr()}"
            ) from error

        self._asegurar_lector()
        try:
            respuesta_linea = self._stdout_queue.get(timeout=self.timeout)
        except queue.Empty as error:
            raise TimeoutError(
                f"El backend de Scheme no respondió en {self.timeout:g} segundos. "
                f"Detalle: {self._obtener_stderr()}"
            ) from error

        if respuesta_linea is None or not respuesta_linea.strip():
            raise ConnectionError(
                "El backend de Scheme cerró la salida sin responder. "
                f"Detalle: {self._obtener_stderr()}"
            )

        try:
            respuesta = json.loads(respuesta_linea)
        except json.JSONDecodeError as error:
            raise ValueError(
                f"El backend devolvió JSON inválido: {error.msg}. "
                f"Detalle: {self._obtener_stderr()}"
            ) from error

        if respuesta.get("version") != PROTOCOL_VERSION:
            raise ValueError(
                f"Versión de protocolo incompatible: "
                f"{respuesta.get('version')!r}; se esperaba {PROTOCOL_VERSION}."
            )
        return respuesta

    def reiniciar(self):
        """Cierra el proceso actual y arranca una instancia limpia del motor."""
        self.cerrar()
        self._iniciar_proceso()

    def cerrar(self):
        proceso = self.proc
        if not proceso:
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
        except (OSError, subprocess.TimeoutExpired) as error:
            raise ConnectionError(
                f"No se pudo cerrar correctamente el backend de Scheme: {error}"
            ) from error