#!/usr/bin/env bash

image_id=$(yc compute image get centos-7-base --format yaml 2>/dev/null | grep -w id: | sed 's/id: //')

terraform apply -auto-approve -var "centos-7-base=${image_id}"
