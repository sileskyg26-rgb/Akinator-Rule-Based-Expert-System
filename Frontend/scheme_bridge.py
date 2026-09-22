import subprocess
import json
import os
import shutil

PROTOCOL_VERSION = 1

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
    def __init__(self, engine_path="Backend/motor.rkt"):
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
        except Exception as e:
            raise RuntimeError(f"Error crítico al iniciar el backend de Scheme: {e}")

    def enviar_mensaje(self, accion: dict) -> dict:
        if not self.proc or self.proc.poll() is not None:
            stderr_msg = self.proc.stderr.read() if self.proc and self.proc.stderr else "Sin detalles"
            raise ConnectionError(f"El proceso de Scheme no está activo. Error: {stderr_msg}")
        
        mensaje = json.dumps(accion)
        self.proc.stdin.write(mensaje + "\n")
        self.proc.stdin.flush()
        
        respuesta_linea = self.proc.stdout.readline()
        if not respuesta_linea:
            return {"tipo": "error", "mensaje": "No se recibió respuesta de Scheme."}
        
        respuesta = json.loads(respuesta_linea)
        if respuesta.get("version") != PROTOCOL_VERSION:
            raise ValueError(
                f"Versión de protocolo incompatible: "
                f"{respuesta.get('version')!r}; se esperaba {PROTOCOL_VERSION}."
            )
        return respuesta

    def cerrar(self):
        if self.proc:
            self.proc.terminate()
            self.proc.wait()