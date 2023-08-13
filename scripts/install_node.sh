sudo apt install -y curl unzip
curl -fsSL https://fnm.vercel.app/install | bash
source /home/vagrant/.bashrc
fnm install 18.17.0
node -v
