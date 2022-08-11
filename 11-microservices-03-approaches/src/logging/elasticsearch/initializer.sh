#!/bin/sh

# wait for staring elasticsearch
while true
do
  #status=$(curl -s -u elastic:${ADMIN_PASSWORD:-qwerty123456} elasticsearch:9200)
  status=$(curl -f -s -w %{http_code} -o /dev/null \
    -u elastic:${ADMIN_PASSWORD:-admin} elasticsearch:9200)
  echo $status
   if [ "$status" -eq 200 ]; then 
     break
   fi
  sleep 20
done

# create user ADMIN_USERNAME with ADMIN_PASSWORD
curl -X POST -s -u elastic:${ADMIN_PASSWORD:-admin} \
  elasticsearch:9200/_security/user/${ADMIN_USERNAME:-admin} \
  -H 'Content-Type: application/json' -d'
  { "password" : "'${ADMIN_PASSWORD:-admin}'",
    "roles" : [ "superuser" ],
    "enabled" : true }'

# set password for kibana_system user
curl -X POST -s -u elastic:${ADMIN_PASSWORD:-admin} \
  elasticsearch:9200/_security/user/kibana_system/_password \
  -H 'Content-Type: application/json' -d'
  { "password" : "'${ADMIN_PASSWORD:-admin}'"}'
