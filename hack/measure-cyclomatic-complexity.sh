#!/bin/bash

echo "----------------------------------------------------"
echo "Checking for cyclomatic complexity limits"
echo "in the following directories:"
echo "$directories"
echo "----------------------------------------------------"
echo

echo "PYTHON_VENV_DIR=${PYTHON_VENV_DIR}"

SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"

res=0
for directory in ${SCRIPT_DIR}/.. $directories; do
    pushd "$directory"
    $PYTHON_VENV_DIR/bin/radon cc -s -a -i venv .
    if [ $? -ne 0 ]; then 
        let res++
    fi
    popd
done

if [ $res -ne 0 ]; then
    failed="$failed\n - measure-cyclomatic-complexity"
fi
