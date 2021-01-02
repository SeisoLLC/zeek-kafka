#
#  Copyright 2020-2021 Zeek-Kafka
#  Copyright 2015-2020 The Apache Software Foundation
#
#  Licensed to the Apache Software Foundation (ASF) under one or more
#  contributor license agreements.  See the NOTICE file distributed with
#  this work for additional information regarding copyright ownership.
#  The ASF licenses this file to You under the Apache License, Version 2.0
#  (the "License"); you may not use this file except in compliance with
#  the License.  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.

requirements: requirements-to-freeze.txt
	@docker run --rm -v $$(pwd):/usr/src/app/ python:3 /bin/bash -c "python3 -m pip install --upgrade pip && python3 -m pip install -r /usr/src/app/requirements-to-freeze.txt && python3 -m pip freeze > /usr/src/app/requirements.txt"
