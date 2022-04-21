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

#ifndef ZEEK_PLUGIN_KAFKA
#define ZEEK_PLUGIN_KAFKA

#include <zeek/plugin/Plugin.h>

#include "KafkaWriter.h"

namespace zeek::plugin::Seiso_Kafka {

    class Plugin : public zeek::plugin::Plugin {
    protected:
        // Overridden from plugin::Plugin.
        virtual zeek::plugin::Configuration Configure();
    };

    extern Plugin plugin;
}

#endif
