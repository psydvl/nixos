{ pkgs, unstable }:
with pkgs; { 
	environment.systemPackages = [
		wayland
	
		# CLI
		
		imagemagick
		file
		gitFull
		fossil
		glow # markdown in CLI
		graphviz
		htop
		ncdu
		wget
		
		vim_configurable
		vimPlugins.vim-airline
		vimPlugins.vim-airline-themes
		
		zsh
		oh-my-zsh
		zsh-powerlevel10k
		meslo-lgs-nf # Meslo Nerd Font patched for Powerlevel10k
		zsh-nix-shell
		
		gh
		
		go
		gtk4
		gtk4.dev
		conda
		kotlin
		jdk
		sqlite
		
		nix-tree
		nix-index
		nix-du
		nox
		appimage-run
		libsecret
		wl-clipboard
		
		sl
		ffmpeg-full
		youtube-dl
		gallery-dl
		
		# GUI
		
		gnome.gnome-tweaks
		chrome-gnome-shell
		gnomeExtensions.caffeine
		gnomeExtensions.adwaita-theme-switcher
		gnomeExtensions.dash-to-dock
		gnomeExtensions.ddterm
		gnomeExtensions.maxi
		gnomeExtensions.snowy
		unstable.gnomeExtensions.appindicator
		desktop-file-utils
		gnome.dconf-editor
		gnome.gnome-disk-utility
		
		firefox-wayland
		zathura
		tdesktop
		kotatogram-desktop
		
		cawbird # Twitter
		keybase
		kodi-wayland
		marker
		drawing
		
		unstable.keeweb
		unstable.obsidian
		unstable.zoom-us
		
		unstable.android-studio
		unstable.github-desktop
		vscode-fhs
		gitg
		sqlitebrowser
		dbeaver
		
		pantheon.elementary-code
		gnome-builder
		geany-with-vte
		glade
		patchelf
		nix-prefetch-git
		unstable.inkscape
		chromium
		tangram
		
		steam
	];
	fonts.fonts = [
		meslo-lgs-nf # Meslo Nerd Font patched for Powerlevel10k
	];
}
