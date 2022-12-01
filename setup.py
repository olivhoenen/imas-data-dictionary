from setuptools import setup
import pathlib
import os, glob
import versioneer
from generate import generate_dd_data_dictionary
from generate import generate_html_documentation
from generate import generate_ids_cocos_transformations_symbolic_table
from generate import generate_idsnames
from generate import generate_dd_data_dictionary_validation

from install import install_html_files
from install import install_css_files
from install import install_js_files
from install import install_img_files
from install import install_cocos_csv_files
from install import install_ids_files
from install import install_dd_files
from install import install_utilities_files
from install import create_idsdef_symlink
from install import copy_utilities
from install import install_identifiers_files


current_directory = pathlib.Path(__file__).parent.resolve()
long_description = (current_directory / "README.md").read_text(encoding="utf-8")

# Generate
generate_dd_data_dictionary()
generate_html_documentation()
generate_ids_cocos_transformations_symbolic_table()
generate_idsnames()
generate_dd_data_dictionary_validation()

# install
install_html_files()
install_css_files()
install_js_files()
install_img_files()
install_cocos_csv_files()
install_ids_files()
install_dd_files()
install_utilities_files()
create_idsdef_symlink()
copy_utilities()
install_identifiers_files()

#stores include and share folder in root python path while installing
paths = []
version = versioneer.get_version()
if os.path.exists("install"):
    for (path, directories, filenames) in os.walk("install"):
        paths.append(
            (path.replace("install", "dd_" + version), glob.glob(path + "/*.*"))
        )
    print("Found IDSDef.xml " + str(paths))
else:
    raise Exception(
        "Couldn't find IDSDef.xml, Can not install data dictionary python package"
    )

setup(
    name="data_dictionary",
    version=versioneer.get_version(),
    cmdclass=versioneer.get_cmdclass(),
    description="The Data Dictionary is the implementation of the Data Model of ITER's Integrated Modelling & Analysis Suite (IMAS)",
    long_description=long_description,
    long_description_content_type="text/markdown",
    author="ITER Organization",
    author_email="imas-support@iter.org",
    url="https://imas.iter.org/",
    classifiers=[
        "Development Status :: 4 - Beta",
        "Intended Audience :: Developers",
        "Intended Audience :: Science/Research",
        "License :: Other/Proprietary License",
        "Programming Language :: Python :: 3",
        "Topic :: Scientific/Engineering :: Physics",
    ],
    # hashtag about the package
    keywords="Data Dictionary, IDS",
    setup_requires=["setuptools"],
    # Directories of source files
    packages=["data_dictionary"],
    # Global data available to all packages in the python environment
    data_files=paths,
    # Run command line script and should be installed by Python installer
    entry_points={  # Using inetrnal Python automated script option
        "console_scripts": ["idsdef=data_dictionary.idsdef:main"]
    },
)
