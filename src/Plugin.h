/*
 * Copyright 2020-2021 Zeek-Kafka
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

#include "KafkaWriter.h"
#include <plugin/Plugin.h>

namespace plugin { namespace Seiso_Kafka {

    class Plugin : public ::plugin::Plugin {
    protected:
        // Overridden from plugin::Plugin.
        virtual plugin::Configuration Configure();
    };

    extern Plugin plugin;
}}

#endif
