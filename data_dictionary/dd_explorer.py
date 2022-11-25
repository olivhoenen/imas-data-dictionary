#!/bin/env python

'''
Parses an IMAS data description XML file looking for a specific attribute and ouputs its path.
Default is to list all IDSs names.
Use -s 'text' to look for 'text' Eg: -s 'ggd'
'''

from argparse import ArgumentParser
import traceback
import xml.etree.ElementTree as et
import os


def recursive_find(parent_node, node, name):
    if parent_node.find("field"):

def printRecur(root):
    """Recursively prints the tree."""
    if root.tag in ignoreElems:
        return
    print ' '*indent + '%s: %s' % (root.tag.title(), root.attrib.get('name', root.text))
    global indent
    indent += 4
    for elem in root.findall('field'):
        printRecur(elem)
    indent -= 4
    
    
def search_xml(args):
    try:
        tree = et.parse(args.file)
        root = tree.getroot()
    except Exception as e:
        print(f"Could not parse '{args.file}'. Reason:")
        print(e)

    # empty search text lists all IDS names:
    if not args.text:
        for ids in root.findall('IDS'):
            print(ids.attrib['name'])
        return

    # search for args.text in the 'name' attrib:
    for ids in root.findall('IDS'):
        found = False
        pad = 0
        for field in ids.findall('field'):
            if field.attrib['name'].find(args.text) > -1:
                if not found:
                    found = True
                    pad = len(ids.attrib['name'])+1
                    print(ids.attrib['name']+ '/' + field.attrib['path'])
                else:
                    print("{:>{width}}".format("/",width=pad) + # padding with spaces
                          field.attrib['path'])
            for field2 in field.findall('field'):
                if field2.attrib['name'].find(args.text) > -1:
                    if not found:
                        found = True
                        pad = len(ids.attrib['name']) + 1
                        print(ids.attrib['name']+ '/' +
                              field2.attrib['path'])
                    else:
                        print("{:>{width}}".format("/",width=pad) + # padding with spaces
                              field2.attrib['path'])
                for field3 in field2.findall('field'):
                    if field3.attrib['name'].find(args.text) > -1:
                        if not found:
                            found = True
                            pad = len(ids.attrib['name']) + 1
                            print(ids.attrib['name']+ '/' +
                                  field3.attrib['path'])
                        else:
                            print("{:>{width}}".format("/",width=pad) + # padding with spaces
                                  field3.attrib['path'])

    
if __name__ == "__main__":

    dd_default_name = os.getenv('IMAS_PREFIX', '.') + '/include/IDSDef.xml' 
    
    parser = ArgumentParser(description="Parses an IMAS data description XML file looking for a specific attribute and ouputs its path.")
    parser.add_argument('-f', '--file', \
                        help='input DD XML file to parse (default: \'%(default)s\')', \
                        metavar='filename', \
                        action='store', dest='file', default=dd_default_name)
    parser.add_argument('-s', '--string', \
                        help='string to search for (default: \'%(default)s\')', \
                        metavar='string', \
                        action='store', dest='text', default='') # this default lists all IDSs names
    args = parser.parse_args()
    
    search_xml(args)
