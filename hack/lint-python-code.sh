#!/usr/bin/env bash

source $(cat test-tmp-dir)/venv/bin/activate
PYTHON_VENV_DIR=${VIRTUAL_ENV}

failed=""
CHECK_PYTHON=./hack
source $CHECK_PYTHON/prepare-env.sh
source $CHECK_PYTHON/detect-common-errors.sh
source $CHECK_PYTHON/detect-dead-code.sh
source $CHECK_PYTHON/check-PEP8-style.sh
source $CHECK_PYTHON/measure-cyclomatic-complexity.sh
source $CHECK_PYTHON/measure-maintainability-index.sh

if [ ! -z "$failed" ]; then
    echo -e "\nERROR: Following python checks FAILED:$failed\n"
    exit 1
else
    echo -e "\nAll python checks PASSED"
fi
