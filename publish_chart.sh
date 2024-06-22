#!/bin/bash -x

UNAME=$(tr [A-Z] [a-z] <<< "$(uname)")
SCRIPT_DIR="$( cd "$( echo "${BASH_SOURCE[0]%/*}/" )"; pwd )"

pushd ${SCRIPT_DIR}
helm lint helm-chart-sources
helm package helm-chart-sources

git add . && git commit -m "Minor updates" && git push
popd
