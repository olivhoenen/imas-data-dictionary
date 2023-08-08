"""Sphinx plugin to add a data dictionary (DD) domain to sphinx.

Logic is partly based on code in the :external:py:mod:`sphinx.domains` module.
"""


from functools import partial
import logging
import re
from typing import cast, Iterable, Optional, Dict, List, Tuple, Any

from docutils import nodes
from docutils.statemachine import StringList
from docutils.nodes import Element, Node
from docutils.parsers.rst import directives
from sphinx import addnodes
from sphinx.addnodes import desc_content, desc_signature, pending_xref
from sphinx.application import Sphinx
from sphinx.builders import Builder
from sphinx.directives import ObjectDescription
from sphinx.domains import Domain, ObjType
from sphinx.environment import BuildEnvironment
from sphinx.locale import __
from sphinx.roles import XRefRole
from sphinx.util.docutils import SphinxDirective, switch_source_input
from sphinx.util.nodes import make_id, make_refnode, nested_parse_with_titles
from sphinx.util.typing import OptionSpec
from sphinx.writers.html5 import HTML5Translator


logger = logging.getLogger(__name__)


_bracket_re = re.compile(r"\([^()]*\)")


def remove_brackets(value: str) -> str:
    """Remove brackets (and all contained in it) from value.

    Example:

        >>> remove_brackets("a(bcd)/e(fgh(ijk))/l")
        "a/e/l"
    """
    while True:
        value, substitions_done = _bracket_re.subn("", value)
        if substitions_done == 0:
            return value


class DDNode(ObjectDescription[Tuple[str, str]]):
    """Description of a node in the Data Dictionary."""

    option_spec: OptionSpec = {
        "noindex": directives.flag,
        "noindexentry": directives.flag,
        "nocontentsentry": directives.flag,
        "data_type": directives.unchanged,
        "type": partial(
            directives.choice, values=("constant", "static", "dynamic", "")
        ),
        "unit": directives.unchanged,
    }

    def handle_signature(self, sig: str, signode: desc_signature) -> Tuple[str, str]:
        sig = sig.strip()
        prefix = self.env.ref_context.get("dd:ids")
        parts = sig.split("/")
        target = prefix + "/" if prefix else ""
        for part in parts[:-1]:
            target += part + "/"
            text = nodes.Text(part)
            # Uncomment to create clickable cross-references to each parent structure
            # xref = pending_xref(
            #     "", text, refdomain="dd", reftype="node", reftarget=target[:-1]
            # )
            # signode += addnodes.desc_addname(part, "", xref)
            signode += text
            signode += addnodes.desc_sig_literal_char("/", "/")
        signode += addnodes.desc_name(parts[-1], parts[-1])

        # Add data_type, type and unit
        if "unit" in self.options:
            unit = self.options["unit"]
            signode += addnodes.desc_sig_space("", " ")
            signode += addnodes.desc_sig_literal_char("", "[")
            signode += nodes.Text(unit, unit)
            signode += addnodes.desc_sig_literal_char("", "]")

        if "data_type" in self.options:
            data_type = self.options["data_type"]
            signode += addnodes.desc_sig_space("", " ")
            signode += addnodes.desc_sig_literal_char("", "(")
            text = nodes.Text(data_type, data_type)
            signode += pending_xref(
                "", text, refdomain="dd", reftype="data_type", reftarget=data_type
            )
            signode += addnodes.desc_sig_literal_char("", ")")

        # TODO: type

        fullname = f"{prefix}/{sig}" if prefix else sig
        fullname = remove_brackets(fullname)
        signode["fullname"] = fullname
        return fullname, prefix

    def add_target_and_index(
        self, name: Tuple[str, str], sig: str, signode: desc_signature
    ) -> None:
        node_id = make_id(self.env, self.state.document, "", name[0])
        signode["ids"].append(node_id)
        self.state.document.note_explicit_target(signode)

        domain = cast(DDDomain, self.env.get_domain("dd"))
        domain.note_object(name[0], self.objtype, node_id, location=signode)

        if "noindexentry" not in self.options:
            indextext = name[0]
            if indextext:
                self.indexnode["entries"].append(
                    ("single", indextext, node_id, "", None)
                )

    def _object_hierarchy_parts(self, sig_node: desc_signature) -> Tuple[str, ...]:
        if "fullname" not in sig_node:
            return ()
        fullname = sig_node["fullname"]
        return tuple(fullname.split("/"))

    def _toc_entry_name(self, sig_node: desc_signature) -> str:
        if not sig_node.get("_toc_parts"):
            return ""

        config = self.env.app.config
        *parents, name = sig_node["_toc_parts"]
        if config.toc_object_entries_show_parents == "domain":
            return name
        if config.toc_object_entries_show_parents == "hide":
            return name
        if config.toc_object_entries_show_parents == "all":
            return "/".join(parents + [name])
        return ""


class _TopLevel(SphinxDirective):
    """Directive to mark the description of a Data Dictionary IDS/utility."""

    has_content = True
    required_arguments = 1
    optional_arguments = 0
    final_argument_whitespace = False

    refname = ""

    def run(self) -> List[Node]:
        """Run this directive.

        - Set the dd:ids context in the current document to the IDS name.
        - If :noindex: is not provided, an index entry for the IDS name is added that
          can be referred to with :dd:ids:`<ids_name>`.
        """
        domain = cast(DDDomain, self.env.get_domain("dd"))
        ids_name = self.arguments[0].strip()
        noindex = "noindex" in self.options
        self.env.ref_context["dd:ids"] = ids_name

        content_node = nodes.section()
        with switch_source_input(self.state, self.content):
            # necessary so that the child nodes get the right source/line set
            content_node.document = self.state.document
            nested_parse_with_titles(self.state, self.content, content_node)

        ret = []
        if not noindex:
            # note ids to the domain
            node_id = make_id(self.env, self.state.document, self.refname, ids_name)
            target = nodes.target("", "", ids=[node_id])
            self.set_source_info(target)
            self.state.document.note_explicit_target(target)

            domain.note_object(ids_name, self.refname, node_id, location=target)
            ret.append(target)
            indextext = f"{self.refname}; {ids_name}"
            inode = addnodes.index(entries=[("pair", indextext, node_id, "", None)])
            ret.append(inode)
        ret.extend(content_node.children)
        return ret


class IDS(_TopLevel):
    """Directive to mark the description of a Data Dictionary IDS."""

    refname = "ids"


class Util(_TopLevel):
    """Directive to mark the description of a Data Dictionary utility node."""

    refname = "util"


class UtilReference(DDNode):
    """Directive to mark that a node is a reference to a utility struct."""

    def handle_signature(self, sig: str, signode: desc_signature) -> Tuple[str, str]:
        # reference is guaranteed to not have whitespace, but path may have (?)
        *sigs, reference = sig.split()
        sig = sig.join(sigs)
        self.options["data_type"] = "structure"
        self.options["reference"] = reference
        return super().handle_signature(sig, signode)

    def transform_content(self, contentnode: desc_content) -> None:
        reference = self.options["reference"]
        content = StringList()
        content.append(
            f"See common IDS structure reference: :dd:util:`{reference}`.",
            *self.get_source_info(),
        )
        self.state.nested_parse(content, 0, contentnode)


class IDSXRefRole(XRefRole):
    """Extend standard cross-reference role to process tildes.

    :dd:node:`a/b/c` will display as "a/b/c", whereas :dd:node:`~a/b/c` will
    display as "c".
    """

    def process_link(
        self,
        env: BuildEnvironment,
        refnode: Element,
        has_explicit_title: bool,
        title: str,
        target: str,
    ) -> Tuple[str, str]:
        # Process tildes, similar to the Python domain
        if not has_explicit_title:
            target = target.lstrip("~")  # only has a meaning for the title
            # if the first character is a tilde, only display the name
            if title.startswith("~"):
                title = title[1:].rsplit("/")[-1]
        return title, target


class DDDomain(Domain):
    """Sphinx domain for the Data Dictionary."""

    name = "dd"
    label = "IMAS DD"
    object_types = {
        # IDSs
        "ids": ObjType("IDS", "ids"),
        # Utility structures
        "util": ObjType("utility", "util"),
        "util-ref": ObjType("utility", "util"),
        # IDS nodes
        "node": ObjType("node", "node"),
        # Data types
        "data_type": ObjType("data_type", "data_type"),
    }
    directives = {
        "ids": IDS,
        "util": Util,
        "util-ref": UtilReference,
        "node": DDNode,
        "data_type": DDNode,
    }
    roles = {
        "ids": IDSXRefRole(),
        "util": IDSXRefRole(),
        "node": IDSXRefRole(),
        "data_type": IDSXRefRole(),
    }
    initial_data = {
        "objects": {},  # fullname -> docname, node_id, objtype
    }

    @property
    def objects(self) -> Dict[str, Tuple[str, str, str]]:
        """Get all objects in the DD domain encountered so far.

        Returns:
            Dictionary mapping fullname -> document_name, node_id, object_type
        """
        return self.data.setdefault("objects", {})

    def note_object(
        self, fullname: str, objtype: str, node_id: str, location: Any = None
    ) -> None:
        """Register a new object to the DD domain."""
        fullname = fullname
        if fullname in self.objects:
            docname = self.objects[fullname][0]
            logger.warning(
                "duplicate object description of %s, other instance in %s"
                ", use :noindex: for one of them",
                fullname,
                docname,
            )
            # logger.warning(
            #     __("duplicate %s description of %s, other %s in %s"),
            #     objtype,
            #     fullname,
            #     objtype,
            #     docname,
            #     location=location,
            # )
        self.objects[fullname] = (self.env.docname, node_id, objtype)

    # Implement methods that should be overwritten

    def clear_doc(self, docname: str) -> None:
        for fullname, (obj_docname, _node_id, _l) in list(self.objects.items()):
            if obj_docname == docname:
                del self.objects[fullname]

    def merge_domaindata(self, docnames: List[str], otherdata: dict) -> None:
        for fullname, (fn, node_id, objtype) in otherdata["objects"].items():
            if fn in docnames:
                self.objects[fullname] = (fn, node_id, objtype)

    def find_obj(
        self, ids_name: Optional[str], name: str, typ: Optional[str]
    ) -> Tuple[str, Optional[Tuple[str, str, str]]]:
        """Find the DD object for "name", using the given context IDS name."""
        name = remove_brackets(name)
        newname = f"{ids_name}/{name}" if ids_name else name
        if newname in self.objects:
            obj = self.objects[newname]
        else:
            obj = self.objects.get(name)

        if obj is not None and typ is not None:
            objtypes = self.objtypes_for_role(typ)
            if objtypes is None or obj[2] not in objtypes:
                obj = None  # No match for this role

        return newname, obj

    def resolve_xref(
        self,
        env: BuildEnvironment,
        fromdocname: str,
        builder: Builder,
        typ: str,
        target: str,
        node: pending_xref,
        contnode: Element,
    ) -> Optional[Element]:
        ids_name = node.get("dd:ids")
        name, obj = self.find_obj(ids_name, target, typ)
        if not obj:
            return None
        return make_refnode(builder, fromdocname, obj[0], obj[1], contnode, name)

    def resolve_any_xref(
        self,
        env: BuildEnvironment,
        fromdocname: str,
        builder: Builder,
        target: str,
        node: pending_xref,
        contnode: Element,
    ) -> List[Tuple[str, Element]]:
        ids_name = node.get("dd:ids")
        name, obj = self.find_obj(ids_name, target, None)
        if not obj:
            return []
        return [
            f"dd:{self.role_for_objtype(obj[2])}",
            make_refnode(builder, fromdocname, obj[0], obj[1], contnode, name),
        ]

    def get_objects(self) -> Iterable[Tuple[str, str, str, str, str, int]]:
        for refname, (docname, node_id, typ) in list(self.objects.items()):
            # TODO: check which priority to use, currently 1 (default prio)
            yield refname, refname, typ, docname, node_id, 1

    def get_full_qualified_name(self, node: Element) -> Optional[str]:
        ids_name = node.get("dd:ids")
        target = node.get("reftarget")
        if target is None:
            return None
        return f"{ids_name}/{target}" if ids_name else target


# Monkeypatch:
def visit_desc(self, node: Element) -> None:
    self.body.append(self.starttag(node, "details"))


def depart_desc(self, node: Element) -> None:
    self.body.append("</details>\n\n")


def visit_desc_signature(self, node: Element) -> None:
    # the id is set automatically
    self.body.append(self.starttag(node, "summary"))
    self.protect_literal_text += 1


def depart_desc_signature(self, node: Element) -> None:
    self.protect_literal_text -= 1
    if not node.get("is_multiline"):
        self.add_permalink_ref(node, "Permalink to this definition")
    self.body.append("</summary>\n")


def visit_desc_content(self, node: Element) -> None:
    pass


def depart_desc_content(self, node: Element) -> None:
    pass


HTML5Translator.visit_desc = visit_desc
HTML5Translator.depart_desc = depart_desc
HTML5Translator.visit_desc_signature = visit_desc_signature
HTML5Translator.depart_desc_signature = depart_desc_signature
HTML5Translator.visit_desc_content = visit_desc_content
HTML5Translator.depart_desc_content = depart_desc_content


def setup(app: Sphinx) -> Dict[str, Any]:
    app.add_domain(DDDomain)
    return {
        "version": "0.1",
        "parallel_read_safe": True,
        "parallel_write_safe": True,
    }
