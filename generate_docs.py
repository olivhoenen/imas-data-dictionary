from generate import (
    generate_dd_data_dictionary,
    generate_dd_data_dictionary_validation,
    generate_html_documentation,
    generate_ids_cocos_transformations_symbolic_table,
    generate_idsnames,
    saxon_version,
)
from pathlib import Path
import os
import shutil
import subprocess


def generate_sphinx_documentation():
    from sphinx.cmd.build import main as sphinx_main

    os.chdir("docs")

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

    sphinx_main(sphinx_args)
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
    generate_html_documentation(extra_opts=threads)
    generate_ids_cocos_transformations_symbolic_table(extra_opts=threads)
    generate_idsnames()
    generate_dd_data_dictionary_validation(extra_opts=threads)
    generate_sphinx_documentation()
