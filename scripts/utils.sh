#!/bin/bash

get_access_token() {
    host=$1
    client_id=$2
    client_secret=$3

    access_req=$(     \
        curl -s -X POST ${host}/acm-iam/oauth/token     \
        -F client_id=${client_id}                       \
        -F client_secret=${client_secret}               \
        -F grant_type=client_credentials                \
    )

    access_token=$(echo ${access_req} | jq -r .access_token)
    if [ "${access_token}" == "null" ]; then
        >&2 echo "failed to get access token"
        >&2 echo ${access_req}
        return 1
    fi

    echo ${access_token}
    return 0
}

create_project() {
    host=$1
    access_token=$2
    deploy_name=$3
    deploy_ver=$4
    deploy_desc=$5
    image_url=$6

    echo "perform create: $3, $4, $6"

    cat > deploy_data1.json << EOF
{
    "input": {
        "name": "${deploy_name}",
        "version": "${deploy_ver}",
        "description": "${deploy_desc}",
        "imageUrl": "${image_url}"
    },
    "bundleIcon": "https://media.istockphoto.com/vectors/microservices-icon-vector-vector-id1136809649"
}
EOF

    create_result=$(    \
        curl -s -X POST ${host}/acm-cnab/v1/onestep            \
        -H 'Content-Type: application/json;charset=UTF-8'   \
        -H "Authorization: Bearer ${access_token}"          \
        -d $(jq . -c deploy_data1.json)                      \
    )

    echo ${create_result} | jq .

    error=$(echo ${create_result} | jq -r .error)
    if [ "${error}" != "null" ]; then
        echo "Error create project"
        return 1
    fi

    return 0
}

deploy_project() {
    host=$1
    access_token=$2
    team_sn=$3
    project=$4
    cluster_id=$5
    bundle=$6


    echo "perform deploy: $3, $4, $5, $6"

    cat > deploy_data2.json << EOF
{
    "teamSN": ${team_sn},
    "project": "${project}",
    "clusterId": "${cluster_id}",
    "deployItemList": [
        {"deployBundle": "${bundle}"}
    ]
}
EOF

    deploy_result=$(\
        curl -s -X PUT ${host}/acm-cnab/v1/continuous/deployment/           \
        -H 'Content-Type: application/json;charset=UTF-8'   \
        -H "Authorization: Bearer ${access_token}"          \
        -d $(jq . -c deploy_data2.json)                      \
    )

    echo ${deploy_result} | jq .

    error=$(echo ${deploy_result} | jq -r .error)
    if [ "${error}" != "null" ]; then
        echo "Error create project"
        return 1
    fi

    return 0
}


