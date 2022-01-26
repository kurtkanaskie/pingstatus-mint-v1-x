#!/bin/sh
# shellcheck disable=SC2181
# Copyright 2021 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -e

# To be tested end-to-end
echo Pipeline for pingstatus-mint-v1 in project: "$ORG" for environment: "$ENV"

mvn -P "$ENV" clean
mvn -P "$ENV" jshint:lint
mvn -P "$ENV" frontend:install-node-and-npm@install-node-and-npm
mvn -P "$ENV" frontend:npm@npm-install
mvn -P "$ENV" frontend:npm@apigeelint
mvn -P "$ENV" frontend:npm@unit
mvn -P "$ENV" resources:copy-resources@copy-resources
mvn -P "$ENV" replacer:replace@replace
mvn -P "$ENV" apigee-enterprise:configure
mvn -P "$ENV" apigee-config:targetservers
mvn -P "$ENV" apigee-config:resourcefiles
./create_datacollector.sh
mvn -P "$ENV" apigee-enterprise:deploy
mvn -P "$ENV" apigee-config:apiproducts
# Basic
./create_rateplan_basic.sh
./create_developer_subscription_basic.sh
# Revshare
./create_rateplan_revshare.sh
./create_developer_subscription_revshare.sh
mvn -P "$ENV" apigee-config:developers
./update_developer_monetization_config.sh
./create_developer_balance.sh
mvn -P "$ENV" apigee-config:apps
mvn -P "$ENV" apigee-config:exportAppKeys
mvn -P "$ENV" frontend:npm@integration
