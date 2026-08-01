{
  inputs,
  pkgs,
  ...
}:
{
  imports = [
    inputs.nix4nvchad.homeManagerModules.nvchad
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
