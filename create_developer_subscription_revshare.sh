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

curl --location --request POST https://apigee.googleapis.com/v1/organizations/"$ORG"/developers/cicd-developer-prepaid-"$ENV"@google.com/subscriptions \
-H "Authorization: Bearer $(gcloud auth print-access-token)" \
--header 'Content-Type: application/json' \
--data-raw '{
    "apiproduct": "pingstatus-mint-v1-product-revshare-'"$ENV"'"
}'

curl --location --request POST https://apigee.googleapis.com/v1/organizations/"$ORG"/developers/cicd-developer-postpaid-"$ENV"@google.com/subscriptions \
-H "Authorization: Bearer $(gcloud auth print-access-token)" \
--header 'Content-Type: application/json' \
--data-raw '{
    "apiproduct": "pingstatus-mint-v1-product-revshare-'"$ENV"'"
}'
