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

## Overview

### Initial build and deploy to pingstatus-mint-v1
```
mvn -P test install
```

### Cloud Build all at once (TBD)
* cloud-build-local --dryrun=true --substitutions=BRANCH_NAME=local,COMMIT_SHA=none .
* cloud-build-local --dryrun=false --substitutions=BRANCH_NAME=local,COMMIT_SHA=none .

### Pipeline
```
mvn -P test clean
mvn -P test jshint:lint
mvn -P test frontend:install-node-and-npm@install-node-and-npm
mvn -P test frontend:npm@npm-install
mvn -P test frontend:npm@apigeelint
mvn -P test frontend:npm@unit
mvn -P test resources:copy-resources@copy-resources
mvn -P test replacer:replace@replace
mvn -P test apigee-enterprise:configure
mvn -P test apigee-config:targetservers
mvn -P test apigee-config:resourcefiles
./create_datacollector.sh
mvn -P test apigee-enterprise:deploy
mvn -P test apigee-config:apiproducts
# Basic
./create_rateplan_basic.sh
./create_developer_subscription_basic.sh
# Revshare
./create_rateplan_revshare.sh
./create_developer_subscription_revshare.sh
mvn -P test apigee-config:developers
./update_developer_monetization_config.sh
./create_developer_balance.sh
mvn -P test apigee-config:apps -Dapigee.app.ignoreAPIProducts=true # One set of keys
mvn -P test apigee-config:exportAppKeys
mvn -P test frontend:npm@integration
```

### Cleanup
mvn -P "$ENV" -Dskip.integration=true -Dapigee.config.options=delete -Dapigee.options=clean \
    process-resources \
    apigee-config:apps \
    apigee-config:apiproducts \
    apigee-config:developers \
    apigee-enterprise:deploy
