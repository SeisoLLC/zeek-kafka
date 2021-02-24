#!/usr/bin/env bash
#
#  Copyright 2020-2021 Zeek-Kafka
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

set -u # nounset
set -e # errexit
set -E # errtrap
set -o pipefail

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && cd .. && pwd )"
MISSING_COPYRIGHT=$(find "${DIR}" \( -path "${DIR}/.git" -or                     \
                 -path "${DIR}/.github" \) -prune -false -or \
         \(      -not -name ".*"                             \
            -and -not -name "*.yml"                          \
            -and -not -name "*.pcap"                         \
            -and -not -name "*.pcapng"                       \
            -and -not -name "requirements*.txt"              \
            -and -not -name "Dockerfile"                     \
            -and -not -name "output"                         \
            -and -not -name "random.seed"                    \
            -and -not -name "COPYING"                        \
            -and -not -name "zkg.meta"                       \
                 -type f                                     \
         \)                                                  \
                 -print0 |                                   \
  xargs -0 grep --files-without-match 'Copyright 2020-2.* Zeek-Kafka$')

if [[ "${MISSING_COPYRIGHT:-}" ]]; then
  echo "The following files are missing the Zeek-Kafka copyright"
  echo "${MISSING_COPYRIGHT}"
  exit 1
fi
