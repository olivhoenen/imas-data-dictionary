from pathlib import Path
from setuptools import setup
from setuptools_scm import get_version
import glob
import os
import pathlib
import sys

sys.path.append(str(Path(__file__).parent.resolve()))


from generate import (
    generate_dd_data_dictionary,
    generate_dd_data_dictionary_validation,
    generate_html_documentation,
    generate_sphinx_documentation,
    generate_ids_cocos_transformations_symbolic_table,
    generate_idsnames,
)
from install import (
    copy_utilities,
    create_idsdef_symlink,
    install_cocos_csv_files,
    install_css_files,
    install_dd_files,
    install_html_files,
    install_sphinx_files,
    install_identifiers_files,
    install_ids_files,
    install_img_files,
    install_js_files,
    install_utilities_files,
)

current_directory = pathlib.Path(__file__).parent.resolve()
# long_description = (current_directory / "README.md").read_text(encoding="utf-8")

# Generate
generate_dd_data_dictionary()
generate_html_documentation()
generate_sphinx_documentation()
generate_ids_cocos_transformations_symbolic_table()
generate_idsnames()
generate_dd_data_dictionary_validation()

# install
install_html_files()
install_sphinx_files()
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

# stores include and share folder in root python path while installing
paths = []
version = get_version()
if os.path.exists("install"):
    for path, directories, filenames in os.walk("install"):
        paths.append(
            (path.replace("install", "dd_" + version), glob.glob(path + "/*.*"))
        )
else:
    raise Exception(
        "Couldn't find IDSDef.xml, Can not install data dictionary python package"
    )

setup(
    use_scm_version=True,
    data_files=paths,
    scripts=[
        "scripts/dd_doc",
        "scripts/dd_doclegacy"
    ],
)
