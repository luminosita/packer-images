source "hcloud" "vanilla" {
  token        = "${var.hcloud_token}"   

  rescue       = "linux64"
  image        = "ubuntu-22.04"
  location     = "${var.server_location}"
  server_type  = "${var.server_type}"
  ssh_username = "root"

  snapshot_name   = "Mikrotik CHR Vanilla - ${var.arch} - ${var.chr_version}"
  snapshot_labels = {
    type    = "infra",
    os      = "routeros",
    version = "${var.chr_version}",
    arch    = "${var.arch}",
  }
}

source "hcloud" "final" {
  token        = "${var.hcloud_token}"   
  
  image = var.chr_vanilla_snapshot_id

  location     = "${var.server_location}"
  server_type  = "${var.server_type}"
  ssh_username = "admin"

  snapshot_name   = "Mikrotik CHR Final - ${var.arch} - ${var.chr_version}"
  snapshot_labels = {
    type    = "infra",
    os      = "routeros",
    version = "${var.chr_version}",
    arch    = "${var.arch}",
  }
}