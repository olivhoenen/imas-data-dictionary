#!/usr/bin/env python

"""
Usage

$ python idsdef metadata
This is Data Dictionary version = 3.37.0, following COCOS = 11

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
/home/ITER/sawantp1/.local/dd_3.37.1+54.g20c6794.dirty/include/IDSDef.xml

$ python idsdef idsnames 
amns_data
barometry
bolometer
bremsstrahlung_visible
...

$ python idsdef search ggd 
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
        # Find and parse XML definitions
        self.idsdef_path = ""
        if self.idsdef_path=="":  
            # Check idsdef.xml installed in Python environment system as well as local
            local_path =  os.path.join(str(Path.home()), ".local")
            python_env_list= [sys.prefix, local_path]
            reg_compile = re.compile("dd_*")
            version_list = None
            python_env_path = ""
            for python_env in python_env_list:
                version_list = [
                    dirname
                    for dirname in os.listdir(python_env)
                    if reg_compile.match(dirname)
                ]
                if len(version_list) != 0:
                    python_env_path = python_env
                    break
            if version_list is not None:
                if len(version_list) != 0:
                    latest_version = max(version_list, key=major_minor_micro)
                    folder_to_look = os.path.join(python_env_path, latest_version)
                    for root, dirs, files in os.walk(folder_to_look):
                        for file in files:
                            if file.endswith("IDSDef.xml"):
                                self.idsdef_path = os.path.join(root, file)
                                break
        # Fallback to IMAS_PREFIX environment variable
        if self.idsdef_path=="":
            if "IMAS_PREFIX" in os.environ:
                imaspref = os.environ["IMAS_PREFIX"]
                self.idsdef_path = imaspref + "/include/IDSDef.xml"
        
        # Still you can't find idsdef.xml then crash badly
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
                    search_result_for_ids.append(field.attrib["path"])
                    if not is_top_node:
                        is_top_node = True
                        top_node_name = ids.attrib["name"]
            if top_node_name:  # add to dict only if something is found
                search_result[top_node_name] = search_result_for_ids
        return search_result

    def list_ids_fields(self, idsname=""):
        search_result = {}
        for ids in self.root.findall("IDS"):
            if ids.attrib["name"] == idsname.lower():
                is_top_node = False
                top_node_name = ""
                search_result_for_ids = []
                for field in ids.iter("field"):
                    field_path = re.sub(
                        "\(([^:][^itime]*?)\)", "(:)", field.attrib["path_doc"]
                    )
                    if "timebasepath" in field.attrib.keys():
                        field_path = re.sub(
                        "\(([:]*?)\)$", "(itime)", field_path
                        )
                    search_result_for_ids.append(field_path)
                    if not is_top_node:
                        is_top_node = True
                        top_node_name = ids.attrib["name"]
                if top_node_name:  # add to dict only if something is found
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

    metadata_command_parser = subparsers.add_parser("metadata", help="print metadata")
    metadata_command_parser.set_defaults(cmd="metadata")

    idsnames_command_parser = subparsers.add_parser("idsnames", help="print ids names")
    idsnames_command_parser.set_defaults(cmd="idsnames")

    search_command_parser = subparsers.add_parser("search", help="Search in ids")
    search_command_parser.set_defaults(cmd="search")
    search_command_parser.add_argument(
        "text",
        nargs="?",
        default="",
        help="Text to search in all IDSes",
    )

    idsfields_command_parser = subparsers.add_parser(
        "idsfields", help="shows all fields from ids"
    )
    idsfields_command_parser.set_defaults(cmd="idsfields")
    idsfields_command_parser.add_argument(
        "idsname",
        type=str,
        default="",
        help="Provide ids Name",
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
    if args.cmd == "metadata":
        mstr = f"This is Data Dictionary version = {idsdef_object.version}, following COCOS = {idsdef_object.cocos}"
        print(mstr)
        print("=" * len(mstr))

    if args.cmd == "idspath":
        print(idsdef_object.get_idsdef_path())
    if args.cmd == "info":
        attribute_dict = idsdef_object.query(args.ids, args.path)
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
            print(f"Searching for '{args.text}'.")
            result = idsdef_object.find_in_ids(args.text.strip())
            for key, items in result.items():
                print(f"{key}:")
                for item in items:
                    print("\t" + item)
        else:
            search_command_parser.print_help()
            print("Please provide text to search in IDSes")
            return
    elif args.cmd == "idsfields":
        if args.idsname != "" and args.idsname != None:
            result = idsdef_object.list_ids_fields(args.idsname.strip())
            if bool(result) == True:
                print(f"Listing all fields from ids :'{args.idsname}'")
                for key, items in result.items():
                    for item in items:
                        print(item)
            else:
                idsfields_command_parser.print_help()
                print("Please provide valid IDS name")
                return
        else:
            idsfields_command_parser.print_help()
            print("Please provide valid IDS name")
            return


if __name__ == "__main__":
    sys.exit(main())
