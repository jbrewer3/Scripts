#!/bin/bash
# # This script should be sourced and not run as a shell script as it is setting environment variables
# # To run `. ./aws_login.sh <aws_access_key> <aws_secret_access_key> <aws_default_region> <aws_account_number> <aws_iam_role> <aws_username>`
# # This will give you a one hour session in the account of choice
# # It's recommended to create an alias to run this script vs manually entering the inputs each time

unset AWS_SESSION_TOKEN AWS_SECRET_ACCESS_KEY AWS_ACCESS_KEY_ID AWS_DEFAULT_REGION AWS_ACCOUNT_NUMBER AWS_USERNAME AWS_IAM_ROLE

export AWS_ACCESS_KEY_ID="$1"
export AWS_SECRET_ACCESS_KEY="$2"
export AWS_ACCOUNT_NUMBER="$3"
export AWS_USERNAME="$4"
export AWS_DEFAULT_REGION="us-east-2"

echo "THIS IS THE CALLER IDENTITY FOR: ${AWS_USERNAME}"
echo $(aws sts get-caller-identity) |jq .
echo "============="
if [ -n "$ZSH_VERSION" ]; then
    printf "%s" "Please enter MFA token: "
    read TOKEN
else
    read -p 'Please enter MFA token: ' token
fi

echo "============="
cred="$(aws sts get-session-token --duration 14400 --serial-number arn:aws:iam::730071141898:mfa/myiphone-mfa --token-code "$TOKEN")"
echo "ASSUMED SESSION INFORMATION:"

echo "$cred" | jq .

echo "============"
export AWS_ACCESS_KEY_ID=$(echo $cred | jq .Credentials.AccessKeyId | xargs)
export AWS_SECRET_ACCESS_KEY=$(echo $cred | jq .Credentials.SecretAccessKey | xargs)
export AWS_SESSION_TOKEN=$(echo $cred | jq .Credentials.SessionToken | xargs)
echo $(aws sts get-caller-identity)|jq .
