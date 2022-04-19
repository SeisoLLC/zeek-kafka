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
# Runs a kafka container to retrieve the offset for the provided topic
#

function help {
  echo " "
  echo "usage: ${0}"
  echo "    --network-name                  [OPTIONAL] The Docker network name. Default: zeek-kafka_default"
  echo "    --kafka-topic                   [OPTIONAL] The kafka topic to pull the offset from. Default: zeek"
  echo "    -h/--help                       Usage information."
  echo " "
}

NETWORK_NAME=zeek-kafka_default
KAFKA_TOPIC=zeek

# handle command line options
for i in "$@"; do
  case $i in
  #
  # NETWORK_NAME
  #
  #   --network-name
  #
    --network-name=*)
      NETWORK_NAME="${i#*=}"
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

docker run --rm --network "${NETWORK_NAME}" zeek-kafka_kafka \
  kafka-run-class.sh kafka.tools.GetOffsetShell --topic "${KAFKA_TOPIC}" --broker-list "kafka-1:9092,kafka-2:9092"

