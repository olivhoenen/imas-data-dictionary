"""Sphinx plugin to generate a changelog of the DD and add it to sphinx.
Requires a json file containing all pull requests, which can be generated using
dd_changelog_helper.py
Logic is partly based on code in the :external:py:mod:`sphinx.domains` module.
"""

from pathlib import Path
from typing import Any, Dict, List
from git import Repo, Tag
import json
import re

from sphinx.application import Sphinx
from sphinx.util import logging

logger = logging.getLogger(__name__)


def tag_sort_helper(tag: Tag):
    parts = tag.name.split(".")
    return tuple(map(int, parts))


def sort_tags(list_of_tags: List[Tag]):
    return sorted(list_of_tags, key=tag_sort_helper)


def generate_list(list_text: str, indentation=0) -> str:
    try:
        list_text = list_text[list_text.index("* ") :]
    except ValueError:
        pass
    list_list = list_text.split("\n")
    generated_list = ("\n" * (indentation // 2 + 1)).join(
        [f"{' '*indentation}{a}" for a in list_list]
    )
    return generated_list


def is_list(text: str) -> bool:
    return text.startswith("* ")


def replace_note(text: str):
    return re.sub(
        r"^( *)> Note: (.*)$", r"\g<1>.. note::\n  \g<1>\g<2>", text, flags=re.M
    )


def replace_imas_jira(text: str):
    return re.sub(
        r"(IMAS-\d+)",
        r"`\g<1> <https://jira.iter.org/browse/\g<1>>`__",
        text,
        flags=re.M,
    )


def generate_dd_changelog(app: Sphinx):
    """Generate a changelog using git pull requests"""
    logger.info("Generating DD changelog sources.")

    # Ensure output folders exist
    (Path("generated/changelog")).mkdir(parents=True, exist_ok=True)

    docfile = Path("generated/changelog/changelog.rst")

    docfile.unlink(True)

    repo = Repo("..")

    tags = sort_tags(repo.tags)

    tag_pairs = [(tags[i], tags[i + 1]) for i in range(len(tags) - 1)]

    commits_between_tags = reversed(
        [repo.iter_commits(rev=f"{t[0]}..{t[1]}") for t in tag_pairs]
    )

    with open("pull_requests.json", "r") as f:
        pull_requests = json.load(f)

    changelog_text = "=============\nChangelog\n=============\n\n"

    previous_version_idx = 1

    tags = list(reversed(tags))

    for version, commits in zip(tags[:-1], commits_between_tags):
        release = f"Release {version.name}\n"
        release += "=" * len(release) + "\n\n"

        release_notes_text = ""

        pull_requests_text = ""
        for commit in commits:
            for pr in filter(
                lambda x: commit.hexsha == x["fromRef"]["latestCommit"], pull_requests
            ):
                title: str = pr["title"]
                if title.lower().startswith("release/") or title.lower().startswith(
                    "hotfix/"
                ):
                    description: str = pr.get("description", "no description")
                    release_notes_text += replace_imas_jira(generate_list(description))
                self_uri = pr.get("links", {}).get("self", [])
                if len(self_uri) != 0:
                    title = f"`{title} <{self_uri[0].get('href')}>`__"
                pull_requests_text += f"* {title}\n"

        # if release_notes_text != "" or pull_requests_text != "":
        changelog_text += release

        if release_notes_text != "":
            changelog_text += "Release notes\n--------------\n\n"
            changelog_text += replace_note(release_notes_text)
            changelog_text += "\n\n"

        diff_url = None

        if len(tags) > previous_version_idx:
            previous_version = tags[previous_version_idx]

            diff_url = f"https://git.iter.org/projects/IMAS/repos/data-dictionary/compare/diff?targetBranch={previous_version.tag.tag}&sourceBranch={version.tag.tag}&targetRepoId=114"
            previous_version_idx += 1

        if pull_requests_text != "":
            changelog_text += "Included pull requests\n"
            changelog_text += "----------------------------------------------------\n\n"
            changelog_text += f"`diff <{diff_url}>`__\n\n"
            changelog_text += pull_requests_text
            changelog_text += "\n\n"
        elif diff_url:
            changelog_text += f"`diff <{diff_url}>`__\n\n"

    with open(docfile, "w") as f:
        f.write(changelog_text)

    logger.info("Finished generating DD changelog sources.")


def setup(app: Sphinx) -> Dict[str, Any]:
    app.connect("builder-inited", generate_dd_changelog)
    return {
        "version": "0.1",
        "parallel_read_safe": True,
        "parallel_write_safe": True,
    }
