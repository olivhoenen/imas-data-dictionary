#!/bin/bash
# Generic Sphinx documentation without using make
# Note: this script should be run from the root of the git repository
module purge

# Get toolchain version
if [ -z "$1" ]; then
    echo 'Please provide GIT token with read as parameter '
    echo 'access to https://git.iter.org/projects/IMAS/repos/data-dictionary/browse'
    echo 'See https://confluence.iter.org/display/IMP/How+to+access+repositories+with+access+token'
else
    export IMAS_DD_BITBUCKET_TOKEN="$1"
fi

module load Saxon-HE/12.4-Java-21 
module load Python/3.11.5-GCCcore-13.2.0 
module load IMASPy/1.0.0-gfbf-2023b

python -m venv --system-site-packages venv
source venv/bin/activate
pip install -r docs/requirements.txt

cd docs; python -m sphinx_dd_extension.dd_changelog_helper; cd ..

python generate_docs.py
echo "Sphinx document generation is completed"
deactivate