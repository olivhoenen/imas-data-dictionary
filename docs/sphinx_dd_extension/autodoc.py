"""An autodoc-like plugin for documenting the Data Dictionary
"""

from pathlib import Path
import re
from textwrap import dedent, indent
from typing import Any, Dict, List
from xml.etree import ElementTree

from docutils import nodes
from docutils.statemachine import StringList
from sphinx.application import Sphinx
from sphinx.util.docutils import SphinxDirective
from sphinx.util.nodes import nested_parse_with_titles


DOCUMENTED_UTILITIES = ["ids_properties", "code"]


class DDAutoDoc(SphinxDirective):
    final_argument_whitespace = True

    def run(self) -> None:
        rst = dedent(
            """
            IDS reference
            -------------

            .. toctree::
                :name: dd-reference-toc
                :glob:
                :maxdepth: 1

                generated/ids/*

            Common IDS structures reference
            -------------------------------

            .. toctree::
                :name: dd-reference-toc-util
                :glob:
                :maxdepth: 1

                generated/util/*
                """
        )
        self.result = StringList()
        for line in rst.splitlines():
            self.result.append(line, *self.get_source_info())

        # handle result
        node = nodes.section()
        # necessary so that the child nodes get the right source/line set
        node.document = self.state.document
        nested_parse_with_titles(self.state, self.result, node)
        return node.children


def rst_escape(text: str):
    return re.sub(r"([*`|\\])", r"\\\1", text)


def parse_lifecycle_status(field: ElementTree.Element) -> List[str]:
    result = []
    lifecycle_status = field.get("lifecycle_status")
    lifecycle_version = field.get("lifecycle_version")
    lifecycle_last_change = field.get("lifecycle_last_change")

    if lifecycle_status == "obsolescent":
        result.append(f".. deprecated:: {lifecycle_version}")
    elif lifecycle_status == "alpha":
        result.append(f".. versionadded:: {lifecycle_version}")
        result.append(f"  Alpha since version {lifecycle_version}.")
    elif lifecycle_status == "active":
        result.append(f".. versionadded:: {lifecycle_version}")
        result.append(f"  Active since version {lifecycle_version}.")

    if lifecycle_last_change:
        result.append(f".. versionchanged:: {lifecycle_last_change}")
        result.append(f"  Last change occurred in version {lifecycle_last_change}.")

    if result:
        result.append("")
    return result


def generate_dd_docs(app: Sphinx):
    """Read IDSDef.xml and generate rst source files for all IDSs."""
    etree = ElementTree.parse("../IDSDef.xml")
    for ids in etree.iterfind("IDS"):
        idsname = ids.get("name")
        if not idsname:
            raise RuntimeError("Empty IDS name!")
        docname = "generated/ids/" + idsname
        docfile = docname + ".rst"
        Path(docfile).parent.mkdir(parents=True, exist_ok=True)
        Path(docfile).write_text(ids2rst(ids))
    for util in DOCUMENTED_UTILITIES:
        node = etree.find(f"utilities/field[@name='{util}']")
        if not node:
            raise RuntimeError(f"Utility {util} does not exist in DD XML")
        docname = "generated/util/" + util
        docfile = docname + ".rst"
        Path(docfile).parent.mkdir(parents=True, exist_ok=True)
        Path(docfile).write_text(util2rst(node))


def util2rst(node: ElementTree.Element) -> str:
    """Convert a utilities/field node to rst documentation."""
    result = []
    name = node.get("name")
    title = f"``{name}`` structure"
    result.append(title)
    result.append("=" * len(title))
    result.append("")
    result.append(f".. dd:util:: {name}")
    # TODO: options for utils?
    result.append("")
    result.append(indent(rst_escape(node.get("documentation")), "  "))
    result.append("")
    result.append(indent("\n".join(parse_lifecycle_status(node)), "  "))
    result.append(children2rst(node, 1))
    result.append("")
    return "\n".join(result)


def ids2rst(ids: ElementTree.Element) -> str:
    """Convert an IDS Element to rst documentation."""
    result = []
    name = ids.get("name")
    lifecycle_status = ids.get("lifecycle_status")
    icon = {
        "alpha": ":si-icon:`material/alpha;ids-icon`",
        "active": ":si-icon:`material/star;ids-icon`",
    }.get(lifecycle_status, "")
    title = f"{icon}\\ ``{name}``"
    result.append(title)
    result.append("=" * len(title))
    result.append("")
    result.append(f".. dd:ids:: {name}")
    # TODO: options for IDS
    result.append("")
    result.append(indent(rst_escape(ids.get("documentation")), "  "))
    result.append("")
    result.append(indent("\n".join(parse_lifecycle_status(ids)), "  "))
    result.append(children2rst(ids, 1))
    result.append("")
    return "\n".join(result)


def field2rst(field: ElementTree.Element, has_error: bool, level: int) -> str:
    """Convert an IDS Field element to rst documentation."""
    if field.get("structure_reference") in DOCUMENTED_UTILITIES:
        util = field.get("structure_reference")
        assert len(util.split()) == 1, "structure_reference contains whitespace"
        path = field.get("path_doc")
        return f"{'  ' * level}.. dd:util-ref:: {path} {util}\n"
    result = []
    result.append(f"{'  ' * level}.. dd:node:: {field.get('path_doc')}")
    # options for nodes
    result.append(f":data_type: {field.get('data_type')}")
    if "type" in field.keys():
        result.append(f":type: {field.get('type')}")
    if "units" in field.keys():
        result.append(f":unit: {field.get('units')}")
    if has_error:
        result.append(":has_error:")
    # TODO: coordinates
    result.append("")
    result.append(rst_escape(field.get("documentation")))
    result.append("")
    result.extend(parse_lifecycle_status(field))
    level += 1
    return f"\n{'  '*level}".join(result) + "\n" + children2rst(field, level)


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
