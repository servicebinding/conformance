#!/bin/bash

set -o pipefail

usage() {
    echo "$0 usage:"
    grep " .)\ #" "$0" | sed -e "s/^\s\+\([a-z]\).*)\ # \(.*\)$/\t-\1: \2/g"
    exit 0
}

while getopts ":j:n:h" arg; do
    case ${arg} in
        j) # set number of jobs to use to run tests (may cause test instability!)
            jobs=${OPTARG}
            ;;
        n) # set the namespace to run tests in
            TEST_NAMESPACE="${OPTARG}"
            ;;
        h) # display help
            usage
            ;;
        *)
            usage
            ;;
    esac
done

OUTPUT_DIR=test-output
if [[ -f test-tmp-dir ]]; then
    OUTPUT_DIR="$(cat test-tmp-dir)"
fi
[[ -d "${OUTPUT_DIR}" ]] || mkdir -p "${OUTPUT_DIR}"

PYTHON_VENV_DIR="${OUTPUT_DIR}/venv"

mkdir -p "${OUTPUT_DIR}"

if [[ -z "${TEST_NAMESPACE}" ]]; then
    TEST_NAMESPACE="servicebindings-cts"
fi

TEST_ACCEPTANCE_OUTPUT_DIR="${OUTPUT_DIR}"/results

# shellcheck disable=SC2261
kubectl get namespace "${TEST_NAMESPACE}" 2&>/dev/null > /dev/null || kubectl delete namespace "${TEST_NAMESPACE}"

if [[ -z "${jobs}" ]]; then
    jobs=1
fi

echo "Running acceptance tests"

FEATURES_PATH=features TEST_NAMESPACE="${TEST_NAMESPACE}" "${PYTHON_VENV_DIR}/bin/behavex" -o "${TEST_ACCEPTANCE_OUTPUT_DIR}" --capture --capture-stderr --parallel-processes "${jobs}" --parallel-scheme scenario
