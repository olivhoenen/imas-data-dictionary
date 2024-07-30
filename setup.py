from setuptools import setup
from setuptools import setup
from setuptools.command.install import install
from setuptools_scm import get_version
import glob
import os
import pathlib
import sys
sys.path.append(str(pathlib.Path(__file__).parent.resolve()))

current_directory = pathlib.Path(__file__).parent.resolve()

class CustomInstallCommand(install):
    description = "DD files generation"
    paths = []
    def run(self):
        from generate import (
        generate_dd_data_dictionary,
        generate_dd_data_dictionary_validation,
        generate_html_documentation,
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
            install_identifiers_files,
            install_ids_files,
            install_img_files,
            install_js_files,
            install_utilities_files,
        )
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
        
        if os.getenv('DD_DOC'):
            from generate import generate_sphinx_documentation
            from install import install_sphinx_files
            
            generate_sphinx_documentation()
            install_sphinx_files()
        self.set_data_files()
        super().run()
        
    def set_data_files(self):
        version = get_version()
        if os.path.exists("install"):
            for path, directories, filenames in os.walk("install"):
                CustomInstallCommand.paths.append(
                    (path.replace("install", "dd_" + version), glob.glob(path + "/*.*"))
                )
        else:
            raise Exception(
                "Couldn't find IDSDef.xml, Can not install data dictionary python package"
            )
        
if __name__ == "__main__":
    setup(
        data_files=CustomInstallCommand.paths,
        cmdclass={
        'install': CustomInstallCommand,
        },
    )
