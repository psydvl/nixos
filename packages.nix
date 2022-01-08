{ pkgs }:
with pkgs; {
	nix = nixFlakes;
	linux = linuxPackages_zen;
	printing.drivers = [
		gutenprint
		gutenprintBin
	];
	unstablePackages = with unstable; [

		fq

		#$ GUI
		gnomeExtensions.ddterm
		gnomeExtensions.emoji-selector

		obsidian
		keepassxc
		keeweb
		latest.firefox-nightly-bin

		ventoy-bin
		github-desktop
		android-studio

		zoom-us
		waydroid

		the-powder-toy
	];
	latexPackages = [
		(texlive.combine { # FIX: rework for smaller collection
			inherit (texlive)
			scheme-basic #⊇ collection-basic collection-latex
			scheme-tetex #⊇ collection-latexrecommended collection-fontsrecommended collection-langcyrillic
				#collection-langcyrillic #⊇ cyrillic russ
			latexmk #⊆ collection-binextra
			collection-latexextra
			;
		})
		latexrun
		gnome-latex
		setzer
	];
	environment.systemPackages = latexPackages ++ unstablePackages ++ [
		#%
		wayland
		libsecret

		#$ CLI

		#% simple cli
		bat
		binutils
		imagemagick
		file
		gdu
		gitFull
		glow #: markdown in CLI
		graphviz
		htop
		ncdu
		wget

		#% jq similar
		jq # JSON
		yq # YAML, xq (inside) for XML, tomlq (inside) for TOML https://github.com/kislyuk/yq
		rq # https://github.com/dflemstr/rq
		rush # rh WIP https://github.com/Xion/rush
		#fq # in unstable for now
		#htmlq,pup not very comfortable for me

		#% vim stuff
		vim_configurable
		vimPlugins.vim-airline
		vimPlugins.vim-airline-themes

		#% zsh stuff
		zsh
		oh-my-zsh
		zsh-powerlevel10k
		meslo-lgs-nf # Meslo Nerd Font patched for Powerlevel10k
		zsh-nix-shell

		#% SDK, language package and environment
		go
		gtk4
		gtk3.dev
		gtk4.dev
		conda
		python3
		kotlin
		jdk
		sqlite
		tcl tk

		#% Nix(OS) stuff
		nix-tree
		nix-index
		nix-info
		nix-du
		nox
		nix-prefetch
		nix-direnv-flakes

		#% compatibility
		appimage-run
		direnv
		wl-clipboard
		desktop-file-utils
		patchelf

		#%
		ookla-speedtest
		gh
		sl
		tealdeer

		#%
		ffmpeg-full
		youtube-dl
		gallery-dl

		#$ GUI

		adwaita-qt
		gnome.gnome-tweaks
		chrome-gnome-shell
		gnome.gnome-characters
		gnome.gucharmap
		emote
	] ++ (with gnomeExtensions; [
		appindicator
		bluetooth-quick-connect
		caffeine
		#ddterm
		#emoji-selector
		night-theme-switcher
		snowy
	]) ++ [
		gnome.dconf-editor
		

		#% main
		firefox-wayland
		tdesktop
		kotatogram-desktop

		#% office
		abiword
		gnumeric
		libreoffice

		#%
		cawbird # Twitter
		gnome.gnome-disk-utility
		gparted
		gnome-passwordsafe

		#% drawing
		drawing
		gimp
		inkscape

		#% IDE
		vscode-fhs
		jetbrains.idea-community
		pantheon.elementary-code
		gnome-builder
		geany-with-vte
		thonny

		#% various file stuff
		zathura
		marker
		meld
		glade
		sqlitebrowser
		dbeaver

		#%
		cherrytree
		gitg

		#%
		chromium
		tangram
		keybase

		#%
		transmission-gtk
		bottles
		steam
	];
	fonts.fonts = [
		meslo-lgs-nf # Meslo Nerd Font patched for Powerlevel10k
	];
}
