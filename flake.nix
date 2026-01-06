{
  description = "NixOS Configuration with Device Types and Home Manager";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    
    # Home Manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager }: {
    nixosConfigurations = {
      # VMware VM
      vmware = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hardware-configuration.nix
          ./configuration.nix
          ./sops.nix
          { device.type = "vmware"; }
          
          # Home Manager Integration
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.stinooo = import ./home.nix;
          }
        ];
      };
      
      # VirtualBox VM
      virtualbox = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hardware-configuration.nix
          ./configuration.nix
          ./sops.nix
          { device.type = "virtualbox"; }
          
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.stinooo = import ./home.nix;
          }
        ];
      };
      
      # Laptop
      laptop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hardware-configuration-laptop.nix
          ./configuration.nix
          ./sops.nix
          { device.type = "laptop"; }
          
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.stinooo = import ./home.nix;
          }
        ];
      };
      
      # Desktop PC
      desktop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hardware-configuration-desktop.nix
          ./configuration.nix
          ./sops.nix
          { device.type = "desktop"; }
          
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.stinooo = import ./home.nix;
          }
        ];
      };
    };
  };
}
