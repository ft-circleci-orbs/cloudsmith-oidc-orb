#!/bin/bash

# shellcheck disable=SC2296

set +e

if [ -z "${<<parameters.organisation>>}" ]
then
  echo "Unable to generate OIDC token. Environment variable CLOUDSMITH_ORGANISATION is not set."
  exit 1
fi

if [ -z "${<<parameters.service_accoun>>}" ]
then
  echo "Unable to generate OIDC token. Environment variable CLOUDSMITH_SERVICE_ACCOUNT is not set."
  exit 1
fi

echo "Generating Cloudsmith OIDC token for service account: ${<<parameters.organisation>>}/${<<parameters.service_account>>}"

RESPONSE=$(curl -X POST -H "Content-Type: application/json" \
            -d "{\"oidc_token\":\"$CIRCLE_OIDC_TOKEN_V2\", \"service_slug\":\"${<<parameters.organisation>>}\"}" \
            --silent --show-error "https://api.cloudsmith.io/openid/${<<parameters.service_account>>}/")

CLOUDSMITH_OIDC_TOKEN=$(echo "$RESPONSE" | grep -o '"token": "[^"]*' | grep -o '[^"]*$')

if [ -z "$CLOUDSMITH_OIDC_TOKEN" ]
then
  echo "Unable to generate OIDC token."
  echo "Response from Cloudsmith OIDC endpoint was: "
  echo "$RESPONSE"
  exit 1
else
  echo "Successfully generated OIDC token."
  echo ""

  echo "export CLOUDSMITH_OIDC_TOKEN=\"$CLOUDSMITH_OIDC_TOKEN\"" >> "$BASH_ENV"

  echo "The following environment variables have been exported. The OIDC token has been masked below."
  echo ""
  echo "CLOUDSMITH_OIDC_TOKEN=********"
fi
