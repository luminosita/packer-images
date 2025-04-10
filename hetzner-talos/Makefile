HCL_FOLDER:=./hcl/

include common.mk

init: 
	$(info PACKER: Init Packer plugins)
	packer init ${HCL_FOLDER}

talos: validate
	$(info PACKER: Creating Talos Snapshot)
	packer build ${HCL_FOLDER}

validate: init
	$(info PACKER: Validating ...)
	packer validate ${HCL_FOLDER}
