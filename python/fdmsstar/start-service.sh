#!/bin/bash

if [[ -d $FASTOP/python/.venv/Scripts ]] ; then
    . $FASTOP/python/.venv/Scripts/activate
else
    . $FASTOP/python/.venv/bin/activate
fi

uvicorn main:app --host 0.0.0.0 --port 3503 --log-level debug
