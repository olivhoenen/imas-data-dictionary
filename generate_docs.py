from pathlib import Path
import os
import shutil
import subprocess
import re
from setuptools_scm import get_version

DD_GIT_DESCRIBE = get_version()


def saxon_version(verb=False) -> int:
    cmd = ["java", "net.sf.saxon.Transform", "-t"]
    try:
        out = subprocess.run(cmd, capture_output=True, text=True, check=False)
        line = out.stderr.split("\n")[0]
        version = re.search(r"Saxon.* +(\d+)\.(\d+)", line)
        if verb:
            print("Got Saxon version:", version.group(1), version.group(2))
        major = int(version.group(1)) * 100
        minor = int(version.group(2))
        version = major + minor
    except Exception as e:
        if verb:
            print(f"Error: can't get Saxon version. {e}")
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
        if not os.path.islink(os.path.join(".", "IDSDef.xml")):
            os.symlink(
                "dd_data_dictionary.xml",
                "IDSDef.xml",
            )


def generate_sphinx_documentation():
    from sphinx.cmd.build import main as sphinx_main

    os.chdir("docs")

    try:
        subprocess.run(["python", "-m", "sphinx_dd_extension.dd_changelog_helper"], check=True)
    except subprocess.CalledProcessError as e:
        print(f"An error occurred while updating the changelog: {e}")

    idsdef_path = os.path.join(".", "_static/IDSDefxml.js")
    with open(idsdef_path, "w") as file:
        file.write("const xmlString=`\n")

    idsdef_command = ["java", "net.sf.saxon.Transform", "-t", "-s:../IDSDef.xml", "-xsl:generate_js_IDSDef.xsl"]
    with open(idsdef_path, "a") as file:
        subprocess.run(idsdef_command, stdout=file, check=True)

    with open(idsdef_path, "a") as file:
        file.write("`;")

    source_dir = os.path.join(".")
    build_dir = os.path.join(".", "_build/html")

    directory = Path(build_dir)
    if directory.exists():
        shutil.rmtree(build_dir)
    sphinx_args = [
        "-b",
        "html",
        source_dir,
        build_dir,
        "-D",
        "dd_changelog_generate=1",
        "-D",
        "dd_autodoc_generate=1",
        "-W",
        "--keep-going",
    ]

    ret = sphinx_main(sphinx_args)
    # if ret != 0:
    #     raise RuntimeError(f"Sphinx build failed with return code {ret}")

    from git import Repo

    output_file_path = os.path.join("docs", "_build", "html", "version.txt")

    repo = Repo("..")

    git_describe_output = repo.git.describe().strip()

    os.makedirs(os.path.dirname(output_file_path), exist_ok=True)
    with open(output_file_path, "w") as version_file:
        version_file.write(git_describe_output)
    os.chdir("..")


if __name__ == "__main__":

    # Can we use threads in this version of Saxon?
    threads = ""
    if saxon_version() >= 904:
        threads = " -threads:4"

    generate_dd_data_dictionary(extra_opts=threads)
    generate_sphinx_documentation()
