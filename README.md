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
mvn -P apigeex-mint-kurt-test install
```

### Cloud Build all at once
* cloud-build-local --dryrun=true --substitutions=BRANCH_NAME=local,COMMIT_SHA=none .
* cloud-build-local --dryrun=false --substitutions=BRANCH_NAME=local,COMMIT_SHA=none .

## Other commands for iterations

### Full install and test, but skip cleaning target
* mvn -P test install -Dskip.clean=true

### Skip clean and export - just install, deploy and test
* mvn -P test install -Dskip.clean=true -Dskip.export=true -Dapigee.config.options=none -Dapi.testtag=@health

### Just update Developers, Products and Apps
* mvn -P test process-resources apigee-config:developers apigee-config:apiproducts apigee-config:apps apigee-config:exportAppKeys -Dskip.clean=true

### Just update resource files
* mvn -P test process-resources apigee-config:resourcefiles -Dskip.clean=true

### Just update Target Servers
* mvn -P test process-resources apigee-config:targetservers -Dskip.clean=true

### Export App keys
* mvn -P test apigee-config:exportAppKeys -Dskip.clean=true

### Export Apps and run the tests (after skip.clean)
* mvn -P test process-resources apigee-config:exportAppKeys frontend:npm@integration -Dskip.clean=true -Dapi.testtag=@get-ping

### Just run the tests (after skip.clean) - for test iterations
* mvn -P test process-resources -Dskip.clean=true frontend:npm@integration -Dapi.testtag=@health

### Skip Creating Apps and Overwrite latest revision
* mvn -P test install -Dskip.apps=true -Dapigee.config.dir=target/resources/edge -Dapi.testtag=@health

### Just update the API Specs in Drupal
* mvn -P test process-resources apigee-smartdocs:apidoc -Dapigee.smartdocs.config.options=update

### Just update the Integrated Portal API Specs
Via process-resources after replacements
* mvn -P test process-resources apigee-config:specs -Dskip.clean=true

Via the source without replacements
* mvn -P test -Dapigee.config.options=update apigee-config:specs -Dapigee.config.dir=resources/edge

### Other discrete commands
* mvn -Ptest validate (runs all validate phases: lint, apigeelint, unit)
* mvn jshint:lint
* mvn -Ptest frontend:npm@apigeelint
* mvn -Ptest frontend:npm@unit
* mvn -Ptest frontend:npm@integration
