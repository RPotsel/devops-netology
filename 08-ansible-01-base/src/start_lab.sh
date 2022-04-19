#!/usr/bin/env bash
docker-compose up -d
ansible-playbook site.yml -i inventory/prod.yml --ask-vault-pass
docker-compose down
