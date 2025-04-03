variable "hcloud_token" {
    type    = string
    default = env("HCLOUD_TOKEN")
}

variable "chr_version" {
  type    = string
}

variable "chr_vanilla_snapshot_id" {
  type    = number
}

variable "arch" {
  type    = string
  default = "amd64"
}

variable "server_type" {
  type    = string
  default = "cx22"
}

variable "server_location" {
  type    = string
  default = "fsn1-dc14"
}

locals {
	ext = var.arch == "amd64" ? "" : "-arm64" 

	imageUrl = "https://download.mikrotik.com/routeros/${var.chr_version}/chr-${var.chr_version}${local.ext}.img.zip"
}