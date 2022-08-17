#!/bin/bash
set -e

client_id=${ACM_CLIENT_ID}
client_secret=${ACM_CLIENT_SECRET}
deploy_ver=${DEPLOY_VER}
image_url=${IMAGE_URL}

deploy_name="simple-web"
deploy_desc="test"

host="https://hks.hicloud.hinet.net/api"

. $(dirname "$0")/utils.sh

echo "Get access token"
access_token=$(get_access_token "${host}" "${client_id}" "${client_secret}")


echo "Create project"
create_project "${host}" "${access_token}" \
    "${deploy_name}" "${deploy_ver}" "${deploy_desc}" "${image_url}"

echo "Deploy project"
deploy_project "${host}" "${access_token}" \
    "98" "jeffzhang2" "vh550226100001" "${deploy_name}:${deploy_ver}"

