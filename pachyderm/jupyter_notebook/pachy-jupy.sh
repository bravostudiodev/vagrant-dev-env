#!/usr/bin/env bash

cp -f jupyter.json jupyter-run.json
LAST_COMMIT_TRIPS=$(pachctl list-commit trips | head -n 2 | tail -n 1 | tr -s ' ' | cut -d ' ' -f 2)
LAST_COMMIT_SALES=$(pachctl flush-commit trips/${LAST_COMMIT_TRIPS} -r sales | head -n 2 | tail -n 1 | tr -s ' ' | cut -d ' ' -f 2)
LAST_COMMIT_WEATHER=$(pachctl list-commit weather | head -n 2 | tail -n 1 | tr -s ' ' | cut -d ' ' -f 2)
echo "LAST_COMMIT_TRIPS=${LAST_COMMIT_TRIPS}"
echo "LAST_COMMIT_SALES=${LAST_COMMIT_SALES}"
echo "LAST_COMMIT_WEATHER=${LAST_COMMIT_WEATHER}"
sed -e "s/COMMIT_TRIPS/${LAST_COMMIT_TRIPS}/" \
    -e "s/COMMIT_SALES/${LAST_COMMIT_SALES}/"  \
    -e "s/COMMIT_WEATHER/${LAST_COMMIT_WEATHER}/" \
    -i jupyter-run.json
    
JOB_ID=$(pachctl create-job -f jupyter-run.json)
echo "JOB_ID=${JOB_ID}"

until kubectl get pod -l app=job-${JOB_ID} | grep -q Running; do sleep 1; done
JOB_POD=$(kubectl get pod -l app=job-${JOB_ID} | head -n 2 | tail -n 1 | cut -d ' ' -f 1)
echo "JOB_POD=${JOB_POD}"

sleep 3
kubectl port-forward ${JOB_POD} 8888 &
echo "Port 8888 forwarder to localhost"
xdg-open http://localhost:8888
