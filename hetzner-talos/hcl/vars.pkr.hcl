variable "hcloud_token" {
    type    = string
    default = env("HCLOUD_TOKEN")
}

variable "talos_version" {
  type    = string
}

variable "arch" {
  type    = string
}

variable "schematic_id" {
  type    = string
}

variable "server_type" {
  type    = string
}

variable "server_location" {
  type    = string
}

locals {  
  image = "https://factory.talos.dev/image/${var.schematic_id}/${var.talos_version}/hcloud-${var.arch}.raw.xz"
}

