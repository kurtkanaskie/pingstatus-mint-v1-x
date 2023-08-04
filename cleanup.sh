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

# NOT TESTED END TO END

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

mvn -P ${ENV} ${ARGS} -Dskip.integration=true -Dapigee.config.options=delete -Dapigee.options=clean \
    process-resources \
    apigee-config:apps \
    apigee-config:apiproducts \
    apigee-config:developers \
    apigee-enterprise:deploy

mvn -P ${ENV} ${ARGS} clean
mvn -P ${ENV} ${ARGS} resources:copy-resources@copy-resources
mvn -P ${ENV} ${ARGS} replacer:replace@replace
mvn -P ${ENV} ${ARGS} apigee-config:apps -Dapigee.config.options=delete
mvn -P ${ENV} ${ARGS} apigee-config:developers
mvn -P ${ENV} ${ARGS} apigee-config:apiproducts

# delete the proxy
mvn -P ${ENV} ${ARGS} apigee-enterprise:deploy -Dapigee.options=clean

mvn -P ${ENV} ${ARGS} apigee-config:resourcefiles
mvn -P ${ENV} ${ARGS} apigee-config:targetservers

mvn -P ${ENV} ${ARGS} clean
rm -rf targetnode