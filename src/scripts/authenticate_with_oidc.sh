#!/bin/bash

set +e

organisation=$(eval echo "\$$CLOUDSMITH_ORGANISATION_ENV_VAR")
service_account=$(eval echo "\$$CLOUDSMITH_SERVICE_ACCOUNT_ENV_VAR")

if [ -z "$organisation" ]
then
  echo "Unable to generate OIDC token. Environment variable $CLOUDSMITH_ORGANISATION_ENV_VAR is not set."
  exit 1
fi

if [ -z "$service_account" ]
then
  echo "Unable to generate OIDC token. Environment variable $CLOUDSMITH_SERVICE_ACCOUNT_ENV_VAR is not set."
  exit 1
fi

echo "Generating Cloudsmith OIDC token for service account ..."

RESPONSE=$(curl -X POST -H "Content-Type: application/json" \
            -d "{\"oidc_token\":\"$CIRCLE_OIDC_TOKEN_V2\", \"service_slug\":\"$service_account\"}" \
            --silent --show-error "https://api.cloudsmith.io/openid/$organisation/")

CLOUDSMITH_OIDC_TOKEN=$(echo "$RESPONSE" | grep -o '"token":"[^"]*' | grep -o '[^"]*$')

if [ -z "$CLOUDSMITH_OIDC_TOKEN" ]
then
  echo "Unable to generate OIDC token."
  echo "Response from Cloudsmith OIDC endpoint was: "
  echo "$RESPONSE"
  exit 1
else
  echo "export CLOUDSMITH_OIDC_TOKEN=\"$CLOUDSMITH_OIDC_TOKEN\"" >> "$BASH_ENV"

  echo "Successfully generated OIDC token."
  echo ""
  echo "The following environment variable has been exported. The OIDC token value has been masked."
  echo ""
  echo "CLOUDSMITH_OIDC_TOKEN=********"
fi
