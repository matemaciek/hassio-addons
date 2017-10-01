set -e
CONFIG_PATH=/data/options.json
if [ ! -d /data/home-assistant ]; then
	echo "Fresh install detected, preparing environment."
	echo "Copying /config..."
	cp -rv /config /data/config
	echo "Setting default port, disabling ssl..."
	sed -i '/server_port/d' /data/config/configuration.yaml
	sed -i '/ssl_key/d' /data/config/configuration.yaml
	sed -i '/ssl_certificate/d' /data/config/configuration.yaml
	echo "Cloning..."
	GITHUB_USER="$(jq --raw-output '.github_user' $CONFIG_PATH)"
	echo "Will clone https://github.com/$GITHUB_USER/home-assistant.git"
	git clone https://github.com/$GITHUB_USER/home-assistant.git
	echo "Creating venv..."
	python3 -m venv venv
        source venv/bin/activate
	cd home-assistant
	git remote add upstream https://github.com/home-assistant/home-assistant.git
	echo "Setting up..."
	script/setup
else
	echo "Already installed."
        source venv/bin/activate
	cd home-assistant
fi
echo "Running hass..."
hass -c /data/config
