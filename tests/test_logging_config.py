import logging
import tempfile
import unittest
from pathlib import Path

from Frontend.logging_config import configurar_logging


class LoggingConfigTests(unittest.TestCase):
    def test_configura_archivo_rotativo_y_nivel(self):
        root = logging.getLogger()
        handlers_originales = root.handlers[:]
        nivel_original = root.level
        with tempfile.TemporaryDirectory() as directorio:
            try:
                logger = configurar_logging(directorio)
                logger.info("evento de prueba")

                archivo_log = Path(directorio) / "stardew-akinator.log"
                for handler in root.handlers:
                    handler.flush()

                self.assertTrue(archivo_log.exists())
                self.assertIn(
                    "evento de prueba", archivo_log.read_text(encoding="utf-8")
                )
            finally:
                for handler in root.handlers:
                    handler.close()
                root.handlers[:] = handlers_originales
                root.setLevel(nivel_original)


if __name__ == "__main__":
    unittest.main()
