from fastapi import APIRouter

from fastoplib import TaskParams
from .task_controller import TaskController

router = APIRouter()
controller = TaskController()

@router.post('/{task_id}')
async def run_task(task_id: str, body: TaskParams):
    return await controller.run_task(task_id, body)
