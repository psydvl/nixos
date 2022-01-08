{ config, pkgs, lib, ... }:
let
	stored = {
		networking.wireless.networks = import ./networking-wireless-networks.nix;
		fileSystems."/home" = import ./fileSystems-home.nix;
	};
	packages = import ./packages.nix {
		inherit pkgs;
	};

	environment.sessionVariables = {
		XDG_CACHE_HOME	= "\${HOME}/.cache";
		XDG_CONFIG_HOME	= "\${HOME}/.config";
		XDG_BIN_HOME	= "\${HOME}/.local/bin";
		XDG_DATA_HOME	= "\${HOME}/.local/share";
		QT_QPA_PLATFORM	= "wayland";
		SDL_VIDEODRIVER	= "wayland";

		PATH = [
			"\${XDG_BIN_HOME}"
		];
	};
in {
	nix = {
		autoOptimiseStore = true;
		gc = {
			automatic = true;
			dates = "weekly";
			options = "--delete-older-than 30d";
		};
		package = packages.nix;
		extraOptions = ''
			experimental-features = nix-command flakes
			keep-outputs = true
			keep-derivations = true
		'';
	};

	imports = [
		./hardware-configuration.nix # Include the results of the hardware scan.
	];

	fileSystems."/home" = stored.fileSystems."/home";

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
		supportedFilesystems = [ "ntfs" ];
	};
	
	
	# Set your time zone.
	time.timeZone = "Europe/Moscow";

	networking = {
		hostName = "nixos";
		# networking.wireless.enable = true;	# Enables wireless support via wpa_supplicant. -- conflicts with networking.networkmanager by GNOME

		# The global useDHCP flag is deprecated, therefore explicitly set to false here.
		# Per-interface useDHCP will be mandatory in the future, so this generated config
		# replicates the default behaviour.
		useDHCP = false;
		interfaces.wlp1s0.useDHCP = true;

		wireless.networks = stored.networking.wireless.networks;

		# Configure network proxy if necessary
		# networking.proxy.default = "http://user:password@proxy:port/";
		# networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";
	};


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

	services = {
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
		# If you want to use JACK applications, uncomment this
		jack.enable = true;

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
			"adbusers"
		];
	};
	users.extraUsers.root.shell = pkgs.zsh;

	environment.systemPackages = with pkgs; [
	] ++ packages.environment.systemPackages;
	environment.pathsToLink = [
		"/share/nix-direnv"
	];
	fonts.fonts = with pkgs; [] ++ packages.fonts.fonts;

	programs = {
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
		vim.defaultEditor = true;
		adb.enable = true;
		steam.enable = true;
	};

	# This value determines the NixOS release from which the default
	# settings for stateful data, like file locations and database versions
	# on your system were taken. It‘s perfectly fine and recommended to leave
	# this value at the release version of the first install of this system.
	# Before changing this value read the documentation for this option
	# (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
	system.stateVersion = "21.05"; # Did you read the comment?
}

