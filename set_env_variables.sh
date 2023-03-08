#! /bin/bash

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
    