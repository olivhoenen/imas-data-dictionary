# Configuration file for the Sphinx documentation builder.
#
# For the full list of built-in configuration values, see the documentation:
# https://www.sphinx-doc.org/en/master/usage/configuration.html

import datetime
import os
import subprocess
import sys

# Ensure that our extension module can be imported:
sys.path.append(os.path.curdir)
import sphinx_dd_extension.dd_domain

# -- Project information -----------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#project-information

project = "IMAS Data Dictionary"
copyright = f"{datetime.datetime.now().year}, ITER Organization"
author = "ITER Organization"

version = subprocess.check_output(["git", "describe"]).decode().strip()
last_tag = subprocess.check_output(["git", "describe", "--abbrev=0"]).decode().strip()
is_develop = version != last_tag

html_context = {
    "is_develop": is_develop
}

language = "en"

# -- General configuration ---------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#general-configuration

extensions = [
    "sphinx.ext.todo",
    # "sphinx.ext.autosectionlabel",
    "sphinx.ext.intersphinx",
    "sphinx.ext.mathjax",
    "sphinx_immaterial",
    "sphinx_dd_extension.dd_domain",
    "sphinx_dd_extension.autodoc",
    "sphinx_dd_extension.dd_changelog",
]

templates_path = ["_templates"]
exclude_patterns = ["_build", "Thumbs.db", ".DS_Store"]


# -- Intersphinx configuration -----------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/extensions/intersphinx.html#configuration

intersphinx_mapping = {}


# -- Options for HTML output -------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#options-for-html-output

html_theme = "sphinx_immaterial"
html_theme_options = {
    "repo_url": "https://git.iter.org/projects/IMAS/repos/data-dictionary",
    "repo_name": "Data Dictionary",
    "icon": {
        "repo": "fontawesome/brands/bitbucket",
    },
    "features": [
        # "navigation.expand",
        # "navigation.tabs",
        "navigation.sections",
        "navigation.instant",
        # "header.autohide",
        "navigation.top",
        # "navigation.tracking",
        # "search.highlight",
        # "search.share",
        # "toc.integrate",
        # "toc.follow",
        "toc.sticky",
        # "content.tabs.link",
        "announce.dismiss",
    ],
    # "toc_title_is_page_title": True,
    # "globaltoc_collapse": True,
    "palette": [
        {
            "media": "(prefers-color-scheme: light)",
            "scheme": "default",
            "primary": "blue",
            "accent": "light-green",
            "toggle": {
                "icon": "material/lightbulb-outline",
                "name": "Switch to dark mode",
            },
        },
        {
            "media": "(prefers-color-scheme: dark)",
            "scheme": "slate",
            "primary": "light-blue",
            "accent": "lime",
            "toggle": {
                "icon": "material/lightbulb",
                "name": "Switch to light mode",
            },
        },
    ],
    "version_dropdown": True,
    "version_info": [  # TODO: remove once this is covered by the deployment script
        {
            "version": "html/index.html#",
            "title": "dev",
            "aliases": [],
        }
    ] + [
        {
            "version": f"https://sharepoint.iter.org/departments/POP/CM/IMDesign/Data%20Model/CI/imas-{version}/html_documentation.html#",
            "title": f"{version}",
            "aliases": ["latest"] if version == "3.38.1" else [],
        }
        for version in ["3.38.1", "3.37.2", "3.36.0", "3.35.0", "3.34.0", "3.33.0", "3.34.0", "3.33.0", "3.32.1", "3.31.0", "3.30.0"]
    ],
    "version_json": "../versions.js",
}

html_static_path = ["_static"]


def setup(app):
    app.add_css_file("dd.css")
    app.add_js_file("dd.js")
