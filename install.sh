#!/bin/bash
set -e

# Local variables
ENV_NAME=ffl
PYTHON=3.10.10

# Installation script for Anaconda3 environments
echo "____________ Pick conda install _____________"
echo
# Recover the path to conda on your machine
CONDA_DIR=`realpath /opt/miniconda3`
if (test -z $CONDA_DIR) || [ ! -d $CONDA_DIR ]
then
  CONDA_DIR=`realpath ~/anaconda3`
fi

while (test -z $CONDA_DIR) || [ ! -d $CONDA_DIR ]
do
    echo "Could not find conda at: "$CONDA_DIR
    read -p "Please provide you conda install directory: " CONDA_DIR
    CONDA_DIR=`realpath $CONDA_DIR`
done

echo "Using conda found at: ${CONDA_DIR}/etc/profile.d/conda.sh"
source ${CONDA_DIR}/etc/profile.d/conda.sh
echo
echo


echo "________________ Installation _______________"
echo

# Check if the environment exists
if conda env list | awk '{print $1}' | grep -q "^$ENV_NAME$"; then
    echo "Conda environment '$ENV_NAME' already exists. Removing..."

    # Remove the environment
    conda env remove --name "$ENV_NAME" --yes > /dev/null 2>&1

    # Double-check removal
    if conda env list | awk '{print $1}' | grep -q "^$ENV_NAME$"; then
        echo "Failed to remove the environment '$ENV_NAME'."
        exit 1
    else
        echo "Conda environment '$ENV_NAME' removed successfully."
    fi
fi

## Create a conda environment from yml
echo "Create conda environment '$ENV_NAME'."
conda create -y --name $ENV_NAME python=$PYTHON > /dev/null 2>&1

# Activate the env
source ${CONDA_DIR}/etc/profile.d/conda.sh
conda activate ${ENV_NAME}

########## PIP VERSION IS NOW WORKING #############
### PIP VERSION
pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118
pip install -r requirements.txt
pip install -e .
pip install -e lydorn_utils
pip install -e pytorch_lydorn

python -c "import torch; torch.cuda.is_available()"
RETVAL=$?  # Capture return code
if [ $RETVAL -eq 0 ]; then
    echo "PyTorch cuda is working!"
fi