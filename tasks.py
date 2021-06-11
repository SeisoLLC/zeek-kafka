#!/usr/bin/env python3
"""
Task execution tool & library
"""

import sys
from logging import basicConfig, getLogger
from pathlib import Path

import json
import git
from bumpversion.cli import main as bumpversion
from invoke import task

LOG_FORMAT = json.dumps(
    {
        "timestamp": "%(asctime)s",
        "namespace": "%(name)s",
        "loglevel": "%(levelname)s",
        "message": "%(message)s",
    }
)

basicConfig(level="INFO", format=LOG_FORMAT)
LOG = getLogger("zeek-kafka.invoke")

CWD = Path(".").absolute()
try:
    REPO = git.Repo(CWD)
except git.InvalidGitRepositoryError:
    REPO = None


@task
def release(_c, release_type):
    """Make a new release of zeek-kafka"""
    if REPO.head.is_detached:
        LOG.error("In detached HEAD state, refusing to release")
        sys.exit(1)

    if release_type not in ["major", "minor", "patch"]:
        LOG.error("Please provide a release type of major, minor, or patch")
        sys.exit(1)

    bumpversion([release_type])
