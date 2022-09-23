#!/bin/bash

. ./hack/prepare-env.sh

[ "$NOVENV" == "1" ] || prepare_venv || exit 1

echo "----------------------------------------------------"
echo "Checking for cyclomatic complexity limits"
echo "in the following directories:"
echo "$directories"
echo "----------------------------------------------------"
echo

echo "PYTHON_VENV_DIR=${PYTHON_VENV_DIR}"

SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"

for directory in ${SCRIPT_DIR}/.. $directories; do
    pushd "$directory"
    $PYTHON_VENV_DIR/bin/radon cc -s -a -i venv .
    popd
done
