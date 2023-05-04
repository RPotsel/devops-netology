WORKSPACE?=prod
ENV=$(shell pwd)/env/$(WORKSPACE)
export ANSIBLE_INVENTORY_PLUGINS=~/.ansible/plugins/inventory:/usr/share/ansible/plugins/inventory:$(shell pwd)/ansible/library/plugins/inventory
export ANSIBLE_INVENTORY_ENABLED=host_list,script,auto,yaml,ini,yacloud_compute

submodules:
	git submodule add git@github.com:kubernetes-sigs/kubespray.git

ans-kubespray:
	cd ./kubespray && ansible-playbook -b -i ../ansible/inventory/$(WORKSPACE) cluster.yml \
		--vault-password-file ../ansible/inventory/$(WORKSPACE)/.vault

ans-play:
	cd ./ansible && ansible-playbook -i ./inventory/$(WORKSPACE) $(WORKSPACE).yml \
		--vault-password-file ./inventory/$(WORKSPACE)/.vault

ans-list:
	ansible-inventory --playbook-dir ./ansible \
		-i ./ansible/inventory/$(WORKSPACE) --list --vault-password-file ./ansible/inventory/$(WORKSPACE)/.vault
	ansible -i ./ansible/inventory/$(WORKSPACE) jenkins01 -m ansible.builtin.setup \
		--vault-password-file ./ansible/inventory/$(WORKSPACE)/.vault
