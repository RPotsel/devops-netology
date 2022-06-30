#!/usr/bin/env bash

set -e

create_network(){
    yc vpc network create \
        --name net \
        --labels prj=netology \
        --description "netology homework net"
    yc vpc subnet create \
        --name subnet \
        --zone ru-central1-a \
        --range 10.1.2.0/24 \
        --network-name net \
        --labels prj=netology \
        --description "netology homework subnet"
}

create_from_docker-compose(){
    yc compute instance create-with-container \
        --name teamcity \
        --cores 6 \
        --platform "standard-v1" \
        --core-fraction 100 \
        --memory 6GB \
        --zone ru-central1-a \
        --ssh-key ~/.ssh/id_rsa.pub \
        --network-interface subnet-name=subnet,nat-ip-version=ipv4 \
        --docker-compose-file docker-compose.yml
        #--service-account-name default-sa
}

create_instances(){
    # create main teamcity
    yc compute instance create-with-container \
        --name teamcity \
        --zone ru-central1-a \
        --ssh-key ~/.ssh/id_rsa.pub \
        --cores 4 \
        --memory 4GB \
        --network-interface subnet-name=subnet,nat-ip-version=ipv4 \
        --container-name=teamcity \
        --container-image=jetbrains/teamcity-server

    # create teamcity-agen
    server_ip=$(
        yc compute instances list --format=json | \
        jq -r '.[] |  select(.name=="teamcity") | .network_interfaces[0].primary_v4_address.address'
    )
    server_url=http://${server_ip}:8111

    yc compute instance create-with-container \
        --name teamcity-agent \
        --zone ru-central1-a \
        --ssh-key ~/.ssh/id_rsa.pub \
        --cores 2 \
        --memory 4GB \
        --network-interface subnet-name=subnet,nat-ip-version=ipv4 \
        --container-name=teamcity \
        --container-image=jetbrains/teamcity-agent \
        --container-env=SERVER_URL=${server_url}

    # create nexus
    yc compute instance create \
        --name nexus-instance \
        --hostname nexus-instance \
        --network-interface subnet-name=subnet,nat-ip-version=ipv4 \
        --zone ru-central1-a \
        --ssh-key ~/.ssh/id_rsa.pub \
        --cores 4 \
        --core-fraction 100 \
        --memory 4GB \
        --platform "standard-v1" \
        --create-boot-disk size=10,type=network-hdd,image-folder-id=standard-images,image-family=centos-7
        #--create-boot-disk image-id=fd88d14a6790do254kj7 # centos-7-v20220620
    
    yc compute instances list
}

delete_instances(){
    yc compute instance delete teamcity
    yc compute instance delete teamcity-agent
    yc compute instance delete nexus-instance
}

delete_network(){
    yc vpc subnet delete subnet
    yc vpc network delete net
}

declare ACTION=$1

case $ACTION in
    "create")
        create_network
        create_instances
        ;;
    "delete")
        delete_instances
        delete_network
        ;;
    *)
        $ACTION
        ;;
esac
