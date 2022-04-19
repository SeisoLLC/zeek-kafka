#!/usr/bin/env bash
#
#  Copyright 2020-2022 Zeek-Kafka
#  Copyright 2015-2020 The Apache Software Foundation
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

shopt -s nocasematch
set -u # nounset
set -e # errexit
set -E # errtrap
set -o pipefail

#
# Executes the configure_plugin.sh in the docker container
#

function help {
  echo " "
  echo "usage: ${0}"
  echo "    --container-name                [OPTIONAL] The Docker container name. Default: zeek-kafka_zeek_1"
  echo "    --kafka-topic                   [OPTIONAL] The kafka topic to create. Default: zeek"
  echo "    -h/--help                       Usage information."
  echo " "
  echo " "
}

CONTAINER_NAME=zeek-kafka_zeek_1
KAFKA_TOPIC=zeek

# Handle command line options
for i in "$@"; do
  case $i in
  #
  # CONTAINER_NAME
  #
  #   --container-name
  #
    --container-name=*)
      CONTAINER_NAME="${i#*=}"
      shift # past argument=value
    ;;
  #
  # KAFKA_TOPIC
  #
  #   --kafka-topic
  #
    --kafka-topic=*)
      KAFKA_TOPIC="${i#*=}"
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
  #
  # Unknown option
  #
    *)
      UNKNOWN_OPTION="${i#*=}"
      echo "Error: unknown option: $UNKNOWN_OPTION"
      help
    ;;
  esac
done

echo "Running docker_execute_configure_plugin.sh with "
echo "CONTAINER_NAME = ${CONTAINER_NAME}"
echo "KAFKA_TOPIC = ${KAFKA_TOPIC}"
echo "==================================================="

docker exec -w /root "${CONTAINER_NAME}" bash -c "/root/built_in_scripts/configure_plugin.sh --kafka-topic=\"${KAFKA_TOPIC}\""

echo "configured the kafka plugin"

