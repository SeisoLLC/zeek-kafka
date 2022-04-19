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

find_path(LibRDKafka_ROOT_DIR
    NAMES include/librdkafka/rdkafkacpp.h
)

find_library(LibRDKafka_LIBRARIES
    NAMES rdkafka++
    HINTS ${LibRDKafka_ROOT_DIR}/lib
    PATH_SUFFIXES ${CMAKE_LIBRARY_ARCHITECTURE}
)

find_library(LibRDKafka_C_LIBRARIES
    NAMES rdkafka
    HINTS ${LibRDKafka_ROOT_DIR}/lib
    PATH_SUFFIXES ${CMAKE_LIBRARY_ARCHITECTURE}
)

find_path(LibRDKafka_INCLUDE_DIR
    NAMES librdkafka/rdkafkacpp.h
    HINTS ${LibRDKafka_ROOT_DIR}/include
)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(LibRDKafka DEFAULT_MSG
    LibRDKafka_LIBRARIES
    LibRDKafka_C_LIBRARIES
    LibRDKafka_INCLUDE_DIR
)

mark_as_advanced(
    LibRDKafka_ROOT_DIR
    LibRDKafka_LIBRARIES
    LibRDKafka_C_LIBRARIES
    LibRDKafka_INCLUDE_DIR
)
