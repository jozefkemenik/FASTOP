#!/bin/bash

echo building corecom airflow image and starting airflow...
if [ -z "$AIRFLOW_CORECOM" ]
then
        echo "AIRFLOW_CORECOM variable is not set!"
        exit 1
fi

cd "$AIRFLOW_CORECOM" || exit 2
./run_airflow_budg.sh
