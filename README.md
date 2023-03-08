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

Set your environment variables in `set_env_variales.sh` and `source set_env_variales.sh`:
```
export ORG=your_org_name
export ENV=your_env_name
export API=your.northbound.hostname
export SA_USER=cicd-test-service-account@${ORG}.iam.gserviceaccount.com
export SA_CREDS=/path/to/your/sa/keyfile.json
export PORTAL_URL=admin_username
export PORTAL_USERNAME=admin_username
export PORTAL_PASSWORD=admin_password
export ARGS="-Dapigee.org=$ORG \
    -Dapigee.env=$ENV \
    -Dapi.northbound.domain=$API \
    -Dapigee.username=$SA_USER \
    -Dapigee.serviceaccount.file=$SA_CREDS \
    -Dportal.url=$DRUPAL_PORTAL_URL \
    -Dportal.username=$PORTAL_USERNAME \
    -Dportal.password=$PORTAL_PASSWORD"
```

Or update each pom.xml profile to reflect your specifics (e.g. org, env, hostname, SA credentials).

## Initial build and deployment
All at once
```
./pipeline.sh
```

### Individual Pipeline Steps
```
mvn -P ${ENV} ${ARGS} clean
mvn -P ${ENV} ${ARGS} jshint:lint
mvn -P ${ENV} ${ARGS} frontend:install-node-and-npm@install-node-and-npm
mvn -P ${ENV} ${ARGS} frontend:npm@npm-install
mvn -P ${ENV} ${ARGS} frontend:npm@apigeelint
mvn -P ${ENV} ${ARGS} frontend:npm@unit
mvn -P ${ENV} ${ARGS} resources:copy-resources@copy-resources
mvn -P ${ENV} ${ARGS} replacer:replace@replace
mvn -P ${ENV} ${ARGS} apigee-config:targetservers
mvn -P ${ENV} ${ARGS} apigee-config:resourcefiles

# System.uuid for analytics not needed for Monetization, used for debugging.
./create_datacollector.sh

mvn -P ${ENV} ${ARGS} apigee-enterprise:configure
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
```

### Re-run integration tests
```
mvn -P ${ENV} ${ARGS} resources:copy-resources@copy-resources replacer:replace@replace apigee-config:resourcefiles apigee-config:exportAppKeys frontend:npm@integration
```

## Drupal
Enable modules JSON:API and HTTP Basic Authentication.

Add taxonomy elements: /admin/structure/taxonomy

The tool processes all files with `.yaml` or `.json` in the `portal.directory` as Open API Specifications. Putting other files with those suffices will cause errors.

Use username not email for admin, e.g. maintenance

### Just update the API Specs in Drupal
```
mvn -P ${ENV} ${ARGS} clean resources:copy-resources replacer:replace apigee-smartdocs:apidoc
```

### Cleanup (NOT TESTED)
```
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
mvn -P ${ENV} ${ARGS} apigee-config:developers -Dapigee.config.options=delete
mvn -P ${ENV} ${ARGS} apigee-config:apiproducts -Dapigee.config.options=delete

# delete the proxy
mvn -P ${ENV} ${ARGS} apigee-enterprise:deploy -Dapigee.options=clean

mvn -P ${ENV} ${ARGS} apigee-config:resourcefiles -Dapigee.config.options=delete
mvn -P ${ENV} ${ARGS} apigee-config:targetservers -Dapigee.config.options=delete

mvn -P ${ENV} ${ARGS} clean
rm -rf targetnode
```
## TODO
1. Generate load and show analytics.\
For example:
```
export NUM_CALLS=100
export CONCURRENT_CLIENTS=10
export API_HOSTNAME=your-hostname
export KEY=your-app-key
hey -n $NUM_CALLS -c $CONCURRENT_CLIENTS -m GET -H x-apikey:$KEY https://$API_HOSTNAME/pingstatus-mint/v1/ping
hey -n $NUM_CALLS -c $CONCURRENT_CLIENTS -m GET -H x-apikey:$KEY https://$API_HOSTNAME/pingstatus-mint/v1/status
```
2. Test cleanup
