#!/usr/bin/env bash
#
#  Copyright 2020-2023 Zeek-Kafka
#  Copyright 2020 The Apache Software Foundation
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

#
# This script should be run _after_ run_end_to_end.sh when you are finished with your testing and the containers.
# Do not run this if you plan on running docker_execute_shell.sh for example
#

shopt -s nocasematch
set -u # nounset
set -e # errexit
set -E # errtrap
set -o pipefail

function help {
  echo " "
  echo "USAGE"
  echo "    --zeek-kafka-os     [OPTIONAL] The OS to run zeek and zeek-kafka in. Default: ubuntu"
  echo "    -h/--help           Usage information."
}

PROJECT_NAME="zeek-kafka"
ZEEK_KAFKA_OS="ubuntu"

# Handle command line options
for i in "$@"; do
  case $i in
  #
  # ZEEK_KAFKA_OS
  #
  #   --zeek-kafka-os
  #
    --zeek-kafka-os=*)
      ZEEK_KAFKA_OS="${i#*=}"
      shift # past argument=value
    ;;
  #
  # -h/--help
  #
    -h | --help)
      help
      exit 0
      shift # past argument with no value
    ;;
  esac
done

if [[ "${ZEEK_KAFKA_OS}" == "ubuntu" ]]; then
  ZEEK_KAFKA_OS="ubuntu:20.04"
else
  echo "OS must be ubuntu"
  exit 1
fi

# docker compose down
COMPOSE_PROJECT_NAME="${PROJECT_NAME}" \
  ZEEK_KAFKA_OS="${ZEEK_KAFKA_OS}" \
  docker-compose down

