export PTERODACTYL_DIRECTORY=/var/www/pterodactyl


if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root. Please run with sudo."
    exit 1
fi

if [ ! -d "$PTERODACTYL_DIRECTORY/blueprint" ]; then
  echo "Blueprint is not installed in the specified Pterodactyl directory. Installing..."
  sudo apt install -y curl wget unzip

  cd $PTERODACTYL_DIRECTORY

  wget "$(curl -s https://api.github.com/repos/BlueprintFramework/framework/releases/latest | grep 'browser_download_url' | grep 'release.zip' | cut -d '"' -f 4)" -O "$PTERODACTYL_DIRECTORY/release.zip"
  unzip -o release.zip

  sudo apt install -y ca-certificates curl git gnupg unzip wget zip

  sudo mkdir -p /etc/apt/keyrings
  curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
  echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list
  sudo apt update
  sudo apt install -y nodejs

  cd $PTERODACTYL_DIRECTORY
  npm i -g yarn
  yarn install

  echo \
  'WEBUSER="www-data";
  OWNERSHIP="www-data:www-data";
  USERSHELL="/bin/bash";' > $PTERODACTYL_DIRECTORY/.blueprintrc
  touch $PTERODACTYL_DIRECTORY/.blueprintrc

  chmod +x $PTERODACTYL_DIRECTORY/blueprint.sh
  exit 1
fi

# Copy files from admin/, assets/ and client/ into Pterodactyl structure
mkdir -p $PTERODACTYL_DIRECTORY/.blueprint/dev
mkdir -p $PTERODACTYL_DIRECTORY/.blueprint/dev/admin
mkdir -p $PTERODACTYL_DIRECTORY/.blueprint/dev/assets
mkdir -p $PTERODACTYL_DIRECTORY/.blueprint/dev/client

cp -r admin/* $PTERODACTYL_DIRECTORY/.blueprint/dev/admin/
cp -r assets/* $PTERODACTYL_DIRECTORY/.blueprint/dev/assets/
cp -r client/* $PTERODACTYL_DIRECTORY/.blueprint/dev/client/

cd $PTERODACTYL_DIRECTORY/.blueprint/dev

blueprint build