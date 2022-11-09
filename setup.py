from setuptools import setup
import pathlib
import os, glob
import versioneer

current_directory = pathlib.Path(__file__).parent.resolve()
long_description = (current_directory / "README.md").read_text(encoding="utf-8")

paths = []
for schema in os.listdir("schemas"):
    paths.append(("schemas/" + schema, glob.glob("schemas/" + schema + "/*.*")))

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
