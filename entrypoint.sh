#!/bin/sh
set -o errexit
set -o nounset

export PLANTON_CLOUD_SERVICE_CLI_ENV=${1}
export PLANTON_CLOUD_SERVICE_CLIENT_ID=${2}
export PLANTON_CLOUD_SERVICE_CLIENT_SECRET=${3}
export PLANTON_CLOUD_ARTIFACT_STORE_ID=${4}

if ! [ -n "${PLANTON_CLOUD_SERVICE_CLIENT_ID}" ]; then
  echo "PLANTON_CLOUD_SERVICE_CLIENT_ID is not set. Configure Machine Account Credentials for Repository or Organization."
  exit 1
fi
if ! [ -n "${PLANTON_CLOUD_SERVICE_CLIENT_SECRET}" ]; then
  echo "PLANTON_CLOUD_SERVICE_CLIENT_SECRET is not set. Configure Machine Account Credentials for Repository or Organization."
  exit 1
fi
if ! [ -n "${PLANTON_CLOUD_ARTIFACT_STORE_ID}" ]; then
  echo "PLANTON_CLOUD_ARTIFACT_STORE_ID is required. It should be set to the id of the artifact-store on planton cloud"
  exit 1
fi

#!/bin/bash
set -o errexit
set -o nounset

echo "exchanging planton-cloud machine-account credentials to get an access token"
planton auth machine login \
  --client-id $PLANTON_CLOUD_SERVICE_CLIENT_ID \
  --client-secret $PLANTON_CLOUD_SERVICE_CLIENT_SECRET
echo "successfully exchanged planton-cloud machine-account credentials and received an access token"
mkdir -p /root/.ssh
touch /root/.ssh/id_rsa
echo "fetching git ssh key from planton cloud service"
planton product artifact-store secrets get-git-ssh-key \
  --output-file /root/.ssh/id_rsa --artifact-store-id $PLANTON_CLOUD_ARTIFACT_STORE_ID
echo "fetched git ssh key from planton cloud service"
echo "setting up gitconfig"
cat <<EOT >>/root/.gitconfig
[url "git@gitlab.com:"]
    insteadOf = https://gitlab.com/
EOT
mkdir -p /root/.ssh
echo "StrictHostKeyChecking no " >/root/.ssh/config
chmod 400 /root/.ssh/id_rsa
echo "completed setting up gitconfig"
cat /root/.gitconfig
echo "running make build"
make build
