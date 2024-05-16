# This service is deprecated. It should not be used anymore.

import logging

class LogService:

    def __init__(self, log_level):
        logging.basicConfig(level=log_level)

    def critical(self, *args):
        logging.critical(*args)

    def error(self, *args):
        logging.error(*args)

    def warning(self, *args):
        logging.warning(*args)

    def info(self, *args):
        logging.info(*args)

    def debug(self, *args):
        logging.debug(*args)

log = LogService(logging.DEBUG)