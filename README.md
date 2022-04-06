# Ping and Status API with Monetization

This proxy demonstrates a simple design to demonstrate a full CI/CD lifecycle.
It uses the following health check or monitoring endpoints
* GET /free - response that is not monetized
* GET /ping - response indicates that the proxy is operational
* GET /status - response indicates the the backend is operational

These endpoints can then be used by API Monitorying with Edge to send notifications when something is wrong.

## Disclaimer

This example is not an official Google product, nor is it part of an official Google product.

## License

This material is copyright 2019, Google LLC. and is licensed under the Apache 2.0 license.
See the [LICENSE](LICENSE) file included.

This code is open source.

## Prerequisites
[Monetization must be purchased and enabled](https://cloud.google.com/apigee/docs/api-platform/monetization/enable) in the organization.

### Set Environment Variables
ORG=your_org_name
ENV=your_env_name

## Overview

**NOTE:** THIS IS WIP

This hasn't been tested end-to-end in a clean org.

The Monetization resources should be created following the pipeline below.

### Initial build and deploy of pingstatus-mint-v1
This won't run completely until the Monetization resources have been created,
but can be used to iterate the proxy design.
```
mvn -P test install
```

### Pipeline (NOT TESTED IN CLEAN ORG - NOR IS IT IDEMPOTENT)
```
mvn -P "$ENV" clean
mvn -P "$ENV" jshint:lint
mvn -P "$ENV" frontend:install-node-and-npm@install-node-and-npm
mvn -P "$ENV" frontend:npm@npm-install
mvn -P "$ENV" frontend:npm@apigeelint
mvn -P "$ENV" frontend:npm@unit
mvn -P "$ENV" resources:copy-resources@copy-resources
mvn -P "$ENV" replacer:replace@replace
mvn -P "$ENV" apigee-config:targetservers
mvn -P "$ENV" apigee-config:resourcefiles

# System.uuid for analytics not needed for Monetization, used for debugging.
./create_datacollector.sh

mvn -P "$ENV" apigee-enterprise:configure
mvn -P "$ENV" apigee-enterprise:deploy
mvn -P "$ENV" apigee-config:apiproducts

# Rate Plans
./create_rateplan_basic.sh
./create_rateplan_revshare.sh

mvn -P "$ENV" apigee-config:developers

# Prepaid and Postpaid developers
./update_developer_monetization_config.sh

# Prepaid developer balance
./create_developer_balance.sh

# Subscriptions Prepaid and Postpaid
./create_developer_subscription_basic.sh
./create_developer_subscription_revshare.sh

mvn -P "$ENV" apigee-config:apps
mvn -P "$ENV" apigee-config:exportAppKeys
mvn -P "$ENV" frontend:npm@integration

mvn -P "$ENV" apigee-smartdocs:apidoc -Dapigee.smartdocs.config.options=create -Dpusername=from-marketplace -Dppassword=from-marketplace
```

### Re-run integration tests
```
mvn -P $ENV resources:copy-resources@copy-resources replacer:replace@replace apigee-config:resourcefiles apigee-config:exportAppKeys frontend:npm@integration
```

### Cleanup (NOT TESTED)
```
mvn -P "$ENV" -Dskip.integration=true -Dapigee.config.options=delete -Dapigee.options=clean \
    process-resources \
    apigee-config:apps \
    apigee-config:apiproducts \
    apigee-config:developers \
    apigee-enterprise:deploy

mvn -P "$ENV" clean
mvn -P "$ENV" resources:copy-resources@copy-resources
mvn -P "$ENV" replacer:replace@replace
mvn -P "$ENV" apigee-config:apps -Dapigee.config.options=delete
mvn -P "$ENV" apigee-config:developers
mvn -P "$ENV" apigee-config:apiproducts

# delete the proxy
mvn -P "$ENV" apigee-enterprise:deploy -Dapigee.options=clean

mvn -P "$ENV" apigee-config:resourcefiles
mvn -P "$ENV" apigee-config:targetservers

mvn -P "$ENV" clean
rm -rf targetnode
```

