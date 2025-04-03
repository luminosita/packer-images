TOKEN:=$(shell hcp vault-secrets run --app=Packer -- env | grep HETZNER_TOKEN | sed -e s/HETZNER_TOKEN=//)

export HCLOUD_TOKEN=${TOKEN}
