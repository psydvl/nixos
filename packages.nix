{ pkgs }:
with pkgs; rec {
	nix = nixFlakes;
	linux = linuxPackages_zen;
	printing.drivers = [
		gutenprint
		gutenprintBin
	];
	pkgs.vaapiIntel = vaapiIntel.override { enableHybridCodec = true; };
	hardware.opengl.extraPackages = [
		intel-media-driver # LIBVA_DRIVER_NAME=iHD
		vaapiIntel # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
		vaapiVdpau
		libvdpau-va-gl
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
	environment.systemPackages = latexPackages ++ [
		#%
		wayland
		libsecret
		alsa-utils
		vulkan-loader

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
		potrace
		unzip
		wget

		#% jq similar
		jq # JSON
		fq # binary
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
		virt-manager

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
		ddterm
		dash-to-dock
		#dash-to-panel
		emoji-selector
		night-theme-switcher
		snowy
	]) ++ [
		gnome.dconf-editor

		helvum #: pipewire patchbay

		#% main
		firefox-wayland
		tdesktop

		#% office
		abiword
		gnumeric
		libreoffice

		#%
		tor-browser-bundle-bin
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
		#jetbrains.idea-community
		pantheon.elementary-code
		gnome-builder
		geany-with-vte
		thonny
		#android-studio

		#% git
		github-desktop
		gitg

		#% various file stuff
		zathura
		marker
		meld
		glade
		sqlitebrowser
		dbeaver
		transmission-gtk

		#%
		obsidian
		cherrytree
		keepassxc
		#keeweb
		ventoy-bin
		vlc

		#%
		chromium
		tangram
		keybase
		zoom-us
		waydroid

		#%
		steam
		the-powder-toy

		#% overlayed
		bottles
	];
	fonts.fonts = [
		meslo-lgs-nf # Meslo Nerd Font patched for Powerlevel10k
	];
}
