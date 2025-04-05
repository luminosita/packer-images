# Setup Mikrotik Appliance (i.e. Mikrotik Chateau LTE6)

### Start/Reset Router

Plug router to DC source. If reset is required press `Reset` button and hold immediately after router starts while `power` light has purple color at the front side of the router box. Once `power` light turns blue release `Reset` button.

Connect to router WIFI `MikroTik-2945D2` using wifi key specified at the bottom of the router box (`Wifi Key`)

### Set Router Configuration

Edit default configuration file `rsc/vars.rsc`

Create or symlink RSA public key at `tmp/id_rsa.pub`. Public key will be assigned to the new admin user specified in configuration file

### Setup Router
*NOTE:* Default router IP address is 192.168.88.1

Using /bin/bash execute the following

```bash
$ ./setup.sh -c 192.168.88.1 -p <NEW PASSWORD>
```

*NOTE:* Default router admin password is specified at the bottom of the router box (`Password`)

Prompt will ask for new password. It should be the same value as specified by `-p` flag. Password needs to be confirmed.

Exit router SSH console with

```bash
[admin@MikroTik] > /quit
```

### Verify Setup

Restart Wifi connection at verify that new IP address is allocated (`192.168.50.254`) and proper default gateway set (`192.168.50.1`)

Establish SSH connection to the router 

```bash
$ ssh <new admin>@router.lan
```

It should not require password. Public key is used for authentication.

*NOTE:* Web management console at `https://router.lan` will not allow password login for new admin user. Solution is to create separate web admin user if web console is required

### Secure Router

If secured router is required execute the following. New user with SSH public key will be deployed and default admin will be removed as specified in `rsc/vars.rsc`

```bash
$ ./secure.sh -c 192.168.50.1 -p <NEW PASSWORD>
```
