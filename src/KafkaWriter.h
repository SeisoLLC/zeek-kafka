/*
 * Copyright 2020-2022 Zeek-Kafka
 * Copyright 2015-2020 The Apache Software Foundation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#ifndef ZEEK_PLUGIN_KAFKA_KAFKAWRITER_H
#define ZEEK_PLUGIN_KAFKA_KAFKAWRITER_H

#include <librdkafka/rdkafkacpp.h>
#include <map>
#include <string>

#include <zeek/Desc.h>
#include <zeek/logging/WriterBackend.h>
#include <zeek/threading/formatters/JSON.h>
#include <zeek/threading/Formatter.h>

#include "kafka.bif.h"
#include "TaggedJSON.h"

namespace RdKafka {
    class Conf;
    class Producer;
    class Topic;
}

namespace zeek::logging::writer {

/**
 * A logging writer that sends data to a Kafka broker.
 */
class KafkaWriter : public WriterBackend {

public:
    explicit KafkaWriter(WriterFrontend* frontend);
    ~KafkaWriter();

    static WriterBackend* Instantiate(WriterFrontend* frontend)
    {
        return new KafkaWriter(frontend);
    }

protected:
    virtual bool DoInit(const WriterBackend::WriterInfo& info, int num_fields, const threading::Field* const* fields);
    virtual bool DoWrite(int num_fields, const threading::Field* const* fields, threading::Value** vals);
    virtual bool DoSetBuf(bool enabled);
    virtual bool DoRotate(const char* rotated_path, double open, double close, bool terminating);
    virtual bool DoFlush(double network_time);
    virtual bool DoFinish(double network_time);
    virtual bool DoHeartbeat(double network_time, double current_time);

private:
    std::string GetConfigValue(const WriterInfo& info, const std::string name) const;
    void raise_topic_resolved_event(const std::string topic);
    static const std::string default_topic_key;
    std::string stream_id;
    bool tag_json;
    bool mocking;
    std::string json_timestamps;
    std::map<std::string, std::string> kafka_conf;
    std::map<std::string, std::string> additional_message_values;
    std::string topic_name;
    std::string topic_name_override;
    threading::Formatter *formatter;
    RdKafka::Producer* producer;
    RdKafka::Topic* topic;
    RdKafka::Conf* conf;
    RdKafka::Conf* topic_conf;
};

}

#endif
