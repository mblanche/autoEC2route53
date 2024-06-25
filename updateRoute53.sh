#!/usr/bin/env bash

TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
api="http://169.254.169.254/latest/meta-data"
header="X-aws-ec2-metadata-token: $TOKEN"

instance_id=$(curl -s -H "${header}" ${api}/instance-id)
az=$(curl -s -H "${header}" ${api}/placement/availability-zone)

## Make sure to enable tags on instance
resp=$(aws ec2 modify-instance-metadata-options \
    --region ${az::-1} \
    --instance-id ${instance_id} \
    --instance-metadata-tags enabled)

## Could make sure that resp has been executed...

ip=$(curl -s -H "${header}" ${api}/public-ipv4)
domain_name=$(curl -s -H "${header}" ${api}/tags/instance/domain_name)
host_name=$(curl -s -H "${header}" ${api}/tags/instance/host_name)

hostedZone=$( aws route53 list-hosted-zones-by-name \
  | jq '.HostedZones' \
  | jq 'map(select(.Name == "'${domain_name}'.").Id)[]'
)
hostedZone=$(basename ${hostedZone//\"})


aws route53 change-resource-record-sets --hosted-zone-id ${hostedZone} --change-batch \
"{
    \"Changes\": [
        {
            \"Action\" : \"UPSERT\",
            \"ResourceRecordSet\": {
                \"Name\": \"${host_name}.${domain_name}\",
                \"Type\": \"A\",
                \"TTL\": 60,
                \"ResourceRecords\": [
                    {\"Value\": \"${ip}\"}
                ]
            }
        }
    ]
}"