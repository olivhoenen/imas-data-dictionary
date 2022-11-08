from argparse import ArgumentParser
import glob
import os
import shutil


CLEAN_FILES = "dd_data_dictionary.xml dd_data_dictionary_validation.txt IDSDef.xml IDSNames.txt ./html_documentation/*.html ./html_documentation/cocos/ids_cocos_transformations_symbolic_table.csv ./install/*.*".split(
    " "
)


# read config file
PWD = os.path.realpath(os.path.dirname(__file__))


def run(files=""):
    """
    functio for cleanup
    """
    print("Removing " + " ".join(files))
    for path_spec in files:
        # Make paths absolute and relative to this path
        abs_paths = glob.glob(os.path.normpath(os.path.join(PWD, path_spec)))

        for path in [str(p) for p in abs_paths]:
            if not path.startswith(PWD):
                # Die if path in files is absolute + outside this directory
                raise ValueError("%s is not a path inside %s" % (path, PWD))
            print("removing %s" % os.path.relpath(path))
            if os.path.isdir(path) and not os.path.islink(path):
                try:
                    shutil.rmtree(path)
                except:
                    print("Error occurred while removing path" + path)

            elif os.path.islink(path):
                try:
                    os.unlink(path)
                except:
                    print("Error occurred while removing path" + path)
            else:
                try:
                    os.remove(path)
                except:
                    print("Error occurred while removing path" + path)


run(CLEAN_FILES)
