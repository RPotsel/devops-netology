#!/usr/bin/env bash

create_net(){
    echo $(yc vpc network create \
        --name net_img \
        --labels prj=netology \
        --description "Net for create image" --format yaml | grep -w id: | sed 's/id: //')
    
}
create_subnet(){
    echo $(yc vpc subnet create \
    --name subnet_img \
    --zone ru-central1-a \
    --range 10.128.0.0/24 \
    --network-name net_img \
    --labels prj=netology \
    --description "Subnet for create image" --format yaml | grep -w id: | sed 's/id: //')
}

token=$(yc config get token 2>/dev/null)
folder_id=$(yc resource-manager folder get netology --format yaml 2>/dev/null | grep -w id: | sed 's/id: //')

net_id=$(yc vpc net get --name net_img --format yaml 2>/dev/null | grep -w id: | sed 's/id: //')
subnet_id=$(yc vpc subnet get --name subnet_img --format yaml 2>/dev/null | grep -w id: | sed 's/id: //')

if [[ folder_id == '' || token == '' ]]; then 
    echo "Error get cloud!"
    exit 1
fi 

if [[ "$net_id" == '' ]]; then 
    net_id=$(create_net)
fi 
if [[ "$subnet_id" == '' ]]; then 
    subnet_id=$(create_subnet)
fi

packer build \
	-var "token=${token}" \
	-var "folder_id=${folder_id}" \
	-var "subnet_id=${subnet_id}" \
	centos-7-base.json
