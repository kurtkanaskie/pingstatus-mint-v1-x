# Free, Ping and Status API with Monetization

This simple proxy demonstrates the use of Monetization in Apigee X.
It shows how to control which operations are monetized and how to use the rate multiplier. It also shows how to use revenue share.\
It has three operations.
* GET /free - response that is not monetized
* GET /ping - response indicates that the proxy is operational (single charge)
* GET /status - response indicates the the backend is operational (double charge)

It creates demo resources for developers (prepaid, postpaid), apps, API products and rate plans.

## Disclaimer

This example is not an official Google product, nor is it part of an official Google product.

## License

This material is copyright 2019, Google LLC. and is licensed under the Apache 2.0 license.
See the [LICENSE](LICENSE) file included.

This code is open source.

## Prerequisites
[Monetization must be purchased and enabled](https://cloud.google.com/apigee/docs/api-platform/monetization/enable) in the organization.

Set Environment Variables
```
ORG=your_org_name
ENV=your_env_name
```

## Initial build and deployment
All at once
```
./pipeline.sh
```

### Individual Pipeline Steps
```
mvn -P test clean
mvn -P test jshint:lint
mvn -P test frontend:install-node-and-npm@install-node-and-npm
mvn -P test frontend:npm@npm-install
mvn -P test frontend:npm@apigeelint
mvn -P test frontend:npm@unit
mvn -P test resources:copy-resources@copy-resources
mvn -P test replacer:replace@replace
mvn -P test apigee-config:targetservers
mvn -P test apigee-config:resourcefiles

# System.uuid for analytics not needed for Monetization, used for debugging.
./create_datacollector.sh

mvn -P test apigee-enterprise:configure
mvn -P test apigee-enterprise:deploy
mvn -P test apigee-config:apiproducts

# Rate Plans
./create_rateplan_basic.sh
./create_rateplan_revshare.sh

mvn -P test apigee-config:developers

# Prepaid and Postpaid developers
./update_developer_monetization_config.sh

# Prepaid developer balance
./create_developer_balance.sh

# Subscriptions Prepaid and Postpaid
./create_developer_subscription_basic.sh
./create_developer_subscription_revshare.sh

mvn -P test apigee-config:apps
mvn -P test apigee-config:exportAppKeys
mvn -P test frontend:npm@integration
```

### Re-run integration tests
```
mvn -P test resources:copy-resources@copy-resources replacer:replace@replace apigee-config:resourcefiles apigee-config:exportAppKeys frontend:npm@integration
```

### Cleanup (NOT TESTED)
```
mvn -P test -Dskip.integration=true -Dapigee.config.options=delete -Dapigee.options=clean \
    process-resources \
    apigee-config:apps \
    apigee-config:apiproducts \
    apigee-config:developers \
    apigee-enterprise:deploy

mvn -P test clean
mvn -P test resources:copy-resources@copy-resources
mvn -P test replacer:replace@replace
mvn -P test apigee-config:apps -Dapigee.config.options=delete
mvn -P test apigee-config:developers -Dapigee.config.options=delete
mvn -P test apigee-config:apiproducts -Dapigee.config.options=delete

# delete the proxy
mvn -P test apigee-enterprise:deploy -Dapigee.options=clean

mvn -P test apigee-config:resourcefiles -Dapigee.config.options=delete
mvn -P test apigee-config:targetservers -Dapigee.config.options=delete

mvn -P test clean
rm -rf targetnode
```
## TODO
1. Generate load and show analytics
2. Install Spec to drupal portal
```
mvn -P test" apigee-smartdocs:apidoc -Dapigee.smartdocs.config.options=create -Dpusername=from-marketplace -Dppassword=from-marketplace
```
3. Test cleanup
