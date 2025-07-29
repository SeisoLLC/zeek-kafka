#!/usr/bin/env python3
"""
Task execution tool & library
"""

#
#  Copyright 2020-2025 Zeek-Kafka
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#

import re
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
def version(_c, version_type):
    """Make a new release of zeek-kafka"""
    if REPO.head.is_detached:
        LOG.error("In detached HEAD state, refusing to release")
        sys.exit(1)

    if version_type not in ["major", "minor", "patch", "build", "release"]:
        LOG.error("Please provide a release type of major, minor, patch, build, or release")
        sys.exit(1)

    bumpversion([version_type])
