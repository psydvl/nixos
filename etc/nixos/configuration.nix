# Edit this configuration file to define what should be installed on
# your system.	Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
	stored = {
		networking.wireless.networks = import ./networking-wireless-networks.nix;
		fileSystems."/home" = import ./fileSystems-home.nix;
	};
	# sudo nix-channel --add https://nixos.org/channels/nixos-unstable nixos-unstable
	# sudo nix-channel --update
	unstable = import <nixos-unstable> {
		config = {
			allowUnfree = true;
		};
	};
in {
	imports =
		[ # Include the results of the hardware scan.
			./hardware-configuration.nix
		];
	fileSystems."/home" = stored.fileSystems."/home";

	# Use the systemd-boot EFI boot loader.
	boot.loader.systemd-boot.enable = true;
	boot.loader.efi.canTouchEfiVariables = true;
	
	boot.kernelPackages = pkgs.linuxPackages_zen;
	
	boot.supportedFilesystems = [ "ntfs" ];

	networking.hostName = "nixos";
	# networking.wireless.enable = true;	# Enables wireless support via wpa_supplicant. -- conflicts with networking.networkmanager by GNOME 

	# Set your time zone.
	time.timeZone = "Europe/Moscow";

	# The global useDHCP flag is deprecated, therefore explicitly set to false here.
	# Per-interface useDHCP will be mandatory in the future, so this generated config
	# replicates the default behaviour.
	networking.useDHCP = false;
	networking.interfaces.enp0s20f0u1u2.useDHCP = true;
	networking.interfaces.wlp1s0.useDHCP = true;
	
	networking.wireless.networks = stored.networking.wireless.networks;

	# Configure network proxy if necessary
	# networking.proxy.default = "http://user:password@proxy:port/";
	# networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

	# Select internationalisation properties.
	i18n = {
		defaultLocale = "en_US.UTF-8";
		supportedLocales = [
			"ru_RU.UTF-8/UTF-8"
			"en_US.UTF-8/UTF-8"
		];
	};
	console = {
		font = "Lat2-Terminus16";
		keyMap = "us";
	};

	# Enable the X11 windowing system.
	services.xserver.enable = true;


	# Enable the GNOME Desktop Environment.
	# With Wayland	
	services.xserver.displayManager.gdm.wayland = true;
	services.xserver.displayManager.gdm.enable = true;
	services.xserver.desktopManager.gnome.enable = true;

	# Enable the KDE Desktop Environment.
	# services.xserver.displayManager.sddm.enable = true;
	# services.xserver.desktopManager.plasma5.enable = true;
	

	# Configure keymap in X11
	# services.xserver.layout = "us";
	# services.xserver.xkbOptions = "eurosign:e";

	# Enable CUPS to print documents.
	# services.printing.enable = true;

	# Remove sound.enable or turn it off if you had it set previously, it seems to cause conflicts with pipewire
	# sound.enable = false;
	hardware.pulseaudio.enable = false;

	# rtkit is optional but recommended
	security.rtkit.enable = true;
	services.pipewire = {
		enable = true;
		alsa.enable = true;
		alsa.support32Bit = true;
		pulse.enable = true;
		# If you want to use JACK applications, uncomment this
		#jack.enable = true;

		# use the example session manager (no others are packaged yet so this is enabled by default,
		# no need to redefine it in your config for now)
		#media-session.enable = true;
		
		media-session.config.bluez-monitor.rules = [
			{
				# Matches all cards
				matches = [ { "device.name" = "~bluez_card.*"; } ];
				actions = {
					"update-props" = {
						"bluez5.reconnect-profiles" = [ "hfp_hf" "hsp_hs" "a2dp_sink" ];
						# mSBC is not expected to work on all headset + adapter combinations.
						"bluez5.msbc-support" = true;
						# SBC-XQ is not expected to work on all headset + adapter combinations.
						"bluez5.sbc-xq-support" = true;
					};
				};
			}
			{
				matches = [
					# Matches all sources
					{ "node.name" = "~bluez_input.*"; }
					# Matches all outputs
					{ "node.name" = "~bluez_output.*"; }
				];
				actions = {
					"node.pause-on-idle" = false;
				};
			}
		];
	};

	# Enable touchpad support (enabled default in most desktopManager).
	# services.xserver.libinput.enable = true;

	# Define a user account. Don't forget to set a password with ‘passwd’.
	users.users.nixi = {
		isNormalUser = true;
		shell = pkgs.zsh;
		extraGroups = [
			"wheel" # Enable ‘sudo’ for the user.
			"networkmanager"
			];
	};
	users.extraUsers.root.shell = pkgs.zsh;

	# Allow to install non-free packages
	nixpkgs.config.allowUnfree = true;	
	
	# List packages installed in system profile. To search, run:
	# $ nix search wget
	environment.systemPackages = with pkgs; [
		wget
		gitFull
		htop
		vim
		glow
		
		zsh
		oh-my-zsh
		zsh-powerlevel10k
		zsh-nix-shell
		
		nix-tree
		
		go
		conda
		
		sl
		ffmpeg-full
		youtube-dl
		gallery-dl
		
		# GUI
		gnome.gnome-tweaks
		gnomeExtensions.caffeine
		gnomeExtensions.maxi
		desktop-file-utils
		
		firefox-wayland
		zathura
		tdesktop
		unstable.keeweb
		
		guake
		pantheon.elementary-code
		vscode
		glade
		chromium
		
		steam
		gnome.gnome-disk-utility
	];

	# Some programs need SUID wrappers, can be configured further or are
	# started in user sessions.
	# programs.mtr.enable = true;
	# programs.gnupg.agent = {
	#	 enable = true;
	#	 enableSSHSupport = true;
	# };
	programs.xwayland.enable = true;
	programs.zsh = {
		enable = true;
		promptInit = "source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
		interactiveShellInit = "source ${pkgs.zsh-nix-shell}/share/zsh-nix-shell/nix-shell.plugin.zsh"; # zsh-nix-shell
	};
	programs.sway = {
		enable = true;
		wrapperFeatures.gtk = true; # so that gtk works properly
		extraPackages = with pkgs; [
			swaylock
			swayidle
			wl-clipboard
			mako # notification daemon
			alacritty # Alacritty is the default terminal in the config
			dmenu # Dmenu is the default in the config but i recommend wofi since its wayland native
  		];
	};
	programs.steam.enable = true;

	# List services that you want to enable:

	# Enable the OpenSSH daemon.
	# services.openssh.enable = true;

	# Open ports in the firewall.
	# networking.firewall.allowedTCPPorts = [ ... ];
	# networking.firewall.allowedUDPPorts = [ ... ];
	# Or disable the firewall altogether.
	# networking.firewall.enable = false;

	# This value determines the NixOS release from which the default
	# settings for stateful data, like file locations and database versions
	# on your system were taken. It‘s perfectly fine and recommended to leave
	# this value at the release version of the first install of this system.
	# Before changing this value read the documentation for this option
	# (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
	system.stateVersion = "21.05"; # Did you read the comment?

}

