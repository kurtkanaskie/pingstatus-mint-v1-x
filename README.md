# Free, Ping and Status APIs with Monetization

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

or
export ARGS="-Dapigee.org=$ORG \
    -Dapigee.env=$ENV \
    -Dapi.northbound.domain=$API \
    -Dbearer=$(gcloud auth print-access-token) \
    -Dportal.url=$DRUPAL_PORTAL_URL \
    -Dportal.username=$PORTAL_USERNAME \
    -Dportal.password=$PORTAL_PASSWORD"
```

Or update each pom.xml profile to reflect your specifics (e.g. org, env, hostname, SA credentials).

## Proxy Design
### PreFlow
Since we want to control which flows are charged and set other monetization values per flow, the **PreFlow** in the proxy merely verifies the API key and gets some configuration values.

![Pre Flow](./images/pre-flow.png)
### Free Conditional Flow
The `/free` conditional flow enforces quota based on the API Product on the request and counts quota on a successful response. The AssignMessage **AM-monetization-free** sets a variable, in this case a header, to hold the value `false` for the Monetization Success value.
```
    <AssignVariable>
        <Name>response.header.X-Monetization-Success</Name>
        <Value>false</Value>
    </AssignVariable>
```
![Free Flow](./images/free-flow.png)

### Charged Conditional Flows
Each of the conditional flows follow a similar pattern of enforcing quota, enforcing monetization limits, counting quota on successful response and setting values for:
- Monetization Success
- Rate Multiplier
- Revenue Share Gross Price
- Currency

#### Ping Conditional Flow
The `/ping` flow charges one for each call.
![Ping Flow](./images/ping-flow.png)

#### Status Conditional Flow
The `/status` flow charges two for each call.
![Status Flow](./images/status-flow.png)

### PostFlow
The **PostFlow** response uses the DataCapture policy to set the special Monetization values from the variables set in each flow, headers in this example, but they could be flow variables.
```
<DataCapture name="DC-monetization" continueOnError="false" enabled="true">
    <IgnoreUnresolvedVariables>true</IgnoreUnresolvedVariables>
    <Capture>
        <Collect ref="response.header.x-monetization-currency" default="USD"/>
        <DataCollector scope="monetization">currency</DataCollector>
    </Capture>
    <Capture>
        <Collect ref="response.header.x-monetization-success" default="false"/>
        <DataCollector scope="monetization">transactionSuccess</DataCollector>
    </Capture>
    <Capture>
        <Collect ref="response.header.x-monetization-multiplier" default="1"/>
        <DataCollector scope="monetization">perUnitPriceMultiplier</DataCollector>
    </Capture>
    <Capture>
        <Collect ref="response.header.x-monetization-revenue-share" default="0"/>
        <DataCollector scope="monetization">revShareGrossPrice</DataCollector>
    </Capture>
</DataCapture>
```
![Post Flow](./images/post-flow.png)


## Initial build and deployment
### Pipeline
All at once
```
./pipeline.sh
```

### Maven all at once
Only for proxy and maven configuration items, using Service Account.
```
mvn -P test install
```

Only for proxy and maven configuration items, using Bearer token.
```
mvn -P test install -Dbearer=$(gcloud auth print-access-token)
```

### Cloud Build all at once
Only for proxy and maven configuration items.
```
cloud-build-local --dryrun=true --config=cloudbuild-test.yaml --substitutions=BRANCH_NAME=local-gcloud,COMMIT_SHA=none .
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

### Just run the tests (after skip.clean) - for test iterations or un failure
* mvn -P test resources:copy-resources replacer:replace frontend:npm@integration -Dapi.testtag=@cors
* npm run integration
* npm run integration -- --tags @get-status
* npm run integration -- --tags @cors


## Drupal
Enable modules JSON:API and HTTP Basic Authentication.

Add taxonomy elements: /admin/structure/taxonomy

The tool processes all files with `.yaml` or `.json` in the `portal.directory` as Open API Specifications. Putting other files with those suffices will cause errors.

Use username not email for admin, e.g. maintenance

### Just update the API Specs in Drupal
```
mvn -P ${ENV} ${ARGS} clean resources:copy-resources replacer:replace apigee-smartdocs:apidoc
```

## Clean Up (NOT TESTED)
All at once
```
./cleanup.sh
```

### Individual Clean Up Steps
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
