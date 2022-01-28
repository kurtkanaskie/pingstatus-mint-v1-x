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

curl --location --request POST https://apigee.googleapis.com/v1/organizations/"$ORG"/apiproducts/pingstatus-mint-v1-product-basic-"$ENV"/rateplans \
-H "Authorization: Bearer $(gcloud auth print-access-token)" \
--header 'Content-Type: application/json' \
--data-raw '{
    "apiproduct": "pingstatus-mint-v1-product-basic-'"$ENV"'",
    "displayName": "pingstatus-mint-v1-rateplan-basic-'"$ENV"'",
    "description": "Setup fee of $10, recurring monthly",
    "billingPeriod": "MONTHLY",
    "currencyCode": "USD",
    "setupFee": {
        "currencyCode": "USD",
        "units": 10
    },
    "fixedRecurringFee": {
        "units": 5
    },
    "fixedFeeFrequency": 30,
    "consumptionPricingType": "BANDED",
    "consumptionPricingRates": [
        {
            "end": "10",
            "fee": {
                "currencyCode": "USD"
            }
        },
        {
            "start": "11",
            "end": "20",
            "fee": {
                "currencyCode": "USD",
                "nanos": 50000000
            }
        },
        {
            "start": "21",
            "fee": {
                "currencyCode": "USD",
                "nanos": 10000000
            }
        }
    ],
    "state": "PUBLISHED",
    "startTime": "1641509016273"
}'
