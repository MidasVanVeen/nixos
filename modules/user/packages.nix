{ pkgs, ... }:

{
  home.packages = with pkgs; [
    codex
    curl
    fd
    fzf
    ghq
    jq
    lazygit
    lua-language-server
    nil
    nixfmt
    ripgrep
    socat
    tree-sitter
    tmux
    unzip
    wget
  ];
}
