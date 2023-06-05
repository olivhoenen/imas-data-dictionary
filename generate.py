import os
import shutil
import subprocess

PWD = os.path.realpath(os.path.dirname(__file__))
UAL = os.path.dirname(PWD)


def join_path(path1="", path2=""):
    return os.path.normpath(os.path.join(path1, path2))


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
        "utilities/coordinate_identifier.xml",
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
        "java"
        + " net.sf.saxon.Transform"
        + " -threads:4"
        + " -t -warnings:fatal -s:"
        + "dd_data_dictionary.xml"
        + " -xsl:"
        + "dd_data_dictionary_validation.txt.xsl"
        + " -o:"
        + "dd_data_dictionary_validation.txt"
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

if __name__ == "__main__":
    generate_dd_data_dictionary()
    generate_html_documentation()
    generate_ids_cocos_transformations_symbolic_table()
    generate_idsnames()
    generate_dd_data_dictionary_validation()
