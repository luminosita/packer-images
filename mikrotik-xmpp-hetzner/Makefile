HCL_FOLDER:=./hcl/
SCRIPTS_FOLDER:=./scripts

include common.mk

init: 
	$(info PACKER: Init Packer plugins)
	packer init ${HCL_FOLDER}

mikrotik-vanilla: validate
	$(info PACKER: Creating Vanilla Mikrotik Snapshot)
	packer build -only=vanilla.hcloud.vanilla ${HCL_FOLDER}

.PHONY: mikrotik
mikrotik: 
	$(info PACKER: Creating Final Mikrotik Snapshot)
	source ${SCRIPTS_FOLDER}/bootstrap.sh

validate: init
	$(info PACKER: Validating ...)
	packer validate ${HCL_FOLDER}
