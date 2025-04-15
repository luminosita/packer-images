# Deploy GNS3 Server VM on Proxmox

### Setup VM

Run GNS3 server setup on Proxmox server 

```bash
milosh@gianni ~ % ssh proxmox@proxmox.lan
proxmox@proxmox:~$ ./opnsense-vm.sh -i 300 -n GNS3 -v 25.1 -s vm-disks
...
```

Using Proxmox console on the VM (i.e. id=300) login to OPNSense shell 

```
Username: root  
Password: opnsense
```

### Setup OPNSense Web Console via WAN

#### Create Ubuntu Desktop VM

1. Download Ubuntu Desktop ISO image in Proxmox
2. Setup new VM with that ISO image (RAM: 4GB, Network: vmbr1)

By setting `vmbr1` as network interface it will connect Ubuntu Desktop VM with internal OPNSense network and allow `OPNSense Web Console` via LAN (http://192.168.1.1)

3. Start VM and verify that the proper IP got assigned (i.e. 192.168.1.100)

#### Enable OPNSense Web Console via WAN 

1. In Firefox, go to http://192.168.1.1
2. Go to Interfaces > [WAN] deselect "Block private networks"
3. Go to Firewall > Rules > WAN and create a new rule using below parameter save then apply.

```
Action : Pass
Interface : WAN
Direction : In
TCP/IP Version: IPv4
Protocol: any
Source: WAN net
Destination: any
Destination port range: any
Gateway: default
repeat this for IPv6
```

4. Go to Firewall > Settings > Advanced and tick "Disable reply-to (Disable reply-to on WAN rules)"
5. Reboot (Very Important)
