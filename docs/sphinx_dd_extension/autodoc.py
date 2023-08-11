"""An autodoc-like plugin for documenting the Data Dictionary
"""

from pathlib import Path
import re
from textwrap import indent
from typing import Any, Dict, List
from xml.etree import ElementTree

from sphinx.application import Sphinx
from sphinx.util import logging

logger = logging.getLogger(__name__)


# Utilities that are documented separately to reduce the size of the reference pages
DOCUMENTED_UTILITIES = ["ids_properties"]
# Indentation character
INDENT = " "


def generate_dd_docs(app: Sphinx):
    """Read IDSDef.xml and generate rst reference files.

    Generate rst files for: all IDSs, common utilities and identifiers.
    """
    logger.info("Generating DD documentation sources.")
    etree = ElementTree.parse("../IDSDef.xml")
    # Ensure output folders exist
    for folder in ("ids", "util", "identifier"):
        (Path("generated") / folder).mkdir(parents=True, exist_ok=True)

    for ids in etree.iterfind("IDS"):
        idsname = ids.get("name")
        if not idsname:
            raise RuntimeError("Empty IDS name!")
        docfile = f"generated/ids/{idsname}.rst"
        Path(docfile).write_text(ids2rst(ids))

    for util in DOCUMENTED_UTILITIES:
        node = etree.find(f"utilities/field[@name='{util}']")
        if not node:
            raise RuntimeError(f"Utility {util} does not exist in DD XML")
        docfile = f"generated/util/{util}.rst"
        Path(docfile).write_text(util2rst(node))

    # Find all ../*/*_identifier.xml files
    for identifier in Path.cwd().parent.glob("*/*_identifier.xml"):
        iden_tree = ElementTree.parse(identifier)
        element = iden_tree.getroot()
        docfile = f"generated/identifier/{identifier.stem}.rst"
        fname = identifier.relative_to(identifier.parents[1])  # folder/file.xml
        Path(docfile).write_text(identifier2rst(element, fname))
    logger.info("Finished generating DD documentation sources.")


def parse_documentation(text: str) -> str:
    """Parse documentation string from a DD node.

    Args:
        text: documentation string (from field/@documentation attribute)
    """
    # Escape special characters used by ReST as markup: *, `, |
    text = re.sub(r"([*`|])", r"\\\1", text)
    # Inline math
    text = re.sub(r"\$(.*?)(?<!\\)\$", r":math:`\1`", text)
    return text


def link_to_coordinate(coordinate: str) -> str:
    """Generate rst to link to a coordinate.

    Args:
        coordinate: coordinate string (from field/@coordinate<N>[_same_as])
    """
    result = []
    for coor in coordinate.split(" OR "):
        if coor.startswith("1..."):
            result.append(f"``{coor}``")
        elif coor.startswith("IDS:"):
            result.append(f":dd:node:`{coor[4:]}`")
        else:
            result.append(f":dd:node:`{coor}`")
    return " OR ".join(result)


def parse_lifecycle_status(field: ElementTree.Element) -> List[str]:
    """Parse lifecycle status and return a list of rst source lines."""
    result = []
    lifecycle_status = field.get("lifecycle_status")
    lifecycle_version = field.get("lifecycle_version")
    lifecycle_last_change = field.get("lifecycle_last_change")

    if lifecycle_status == "obsolescent":
        result.append(f".. deprecated:: {lifecycle_version}")
    elif lifecycle_status in ("alpha", "active"):
        status = f"lifecycle status `{lifecycle_status}`"
        result.append(f".. versionadded:: {lifecycle_version} {status}")
    elif lifecycle_status:
        logger.warning("Unknown lifecycle status %s", lifecycle_status)

    if lifecycle_last_change:
        result.append(f".. versionchanged:: {lifecycle_last_change}")

    if result:
        result.append("")
    return result


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
    result.append(indent(parse_documentation(node.get("documentation")), INDENT))
    result.append("")
    result.append(indent("\n".join(parse_lifecycle_status(node)), INDENT))
    result.append(children2rst(node, 1))
    result.append("")
    # Collapse triple or more newlines
    return re.sub(r"[\n]{2,}", "\n\n", "\n".join(result))


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
    result.append(indent(parse_documentation(ids.get("documentation")), INDENT))
    result.append("")
    result.append(indent("\n".join(parse_lifecycle_status(ids)), INDENT))
    result.append(children2rst(ids, 1))
    result.append("")
    # Collapse triple or more newlines
    return re.sub(r"[\n]{2,}", "\n\n", "\n".join(result))


def field2rst(field: ElementTree.Element, has_error: bool, level: int) -> str:
    """Convert an IDS Field element to rst documentation.

    Args:
        field: XML element of this field
        has_error: True iff this field has corresponding error nodes
        level: indentation level
    """
    # Link to common utilities that are documented elsewhere
    if field.get("structure_reference") in DOCUMENTED_UTILITIES:
        util = field.get("structure_reference")
        assert len(util.split()) == 1, "structure_reference may not contain whitespace"
        path = field.get("path_doc")
        return indent(f".. dd:util-ref:: {path} {util}\n", INDENT * level)

    result = []
    result.append(f".. dd:node:: {field.get('path_doc')}")

    # options for nodes
    result.append(f":data_type: {field.get('data_type')}")
    if "type" in field.keys():
        result.append(f":type: {field.get('type')}")
    if "units" in field.keys():
        result.append(f":unit: {field.get('units')}")
    if has_error:
        result.append(":has_error:")
    result.append("")

    # Documentation string
    result.append(parse_documentation(field.get("documentation")))
    result.append("")

    # Identifier
    if "doc_identifier" in field.keys():
        identifier = f":dd:identifier:`{field.get('doc_identifier')}`"
        result.append(
            f"This is an :ref:`identifier <identifiers>`. See {identifier} for the "
            "available options."
        )
        result.append("")

    # Miscellaneous attributes
    if "appendable_by_appender_actor" in field.keys():
        appendable = field.get("appendable_by_appender_actor")
        result.append(f":Appendable by appender actor: {appendable}")
    result.append("")

    # Coordinates
    coordinates_csv = []
    for i in range(6):
        coordinate = field.get(f"coordinate{i+1}")
        if not coordinate:
            break
        coordinate_same_as = field.get(f"coordinate{i+1}_same_as")
        same_as = ""
        if coordinate_same_as:
            same_as += f" (same as {link_to_coordinate(coordinate_same_as)})"
        coordinates_csv.append(f' {i+1},"{link_to_coordinate(coordinate)}{same_as}"')

    if coordinates_csv:
        result.append(".. csv-table::")
        result.append(" :class: dd-coordinates")
        result.append(" :header: ,:ref:`Coordinate <coordinates>`")
        result.append("")
        result.extend(coordinates_csv)
        result.append("")

    # NBC changes
    if "change_nbc_description" in field.keys():
        change_nbc_description = field.get("change_nbc_description")
        change_nbc_version = field.get("change_nbc_version")
        renames = ("aos_renamed", "leaf_renamed", "structure_renamed")
        if change_nbc_description in renames:
            result.append(f".. versionchanged:: {change_nbc_version}")
            result.append(f"  Renamed from ``{field.get('change_nbc_previous_name')}``")
        elif change_nbc_description == "type_changed":
            result.append(f".. versionchanged:: {change_nbc_version}")
            previous_type = field.get("change_nbc_previous_type")
            result.append(f"  Type changed from ``{previous_type}``")
        else:
            logger.warning(
                "Unknown nbc change %r, not documenting NBC change.",
                change_nbc_description,
            )
        result.append("")

    # Lifecycle information
    result.extend(parse_lifecycle_status(field))
    level += 1
    result = indent("\n".join(result), INDENT * level)
    result = result[len(INDENT) :]  # Indent first line one level lower
    # Add documentation for children
    result += "\n" + children2rst(field, level)
    return result


def children2rst(element: ElementTree.Element, level: int) -> str:
    """Convert all children of an IDS element to rst documentation.

    Args:
        element: XML element of this field
        level: indentation level
    """
    children = {field.get("name"): field for field in element.iterfind("field")}

    # Check which fields have error nodes, and skip those error nodes
    has_error = set()
    skip = set()
    for fieldname in children:
        if fieldname in skip:
            continue
        for error_suffix in ("_error_upper", "_error_lower", "_error_index"):
            error_name = fieldname + error_suffix
            if error_name in children:
                has_error.add(fieldname)
                skip.add(error_name)

    return "\n".join(
        field2rst(field, fieldname in has_error, level)
        for fieldname, field in children.items()
        if fieldname not in skip
    )


def identifier2rst(element: ElementTree.Element, fname: Path) -> str:
    """Generate rst documentation for an identifier.

    Args:
        element: root element (constants tag) of _identifier.xml
        fname: Path consisting of the parent folder and filename of the identifier, for
            example ``Path("utilities/neutrals_identifier.xml")``
    """
    # Construct CSV
    csv_items = "\n".join(
        f'"{ele.get("name")}","{ele.text}","{ele.get("description")}"'
        for ele in element.iterfind("int")
    )

    result = []
    title = f"``{fname.stem}``"
    result.append(f".. dd:identifier:: {fname}")
    result.append("")
    result.append(title)
    result.append("=" * len(title))
    result.append("")
    for line in element.find("header").text.splitlines():
        result.append(line.strip())
    result.append("")
    result.append(".. csv-table::")
    result.append(f'{INDENT}:header: "Name","Index","Description"')
    result.append("")
    result.append(indent(csv_items, INDENT))
    result.append("")
    return "\n".join(result)


def setup(app: Sphinx) -> Dict[str, Any]:
    app.setup_extension("sphinx_dd_extension.dd_domain")
    app.connect("builder-inited", generate_dd_docs)
    return {
        "version": "0.1",
        "parallel_read_safe": True,
        "parallel_write_safe": True,
    }
