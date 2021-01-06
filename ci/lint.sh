#!/usr/bin/env bash
#
#  Copyright 2020-2021 Zeek-Kafka
#

set -u # nounset
set -e # errexit
set -E # errtrap
set -o pipefail

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && cd .. && pwd )"
FILES=$(find "${DIR}" \( -path "${DIR}/.git" -prune -or       \
                         -path "${DIR}/.github" -prune \) -or \
              \(      -not -name ".*"                         \
                 -and -not -name "*.yml"                      \
                 -and -not -name "*.pcap"                     \
                 -and -not -name "*.pcapng"                   \
                 -and -not -name "requirements*.txt"          \
                 -and -not -name "Dockerfile"                 \
                 -and -not -name "output"                     \
                 -and -not -name "random.seed"                \
                 -and -not -name "COPYING"                    \
                 -and -not -name "zkg.meta"                   \
                      -type f                                 \
              \)                                              \
       )

while IFS= read -r file; do
  # If the file still exists, and matches one of the provided extensions
  if [[ -f "${file}" ]]; then
    # Ensure that it has the required copyright statemenet
    grep --files-without-match 'Copyright 2020-2.* Zeek-Kafka$' "${file}"
  else
    echo "${file} was excluded from linting"
  fi
done <<< "${FILES}"

