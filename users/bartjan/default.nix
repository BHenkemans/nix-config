_: {
  # Shared user config for every platform. The platform-specific half
  # (./darwin or ./linux) is added alongside this module by flake.nix, the
  # same way hosts/*/configuration.nix imports modules/workstations plus its
  # modules/workstations/<platform> sibling.
  #
  # The dispatch deliberately does NOT live here as
  # `lib.optional pkgs.stdenv.isDarwin ./darwin`: Home Manager resolves `pkgs`
  # through `_module.args`, which requires `config`, so referencing it in
  # `imports` is an infinite-recursion trap even with `useGlobalPkgs = true`.
  imports = [
    ./firefox.nix
    ./git.nix
    ./nvim.nix
    ./terminal.nix
    ./vscode.nix
  ];

  home.sessionVariables = {
    EDITOR = "vim";
  };

  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/.cargo/bin"
  ];

  # home.homeDirectory is derived from users.users.bartjan.home, set per
  # platform in modules/workstations/users.nix.
  home.stateVersion = "25.11";
  programs.home-manager.enable = true;
}
