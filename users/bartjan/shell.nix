{ pkgs , ... } :
{
  programs = {
    zsh = {
      enable = true;
      autosuggestion.enable = true;
      enableCompletion = true;
      syntaxHighlighting.enable = true;
      initContent = ''
        fpath+=("${pkgs.pure-prompt}/share/zsh/site-functions")
        autoload -Uz promptinit; promptinit
        prompt pure
      '';
    };
  };
}