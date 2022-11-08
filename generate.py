import configparser
import os
import shutil
import subprocess
from argparse import ArgumentParser
from distutils.dir_util import copy_tree
from pathlib import Path

PWD = os.path.realpath(os.path.dirname(__file__))
UAL = os.path.dirname(PWD)
assert (
    os.path.isfile(os.path.join(PWD, "configuration.ini")) is True
), "Couldn't find configuration ini file. Please execute using command [python configure.py]"


parser = ArgumentParser()
parser.add_argument("--test", action="store_true")
parser.add_argument("--no_test", dest="test", action="store_false")
parser.set_defaults(test=False)

parser.add_argument("--identifiers", action="store_true")
parser.add_argument("--no_identifiers", dest="identifiers", action="store_false")
parser.set_defaults(identifiers=False)

args = parser.parse_args()


def join_path(path1="", path2=""):
    return os.path.normpath(os.path.join(path1, path2))


# read config file
config = configparser.ConfigParser()
config.read(join_path(PWD, "configuration.ini"))

SAXONICA_JAR = config["BUILD"]["SAXONICA_JAR"]
DD_GIT_DESCRIBE = str(
    subprocess.check_output(["git", "describe"], cwd=PWD)
    .decode()
    .strip()
)

if not os.path.islink(join_path(PWD, "IDSDef.xml")):
                os.symlink(
                    "dd_data_dictionary.xml",
                    "IDSDef.xml",
                )
                
                
def generate_dd_data_dictionary():
    dd_data_dictionary_generation_command = (
        "java"
        + " net.sf.saxon.Transform"
        + " -threads:4"
        + " -t -warnings:fatal -s:"
        + "dd_data_dictionary.xml.xsd"
        + " -xsl:"
        + "dd_data_dictionary.xml.xsl"
        + " -o:"
        + "dd_data_dictionary.xml"
        + " DD_GIT_DESCRIBE="
        + DD_GIT_DESCRIBE
    )
    proc = subprocess.Popen(dd_data_dictionary_generation_command.split(),
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        # env=env,
        universal_newlines=True,
    )
    proc.wait()
    (stdout, stderr) = proc.communicate()

    if proc.returncode != 0:
        assert False, stderr
            
#TODO Check the problem of generation
def generate_html_documentation():
    html_documentation_generation_command = (
        "java"
        + " net.sf.saxon.Transform"
        + " -threads:4"
        + " -t -warnings:fatal -s:"
        + "dd_data_dictionary.xml"
        + " -xsl:"
        + "dd_data_dictionary_html_documentation.xsl"
        + " -o:"
        + "html_documentation.html"
        + " DD_GIT_DESCRIBE="
        + DD_GIT_DESCRIBE
    )
    proc = subprocess.Popen(html_documentation_generation_command.split(),
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        # env=env,
        universal_newlines=True,
    )
    proc.wait()
    (stdout, stderr) = proc.communicate()

    if proc.returncode != 0:
        assert False, stderr
    
    shutil.copy("utilities/coordinate_identifier.xml", "html_documentation/utilities/coordinate_identifier.xml")

def generate_ids_cocos_transformations_symbolic_table():
    ids_cocos_transformations_symbolic_table_generation_command = (
        "java"
        + " net.sf.saxon.Transform"
        + " -threads:4"
        + " -t -warnings:fatal -s:"
        + "dd_data_dictionary.xml"
        + " -xsl:"
        + "ids_cocos_transformations_symbolic_table.csv.xsl"
        + " -o:"
        + "html_documentation/cocos/ids_cocos_transformations_symbolic_table.csv"
        + " DD_GIT_DESCRIBE="
        + DD_GIT_DESCRIBE
    )
    proc = subprocess.Popen(ids_cocos_transformations_symbolic_table_generation_command.split(),
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        # env=env,
        universal_newlines=True,
    )
    proc.wait()
    (stdout, stderr) = proc.communicate()

    if proc.returncode != 0:
        assert False, stderr

def generate_idsnames():
    proc = subprocess.Popen(
                    [
                        "xsltproc",
                        join_path(PWD, "IDSNames.txt.xsl"),
                        join_path(PWD, "dd_data_dictionary.xml"),
                    ],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        # env=env,
        universal_newlines=True,
    )
    proc.wait()
    (stdout, stderr) = proc.communicate()

    if proc.returncode != 0:
        assert False, stderr
    else:
        f = open("IDSNames.txt", "w")
        f.write(stdout)
        f.close()        
        

def generate_dd_data_dictionary_validation():
    dd_data_dictionary_validation_generation_command = (
        "xsltproc"
        + " dd_data_dictionary_validation.txt.xsl"
        + " dd_data_dictionary.xml"
    )
    proc = subprocess.Popen(dd_data_dictionary_validation_generation_command.split(),
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        universal_newlines=True,
    )
    proc.wait()
    (stdout, stderr) = proc.communicate()

    if proc.returncode != 0:
        assert False, stderr   
    else:
        f = open("dd_data_dictionary_validation.txt", "w")
        f.write(stdout)
        f.close()   
                         
# generate_dd_data_dictionary()
generate_html_documentation()        
# generate_ids_cocos_transformations_symbolic_table()
# generate_idsnames()
# generate_dd_data_dictionary_validation()

#             define xslt2proc
# @# Expect prerequisites: <xmlfile> <xslfile>
# $(SAXON) -threads:4 -t -warnings:fatal -s:$< -xsl:$(word 2,$^) > $@ DD_GIT_DESCRIBE=$(DD_GIT_DESCRIBE) || { rm -f $@ ; exit 1 ; }
# endef

# xsltproc $(word 2,$^) $< > $@ || { rm -f $@ ; exit 1 ;}
# html_documentation/html_documentation.html: dd_data_dictionary.xml dd_data_dictionary_html_documentation.xsl
# 	$(xslt2proc)
# 	cp utilities/coordinate_identifier.xml html_documentation/utilities/coordinate_identifier.xml

# html_documentation/cocos/ids_cocos_transformations_symbolic_table.csv: dd_data_dictionary.xml ids_cocos_transformations_symbolic_table.csv.xsl
# 	$(xslt2proc)

# IDSNames.txt dd_data_dictionary_validation.txt: %: dd_data_dictionary.xml %.xsl
# 	$(xsltproc)
