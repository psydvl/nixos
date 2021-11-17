# NixOS Configuration

## [@psydvl](https://github.com/psydvl) NixOS Configuration

Git'ed after about a week of use  
Still need improvements

Go to [config](https://github.com/psydvl/nixos/tree/config)

### There are git creation steps:
```bash
# /work symlinked to $HOME/work
mkdir -p /work/Projects/nixos.git/
pushd /work/Projects/nixos.git/

git init --bare
git config --local alias.dt "!git --work-tree=./"
git config --local alias.ct "!git --work-tree=/etc/nixos"
git config --local alias.st "!git ct status -uno"
git config --local alias.ci "!git ct commit"

git ct checkout -b docs
git ct add README.md
git ct commit -m "Add little documentation set"

git dt checkout --orphan config
git dt rm --cached -r .
git dt add configuration.nix
git dt add packages.nix fileSystems-home.nix networking-wireless-networks.nix
git ci -m "Init first bare git commit for configs"

git remote add https://github.com/psydvl/nixos.git
git push

popd
```


### WARNING: I'm still understanding git bare mechanics... 
#### There are after-install ~~git clone command~~ steps:
```bash
mkdir -p $HOME/work
sudo ln -s $HOME/work /work
mv $HOME/Projects $HOME/work
ln -s $HOME/Projects $HOME/work/Projects

git clone --mirror https://github.com/psydvl/nixos.git /work/Projects/nixos.git/
pushd /work/Projects/nixos.git/

git config --local alias.dt "!git --work-tree=./"
git config --local alias.ct "!git --work-tree=/etc/nixos"
git config --local alias.st "!git ct status -uno"
git config --local alias.ci "!git ct commit"

git dt checkout docs -f
#git dt fetch

sudo git ct checkout config -f
#sudo git ct fetch 

popd
```
