build {
  name = "vanilla"
  sources = ["source.hcloud.vanilla"]

  provisioner "shell" {
    inline = [
      "curl -L ${local.imageUrl} > mikrotik-chr.zip",
      "funzip mikrotik-chr.zip > mikrotik-chr.img",
      "dd if=mikrotik-chr.img of=/dev/sda bs=1M"
    ]
  }
}
