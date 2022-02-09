SHELL := bash
CURRENT_DIR = $(shell pwd)
ENV_FILE := $(CURRENT_DIR)/.envrc

#------------------------------------------------------------------------
##help: 	                     print this help message
help:
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/##//'

#------------------------------------------------------------------------
##setup-ansible: 		     setup ansible environment
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
#------------------------------------------------------------------------
##clean-up: 		     cleans the setup and environment
clean-up:
	ansible-playbook cleanup.yml  $(EXTRA_ARGS)
	$(MAKE) ensure-env

.PHONY:	create-vms
#------------------------------------------------------------------------
##create-vms: 		     create the multipass vms
create-vms: ensure-env
	ansible-playbook vms.yml $(EXTRA_ARGS)
	$(MAKE) ensure-env

.PHONY:	create-kubernetes-clusters
#------------------------------------------------------------------------
##create-kubernetes-clusters:   Installs k3s on the multipass vms
create-kubernetes-clusters: ensure-env
	ansible-playbook k3s.yml $(EXTRA_ARGS)
	$(MAKE) ensure-env

.PHONY:	deploy-base
#------------------------------------------------------------------------
##deploy-base: 		      Prepare the vm with required packages and tools
deploy-base: ensure-env
	ansible-playbook workload.yml --tags="base" $(EXTRA_ARGS)
	$(MAKE) ensure-env

.PHONY:	deploy-istio
#------------------------------------------------------------------------
##deploy-istio: 		      Deploy Istio on to workload cluster
deploy-istio:	ensure-env
	ansible-playbook istio.yml $(EXTRA_ARGS)
	$(MAKE) ensure-env

.PHONY:	deploy-gloo
#------------------------------------------------------------------------
##deploy-gloo: 		      Deploy Gloo Mesh on to management and workload clusters
deploy-gloo:	ensure-env
	ansible-playbook gloo.yml $(EXTRA_ARGS)
	$(MAKE) ensure-env

.PHONY:	deploy-workload
#------------------------------------------------------------------------
##deploy-workload: 	      Deploy workload recommendation service on vm
deploy-workload: ensure-env
	ansible-playbook workload.yml --tags="workload" $(EXTRA_ARGS)
	$(MAKE) ensure-env

.PHONY:	test
test:	ensure-env
	@ansible-playbook test.yml $(EXTRA_ARGS)
	$(MAKE) ensure-env
