set -e
CONFIG_PATH=/data/options.json
KEYS_PATH=/data/host_keys

echo "[INFO] Creating screen session..."
screen -dmS SHADE
screen -S SHADE -x -X screen -t sshd ash
screen -S SHADE -x -X screen -t hass ash
screen -S SHADE -x -X screen -t venv ash

AUTHORIZED_KEYS=$(jq --raw-output ".authorized_keys[]" $CONFIG_PATH)

# Init defaults config
sed -i s/#PermitRootLogin.*/PermitRootLogin\ yes/ /etc/ssh/sshd_config
sed -i s/#LogLevel.*/LogLevel\ DEBUG/ /etc/ssh/sshd_config

if [ ! -z "$AUTHORIZED_KEYS" ]; then
    echo "[INFO] Setup authorized_keys"
    mkdir -p ~/.ssh
    while read -r line; do
        echo "$line" >> ~/.ssh/authorized_keys
    done <<< "$AUTHORIZED_KEYS"
    chmod 600 ~/.ssh/authorized_keys
    sed -i s/#PasswordAuthentication.*/PasswordAuthentication\ no/ /etc/ssh/sshd_config
else
    echo "[Error] You need to setup a login!"
    exit 1
fi
# Generate host keys
if [ ! -d "$KEYS_PATH" ]; then
    echo "[INFO] Create host keys"
    mkdir -p "$KEYS_PATH"
    ssh-keygen -A
    cp -fp /etc/ssh/ssh_host* "$KEYS_PATH/"
else
    echo "[INFO] Restore host keys"
    cp -fp "$KEYS_PATH"/* /etc/ssh/
fi

# Persist shell history by redirecting .ash_history to /data
touch /data/.ash_history
chmod 600 /data/.ash_history
ln -s -f /data/.ash_history /root/.ash_history

# start server

screen -S SHADE -p sshd -X stuff $'exec /usr/sbin/sshd -D -e\n'

if [ ! -d /data/home-assistant ]; then
	echo "[INFO] Fresh install detected, preparing environment."
	echo "[INFO] Copying /config..."
	cp -rv /config /data/config
	echo "[INFO] Setting default port, disabling ssl..."
	sed -i '/server_port/d' /data/config/configuration.yaml
	sed -i '/ssl_key/d' /data/config/configuration.yaml
	sed -i '/ssl_certificate/d' /data/config/configuration.yaml
	echo "[INFO] Cloning..."
	GITHUB_USER="$(jq --raw-output '.github_user' $CONFIG_PATH)"
	echo "[DEBUG] Will clone https://github.com/$GITHUB_USER/home-assistant.git"
	git clone https://github.com/$GITHUB_USER/home-assistant.git
	echo "[INFO] Creating venv..."
	python3 -m venv --system-site-packages venv
        source venv/bin/activate
	cd home-assistant
	git remote add upstream https://github.com/home-assistant/home-assistant.git
	echo "[INFO] Setting up..."
	script/setup
else
	echo "[INFO] Already installed."
fi

echo "[INFO] Running hass..."
screen -S SHADE -p hass -X stuff $'source venv/bin/activate\ncd home-assistant\nhass -c /data/config\n'

echo "[INFO] Prepering dev console..."
screen -S SHADE -p venv -X stuff $'source venv/bin/activate\n'

echo "[INFO] All set. For logs of hass ssh to this addon and exec screen -r"
# prevent container from terminating
tail -f /dev/null
