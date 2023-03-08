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

# usage: 
# source set_env_varables.sh
# ./pipeline.sh
# NOTE: This is not idempotent, scripts just try to create monetization artifacts.
# TODO: convert to use apigeecli

set -e

echo Pipeline for \"pingstatus-mint-v1\" in project: \"${ORG}\" for environment: \"${ENV}\"
echo
echo ARGS=$ARGS

read -p "OK to proceed (Y/n)? " i
if [ "$i" != "Y" ]
then
  echo aborted
  exit 1
fi
echo Proceeding...

mvn -P ${ENV} ${ARGS} clean
mvn -P ${ENV} ${ARGS} jshint:lint
mvn -P ${ENV} ${ARGS} frontend:install-node-and-npm@install-node-and-npm
mvn -P ${ENV} ${ARGS} frontend:npm@npm-install
mvn -P ${ENV} ${ARGS} frontend:npm@apigeelint
mvn -P ${ENV} ${ARGS} frontend:npm@unit
mvn -P ${ENV} ${ARGS} resources:copy-resources@copy-resources
mvn -P ${ENV} ${ARGS} replacer:replace@replace
mvn -P ${ENV} ${ARGS} apigee-enterprise:configure
mvn -P ${ENV} ${ARGS} apigee-config:targetservers
mvn -P ${ENV} ${ARGS} apigee-config:resourcefiles

# System.uuid for analytics not needed for Monetization, used for debugging.
# ./create_datacollector.sh

mvn -P ${ENV} ${ARGS} apigee-enterprise:deploy
mvn -P ${ENV} ${ARGS} apigee-config:apiproducts

# Rate Plans
./create_rateplan_basic.sh
./create_rateplan_revshare.sh

mvn -P ${ENV} ${ARGS} apigee-config:developers

# Prepaid and Postpaid developers
./update_developer_monetization_config.sh

# Prepaid developer balance
./create_developer_balance.sh

# Subscriptions Prepaid and Postpaid
./create_developer_subscription_basic.sh
./create_developer_subscription_revshare.sh

mvn -P ${ENV} ${ARGS} apigee-config:apps
mvn -P ${ENV} ${ARGS} apigee-config:exportAppKeys
mvn -P ${ENV} ${ARGS} frontend:npm@integration
