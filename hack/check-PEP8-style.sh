#!/usr/bin/env bash

echo "----------------------------------------------------"
echo "Running Python linter against following directories:"
echo "$directories"
echo "----------------------------------------------------"
echo

# checks for the whole directories
for directory in $directories
do
    files=$(find "$directory" -path "$PYTHON_VENV_DIR" -prune -o -name '*.py' -print)

    for source in $files
    do
        echo "$source"
        $PYTHON_VENV_DIR/bin/pycodestyle "$source"
        if [ $? -eq 0 ]
        then
            echo "    Pass"
            let "pass++"
        else
            echo "    Fail"
            let "fail++"
        fi
    done
done


if [ $fail -eq 0 ]
then
    echo "All checks passed for $pass source files"
else
    let total=$pass+$fail
    echo "Linter fail, $fail source files out of $total source files need to be fixed"
    failed="$failed\n - check-PEP8-style"
fi
