{
	inputs = {
		nixos.url = "github:NixOS/nixpkgs/nixos-21.11";
		nixos-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
		mozilla = { url = "github:mozilla/nixpkgs-mozilla"; flake = false; };
	};

	outputs = inputs:
		let
			system = "x86_64-linux";
		in
		{
			nixosConfigurations.nixos = inputs.nixos.lib.nixosSystem {
				inherit system;
				specialArgs = {
					inherit inputs;
				};
				modules = [
						({ config, pkgs, lib, ... }:
						let
							unstable-overlay = final: prev: {
								unstable = import inputs.nixos-unstable {
									inherit system;
									config.allowUnfree = true;
								};
							};
						in
						{
							nixpkgs.pkgs = import inputs.nixos {
								inherit system;
								config.allowUnfree = true;
							};
							nixpkgs.config.allowUnfree = true;
							nixpkgs.overlays = [
								(import "${inputs.mozilla}/firefox-overlay.nix")
								unstable-overlay
							];
						})
						./configuration.nix
					];
			};
		};
}
