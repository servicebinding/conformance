#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"

res=0
for directory in ${SCRIPT_DIR}/.. $directories; do
    pushd "$directory"
    $PYTHON_VENV_DIR/bin/radon mi -s -i venv .
    if [ $? -ne 0 ]; then
        let res++
    fi
    popd
done

if [ $res -ne 0 ]; then
    failed="$failed\n - measure-maintainability-index"
fi
