SHELL := bash
CURRENT_DIR = $(shell pwd)
ENV_FILE := $(CURRENT_DIR)/.envrc

.PHONY:	create-venv
create-venv:
	install

.PHONY:	setup-ansible
setup-ansible:
	pip3 install -r requirements.txt
	ansible-galaxy role install -r requirements.yml
	ansible-galaxy collection install -r requirements.yml

.PHONY:	ensure-env
ensure-env: 
	@if [ -f $(ENV_FILE) ]; \
  then \
    direnv allow $(ENV_FILE); \
  fi;

.PHONY:	lint
lint:	
	@ansible-lint --force-color

.PHONY: clean-up
clean-up:
	ansible-playbook cleanup.yml  $(EXTRA_ARGS)
	$(MAKE) ensure-env

.PHONY:	create-vms
create-vms: ensure-env
	ansible-playbook vms.yml $(EXTRA_ARGS)
	$(MAKE) ensure-env

.PHONY:	create-kube-clusters
create-kube-clusters: ensure-env
	ansible-playbook -i localhost -c local clusters.yml $(EXTRA_ARGS)
	$(MAKE) ensure-env

.PHONY:	deploy-base
deploy-base: ensure-env
	ansible-playbook workload.yml --tags="base" $(EXTRA_ARGS)
	$(MAKE) ensure-env

.PHONY:	deploy-istio
deploy-istio:	ensure-env
	ansible-playbook istio.yml $(EXTRA_ARGS)
	$(MAKE) ensure-env

.PHONY:	deploy-gloo
deploy-gloo:	ensure-env
	ansible-playbook gloo.yml $(EXTRA_ARGS)
	$(MAKE) ensure-env

.PHONY:	deploy-workload
deploy-workload: ensure-env
	ansible-playbook workload.yml --tags="workload" $(EXTRA_ARGS)
	$(MAKE) ensure-env

.PHONY:	test
test:	ensure-env
	@ansible-playbook test.yml $(EXTRA_ARGS)
	$(MAKE) ensure-env