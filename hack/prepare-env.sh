directories=${directories:-"features"}
pass=0
fail=0

export PYTHON_VENV_DIR=${PYTHON_VENV_DIR:-venv}
"${PYTHON_VENV_DIR}"/bin/pip install -r $(dirname $0)/requirements.txt
