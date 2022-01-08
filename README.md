# NixOS Configuration

## [@psydvl](https://github.com/psydvl) NixOS Configuration

Git'ed after about a week of use  
Still need improvements

Go to [config](https://github.com/psydvl/nixos/tree/config)

### There are git creation steps:
```bash
GITUSER="psydvl"
GITREPO="nixos"
REMOTE="https://github.com/$GITUSER/$GITREPO.git"

# /work symlinked to $HOME/work for me
mkdir -p /work/Projects/nixos.git/{docs,config}/
pushd /work/Projects/nixos.git/config/

git init --bare
git remote add $REMOTE
git config --local --bool core.bare false
git config --local --path core.worktree /etc/nixos
git config --local alias.st "status -uno"
git config --local alias.ci "commit"

git ct add flake.nix # if you using nix flakes as I am
git ct add configuration.nix
git ct add packages.nix fileSystems-home.nix networking-wireless-networks.nix
git ci -m "Init first bare git commit for configs"

git push

popd
pushd /work/Projects/nixos.git/docs/

git init
git remote add $REMOTE
git config --local alias.st "status"
git checkout -b docs
git add README.md
git commit -m "Add little documentation set"

git push

popd
```


### WARNING: I'm still understanding git bare mechanics...
### And next part not clearly checked
#### There are restore steps:
```bash
GITUSER="psydvl"
GITREPO="nixos"
REMOTE="https://github.com/$GITUSER/$GITREPO.git"

mkdir -p $HOME/work
sudo ln -s $HOME/work /work
mv $HOME/Projects $HOME/work
ln -s $HOME/Projects $HOME/work/Projects

mkdir -p /work/Projects/nixos.git/{docs,config}/

git clone --single-branch --branch=docs \
	$REMOTE \
	/work/Projects/nixos.git/docs
git clone --mirror --single-branch --branch=config \
	$REMOTE \
	/work/Projects/nixos.git/config

pushd /work/Projects/nixos.git/docs

#git config --local alias.dt "!git --work-tree=./"
git config --local alias.st "status"

popd
pushd /work/Projects/nixos.git/config

git config --local --bool core.bare false
git config --local --path core.worktree /etc/nixos
git config --local alias.st "status -uno"
git config --local alias.ci "commit"

# Only once when sudo used: furter work possible without sudo as readonly mode enough to it
sudo git ct checkout config -f

popd
```
