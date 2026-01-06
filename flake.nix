{
  description = "NixOS Configuration with Device Types and Home Manager";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    # Home Manager
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, sops-nix, home-manager }: {
    nixosConfigurations = {
      # VMware VM
      vmware = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          sops-nix.nixosModules.sops
          ./hardware-configuration.nix
          ./configuration.nix
          ./sops.nix
          { device.type = "vmware"; }
          
          # Home Manager Integration
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

            home-manager.sharedModules = [
              sops-nix.homeManagerModules.sops
            ];
            home-manager.users.stinooo = import ./home.nix;
          }
        ];
      };
      
      # VirtualBox VM
      virtualbox = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          sops-nix.nixosModules.sops
          ./hardware-configuration.nix
          ./configuration.nix
          ./sops.nix
          { device.type = "virtualbox"; }
          
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

            home-manager.sharedModules = [
              sops-nix.homeManagerModules.sops
            ];
            home-manager.users.stinooo = import ./home.nix;
          }
        ];
      };
      
      # Laptop
      laptop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          sops-nix.nixosModules.sops
          ./hardware-configuration-laptop.nix
          ./configuration.nix
          ./sops.nix
          { device.type = "laptop"; }
          
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

            home-manager.sharedModules = [
              sops-nix.homeManagerModules.sops
            ];
            home-manager.users.stinooo = import ./home.nix;
          }
        ];
      };
      
      # Desktop PC
      desktop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          sops-nix.nixosModules.sops
          ./hardware-configuration-desktop.nix
          ./configuration.nix
          ./sops.nix
          { device.type = "desktop"; }
          
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

            home-manager.sharedModules = [
              sops-nix.homeManagerModules.sops
            ];
            home-manager.users.stinooo = import ./home.nix;
          }
        ];
      };
    };
  };
}
