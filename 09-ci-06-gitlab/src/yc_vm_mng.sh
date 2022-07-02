#!/usr/bin/env bash

set -e

create_net(){
    yc vpc network create \
        --name net-k8s-test \
        --labels prj=netology \
        --description "netology_96 homework net"
}

create_subnet(){
    yc vpc subnet create \
        --name subnet-k8s-test \
        --zone ru-central1-a \
        --range 10.0.0.0/24 \
        --network-name net-k8s-test \
        --labels prj=netology \
        --description "netology_96 homework subnet"
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

create_gitlab_vm(){

    # create gitlab vm
    # root /etc/gitlab/initial_root_password
    yc compute instance create \
        --name gitlab \
        --hostname gitlab \
        --network-interface subnet-name=subnet-k8s-test,nat-ip-version=ipv4 \
        --zone ru-central1-a \
        --ssh-key ~/.ssh/id_rsa.pub \
        --cores 2 \
        --core-fraction 100 \
        --memory 4GB \
        --platform "standard-v1" \
        --create-boot-disk size=20,type=network-hdd,image-folder-id=standard-images,image-family=gitlab
        #--create-boot-disk image-id=fd88d14a6790do254kj7 # centos-7-v20220620
    
    #yc compute instances list
}

delete_instances(){
    yc compute instance delete gitlab
}

delete_network(){
    yc vpc subnet delete subnet-k8s-test
    yc vpc network delete net-k8s-test
}

create_sa(){
    yc iam service-account create --name sa-k8s-test \
      --description "this is service account for Kubernetes"

    yc iam key create --service-account-name sa-k8s-test --output key.json

    account_id=$(cat key.json | jq -r '.service_account_id')

    # Reset roles for all sa from folder
    #yc resource-manager folder set-access-bindings netology \
    #  --access-binding role=editor,service-account-id=$account_id \
    #  --access-binding role=container-registry.images.puller,service-account-id=$account_id \
    #  --access-binding role=container-registry.images.pusher,service-account-id=$account_id

    yc resource-manager folder add-access-binding netology \
      --role editor \
      --subject serviceAccount:$account_id

    yc resource-manager folder add-access-binding netology \
      --role container-registry.images.puller \
      --subject serviceAccount:$account_id

    yc resource-manager folder add-access-binding netology \
      --role container-registry.images.pusher \
      --subject serviceAccount:$account_id

    # yc resource-manager folder list-access-bindings netology
}

create_k8s_cluster(){
    yc managed-kubernetes cluster create \
      --name k8s-test \
      --network-name net-k8s-test \
      --zone ru-central1-a \
      --subnet-name subnet-k8s-test \
      --public-ip \
      --release-channel regular \
      --version 1.21 \
      --cluster-ipv4-range 10.1.0.0/16 \
      --service-ipv4-range 10.2.0.0/16 \
      --node-ipv4-mask-size 24 \
      --service-account-name sa-k8s-test \
      --node-service-account-name sa-k8s-test
    #  --security-group-ids enpe5sdn7vs5mu6udl7i,enpj6c5ifh755o6evmu4 \ 
    #  --daily-maintenance-window start=22:00,duration=10h

    #yc managed-kubernetes cluster list
    #yc managed-kubernetes cluster get k8s-test
}

delete_k8s_cluster(){
    yc managed-kubernetes cluster delete k8s-test
}

create_k8s_nodegroup(){
    yc managed-kubernetes node-group create \
      --cluster-name k8s-test \
      --cores 2 \
      --core-fraction 100 \
      --disk-size 30 \
      --disk-type network-hdd \
      --fixed-size 1 \
      --network-interface subnets=subnet-k8s-test,ipv4-address=nat \
      --memory 4 \
      --name nodegroup-k8s-test \
      --network-acceleration-type standard \
      --platform-id "standard-v1" \
      --preemptible \
      --version 1.21 \
      --metadata-from-file ssh-keys=rsa.pub
      #--public-ip \
      #--location zone=ru-central1-a,subnet-name=subnet-k8s-test \

    #yc managed-kubernetes node-group list
    #yc managed-kubernetes node-group get nodegroup-k8s-test   
}

delete_k8s_nodegroup(){
    yc managed-kubernetes node-group delete nodegroup-k8s-test
}

create_container_registry(){
    yc container registry create --name reg-k8s-test

    #yc container registry list
    #yc container registry get reg-k8s-test
}

delete_container_registry(){
    yc container registry delete reg-k8s-test
}

install_gitlab_runner(){
    #helm search repo -l gitlab/gitlab-runner
    #helm repo add gitlab https://charts.gitlab.io
    helm install --namespace default gitlab-runner -f values.yaml gitlab/gitlab-runner
    #kubectl get pods -n default | grep gitlab-runner
    #helm upgrade --namespace default -f values.yaml v.2 gitlab/gitlab-runner
}

delete_gitlab_runner(){
    helm delete --namespace default gitlab-runner
}

declare ACTION=$1

case $ACTION in
    "create_k8s")
        create_net
        create_sa
        create_k8s_cluster
        ;;
    "delete")
        delete_instances
        delete_network
        ;;
    *)
        "$@"
        ;;
esac
