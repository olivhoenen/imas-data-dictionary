#!/bin/bash
# Bamboo CI script to build the Sphinx documentation
# Note: this script should be run from the root of the git repository

# Debuggging:
set -e -o pipefail
echo "Loading modules..."

# Set up environment such that module files can be loaded
. /usr/share/Modules/init/sh
module purge
# Load modules required for building the Sphinx documentation
# - Saxon (required for building the DD)
# - Python
# - GitPython (providing `git` package), needed for the changelog
# - IMASPy (providing `imaspy` package), needed for the changelog
module load \
    Saxon-HE/10.3-Java-11 \
    Python/3.8.6-GCCcore-10.2.0 \
    GitPython/3.1.14-GCCcore-10.2.0 \
    IMASPy/1.0.0-foss-2020b


# Debuggging:
echo "Done loading modules"
set -x

# Create Python virtual environment
rm -rf venv
python -m venv --system-site-packages venv
source venv/bin/activate

# Install dependencies
pip install -r docs/requirements.txt

# Debugging:
pip freeze

# Set sphinx options:
# - `-D dd_changelog_generate=1`: generate and build the changelog
# - `-D dd_autodoc_generate=1`: generate and build the IDS reference
# - `-W`: turn warnings into errors
# - `--keep-going`: with -W, keep going when getting warnings
export SPHINXOPTS="-D dd_changelog_generate=1 -D dd_autodoc_generate=1 -W --keep-going"

# Build the sphinx documentation
make sphinx
