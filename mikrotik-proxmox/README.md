# Deploy Mikrotik CHR on Proxmox

### Set Router Configuration

Edit default configuration file `rsc/vars.rsc`

Create or symlink RSA public key at `tmp/id_rsa.pub`. Public key will be assigned to the new admin user specified in configuration file

### Init Proxmox VM

Create vanilla and final Mikrotik VM

```bash
$ source init.sh -i 110 -n Mikrotik -t 111 -v 7.16.1 -s local-lvm -p <NEW PASSWORD>
```

Using Proxmox console on the final VM (i.e. id=110) login to Mikrotik shell 

```
Username: admin
Password: empty
```

Approve license and gather newly assigned IP address

```bash
[admin@MikroTik] /ip/address print
Flags: D - DYNAMIC
Columns: ADDRESS, NETWORK, INTERFACE
#   ADDRESS            NETWORK       INTERFACE
0 D 192.168.50.250/24  192.168.50.0  ether1
```

### Setup Proxmox VM

Run Mikrotik setup with newly assigned IP address

```bash
$ source setup.sh -i 110 -c 192.168.50.250 -p <NEW PASSWORD>
```

### Verify Setup

Clone Mikrotik template and start VM

Establish SSH connection to the router 

```bash
$ ssh <new admin>@192.168.50.250
```

It should not require password. Public key is used for authentication.

*NOTE:* Web management console at `https://192.168.50.250` will not allow password login for new admin user. Solution is to create separate web admin user if web console is required
