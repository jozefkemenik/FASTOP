
from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles

from fastoplib.base_app import base_api, base_lifecycle_hooks, base_logging, base_middleware

from config import appName, appVersion
from routers.calc import calc
from routers.report import report
from routers.task import task

app = FastAPI(
    title=appName,
    description=appName,
    version=appVersion
)

base_logging()
base_lifecycle_hooks(app)
base_middleware(app)
base_api(app)

app.include_router(calc.router, prefix="/calc")
app.include_router(report.router, prefix="/reports")
app.include_router(task.router, prefix="/tasks")
app.mount("/doc", StaticFiles(directory="doc"), name="doc")
