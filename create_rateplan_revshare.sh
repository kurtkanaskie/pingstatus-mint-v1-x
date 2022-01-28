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

curl --location --request POST https://apigee.googleapis.com/v1/organizations/"$ORG"/apiproducts/pingstatus-mint-v1-product-revshare-"$ENV"/rateplans \
-H "Authorization: Bearer $(gcloud auth print-access-token)" \
--header 'Content-Type: application/json' \
--data-raw '{
    "apiproduct": "pingstatus-mint-v1-product-revshare-'"$ENV"'",
    "displayName": "pingstatus-mint-v1-rateplan-revshare-'"$ENV"'",
    "description": "Setup fee of $20, recurring $10 monthly",
    "billingPeriod": "MONTHLY",
    "currencyCode": "USD",
    "setupFee": {
        "currencyCode": "USD",
        "units": 20
    },
    "fixedRecurringFee": {
        "units": 10
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
            "end": "100",
            "fee": {
                "currencyCode": "USD",
                "nanos": 100000000
            }
        },
        {
            "start": "101",
            "fee": {
                "currencyCode": "USD",
                "nanos": 50000000
            }
        }
    ],
    "revenueShareType": "FIXED",
    "revenueShareRates": [
        {
            "sharePercentage": 10
        }
    ],
    "state": "PUBLISHED",
    "startTime": "1641509016273"
}'
