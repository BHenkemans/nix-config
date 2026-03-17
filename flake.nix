{
  description = "Bartjan's machines flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-homebrew.url = "github:zhaofengli/nix-homebrew";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-repo = {
      url = "github:BHenkemans/nix-secrets";
      flake = false; 
    };
    
    nvchad-starter = {
      url = "github:BHenkemans/starter"; 
      flake = false;
    };

    nix4nvchad = {
      url = "github:nix-community/nix4nvchad";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nvchad-starter.follows = "nvchad-starter";
    };
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, home-manager, nix-homebrew, sops-nix, nix4nvchad, nvchad-starter, sops-repo }: {
    
    darwinConfigurations."air" = nix-darwin.lib.darwinSystem {
      specialArgs = { inherit self inputs; }; 
      modules = [ 
        nix-homebrew.darwinModules.nix-homebrew 
        {
          nix-homebrew = {
            enable = true;
            user = "bartjan";
          };
        }
        home-manager.darwinModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            extraSpecialArgs = { inherit inputs; }; #For SOPS
            users.bartjan = import ./users/bartjan;
          };
        }
        sops-nix.darwinModules.sops
        ./hosts/air/configuration.nix
      ];
    };
  };
}