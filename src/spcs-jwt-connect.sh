#!/bin/bash
#
# A sample bash implementation of getting a response from Snowpark Container Services endpoint:
# https://docs.snowflake.com/en/developer-guide/snowpark-container-services/working-with-services#public-endpoint-access-from-outside-snowflake-and-authentication
#
# # Configuration
#
# Run the script and answer the prompts
#
# - or -
# 1. Get the value for SNOWFLAKE_ACCOUNT by copying the account identifier in UI. Format: "<orgName>-<accountName>"
# 2. Get the username of the user to authenticate as, set value of SNOWFLAKE_USER. Format: "<userName>"
# 3. Get the endpoint URL by running SHOW ENDPOINTS IN SERVICE <name>. Store the URL as ENDPOINT_URL.
#
#     Format: "<hash>-<orgname>-<accountanme>.snowflakecomputing.app". Does not need "https://" part.
# 4. Set the optional ENDPOINT_PATH. Example: "/healthcheck"
# 5. Explicitly specify ROLE_WITH_ACCESS_TO_ENDPOINT -- this must be a Snowflake role with endpoint usage privilege
# 6. Set SECRET_PATH to the path of a private key with "pem" extension.
#
#     If the key was generated by `openssl genrsa 2048 | openssl pkcs8 -topk8
#     -inform PEM -out rsa_key.p8 -nocrypt`, you can just `ln -s rsa_key.p8
#     rsa_key.pem` to create a symlink.
# 7.Run the script, specifying the parameters in environment
#
# # Exit codes:
#
# * 0 on success
# * 1 on missing binaries
# * curl exit
#
set -euo pipefail # Stop on errors, undefined vars and if pipelines error
# set -x            # Log all statements for debugging

SNOWFLAKE_ACCOUNT=${SNOWFLAKE_ACCOUNT:=$(read -r -p 'Snowflake account ID: ' _TMP_VAR && echo -n "$_TMP_VAR")}
SNOWFLAKE_USER=${SNOWFLAKE_USER:=$(read -r -p 'Snowflake username: ' _TMP_VAR && echo -n "$_TMP_VAR")}
ENDPOINT_URL=${ENDPOINT_URL:=$(read -r -p "SPCS endpoint url (without https://): " _TMP_VAR && echo -n "$_TMP_VAR")}
ENDPOINT_PATH=${ENDPOINT_PATH:=$(read -r -p "Endpoint path (without '/'): " _TMP_VAR && echo -n "$_TMP_VAR")}
ROLE_WITH_ACCESS_TO_ENDPOINT=${ROLE_WITH_ACCESS_TO_ENDPOINT:=$(read -r -p "Specify role with access to endpoint: " _TMP_VAR && echo -n "$_TMP_VAR")}
SECRET_PATH=${SECRET_PATH:=$(read -r -p "Specify path to the secret key: " _TMP_VAR && echo -n "$_TMP_VAR")}

# Some general checks -- certain binaries should be available
check_bin() {
  command -v "$1" >/dev/null || (echo "$1 binary is not available, please install $2" && exit 1)
}
check_bin "curl" "curl"
check_bin "jwt" "jwt-cli"
check_bin "openssl" "openssl"
check_bin "tr" "tr"

# Source: https://docs.snowflake.com/en/user-guide/key-pair-auth#verify-the-user-s-public-key-fingerprint
KEY_SHA256="SHA256:$(openssl rsa -in "$SECRET_PATH" -pubout -outform DER 2>/dev/null | openssl dgst -sha256 -binary | openssl enc -base64)"

# This is for compatibility purposes, old bash does not do ^^
_ACCOUNT_UPPERCASE=$(echo "$SNOWFLAKE_ACCOUNT" | tr '[:lower:]' '[:upper:]') # tr should be fine here, the data should be ascii. Awk is a heavier dependency.
_USERNAME_UPPERCASE=$(echo "$SNOWFLAKE_USER" | tr '[:lower:]' '[:upper:]')

# NOTE: (jwt-tool specific) key has to have `pem` file extension
# See https://github.com/mike-engel/jwt-cli/issues/56
# If the key was generated by `openssl genrsa 2048 | openssl pkcs8 -topk8 -inform PEM -out rsa_key.p8 -nocrypt`, you can just `ln -s rsa_key.p8 rsa_key.pem`
# NOTE: issuer -> account needs to be uppercase
# NOTE: issuer -> account does not seem to care about "_" vs "-"
# NOTE: issuer -> username needs to be uppercase
# NOTE: sub -> account needs to be uppercase
# NOTE: sub -> account does not seem to care about "_" vs "-"
# NOTE: sub -> username does not seem to care about uppercase vs lowercase
JWT=$(
  jwt encode \
    --alg RS256 \
    --secret @"$SECRET_PATH" \
    --iss "${_ACCOUNT_UPPERCASE}.${_USERNAME_UPPERCASE}.$KEY_SHA256" \
    --sub "${_ACCOUNT_UPPERCASE}.${SNOWFLAKE_USER}" \
    --exp=$((now = $(date +"%s"), now + 30)) # Make a short-lived token
)

# Exchange the JWT for access token
# NOTE: URL _does_ care about "_" vs "-"
TOKEN=$(curl --location "https://${SNOWFLAKE_ACCOUNT//_/-}.snowflakecomputing.com/oauth/token" \
  --header 'Content-Type: application/x-www-form-urlencoded' \
  --fail `# Fail on error` \
  -s `# just the request body` \
  --data-urlencode 'grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer' \
  --data-urlencode "scope=session:role:$ROLE_WITH_ACCESS_TO_ENDPOINT $ENDPOINT_URL" \
  --data-urlencode "assertion=$JWT")

# Get the SPCS endpoint
curl --location "https://$ENDPOINT_URL/${ENDPOINT_PATH}" \
  --header "Authorization: Snowflake Token=\"${TOKEN}\"" \
  --header 'Content-Type: application/x-www-form-urlencoded'
# Uncomment this to discard the body of the response and just get the http code
# -s -o /dev/null `# show only http code`\
# -w "%{http_code}"
