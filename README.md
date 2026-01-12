# luanti_admin_scripts
A small set of administration scripts for Luanti server operators.

Currently implemented:
- `start.sh` a slightly improved startup script based on  https://docs.luanti.org/for-server-hosts/setup/linux/ 
Automatically restarts the server on crash and shuts it down cleanly on `CTRL+C`.
- `backup.sh` a simple local backup script.  
  Saves the server log file and the world directory into `~/backups` with rotation.  
  Backups are stored **locally only** — this script **does not** send archives over the network.
- ```systemd/``` user-level systemd units for automatic daily backups.

## How to use 
1) Clone the repository on a machine with an existing Luanti installation:
``` bash
git clone https://github.com/nichney/luanti_admin_scripts.git
cd luanti_admin_scripts
```

2) Run deploy.sh from utils. It copies start.sh and backup.sh to your luanti directory and installs systemd user units.
``` bash
.utils/deploy.sh
```
By default, the Luanti directory is assumed to be `~/luanti`. To specify a different directory, use the -l flag
``` bash
.utils/deploy.sh -l my/different/luanti/directory
```

3) If you want to disable backups and remove systemd units, run:
``` bash
utils/undeploy.sh
```
`undeploy.sh` also supports -l flag.

`undeploy.sh` **does not** remove `start.sh` or `backup.sh` from the Luanti directory.