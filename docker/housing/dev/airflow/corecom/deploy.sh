#!/bin/bash

echo deploying corecom airflow files...


if [ -z "$AIRFLOW_CORECOM" ]
then
    echo "AIRFLOW_CORECOM variable is not set!"
    exit 1
fi


if [ ! -f "$CORECOM"/deploy/corecom-airflow.deploy.tar.gz ]
then
    echo "Deployment artifact is missing!"
    exit 1
fi


rm -rf "$AIRFLOW_CORECOM"/CORECOM/*
rm -rf "$AIRFLOW_CORECOM"/_image/requirements.txt
rm -rf "$AIRFLOW_CORECOM"/dags/*

cd "$CORECOM"/deploy || exit 2

tar xpzf corecom-airflow.deploy.tar.gz -C .

cp -R corecom-airflow/CORECOM/* "$AIRFLOW_CORECOM"/CORECOM/
cp -R corecom-airflow/dags/* "$AIRFLOW_CORECOM"/dags/
cp corecom-airflow/CORECOM/requirements.txt "$AIRFLOW_CORECOM"/_image/

rm corecom-airflow.deploy.tar.gz
rm -rf corecom-airflow
