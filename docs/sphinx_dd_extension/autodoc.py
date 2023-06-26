"""An autodoc-like plugin for documenting the Data Dictionary
"""

from pathlib import Path
from textwrap import indent
from typing import Any, Dict
from xml.etree import ElementTree

from docutils import nodes
from docutils.statemachine import StringList
from sphinx.application import Sphinx
from sphinx.util.docutils import SphinxDirective
from sphinx.util.nodes import nested_parse_with_titles


class DDAutoDoc(SphinxDirective):
    final_argument_whitespace = True

    def run(self) -> None:
        self.result = StringList()
        self.result.append(".. toctree::", *self.get_source_info())
        self.result.append("  :glob:", *self.get_source_info())
        self.result.append("  :maxdepth: 1", *self.get_source_info())
        self.result.append("", *self.get_source_info())
        self.result.append("  generated/*", *self.get_source_info())

        # handle result
        node = nodes.section()
        # necessary so that the child nodes get the right source/line set
        node.document = self.state.document
        nested_parse_with_titles(self.state, self.result, node)
        return node.children


def generate_dd_docs(app: Sphinx):
    """Read IDSDef.xml and generate rst source files for all IDSs."""
    etree = ElementTree.parse("../IDSDef.xml")
    for ids in etree.iterfind("IDS"):
        idsname = ids.get("name")
        # if idsname > 'c': break
        if not idsname:
            raise RuntimeError("Empty IDS name!")
        docname = "generated/" + idsname
        docfile = docname + ".rst"
        Path(docfile).parent.mkdir(parents=True, exist_ok=True)
        Path(docfile).write_text(ids2rst(ids))


def ids2rst(ids: ElementTree.Element) -> str:
    """Convert an IDS Element to rst documentation."""
    result = []
    name = ids.get("name")
    title = f"``{name}`` reference"
    result.append(title)
    result.append("=" * len(title))
    result.append("")
    result.append(f".. dd:ids:: {name}")
    # TODO: options for IDS
    result.append("")
    result.append(indent(ids.get("documentation"), "  "))
    result.append("")
    result.append(children2rst(ids, 1))
    result.append("")
    return "\n".join(result)


def field2rst(field: ElementTree.Element, has_error: bool, level: int) -> str:
    """Convert an IDS Field element to rst documentation."""
    result = []
    result.append(f"{'  ' * level}.. dd:node:: {field.get('path_doc')}")
    # options for nodes
    result.append(f":data_type: {field.get('data_type')}")
    if "type" in field.keys():
        result.append(f":type: {field.get('type')}")
    if "units" in field.keys():
        result.append(f":unit: {field.get('units')}")
    # TODO: error
    # TODO: coordinates
    result.append("")
    result.append(field.get("documentation"))
    result.append("")
    level += 1
    return (
        f"\n{'  '*level}".join(result)
        + "\n"
        + children2rst(field, level)
    )


def children2rst(element: ElementTree.ElementTree, level: int) -> str:
    children = {field.get("name"): field for field in element.iterfind("field")}
    has_error = set()
    skip = set()
    for fieldname in children:
        if "_error" in fieldname:
            skip.add(fieldname)
            has_error.add(fieldname[: fieldname.find("_error")])
    return "\n".join(
        field2rst(field, fieldname in has_error, level)
        for fieldname, field in children.items()
        if fieldname not in skip
    )


def setup(app: Sphinx) -> Dict[str, Any]:
    app.setup_extension("sphinx_dd_extension.dd_domain")
    app.add_directive_to_domain("dd", "autodoc", DDAutoDoc)
    app.connect("builder-inited", generate_dd_docs)
