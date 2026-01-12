#!/usr/bin/bash
# Automatically deploy admin scripts into infrastructure, run from directory above

# Do not run if user is root
current_user=$(whoami)
if [[ "$current_user" == "root" ]]; then
    echo "You cannot run this script as root" >&2
    exit 1
fi

LUANTI_DIRECTORY="$HOME/luanti"

while getopts ":hl:" option; do
  case $option in
    h)
      echo "Syntax: deploy.sh [-h] [-l luanti_directory]"
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

echo "Deploying Luanti backup to $LUANTI_DIRECTORY..."

mkdir -p "$LUANTI_DIRECTORY"
mkdir -p "$HOME/.config/systemd/user/"
cp "backup.sh" "start.sh" "$LUANTI_DIRECTORY/"
chmod +x "$LUANTI_DIRECTORY/backup.sh" "$LUANTI_DIRECTORY/start.sh"

tmp=$(mktemp)
sed "s:^ExecStart=.*:ExecStart=$LUANTI_DIRECTORY/backup.sh:" "systemd/luanti-backup.service" > "$tmp"
cp "$tmp" "$HOME/.config/systemd/user/luanti-backup.service"
rm "$tmp"

cp "systemd/luanti-backup.timer" "$HOME/.config/systemd/user/"
systemctl --user daemon-reload
systemctl --user enable --now luanti-backup.timer

echo "Success! Timer status:"
systemctl --user list-timers --all | grep luanti