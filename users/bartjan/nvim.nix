{
  inputs,
  pkgs,
  ...
}:
{
  imports = [
    inputs.nix4nvchad.homeManagerModule
  ];
  programs.nvchad = {
    enable = true;
    extraPackages = with pkgs; [
      harper
      rust-analyzer
      lldb
      cargo-nextest
      bacon
      rustfmt
    ];
  };
}
