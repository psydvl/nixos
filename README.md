# NixOS Configuration

## [@psydvl](https://github.com/psydvl) NixOS Configuration

Git'ed after about a week of use 
Still need improvements

### There are git creation steps:
```bash
mkdir ~/work/Projects/nixos.git/
pushd ~/work/Projects/nixos.git/

git init --bare
git config --local alias.st "!git --work-tree=/ status -uno"
git config --local alias.ci "!git --work-tree=/ commit"

git checkout -b config
git --work-tree=/ add /etc/nixos/configuration.nix
git --work-tree=/ add /etc/nixos/packages.nix
git --work-tree=/ add /etc/nixos/fileSystems-home.nix
git --work-tree=/ add /etc/nixos/networking-wireless-networks.nix
git --work-tree=/ commit -m "Init first bare git commit for configs"

git --work-tree=./ checkout --orphan docs
git --work-tree=./ rm --cached -r .
git --work-tree=./ add README.md
git --work-tree=/ commit -m "Add little documentation set"


git remote add 
git pushd

popd
```


### WARNING: I'm still understanding git bare mechanics... 
#### There are git clone command steps:
```bash
mkdir -p $HOME/work/Projects

git clone --mirror git://github.com/psydvl/nixos.git $HOME/work/Projects/nixos.git/
pushd $HOME/work/Projects/nixos.git/

git config --local alias.st "!git --work-tree=/ status -uno"
git config --local alias.ci "!git --work-tree=/ commit"

git checkout docs
git --work-tree=./ fetch

git checkout config
sudo git --work-tree=/ fetch 

popd
```
