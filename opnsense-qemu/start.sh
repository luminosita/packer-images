#Download QCow2 OPNSense image
#For AMD64 -> wget https://mirror.dns-root.de/opnsense/releases/mirror/OPNsense-25.1-nano-amd64.img.bz2
#For ARM64 -> wget https://github.com/maurice-w/opnsense-vm-images/releases/download/25.1/OPNsense-25.1-ufs-efi-vm-aarch64.qcow2.bz2

#GitHub for ARM64 OPNSense ->  https://github.com/maurice-w/opnsense-vm-images

#Download QEMU EFI Bios for ARM64 -> https://github.com/rsms/qemu-macos-x86-arm64/raw/refs/heads/main/QEMU_EFI.fd
#GitHub for ARM64 Qemu -> https://github.com/rsms/qemu-macos-x86-arm64

qemu-system-aarch64 -m 2048M -name "OPNSense" \
  -bios QEMU_EFI.fd \
  -vga none -nographic -monitor none \
  -serial chardev:term0 -chardev stdio,id=term0 \
  -cpu host \
  -smp "cpus=1,sockets=1,cores=1,threads=1" \
  -machine virt,accel=hvf \
  -boot order=c \
  -drive if=virtio,file=OPNsense-25.1-ufs-efi-vm-aarch64.qcow2,index=0,media=disk \
  -device virtio-net-pci,netdev=netdev0 \
  -netdev user,id=netdev0
  