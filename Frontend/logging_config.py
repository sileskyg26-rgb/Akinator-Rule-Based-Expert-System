import logging
import logging.config
import os
from pathlib import Path

DEFAULT_LOG_LEVEL = "INFO"
DEFAULT_LOG_FILE = "stardew-akinator.log"


def configurar_logging(log_dir=None):
    """Configura logging rotativo para la aplicación y devuelve el logger raíz."""
    if log_dir is None:
        log_dir = Path(__file__).resolve().parent.parent / "logs"
    else:
        log_dir = Path(log_dir)

    log_dir.mkdir(parents=True, exist_ok=True)
    log_level = os.getenv("STARDEW_AKINATOR_LOG_LEVEL", DEFAULT_LOG_LEVEL).upper()
    if not hasattr(logging, log_level):
        log_level = DEFAULT_LOG_LEVEL

    log_file = log_dir / DEFAULT_LOG_FILE
    logging.config.dictConfig(
        {
            "version": 1,
            "disable_existing_loggers": False,
            "formatters": {
                "default": {
                    "format": "%(asctime)s | %(levelname)s | %(name)s | %(message)s",
                }
            },
            "handlers": {
                "file": {
                    "class": "logging.handlers.RotatingFileHandler",
                    "filename": str(log_file),
                    "maxBytes": 1_048_576,
                    "backupCount": 3,
                    "encoding": "utf-8",
                    "formatter": "default",
                },
                "console": {
                    "class": "logging.StreamHandler",
                    "formatter": "default",
                },
            },
            "root": {
                "level": log_level,
                "handlers": ["file", "console"],
            },
        }
    )
    logger = logging.getLogger("stardew_akinator")
    logger.info("Logging configurado en %s con nivel %s.", log_file, log_level)
    return logger
