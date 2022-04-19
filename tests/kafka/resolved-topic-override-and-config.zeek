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

# @TEST-EXEC: zeek -r ../../../tests/pcaps/exercise-traffic.pcap ../../../scripts/Seiso/Kafka/ %INPUT | sort > output
# @TEST-EXEC: btest-diff output

module Kafka;

redef Kafka::logs_to_send = set(Conn::LOG);
redef Kafka::topic_name = "const-variable-topic";
redef Kafka::mock = T;

event zeek_init() &priority=-10
{
    local xxx_filter: Log::Filter = [
        $name = "kafka-xxx",
        $writer = Log::WRITER_KAFKAWRITER,
        $path = "kafka_xxx",
        $config = table(["topic_name"] = "configuration-table-topic")
    ];
    Log::add_filter(Conn::LOG, xxx_filter);
}

