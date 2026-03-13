_ : {
  nixpkgs.config.allowUnfree = true;
  nix = {
    settings = {
      accept-flake-config = true;
      trusted-users = [ "@admin" "bartjan" ];
      substituters = [ 
        "https://nix-community.cachix.org" 
        "https://cache.nixos.org" 
        "https://luukblankenstijn.cachix.org"
      ];
      trusted-public-keys = [ 
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" 
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=" 
        "luukblankenstijn.cachix.org-1:gRz/ypm8zdDizcdAuWD6UKLVBDeObfHsNDWoAka2WSw="
      ];
      experimental-features = "nix-command flakes";
    };
  };
}