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
		gdb
		gcc
		go
		golangci-lint
		gtk4
		gtk3.dev
		gtk4.dev
		conda
		python3
		kotlin
		jdk
		sqlite
		tcl tk
	] ++ (with python3.pkgs; [
		bandit
		flake8
		pylint
	]) ++ [

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
		podman
		pulseaudio

		#%
		onefetch
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

		sysprof

		#% pipewire investigation
		pavucontrol
		plasma-pa
		qjackctl
		carla
		cadence #catia
		patchage
		helvum #: pipewire patchbay

		#% main
		firefox-wayland
		tdesktop
		cherrytree
		sublime4

		#% office
		abiword
		gnumeric
		libreoffice

		#% drawing
		drawing
		gimp
		inkscape

		#% IDE
		pantheon.elementary-code
		vscode-fhs
		#jetbrains.idea-community
		gnome-builder
		geany-with-vte
		thonny
		#android-studio

		#% git
		sublime-merge
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

		#% media
		vlc
		mpv
		celluloid

		#% notes
		obsidian
		zim
		keepassxc
		keeweb
		gnome-passwordsafe

		#% communication
		cawbird # Twitter
		#kotatogram-desktop
		discord-ptb
		zoom-us
		streamlink
		chatterino2
		vk-messenger
		tor-browser-bundle-bin

		#% disks stuff
		gnome.gnome-disk-utility
		gparted

		#% relax
		steam
		minetest
		gnome.gnome-mahjongg
		the-powder-toy

		#% overlayed
		(bottles.override {
			bottlesExtraLibraries = pkgs: with pkgs; [ vulkan-loader openxr-loader ];
		})
		cambalache
		#nixos-helper
		twitz

		#% unsorted
		chromium
		contrast
		electron
		electron_15
		fractal
		#gnome.gnome-boxes
		keybase
		kitty
		kooha
		tangram
		ventoy-bin
	];
	fonts.fonts = [
		meslo-lgs-nf # Meslo Nerd Font patched for Powerlevel10k
		iosevka
	];
}
