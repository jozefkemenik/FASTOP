from fastapi import FastAPI
from logging import basicConfig, DEBUG
from multiprocessing import current_process
from os import environ, path
from pydantic import BaseModel
from starlette.requests import Request
from starlette.responses import JSONResponse

from .config import apiKey
from .executor_service import ExecutorService
from .request_service import RequestService

# This module contains app main common functionality

###################################################################################################
##################################### logging #####################################################
###################################################################################################
def base_logging():
    basicConfig(level = environ.get("LOGLEVEL", DEBUG))

def worker_logging(app: str):
    basicConfig(
        filename = path.join(environ.get("LOGS", '.'), f'{app}_{current_process().name}.log'),
        level = environ.get("LOGLEVEL", DEBUG),
    )

###################################################################################################
##################################### lifecycle hooks #############################################
###################################################################################################
def base_lifecycle_hooks(app: FastAPI):

    @app.on_event("startup")
    async def startup_event():
        RequestService.get_service()
        ExecutorService.get_service(worker_logging, app.title)

    @app.on_event("shutdown")
    async def shutdown_event():
        await RequestService.get_service().close_session()
        ExecutorService.get_executor().shutdown()

###################################################################################################
##################################### middleware ##################################################
###################################################################################################
def base_middleware(app: FastAPI):

    @app.middleware("http")
    async def check_api_key(req: Request, next):
        header = 'apiKey'
        if header in req.headers and req.headers[header] == apiKey:
            resp = await next(req)
        else:
            resp = JSONResponse(status_code = 403, content = 'Invalid API key.')
        return resp

###################################################################################################
##################################### api #########################################################
###################################################################################################
class ServerInfoOut(BaseModel):
    serverName: str
    serviceVersion: str

def base_api(app: FastAPI):

    @app.get("/")
    def home():
        return f'{app.title} API is up and running!'

    @app.get("/serverInfo", response_model = ServerInfoOut)
    def server_info():
        return {'serverName': app.title, 'serviceVersion': app.version}
