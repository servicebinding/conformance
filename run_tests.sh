#!/usr/bin/env bash

OUTPUT_DIR=test-output
if [ -f test-tmp-dir ]; then
    OUTPUT_DIR=$(cat test-tmp-dir)
fi
[ -d "${OUTPUT_DIR}" ] || mkdir -p "${OUTPUT_DIR}"

PYTHON_VENV_DIR="${OUTPUT_DIR}/venv"

mkdir -p "${OUTPUT_DIR}"

TEST_NAMESPACE="cts-namespace"
TEST_ACCEPTANCE_OUTPUT_DIR="${OUTPUT_DIR}"/results

if [ $(kubectl get namespace ${TEST_NAMESPACE} > /dev/null; echo $?) -ne 0 ]; then
    kubectl delete namespace ${TEST_NAMESPACE}
fi

echo "Running acceptance tests"

TEST_NAMESPACE=${TEST_NAMESPACE} "${PYTHON_VENV_DIR}/bin/behave" --junit --junit-directory ${TEST_ACCEPTANCE_OUTPUT_DIR} --no-capture --no-capture-stderr features
