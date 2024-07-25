from setuptools_scm import get_version
import os
import re
import shutil
import subprocess

PWD = os.path.realpath(os.path.dirname(__file__))
UAL = os.path.dirname(PWD)

def join_path(path1="", path2=""):
    return os.path.normpath(os.path.join(path1, path2))

DD_GIT_DESCRIBE = get_version()

def saxon_version(verb=False)->int:
    cmd = ["java", "net.sf.saxon.Transform", "-t"]
    try:
        out = subprocess.run(cmd,
                             capture_output=True,
                             text=True,
                             check=False)
        line = out.stderr.split('\n')[0]
        version = re.search(r"Saxon.* +(\d+)\.(\d+)", line)
        if (verb):
            print("Got Saxon version:", version.group(1), version.group(2))
        major = int(version.group(1)) * 100
        minor = int(version.group(2))
        version = major + minor
    except:
        if (verb):
            print("Error: can't get Saxon version.")
        version = 0
    return version


def generate_dd_data_dictionary(extra_opts=""):
    dd_data_dictionary_generation_command = (
        "java"
        + " net.sf.saxon.Transform"
        + extra_opts
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
def generate_html_documentation(extra_opts=""):
    html_documentation_generation_command = (
        "java"
        + " net.sf.saxon.Transform"
        + extra_opts
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

def generate_sphinx_documentation():
    sphinx_documentation_generation_command = (
        r"python -m venv docenv && source docenv/bin/activate && pip install -r docs/requirements.txt && make -C docs html && deactivate && rm -rf docenv"
    )
    proc = subprocess.Popen(
        sphinx_documentation_generation_command,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        shell=True,
        universal_newlines=True,
    )
    proc.wait()
    (stdout, stderr) = proc.communicate()

    if proc.returncode != 0:
        assert False, stderr


def generate_ids_cocos_transformations_symbolic_table(extra_opts=""):
    ids_cocos_transformations_symbolic_table_generation_command = (
        "java"
        + " net.sf.saxon.Transform"
        + extra_opts
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


def generate_dd_data_dictionary_validation(extra_opts=""):
    dd_data_dictionary_validation_generation_command = (
        "java"
        + " net.sf.saxon.Transform"
        + extra_opts
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
    
    # Can we use threads in this version of Saxon?
    threads = ""
    if saxon_version() >= 904: threads = " -threads:4"
    
    generate_dd_data_dictionary(extra_opts=threads)
    generate_html_documentation(extra_opts=threads)
    generate_sphinx_documentation()
    generate_ids_cocos_transformations_symbolic_table(extra_opts=threads)
    generate_idsnames()
    generate_dd_data_dictionary_validation(extra_opts=threads)
