import os
import shutil
import subprocess
from argparse import ArgumentParser

PWD = os.path.realpath(os.path.dirname(__file__))
UAL = os.path.dirname(PWD)
SAXON_VERSIONS = ["saxon-he-10.3.jar", "saxon9he.jar"]



def join_path(path1="", path2=""):
    return os.path.normpath(os.path.join(path1, path2))


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
    SAXONICA_JAR = saxonica_jar
else:
    raise ValueError(
        "Looks like Saxon module is not loaded. module - avail saxon ; module load <saxon module>"
    )
DD_GIT_DESCRIBE = str(
    subprocess.check_output(["git", "describe"], cwd=PWD).decode().strip()
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
    proc = subprocess.Popen(
        dd_data_dictionary_generation_command.split(),
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
        if not os.path.islink(join_path(PWD, "IDSDef.xml")):
            os.symlink(
                "dd_data_dictionary.xml",
                "IDSDef.xml",
            )


# TODO Check the problem of generation
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
    proc = subprocess.Popen(
        html_documentation_generation_command.split(),
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        # env=env,
        universal_newlines=True,
    )
    proc.wait()
    (stdout, stderr) = proc.communicate()

    if proc.returncode != 0:
        assert False, stderr

    shutil.copy(
        "schemas/utilities/coordinate_identifier.xml",
        "html_documentation/utilities/coordinate_identifier.xml",
    )


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
    proc = subprocess.Popen(
        ids_cocos_transformations_symbolic_table_generation_command.split(),
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
    proc = subprocess.Popen(
        dd_data_dictionary_validation_generation_command.split(),
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


generate_dd_data_dictionary()
generate_html_documentation()
generate_ids_cocos_transformations_symbolic_table()
generate_idsnames()
generate_dd_data_dictionary_validation()
