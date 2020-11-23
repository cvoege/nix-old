# nix

[![uses nix](https://img.shields.io/badge/uses-nix-%237EBAE4)](https://nixos.org/)

_my nixpkgs folder_

## install

```bash
# install nix
curl -L https://nixos.org/nix/install | sh

# add line to .bashrc

# switch to nixos-unstable
nix-channel --add https://nixos.org/channels/nixos-unstable nixpkgs

# configure nix to use more resources when building
mkdir -p ~/.config/nix/
echo 'max-jobs = auto' >>~/.config/nix/nix.conf

# install home manager
nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
nix-channel --update
nix-shell '<home-manager>' -A install
echo '. "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"' >>~/.bash_profile

# add starship and direnv to ~/.bashrc
echo 'eval "$(direnv hook bash)"' >>~/.bashrc
echo 'eval "$(starship init bash)"' >>~/.bashrc
echo 'source $HOME/.nix-profile/share/nix-direnv/direnvrc' >>~/.direnvrc

# pull repo into ~/.config/nixpkgs/
cd ~/.config/nixpkgs
git clone git@github.com:benaduggan/nix.git .

# enable home-manager and build packages
home-manager switch
```
