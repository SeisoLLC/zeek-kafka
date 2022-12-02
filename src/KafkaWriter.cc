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

#include "KafkaWriter.h"
#include "events.bif.h"
#include "zeek/Dict.h"

using namespace zeek::logging;
using namespace writer;

namespace {
  // Place elements from zeek::TableVal t in to std::map m
  void ToStdMap(std::map<std::string, std::string>& m, zeek::TableVal *t) {
    for (const auto &iter : t->ToMap() ) {
      std::string key = iter.first->AsListVal()->Idx(0)->AsString()->CheckString();
      std::string value = iter.second->AsString()->CheckString();
      m.insert(m.begin(), std::pair<std::string, std::string>(key, value));
    }
  }
}

// The Constructor is called once for each log filter that uses this log writer.
KafkaWriter::KafkaWriter(WriterFrontend *frontend)
    : WriterBackend(frontend), formatter(NULL), producer(NULL), topic(NULL) {
  /**
   * We need thread-local copies of all user-defined settings coming from zeek
   * scripting land.  accessing these is not thread-safe and 'DoInit' is
   * potentially accessed from multiple threads.
   */

  // tag_json - thread local copy
  tag_json = BifConst::Kafka::tag_json;
  mocking = BifConst::Kafka::mock;

  // json_timestamps
  ODesc tsfmt;
  BifConst::Kafka::json_timestamps->Describe(&tsfmt);
  json_timestamps.assign((const char *)tsfmt.Bytes(), tsfmt.Len());

  // topic name - thread local copy
  topic_name.assign((const char *)BifConst::Kafka::topic_name->Bytes(),
                    BifConst::Kafka::topic_name->Len());

  // kafka_conf and additional messages - thread local copy
  ToStdMap(kafka_conf, BifConst::Kafka::kafka_conf->AsTableVal());
  ToStdMap(additional_message_values, BifConst::Kafka::additional_message_values->AsTableVal());
}

KafkaWriter::~KafkaWriter() {
  // Cleanup must happen in DoFinish, not in the destructor
}

std::string KafkaWriter::GetConfigValue(const WriterInfo &info,
                                   const std::string name) const {
  std::map<const char *, const char *>::const_iterator it =
      info.config.find(name.c_str());
  if (it == info.config.end())
    return std::string();
  else
    return it->second;
}

/**
 * DoInit is called once for each call to the constructor, but in a separate
 * thread
 */
bool KafkaWriter::DoInit(const WriterInfo &info, int num_fields,
                         const threading::Field *const *fields) {
  // TimeFormat object, default to TS_EPOCH
  threading::formatter::JSON::TimeFormat tf =
      threading::formatter::JSON::TS_EPOCH;

  // Allow overriding of the kafka topic via the Zeek script constant
  // 'topic_name' which can be applied when adding a new Zeek log filter.
  topic_name_override = GetConfigValue(info, "topic_name");

  if (!topic_name_override.empty()) {
    // Override the topic name if 'topic_name' is specified in the log
    // filter's $conf
    topic_name = topic_name_override;
  } else if (topic_name.empty()) {
    // If no global 'topic_name' is defined, use the log stream's 'path'
    topic_name = info.path;
  }

  if (mocking) {
    raise_topic_resolved_event(topic_name);
  }

  /**
   * Format the timestamps
   * NOTE: This string comparision implementation is currently the necessary
   * way to do it, as there isn't a way to pass the Zeek enum into C++ enum.
   * This makes the user interface consistent with the existing Zeek Logging
   * configuration for the ASCII log output.
   */
  if (strcmp(json_timestamps.c_str(), "JSON::TS_EPOCH") == 0) {
    tf = threading::formatter::JSON::TS_EPOCH;
  } else if (strcmp(json_timestamps.c_str(), "JSON::TS_MILLIS") == 0) {
    tf = threading::formatter::JSON::TS_MILLIS;
  } else if (strcmp(json_timestamps.c_str(), "JSON::TS_ISO8601") == 0) {
    tf = threading::formatter::JSON::TS_ISO8601;
  } else {
    Error(Fmt("KafkaWriter::DoInit: Invalid JSON timestamp format %s",
              json_timestamps.c_str()));
    return false;
  }

  // initialize the formatter
  if (BifConst::Kafka::tag_json) {
    formatter = new threading::formatter::TaggedJSON(info.path, this, tf);
  } else {
    formatter = new threading::formatter::JSON(this, tf);
  }

  // is debug enabled
  std::string debug;
  debug.assign((const char *)BifConst::Kafka::debug->Bytes(),
               BifConst::Kafka::debug->Len());
  bool is_debug(!debug.empty());
  if (is_debug) {
    MsgThread::Info(
        Fmt("Debug is turned on and set to: %s.  Available debug context: %s.",
            debug.c_str(), RdKafka::get_debug_contexts().c_str()));
  }

  // kafka global configuration
  std::string err;
  conf = RdKafka::Conf::create(RdKafka::Conf::CONF_GLOBAL);

  // apply the user-defined settings to kafka
  std::map<std::string, std::string>::iterator i;
  for (i = kafka_conf.begin(); i != kafka_conf.end(); ++i) {
    std::string key = i->first;
    std::string val = i->second;

    // apply setting to kafka
    if (RdKafka::Conf::CONF_OK != conf->set(key, val, err)) {
      Error(Fmt("Failed to set '%s'='%s': %s", key.c_str(), val.c_str(),
                err.c_str()));
      return false;
    }
  }

  if (is_debug) {
    std::string key("debug");
    std::string val(debug);
    if (RdKafka::Conf::CONF_OK != conf->set(key, val, err)) {
      Error(Fmt("Failed to set '%s'='%s': %s", key.c_str(), val.c_str(),
                err.c_str()));
      return false;
    }
  }

  if (!mocking) {
    // create kafka producer
    producer = RdKafka::Producer::create(conf, err);
    if (!producer) {
      Error(Fmt("Failed to create producer: %s", err.c_str()));
      return false;
    }

    // create handle to topic
    topic_conf = RdKafka::Conf::create(RdKafka::Conf::CONF_TOPIC);
    topic = RdKafka::Topic::create(producer, topic_name, topic_conf, err);
    if (!topic) {
      Error(Fmt("Failed to create topic handle: %s", err.c_str()));
      return false;
    }

    if (is_debug) {
      MsgThread::Info(Fmt("Successfully created producer."));
    }
  }
  return true;
}

/**
 * Writer-specific method called just before the threading system is
 * going to shutdown. It is assumed that once this messages returns,
 * the thread can be safely terminated. As such, all resources created must be
 * removed here.
 */
bool KafkaWriter::DoFinish(double network_time) {
  bool success = false;
  int poll_interval = 1000;
  int waited = 0;
  int max_wait = BifConst::Kafka::max_wait_on_shutdown;

  if (!mocking) {
    // wait a bit for queued messages to be delivered
    while (producer->outq_len() > 0 && waited <= max_wait) {
      producer->poll(poll_interval);
      waited += poll_interval;
    }

    // successful only if all messages delivered
    if (producer->outq_len() == 0) {
      success = true;
    } else {
      Error(Fmt("Unable to deliver %0d message(s)", producer->outq_len()));
    }

    delete topic;
    delete producer;
    delete topic_conf;
  }
  delete formatter;
  delete conf;

  return success;
}

/**
 * Writer-specific output method implementing recording of one log
 * entry.
 */
bool KafkaWriter::DoWrite(int num_fields, const threading::Field *const *fields,
                          threading::Value **vals) {
  if (!mocking) {
    ODesc buff;
    buff.Clear();

    // format the log entry
    if (BifConst::Kafka::tag_json) {
      dynamic_cast<threading::formatter::TaggedJSON *>(formatter)->Describe(
          &buff, num_fields, fields, vals, additional_message_values);
    } else {
      formatter->Describe(&buff, num_fields, fields, vals);
    }

    // send the formatted log entry to kafka
    const char *raw = (const char *)buff.Bytes();
    RdKafka::ErrorCode resp = producer->produce(
        topic, RdKafka::Topic::PARTITION_UA, RdKafka::Producer::RK_MSG_COPY,
        const_cast<char *>(raw), strlen(raw), NULL, NULL);

    if (RdKafka::ERR_NO_ERROR == resp) {
      producer->poll(0);
    } else {
      std::string err = RdKafka::err2str(resp);
      Error(Fmt("Kafka send failed: %s", err.c_str()));
    }
  }
  return true;
}

/**
 * Writer-specific method implementing a change of the buffering
 * state.	If buffering is disabled, the writer should attempt to
 * write out information as quickly as possible even if doing so may
 * have a performance impact. If enabled (which is the default), it
 * may buffer data as helpful and write it out later in a way
 * optimized for performance. The current buffering state can be
 * queried via IsBuf().
 */
bool KafkaWriter::DoSetBuf(bool enabled) {
  // no change in behavior
  return true;
}

/**
 * Writer-specific method implementing flushing of its output.	A writer
 * implementation must override this method but it can just
 * ignore calls if flushing doesn't align with its semantics.
 */
bool KafkaWriter::DoFlush(double network_time) {
  if (!mocking) {
    producer->flush(0);
  }
  return true;
}

/**
 * Writer-specific method implementing log rotation.	Most directly
 * this only applies to writers writing into files, which should then
 * close the current file and open a new one.	However, a writer may
 * also trigger other apppropiate actions if semantics are similar.
 * Once rotation has finished, the implementation *must* call
 * FinishedRotation() to signal the log manager that potential
 * postprocessors can now run.
 */
bool KafkaWriter::DoRotate(const char *rotated_path, double open, double close,
                           bool terminating) {
  // no need to perform log rotation
  return FinishedRotation();
}

/**
 * Triggered by regular heartbeat messages from the main thread.
 */
bool KafkaWriter::DoHeartbeat(double network_time, double current_time) {
  if (!mocking) {
    producer->poll(0);
  }
  return true;
}

/**
 * Triggered when the topic is resolved from the configuration, when
 * mocking/testing
 * @param topic
 */
void KafkaWriter::raise_topic_resolved_event(const std::string topic) {
  if (kafka_topic_resolved_event) {
    zeek::Args args;
    args.emplace_back(make_intrusive<StringVal>(topic.c_str()));
    zeek::event_mgr.Enqueue(kafka_topic_resolved_event, std::move(args));
  }
}
