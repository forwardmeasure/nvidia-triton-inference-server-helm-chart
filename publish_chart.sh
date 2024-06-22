#!/bin/bash -x

UNAME=$(tr [A-Z] [a-z] <<< "$(uname)")
SCRIPT_DIR="$( cd "$( echo "${BASH_SOURCE[0]%/*}/" )"; pwd )"

pushd ${SCRIPT_DIR}
helm lint helm-chart-sources
helm repo index --url https://forwardmeasure.github.io/nvidia-triton-inference-server-helm-chart .
helm package helm-chart-sources

git add . && git commit -m "Minor updates" && git push
popd
