"""[summary]

Usage
    python configure.py -IMAS_PYTHON=yes  -IMAS_PYTHON=yes -IMAS_MDSPLUS=yes -IMAS_HDF5=yes
Raises:
    ValueError: [description]

Returns:
    [type]: [description]
"""

import configparser
import os
import re
from argparse import ArgumentParser
import sys
import subprocess


PWD = os.path.realpath(os.path.dirname(__file__))
SAXON_VERSIONS = ["saxon-he-10.3.jar", "saxon9he.jar"]

parser = ArgumentParser()
parser.add_argument(
    "-LINK",
    "--LINK",
    dest="LINK",
    help='Specify copy method ("copy" or "link") default=link',
    type=str,
    choices=["copy", "link"],
    default="link",
)

parser.add_argument(
    "-IMAS_PYTHON",
    "--IMAS_PYTHON",
    dest="IMAS_PYTHON",
    help="Specify IMAS_PYTHON (yes or no) default=no",
    type=str,
    choices=["yes", "no"],
    default="no",
)


args = parser.parse_args()
config = configparser.ConfigParser()
config.optionxform = str
config.add_section("USER")
config.add_section("BUILD")
config.add_section("VERSION")
config.add_section("TEST")

if "CLASSPATH" in os.environ:
    saxonica_jar = ""
    if "CLASSPATH" in os.environ:
        classpaths = os.environ["CLASSPATH"]
        classpaths = classpaths.split(":")
        for saxon_version in SAXON_VERSIONS:
            saxonica_jar_list = [
                classpath for classpath in classpaths if saxon_version in classpath
            ]
            if saxonica_jar_list:
                saxonica_jar = saxonica_jar_list[0]
                break

    assert saxonica_jar != "", "Relevant Saxon Jar not found"
    config.set("BUILD", "SAXONICA_JAR", saxonica_jar)
else:
    raise ValueError(
        "Looks like Saxon module is not loaded. module - avail saxon ; module load <saxon module>"
    )
# Write configuration.ini
with open(os.path.join(PWD, "configuration.ini"), "w") as configfile:
    config.write(configfile)