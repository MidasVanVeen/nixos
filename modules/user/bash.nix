{ config, osConfig, ... }:

{
  programs.bash = {
    enable = true;
    enableCompletion = true;
    initExtra = ''
      PS1='[\u@\h \W]\$ '
      export NIX_SHELL_PRESERVE_PROMPT=1
      bind -x '"\C-n": clear'

      if [ -r /run/secrets/bashrc-secrets ]; then
        set -a
        . <(sed -nE '/^[A-Z][A-Z0-9_]*=/p' /run/secrets/bashrc-secrets)
        set +a
      fi

      _cdp_select() {
        local root repo
        root="$(ghq root)" || return
        repo="$(ghq list | fzf)" || return
        [[ -n "$repo" ]] || return 1
        cd -- "$root/$repo"
      }

      _cdp_has_dev_shell() {
        [[ -f flake.nix ]] || return 1
        local suitable
        # Resolve . just like nix develop: Git flakes exclude untracked and
        # ignored build artifacts instead of copying the entire working tree.
        suitable="$(nix eval --impure --raw .#devShells --apply '
          shells:
          let system = builtins.currentSystem;
          in if builtins.hasAttr system shells
            && ((builtins.getAttr system shells) ? default)
          then "yes" else "no"
        ' 2>/dev/null)" && [[ "$suitable" == yes ]] && return 0

        # Support the older devShell.<system> output as well.
        suitable="$(nix eval --impure --raw .#devShell --apply '
          shells: if builtins.hasAttr builtins.currentSystem shells
          then "yes" else "no"
        ' 2>/dev/null)" && [[ "$suitable" == yes ]]
      }

      cdp() {
        _cdp_select || return
        if _cdp_has_dev_shell; then
          nix develop
        fi
      }

      cdpt() {
        local dir session command
        _cdp_select || return
        dir="$PWD"
        session="''${dir##*/}"
        session="''${session//[.:]/_}"

        # Start the development shell inside tmux so it also works when the
        # tmux server was started before entering the project's environment.
        command='exec bash -i'
        if _cdp_has_dev_shell; then
          command='exec nix develop'
        fi

        if tmux has-session -t "=$session" 2>/dev/null; then
          if [[ -n "''${TMUX:-}" ]]; then
            tmux switch-client -t "=$session"
          else
            tmux attach-session -t "=$session"
          fi
        elif [[ -n "''${TMUX:-}" ]]; then
          tmux new-session -d -s "$session" -c "$dir" "$command" &&
            tmux switch-client -t "=$session"
        else
          tmux new-session -s "$session" -c "$dir" "$command"
        fi
      }

      unzipd() {
        local zip="$1"
        local dest top_count

        [[ -f "$zip" ]] || {
          echo "Usage: unzipd archive.zip" >&2
          return 1
        }

        dest="''${zip##*/}"
        dest="''${dest%.zip}"
        top_count=$(
          unzip -Z1 "$zip" |
            sed '/^$/d; s#^\./##; s#/.*##' |
            sort -u |
            wc -l |
            tr -d ' '
        )

        if [[ "$top_count" -eq 1 ]] && unzip -Z1 "$zip" | grep -q '/'; then
          unzip "$zip"
        else
          mkdir -p "$dest" && unzip "$zip" -d "$dest"
        fi
      }

      clipenv() {
        [[ $# -eq 1 ]] || { echo "Usage: clipenv VARIABLE" >&2; return 2; }
        printenv "$1" | wl-copy
      }

      ghtoken() {
        clipenv GITHUB_TOKEN
      }

      flakeinit() {
        if [[ $# -ne 1 ]]; then
          echo "Usage: flakeinit TEMPLATE" >&2
          return 2
        fi
        nix flake init -t "path:${config.home.homeDirectory}/ghq/github.com/MidasVanVeen/nixos#$1"
      }
    '';
    shellAliases = {
      ls = "ls --color=auto";
      lg = "lazygit";
      v = "nvim";
      t = "tmux";
      tm = "tmux new-session -A -s main";
      vim = "nvim";
      rebuild = "sudo nixos-rebuild switch --flake ${config.home.homeDirectory}/ghq/github.com/MidasVanVeen/nixos#${osConfig.networking.hostName}";
    };
  };
}
