TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
api="http://169.254.169.254/latest/meta-data"
header="X-aws-ec2-metadata-token: $TOKEN"

ip=$(curl -s -H "${header}" ${api}/public-ipv4)


hostedZone=$( aws route53 list-hosted-zones-by-name \
  | jq '.HostedZones' \
  | jq 'map(select(.Name == "liftoff-bio.com.").Id)[]'
)


hostedZone=$(basename ${hostedZone//\"})


echo $hostedZone
# aws route53 change-resource-record-sets --hosted-zone-id ${hostedZone} --change-batch "$( cat << EOF 
# {
#     "Changes": [
#         {
#             "Action" : "UPSERT",
#             "ResourceRecordSet": {
#                 "Name": "gpu.liftoff-bio.com",
#                 "Type": "A",
#                 "TTL": 60,
#                 "ResourceRecords": [
#                     {"Value": "${ip}"}
#                 ]
#             }
#         }
#     ]
# }
# EOF
# )"