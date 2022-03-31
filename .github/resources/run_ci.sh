#!/usr/bin/bash

./setup.sh
./run_tests.sh
if [ $? -ne 0 ]; then
    if [ "$(kubectl get -n cts-namespace servicebindings.servicebinding.io -o jsonpath="{.items[].status}" | wc -m)" = "0" ] && [ "$(kubectl get -n cts-namespace secrets -o name | wc -l)" = "2" ]; then
        exit 0
    else
        exit 1
    fi
fi
