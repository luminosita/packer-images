# Deploy GNS3 Server VM on Proxmox

### Setup VM

Run GNS3 server setup on Proxmox server 

```bash
milosh@gianni ~ % ssh proxmox@proxmox.lan
proxmox@proxmox:~$ ./gns3-vm.sh -i 200 -n GNS3 -v 3.0.4 -s vm-disks
...
```

Using Proxmox console on the VM (i.e. id=200) login to GNS3 shell 

```
Username: gns3
Password: gns3
```

### Install QEMU Guest Agent

```bash
$ sudo apt-get update
$ sudo apt-get upgrade
$ sudo apt-get install qemu-guest-agent
$ sudo systemctl start qemu-guest-agent
```

Once installed it will present valid IP address for GNS3 Server VM in Proxmox Summary

### Install OPNSense Appliance

Steps:
- New Template
- Install an appliance from the GNS3 server
- Under Firewalls, select OPNSense and click Install
- Install the appliance on the main server
- Select version or "Create a new version"
- Download image
- Select Install

OPNSense template will be installed. Configure template to have at least 1GB RAM and at least two network adapters (WAN and LAN). Ethernet 1 is WAN, Ethernet 0 is LAN by default.

Connect OPNSense appliance (em1) to Cloud (eth0)

Start appliance and validate configuration via console. Both interfaces should have proper IP address.

```
Username: root
Password: opnsense
```

### Install WebTerm Appliance

Steps:
- New Template
- Install an appliance from the GNS3 server
- Under Guests, select webterm and click Install

Connect WebTerm appliance (eth0) to OPNSense (em0)

WebTerm can be accessed via VNC (i.e. RealVNC). Open Terminal and set static IP (192.168.1.10, assuming that OPNSense has IP address 192.168.1.1 on LAN interface)

```bash
$ ifconfig eth0 192.168.1.10 netmask 255.255.255.0
```

Access OPNSense web console thru Firefox at https://192.168.1.1

```
Username: root
Password: opnsense
```

### Setup OPNSense Web Console via WAN

1. Go to Interfaces > [WAN] deselect "Block private networks"
2. Go to Firewall > Rules > WAN and create a new rule using below parameter save then apply.

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

3. Go to Firewall > Settings > Advanced and tick "Disable reply-to (Disable reply-to on WAN rules)"
4. Reboot (Very Important)

### Install Mikrotik Appliance

Steps:
- New Template
- Install an appliance from the GNS3 server
- Under Firewalls, select Mikrotik CHR and click Install
- Install the appliance on the main server
- Select version or "Create a new version"
- Download image
- Select Install

Mikrotik CHR template will be installed. Configure template to have at least 1GB RAM and at least two network adapters (WAN and LAN). Ethernet 0 is WAN, Ethernet 1 is LAN by default.

Connect Mikrotik CHR appliance (eth0) to Cloud (eth0)

Start appliance and validate configuration via console

```
Username: admin
Password: 
```
