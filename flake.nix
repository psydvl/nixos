{
	inputs = {
		nixos-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
		#nixos-unstable-small.url = "github:NixOS/nixpkgs/nixos-unstable-small";
		#master.url = "github:NixOS/nixpkgs/master";
		#nixos-2111.url = "github:NixOS/nixpkgs/nixos-21.11";
		#nixpkgs.url = "github:NixOS/nixpkgs";
		#bisect.url = "github:NixOS/nixpkgs/";

		#nur.url = "github:nix-community/NUR";
		#home-manager.url = "github:nix-community/home-manager";
		psydvl = { url = "path:/work/Projects/nixpkgs-overlay/"; flake = false; };
	};

	outputs = inputs:
		let
			system = "x86_64-linux";
			nixospkgs = inputs.nixos-unstable;
		in
		{
			nixosConfigurations.nixos = nixospkgs.lib.nixosSystem {
				inherit system;
				specialArgs = {
					inherit inputs;
				};
				modules = [
						({ config, pkgs, lib, ... }:
							{
								nixpkgs.pkgs = import nixospkgs {
									inherit system;
									config.allowUnfree = true;
								};
								nixpkgs.config.allowUnfree = true;
								nixpkgs.overlays = [
									(import "${inputs.psydvl}/overlay.nix")
									#inputs.nur.overlay
								];
								nix.registry.np.flake = nixospkgs;
							}
						)
						./configuration.nix
					];
			};
		};
}
