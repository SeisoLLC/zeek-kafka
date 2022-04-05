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

#
# This is loaded automatically at Zeek startup once the plugin gets activated
# and its BiF elements have become available. Include code here that should
# always execute unconditionally at that time.
#
# Note that often you may want your plugin's accompanying scripts not here, but
# in scripts/<plugin-namespace>/<plugin-name>/__load__.zeek. That's processed
# only on explicit `@load <plugin-namespace>/<plugin-name>`.
#

@load ./init.zeek
