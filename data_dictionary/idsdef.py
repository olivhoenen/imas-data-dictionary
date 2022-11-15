#!/usr/bin/env python
import os
import re
import sys
import xml.etree.ElementTree as ET
from pathlib import Path


def major_minor_micro(version):
    major, minor, micro = re.search("(\d+)\.(\d+)\.(\d+)", version).groups()
    return int(major), int(minor), int(micro)


class IDSDef:
    """Simple class which allows to query meta-data from the definition of IDSs as expressed in IDSDef.xml."""

    root = None
    version = None
    cocos = None

    def __init__(self):
        # parse the XML def
        try:
            idsdef_path = ""
            if "IMAS_PREFIX1" in os.environ:
                imaspref = os.environ["IMAS_PREFIX"]
                idsdef_path = imaspref + "/include/IDSDef.xml"
            else:  # Get latest version from dd python package
                current_python_path = sys.prefix
                software_path = os.path.join(current_python_path, "../../")
                if os.path.exists(software_path + "/data_dictionary"):
                    dd_path = os.path.join(software_path, "data_dictionary")
                    dd_versions_list = os.listdir(dd_path)
                    latest = max(dd_versions_list, key=major_minor_micro)
                    folder_to_look = os.path.join(dd_path, latest)
                    for root, dirs, files in os.walk(folder_to_look):
                        for file in files:
                            if file.endswith("IDSDef.xml"):
                                idsdef_path = os.path.join(root, file)
                                break
            if idsdef_path == "":  # if still empty get the path from local directory
                local_directory = os.path.join(str(Path.home()), ".local")
                reg_compile = re.compile("dd_*")
                version_list = [
                    dirname
                    for dirname in os.listdir(local_directory)
                    if reg_compile.match(dirname)
                ]
                latest_version = max(version_list, key=major_minor_micro)
                folder_to_look = os.path.join(local_directory, latest_version)
                for root, dirs, files in os.walk(folder_to_look):
                    for file in files:
                        if file.endswith("IDSDef.xml"):
                            idsdef_path = os.path.join(root, file)
                            break
            tree = ET.parse(idsdef_path)
            self.root = tree.getroot()
            self.version = self.root.findtext("./version", default="N/A")
            self.cocos = self.root.findtext("./cocos", default="N/A")
            # print("IDSDefinitions Path:", idsdef_path)
            # print("IDSDefinitions Version:", self.version)
        except:
            print(
                "Error while trying to access IDSDef.xml, make sure you've loaded IMAS module",
                file=sys.stderr,
            )

    def getField(self, struct, field):
        """Recursive function which returns the node corresponding to a given field which is a descendant of struct."""
        elt = struct.find('./field[@name="' + field[0] + '"]')
        if elt == None:
            raise Exception("Element '" + field[0] + "' not found")
        if len(field) > 1:
            f = self.getField(elt, field[1:])
        else:
            # specific generic node for which the useful doc is from the parent
            if field[0] != "value":
                f = elt
            else:
                f = struct
        return f

    def query(self, ids, path=None):
        """Returns attributes of the selected ids/path node as a dictionary."""
        ids = self.root.find(f"./IDS[@name='{ids}']")
        if ids == None:
            raise ValueError(
                f"Error getting the IDS, please check that '{ids}' corresponds to a valid IDS name"
            )

        if path != None:
            fields = path.split("/")

            try:
                f = self.getField(ids, fields)
            except Exception as exc:
                raise ValueError("Error while accessing {path}: {str(exc)}")
        else:
            f = ids

        return f.attrib

    def version():
        """Returns the current Data-Dictionary version."""
        return self.version


def main():
    import argparse
    import sys

    parser = argparse.ArgumentParser(
        description="Query the IDS XML Definition for documentation"
    )
    parser.add_argument("ids", type=str, help="IDS name")
    parser.add_argument(
        "path",
        type=str,
        nargs="?",
        default=None,
        help="Path for field of interest within the IDS",
    )
    opt = parser.add_mutually_exclusive_group()
    opt.add_argument("-a", "--all", action="store_true", help="Print all attributes")
    opt.add_argument(
        "-s",
        "--select",
        type=str,
        default="documentation",
        help="Select attribute to be printed \t(default=%(default)s)",
    )
    parser.add_argument(
        "-m",
        "--metaData",
        action="store_true",
        help="Print associated meta-data (version and cocos)",
    )
    args = parser.parse_args()

    try:
        dd = IDSDef()
        f = dd.query(args.ids, args.path)
    except ValueError as ve:
        print(f"{ve}", file=sys.stderr)

    if args.metaData:
        mstr = f"This is Data Dictionary version = {dd.version}, following COCOS = {dd.cocos}"
        print(mstr)
        print("=" * len(mstr))

    if args.all:
        for a in f.keys():
            print(a + ": " + f[a])
    else:
        print(f[args.select])


if __name__ == "__main__":
    sys.exit(main())
