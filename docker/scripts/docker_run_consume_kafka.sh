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
# Runs a kafka container with the console consumer for the appropriate topic.
# The consumer should quit when it has read all of the messages available on
# the given partition.
#

function help {
  echo " "
  echo "usage: ${0}"
  echo "    --network-name                  [OPTIONAL] The Docker network name. Default: zeek-kafka_default"
  echo "    --offset                        [OPTIONAL] The kafka offset to read from. Default: 0"
  echo "    --partition                     [OPTIONAL] The kafka partition to read from. Default: 0"
  echo "    --kafka-topic                   [OPTIONAL] The kafka topic to consume from. Default: zeek"
  echo "    -h/--help                       Usage information."
  echo " "
}

NETWORK_NAME=zeek-kafka_default
OFFSET=0
PARTITION=0
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
  # OFFSET
  #
  #   --offset
  #
    --offset=*)
      OFFSET="${i#*=}"
      shift # past argument=value
    ;;
  #
  # PARTITION
  #
  #   --partition
  #
    --partition=*)
      PARTITION="${i#*=}"
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
  kafka-console-consumer.sh --topic "${KAFKA_TOPIC}" --offset "${OFFSET}" --partition "${PARTITION}" --bootstrap-server kafka-1:9092 --timeout-ms 5000

