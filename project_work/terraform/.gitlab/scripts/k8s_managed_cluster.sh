#!/bin/bash

exit_code=0
TERR_ARGS="--terragrunt-non-interactive --terragrunt-exclude-dir future_feature/* run-all"

get_iam_token() {
    stage "Get Tokens from Vault"
    export YC_OAUTH_TOKEN=$(python3 .gitlab/scripts/vault_loader.py \
      -a "${VAULT_ADDR}" \
      -r infrastructure_terraform \
      -v "tokens/data/yandex-cloud:oauth")
    export AWS_ACCESS_KEY_ID=$(python3 .gitlab/scripts/vault_loader.py \
      -a "${VAULT_ADDR}" \
      -r infrastructure_terraform \
      -v "tokens/data/yandex-cloud:AWS_ACCESS_KEY_ID")
    export AWS_SECRET_ACCESS_KEY=$(python3 .gitlab/scripts/vault_loader.py \
      -a "${VAULT_ADDR}" \
      -r infrastructure_terraform \
      -v "tokens/data/yandex-cloud:AWS_SECRET_ACCESS_KEY")  
    export YC_IAM_TOKEN=$(curl -d "{\"yandexPassportOauthToken\":\"${YC_OAUTH_TOKEN}\"}" \
      "https://iam.api.cloud.yandex.net/iam/v1/tokens" | jq -r '.iamToken')  
}

stage() {
    stage_name=$1
    curr_date=`date +"%s"`
    prev_date=$curr_date
    echo "$curr_date,$stage_name"
    echo ================================================================================
    echo "=> "`date --date="@$curr_date"`
    echo "=> $stage_name"
}

stage "start"
get_iam_token

case $1 in
    apply )
        stage "apply"
        terragrunt ${TERR_ARGS} apply || exit_code=$?
            ;;
    destroy )
        stage "destroy"
        terragrunt ${TERR_ARGS} destroy || exit_code=$?
            ;;
    plan )
        stage "plan"
        terragrunt ${TERR_ARGS} plan || exit_code=$?
            ;;
esac  

stage "stop"
stage "echo terragrunt status"
echo "=> " "${exit_code}"
exit "${exit_code}"
