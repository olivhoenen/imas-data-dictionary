#!/bin/bash
# Generic Sphinx documentation without using make
# Note: this script should be run from the root of the git repository
module load Python/3.11.5-GCCcore-13.2.0 
module load Saxon-HE/12.4-Java-21 

module load IMAS-AL-Python/5.2.2-intel-2023b-DD-3.41.0
module unload Data-Dictionary
module load IMASPy/1.0.0-intel-2023b

pip install -r docs/requirements.txt

python generate_docs.py
echo "Done"
deactivate