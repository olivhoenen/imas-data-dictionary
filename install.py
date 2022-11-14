import os
import pathlib
import subprocess
import shutil
from genericpath import exists
from os import listdir
from os.path import isfile, join
from pathlib import Path

import versioneer

DD_BUILD = pathlib.Path(__file__).parent.resolve()
IMAS_INSTALL_DIR = os.path.join(DD_BUILD, "install")

DD_GIT_DESCRIBE = versioneer.get_version()
UAL_GIT_DESCRIBE = DD_GIT_DESCRIBE


prefix = IMAS_INSTALL_DIR
exec_prefix = prefix
bindir = os.path.join(exec_prefix, "bin")
sbindir = bindir
libexecdir = os.path.join(exec_prefix, "libexec")
datarootdir = os.path.join(prefix, "share")
datadir = datarootdir
sysconfdir = os.path.join(prefix, "etc")
includedir = os.path.join(prefix, "include")
docdir = os.path.join(datarootdir, "doc")
htmldir = docdir
libdir = os.path.join(exec_prefix, "lib")
srcdir = DD_BUILD


htmldoc = [
    "IDSNames.txt",
    "html_documentation/html_documentation.html",
    "html_documentation/cocos/ids_cocos_transformations_symbolic_table.csv",
]


def execute_command(command_to_execute):
    proc = subprocess.Popen(
        command_to_execute.split(),
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        # env=env,
        universal_newlines=True,
    )
    proc.wait()
    (stdout, stderr) = proc.communicate()

    if proc.returncode != 0:
        assert False, stderr


Path(htmldir + "/imas").mkdir(parents=True, exist_ok=True)
html_files = [
    "html_documentation/" + f
    for f in listdir("html_documentation")
    if isfile(join("html_documentation", f))
]
print(html_files)
html_files_command = (
    "install -m 644 " + " ".join(html_files) + " " + os.path.join(htmldir, "imas")
)
execute_command(html_files_command)

Path(htmldir + "/imas/css").mkdir(parents=True, exist_ok=True)
css_files = [
    "html_documentation/css/" + f
    for f in listdir("html_documentation/css")
    if isfile(join("html_documentation/css", f))
]
css_files_command = (
    "install -m 644 " + " ".join(css_files) + " " + os.path.join(htmldir, "imas/css")
)
execute_command(css_files_command)

Path(htmldir + "/imas/js").mkdir(parents=True, exist_ok=True)
js_files = [
    "html_documentation/js/" + f
    for f in listdir("html_documentation/js")
    if isfile(join("html_documentation/js", f))
]
js_files_command = (
    "install -m 644 " + " ".join(js_files) + " " + os.path.join(htmldir, "imas/js")
)
execute_command(js_files_command)

Path(htmldir + "/imas/img").mkdir(parents=True, exist_ok=True)
img_files = [
    "html_documentation/img/" + f
    for f in listdir("html_documentation/img")
    if isfile(join("html_documentation/img", f))
]
img_files_command = (
    "install -m 644 " + " ".join(img_files) + " " + os.path.join(htmldir, "imas/img")
)
execute_command(img_files_command)


Path(htmldir + "/imas/cocos").mkdir(parents=True, exist_ok=True)
cocos_csv_files = [
    "html_documentation/cocos/" + f
    for f in listdir("html_documentation/cocos")
    if isfile(join("html_documentation/cocos", f))
]
cocos_csv_files_command = (
    "install -m 644 "
    + " ".join(cocos_csv_files)
    + " "
    + os.path.join(htmldir, "imas/cocos")
)
execute_command(cocos_csv_files_command)

# ids documenentation
idsnametxt_file_handle = open("IDSNames.txt", "r")
idsnames = idsnametxt_file_handle.read()
idsnames_list = idsnames.split("\n")
idsnametxt_file_handle.close()
ids_directories = filter(
    lambda file_name: os.path.exists("html_documentation/" + file_name), idsnames_list
)
for ids in ids_directories:
    ids_files = [
        "html_documentation/" + ids + "/" + f
        for f in listdir("html_documentation/" + ids)
        if isfile(join("html_documentation/" + ids, f))
    ]
    Path(htmldir + "/imas/" + ids).mkdir(parents=True, exist_ok=True)
    ids_files_command = (
        "install -m 644 "
        + " ".join(ids_files)
        + " "
        + os.path.join(htmldir, "imas/" + ids)
    )
    execute_command(ids_files_command)


Path(includedir).mkdir(parents=True, exist_ok=True)
dd_files = [
    "dd_data_dictionary.xml",
    "IDSNames.txt",
    "dd_data_dictionary_validation.txt",
]

dd_files_command = "install -m 644 " + " ".join(dd_files) + " " + includedir
execute_command(dd_files_command)
if not os.path.exists(os.path.join(includedir, "IDSDef.xml")):
    os.symlink(
        "dd_data_dictionary.xml",
        os.path.join(includedir, "IDSDef.xml"),
    )


def ignored_files(adir, filenames):
    return [
        filename for filename in filenames if not filename.endswith("_identifier.xml")
    ]


shutil.copytree(
    "utilities", os.path.join(includedir, "utilities"), ignore=ignored_files
)
