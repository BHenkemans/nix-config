{
  inputs,
  pkgs,
  lib,
  ...
}:
let
  # Treesitter grammars built by Nix, so nothing has to be compiled at runtime.
  grammars = with pkgs.vimPlugins.nvim-treesitter-parsers; [
    rust
    toml
    ron
    json
    yaml
    markdown
    markdown_inline
    nix
    lua
  ];
in
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
    extraConfig = ''
      -- Nix-provided treesitter parsers + matching queries
      vim.opt.rtp:prepend("${pkgs.vimPlugins.nvim-treesitter}/runtime")
      ${lib.concatMapStringsSep "\n" (g: ''vim.opt.rtp:append("${g}")'') grammars}

      vim.api.nvim_create_autocmd("FileType", {
        callback = function(args)
          pcall(vim.treesitter.start, args.buf)
        end,
      })
    '';
  };
}
