# nix

[![uses nix](https://img.shields.io/badge/uses-nix-%237EBAE4)](https://nixos.org/)

_my nixpkgs folder_

## install

```bash
# install nix
curl -L https://nixos.org/nix/install | sh

# configure nix to use more cpu/ram when building
mkdir -p ~/.config/nix/
echo -e 'max-jobs = auto\nexperimental-features = nix-command flakes' >~/.config/nix/nix.conf

# Add necessary nix channels
# nix-channel --add https://nixos.org/channels/nixos-unstable nixpkgs
# nix-channel --add nixpkgs https://nixos.org/channels/nixpkgs-unstable nixpkgs
nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
nix-channel --add https://github.com/kwbauson/cfg/archive/main.tar.gz kwbauson-cfg
nix-channel --update
nix-shell '<home-manager>' -A install

# pull repo into ~/.config/nixpkgs/
cd ~/.config
git clone git@github.com:cvoege/nix.git nixpkgs

# move unneeded files
mv ~/.profile ~/.profile.old
mv ~/.bashrc ~/.bashrc.old
mv ~/.bash_profile ~/.bash_profile.old
mv ~/.gitconfig ~/.gitconfig.old
mv ~/.tmux.conf ~/.tmux.conf.old

# enable home-manager and build packages
home-manager switch
. ~/.nix-profile/etc/profile.d/nix.sh
```
