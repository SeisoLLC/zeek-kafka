#
#  Copyright 2020-2021 Zeek-Kafka
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
# Convenience Makefile providing a few common top-level targets.
#

SHELL           := bash
CMAKE_BUILD_DIR  = build
ARCH             = `uname -s | tr A-Z a-z`-`uname -m`

.PHONY: all
all: build-it

.PHONY: build-it
build-it:
	@test -e $(CMAKE_BUILD_DIR)/config.status || ./configure
	-@test -e $(CMAKE_BUILD_DIR)/CMakeCache.txt && \
      test $(CMAKE_BUILD_DIR)/CMakeCache.txt -ot `cat $(CMAKE_BUILD_DIR)/CMakeCache.txt | grep ZEEK_DIST | cut -d '=' -f 2`/build/CMakeCache.txt && \
      echo Updating stale CMake cache && \
      touch $(CMAKE_BUILD_DIR)/CMakeCache.txt

	( cd $(CMAKE_BUILD_DIR) && make )

.PHONY: install
install:
	( cd $(CMAKE_BUILD_DIR) && make install )

.PHONY: clean
clean:
	( cd $(CMAKE_BUILD_DIR) && make clean )

.PHONY: distclean
distclean:
	rm -rf $(CMAKE_BUILD_DIR)

.PHONY: test
test:
	make -C tests

.PHONY: lint
lint:
	@ci/lint.sh
