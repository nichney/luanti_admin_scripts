#!/usr/bin/bash

# Do not run if user is root
current_user=$(whoami)
if [[ "$current_user" == "root" ]]; then
    echo "You cannot run this script as root" >&2
    exit 1
fi

LUANTI_DIRECTORY="$HOME/luanti"
SYSTEMD_USER_DIR="$HOME/.config/systemd/user"

while getopts ":hl:" option; do
  case $option in
    h)
      echo "Syntax: undeploy.sh [-h] [-l luanti_directory]"
      exit 0
      ;;
    l)
      LUANTI_DIRECTORY=$OPTARG
      ;;
    \?)
      echo "Error: Invalid option -$OPTARG" >&2
      exit 2
      ;;
    :)
      echo "Error: Option -$OPTARG requires an argument." >&2
      exit 3
      ;;
  esac
done

echo "Removing Luanti backup deployment from $LUANTI_DIRECTORY..."

# Stop and disable timer if it exists
if systemctl --user list-unit-files | grep -q '^luanti-backup.timer'; then
    systemctl --user stop luanti-backup.timer || true
    systemctl --user disable luanti-backup.timer || true
fi

# Remove systemd units
rm -f \
  "$SYSTEMD_USER_DIR/luanti-backup.service" \
  "$SYSTEMD_USER_DIR/luanti-backup.timer"

systemctl --user daemon-reload
systemctl --user reset-failed


echo "Uninstall complete."

echo "Remaining timers:"
systemctl --user list-timers --all | grep luanti || echo "(none)"
