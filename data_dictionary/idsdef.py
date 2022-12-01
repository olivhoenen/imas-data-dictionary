#!/usr/bin/env python

"""
Usage

$ python idsdef info amns_data ids_properties/comment -a
name: comment
path: ids_properties/comment
path_doc: ids_properties/comment
documentation: Any comment describing the content of this IDS
data_type: STR_0D
type: constant

$ python idsdef info amns_data ids_properties/comment -m
This is Data Dictionary version = 3.37.0, following COCOS = 11
==============================================================
Any comment describing the content of this IDS
$   

$ python idsdef info amns_data ids_properties/comment -s data_type
STR_0D
$  

$ python idsdef idspath
module :/home/ITER/sawantp1/.local/lib/python3.8/site-packages/data_dictionary/idsdef.py
path : /home/ITER/sawantp1/.local/dd_3.37.1+54.g20c6794.dirty/include/IDSDef.xml
version : 3.37.1-54-g20c6794

$ python idsdef idsnames 
amns_data
barometry
bolometer
bremsstrahlung_visible
...

$ python idsdef search -t ggd 
distribution_sources/source/ggd
distributions/distribution/ggd
edge_profiles/grid_ggd
        ggd
        ggd_fast
edge_sources/grid_ggd
        source/ggd
...
"""
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
        self.idsdef_path = ""
        if "IMAS_PREFIX" in os.environ:
            imaspref = os.environ["IMAS_PREFIX"]
            self.idsdef_path = imaspref + "/include/IDSDef.xml"
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
                            self.idsdef_path = os.path.join(root, file)
                            break
        if self.idsdef_path == "":  # if still empty get the path from local directory
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
                        self.idsdef_path = os.path.join(root, file)
                        break
        if self.idsdef_path == "":
            raise Exception(
                "Error while trying to access IDSDef.xml, make sure you've loaded IMAS module",
                file=sys.stderr,
            )
        else:
            tree = ET.parse(self.idsdef_path)
            self.root = tree.getroot()
            self.version = self.root.findtext("./version", default="N/A")
            self.cocos = self.root.findtext("./cocos", default="N/A")

    def get_idsdef_path(self):
        "Get selected idsdef.xml path"
        return self.idsdef_path

    def get_version(self):
        """Returns the current Data-Dictionary version."""
        return self.version

    def get_field(self, struct, field):
        """Recursive function which returns the node corresponding to a given field which is a descendant of struct."""
        elt = struct.find('./field[@name="' + field[0] + '"]')
        if elt == None:
            raise Exception("Element '" + field[0] + "' not found")
        if len(field) > 1:
            f = self.get_field(elt, field[1:])
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
                f = self.get_field(ids, fields)
            except Exception as exc:
                raise ValueError("Error while accessing {path}: {str(exc)}")
        else:
            f = ids

        return f.attrib

    def get_ids_names(self):
        return [ids.attrib["name"] for ids in self.root.findall("IDS")]

    def find_in_ids(self, text_to_search=""):
        search_result = {}
        for ids in self.root.findall("IDS"):
            is_top_node = False
            top_node_name = ""
            search_result_for_ids = []
            for field in ids.iter("field"):
                if field.attrib["name"].find(text_to_search) != -1:
                    if not is_top_node:
                        is_top_node = True
                        top_node_name = ids.attrib["name"] + "/" + field.attrib["path"]
                    else:
                        search_result_for_ids.append(field.attrib["path"])
            search_result[top_node_name] = search_result_for_ids
        return search_result


def main():
    import argparse

    idsdef_parser = argparse.ArgumentParser(description="IDS Def Utilities")
    subparsers = idsdef_parser.add_subparsers(help="sub-commands help")

    idspath_command_parser = subparsers.add_parser(
        "idspath", help="print ids definition path"
    )
    idspath_command_parser.set_defaults(cmd="idspath")

    idsnames_command_parser = subparsers.add_parser("idsnames", help="print ids names")
    idsnames_command_parser.set_defaults(cmd="idsnames")

    search_command_parser = subparsers.add_parser("search", help="Search in ids")
    search_command_parser.set_defaults(cmd="search")
    search_option = search_command_parser.add_mutually_exclusive_group()
    search_option.add_argument(
        "-t",
        "--text",
        type=str,
        default=None,
        help="Text to search in all IDSes \t(default=%(default)s)",
    )

    info_command_parser = subparsers.add_parser(
        "info", help="Query the IDS XML Definition for documentation"
    )
    info_command_parser.set_defaults(cmd="info")

    info_command_parser.add_argument("ids", type=str, help="IDS name")
    info_command_parser.add_argument(
        "path",
        type=str,
        nargs="?",
        default=None,
        help="Path for field of interest within the IDS",
    )
    opt = info_command_parser.add_mutually_exclusive_group()
    opt.add_argument("-a", "--all", action="store_true", help="Print all attributes")
    opt.add_argument(
        "-s",
        "--select",
        type=str,
        default="documentation",
        help="Select attribute to be printed \t(default=%(default)s)",
    )
    info_command_parser.add_argument(
        "-m",
        "--metaData",
        action="store_true",
        help="Print associated meta-data (version and cocos)",
    )
    args = idsdef_parser.parse_args()
    try:
        if args.cmd == None:
            idsdef_parser.print_help()
            return
    except AttributeError:
        idsdef_parser.print_help()
        return

    # Create IDSDef Object
    idsdef_object = IDSDef()
    if args.cmd == "idspath":
        print("module :" + __file__)
        print("path : " + idsdef_object.get_idsdef_path())
        print("version : " + idsdef_object.get_version())
    if args.cmd == "info":
        attribute_dict = idsdef_object.query(args.ids, args.path)

        if args.metaData:
            mstr = f"This is Data Dictionary version = {idsdef_object.version}, following COCOS = {idsdef_object.cocos}"
            print(mstr)
            print("=" * len(mstr))

        if args.all:
            for a in attribute_dict.keys():
                print(a + ": " + attribute_dict[a])
        else:
            print(attribute_dict[args.select])
    elif args.cmd == "idsnames":
        for name in idsdef_object.get_ids_names():
            print(name)
    elif args.cmd == "search":
        if args.text != "" and args.text != None:
            result = idsdef_object.find_in_ids(args.text.strip())
            for key, items in result.items():
                print(key)
                for item in items:
                    print("\t" + item)
        else:
            search_command_parser.print_help()
            print("Please provide text to search in IDSes")
            return


if __name__ == "__main__":
    sys.exit(main())
