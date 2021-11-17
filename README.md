# NixOS Configuration

## [@psydvl](https://github.com/psydvl) NixOS Configuration

Git'ed after about a week of use 
Still need improvements

### There are git creation steps:
```bash
mkdir ~/nixos.git/
pushd ~/nixos.git/

git init --bare
git config --local alias.st "!git --work-tree=/ status -uno"
git config --local alias.ci "!git --work-tree=/ commit"

git --work-tree=/ add /etc/nixos/configuration.nix
git --work-tree=/ add /etc/nixos/fileSystems-home.nix
git --work-tree=/ add /etc/nixos/networking-wireless-networks.nix

git --work-tree=/ commit -m "Init first bare git commit"

git branch config # only creation, keep master as actual

git --work-tree=./ add README.md

git --work-tree=/ commit -m "Add little documentation set"

popd
```


### WARNING: I'm still understanding git bare mechanics... 
#### There are git clone command steps:
```bash
git clone --mirror git://github.com/psydvl/nixos.git $HOME/nixos.git/
pushd $HOME/nixos.git/
git config --local alias.st "!git --work-tree=/ status -uno"
git config --local alias.ci "!git --work-tree=/ commit"
popd
```
