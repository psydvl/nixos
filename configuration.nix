{ config, pkgs, lib, options, ... }:
let
	stored = {
		networking.wireless.networks = import ./networking-wireless-networks.nix;
	};
	packages = import ./packages.nix {
		inherit pkgs;
	};
in {
	nix = {
		#autoOptimiseStore = true;
		settings.auto-optimise-store = true;
		gc = {
			automatic = true;
			dates = "weekly";
			options = "--delete-older-than 30d";
		};
		package = packages.nix;
		extraOptions = ''
			experimental-features = nix-command flakes
		'';
	};

	imports = [
		./hardware-configuration.nix # Include the results of the hardware scan.
		./extra-hardware-configuration.nix
		./specialisation.nix
	];

	fileSystems."/home" = {
		device = "/dev/disk/by-label/home";
		fsType = "ext4";
	};

	hardware.opengl = {
		enable = true;
		extraPackages = with pkgs; [] ++ packages.hardware.opengl.extraPackages;
	};

	# Use the systemd-boot EFI boot loader.
	boot = {
		loader = {
			systemd-boot = {
				enable = true;
				configurationLimit = 12;
				memtest86.enable = true;
				consoleMode = "auto";
			};
			efi = {
				efiSysMountPoint = "/boot";
				canTouchEfiVariables = true;
			};
		};
		kernelPackages = packages.linux;
		kernelParams = [ "threadirq" ];
		supportedFilesystems = [ "ntfs" ];
	};

	# Set your time zone.
	time.timeZone = "Europe/Moscow";

	networking = {
		hostName = "nixos";
		#wireless.enable = true;	# Enables wireless support via wpa_supplicant. -- conflicts with networking.networkmanager by GNOME

		# The global useDHCP flag is deprecated, therefore explicitly set to false here.
		# Per-interface useDHCP will be mandatory in the future, so this generated config
		# replicates the default behaviour.
		useDHCP = false;
		#interfaces.wlp1s0.useDHCP = true;
		#interfaces.enp0s20f0u2.useDHCP = true;

		wireless.networks = stored.networking.wireless.networks;

		timeServers = options.networking.timeServers.default ++ [ "time.cloudflare.com" ]; 
	};

	# Select internationalisation properties.
	i18n = {
		defaultLocale = "en_US.UTF-8";
		supportedLocales = [
			"en_US.UTF-8/UTF-8"
			"ru_RU.UTF-8/UTF-8"
		];
	};
	console = {
		font = "Lat2-Terminus16";
		keyMap = "us";
	};

	systemd.services.NetworkManager-wait-online.enable = false;

	services = {
		accounts-daemon.enable = true;
		fwupd.enable = true;
		flatpak.enable = true;
		sysprof.enable = true;

		# Enable the X11 windowing system.
		xserver.enable = true;

		# Enable the GNOME Desktop Environment.
		# With Wayland
		xserver.displayManager.gdm = {
			enable = true;
			wayland = true;
		};
		xserver.desktopManager.gnome.enable = true;

		# Enable the KDE Desktop Environment.
		#xserver.displayManager.sddm.enable = true;
		#xserver.desktopManager.plasma5.enable = true;

		# Configure keymap in X11
		#xserver.layout = "us";
		#xserver.xkbOptions = "eurosign:e";

		# Enable CUPS to print documents.
		printing = {
			enable = true;
			drivers = packages.printing.drivers;
		};
	};

	virtualisation = {
		libvirtd.enable = true;
		podman = {
			enable = true;

			# Create a `docker` alias for podman, to use it as a drop-in replacement
			dockerCompat = true;
		};
	};

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
		jack.enable = true;
		wireplumber.enable = true;
		media-session.enable = false;

		#media-session.config.bluez-monitor.rules = [
		#	{
		#		# Matches all cards
		#		matches = [ { "device.name" = "~bluez_card.*"; } ];
		#		actions = {
		#			"update-props" = {
		#				"bluez5.reconnect-profiles" = [ "hfp_hf" "hsp_hs" "a2dp_sink" ];
		#				# mSBC is not expected to work on all headset + adapter combinations.
		#				"bluez5.msbc-support" = true;
		#				# SBC-XQ is not expected to work on all headset + adapter combinations.
		#				"bluez5.sbc-xq-support" = true;
		#			};
		#		};
		#	}
		#	{
		#		matches = [
		#			# Matches all sources
		#			{ "node.name" = "~bluez_input.*"; }
		#			# Matches all outputs
		#			{ "node.name" = "~bluez_output.*"; }
		#		];
		#		actions = {
		#			"node.pause-on-idle" = false;
		#		};
		#	}
		#];
		config.pipewire = {
			"context.properties" = {
				#"link.max-buffers" = 64;
				"link.max-buffers" = 16; # version < 3 clients can't handle more than this
				"log.level" = 2; # https://docs.pipewire.org/page_daemon.html
				#"default.clock.rate" = 48000;
				#"default.clock.quantum" = 1024;
				#"default.clock.min-quantum" = 32;
				#"default.clock.max-quantum" = 8192;
 			};
 		};
		config.pipewire-pulse = {
			"context.properties" = {
				"log.level" = 2;
			};
			"context.modules" = [
				{
					name = "libpipewire-module-rtkit";
					args = {
						"nice.level" = -15;
						"rt.prio" = 88;
						"rt.time.soft" = 200000;
						"rt.time.hard" = 200000;
					};
					flags = [ "ifexists" "nofail" ];
				}
				{ name = "libpipewire-module-protocol-native"; }
				{ name = "libpipewire-module-client-node"; }
				{ name = "libpipewire-module-adapter"; }
				{ name = "libpipewire-module-metadata"; }
				{
					name = "libpipewire-module-protocol-pulse";
					args = {
						"pulse.min.req" = "32/48000";
						"pulse.default.req" = "32/48000";
						"pulse.max.req" = "32/48000";
						"pulse.min.quantum" = "32/48000";
						"pulse.max.quantum" = "32/48000";
						"server.address" = [ "unix:native" ];
					};
				}
			];
			"stream.properties" = {
				"node.latency" = "32/48000";
				"resample.quality" = 1;
			};
		};
	};

	# Enable touchpad support (enabled default in most desktopManager).
	# services.xserver.libinput.enable = true;

	environment= {
		gnome.excludePackages = [ pkgs.orca ];
		sessionVariables = {
			XDG_CACHE_HOME		= "\${HOME}/.cache";
			XDG_CONFIG_HOME		= "\${HOME}/.config";
			XDG_BIN_HOME		= "\${HOME}/.local/bin";
			XDG_DATA_HOME		= "\${HOME}/.local/share";
			QT_QPA_PLATFORM		= "wayland";
			SDL_VIDEODRIVER		= "wayland";
			LIBVA_DRIVER_NAME 	= "iHD";

			PATH = [
				"\${XDG_BIN_HOME}"
			];
		};
		systemPackages = with pkgs; [
		] ++ packages.environment.systemPackages;
		pathsToLink = [
			"/share/nix-direnv"
		];
	fonts.fonts = with pkgs; [] ++ packages.fonts.fonts;

	programs = {
		adb.enable = true;
		dconf.enable = true;
		gamemode.enable = true;
		steam.enable = true;
		vim.defaultEditor = true;
		xwayland.enable = true;
		zsh = {
			enable = true;
			promptInit = "source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
			interactiveShellInit = "source ${pkgs.zsh-nix-shell}/share/zsh-nix-shell/nix-shell.plugin.zsh"; # zsh-nix-shell
			ohMyZsh = {
				enable = true;
			};
			shellAliases = {
				store = "ls /nix/store | grep";
			};
		};
	};

	# Define a user account. Don't forget to set a password with ‘passwd’.
	users.users.nixi = {
		isNormalUser = true;
		shell = pkgs.zsh;
		extraGroups = [
			"wheel" # Enable ‘sudo’ for the user.
			"networkmanager"
			"adbusers"
			"libvirtd"
		];
	};
	users.extraUsers.root.shell = pkgs.zsh;

	# This value determines the NixOS release from which the default
	# settings for stateful data, like file locations and database versions
	# on your system were taken. It‘s perfectly fine and recommended to leave
	# this value at the release version of the first install of this system.
	# Before changing this value read the documentation for this option
	# (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
	system.stateVersion = "21.05"; # Did you read the comment?
}

