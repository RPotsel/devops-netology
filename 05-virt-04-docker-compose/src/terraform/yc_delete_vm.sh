#!/usr/bin/env bash 

#rm -f terraform.tfstate.backup
#rm -f terraform.tfstate

#yc compute instances delete --name node02
#yc vpc subnet delete --name subnet
#yc vpc net delete --name net

terraform destroy -auto-approve