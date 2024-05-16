#!/bin/bash

pkill -f $FASTOP/.*uvicorn.*
cd $FASTOP/python/amecodownload; nohup ./start-service.sh >& $FASTOP/logs/amecodownload.log &
cd $FASTOP/python/eucam; nohup ./start-service.sh >& $FASTOP/logs/eucam.log &
cd $FASTOP/python/fdmsstar; nohup ./start-service.sh >& $FASTOP/logs/fdmsstar.log &
cd $FASTOP/python/hicp; nohup ./start-service.sh >& $FASTOP/logs/hicp.log &
cd $FASTOP/python/neer; nohup ./start-service.sh >& $FASTOP/logs/neer.log &
cd $FASTOP/python/sdmx; nohup ./start-service.sh >& $FASTOP/logs/sdmx.log &
cd $FASTOP/python/fpcalc; nohup ./start-service.sh >& $FASTOP/logs/fpcalc.log &
cd $FASTOP/python/fplm; nohup ./start-service.sh >& $FASTOP/logs/fplm.log &
