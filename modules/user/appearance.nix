{ pkgs, ... }:

{
  home.pointerCursor = {
    enable = true;
    name = "Adwaita";
    package = pkgs.adwaita-icon-theme;
    size = 24;
    gtk.enable = true;
  };

  gtk = {
    enable = true;
    theme = {
      name = "adw-gtk3-dark";
      package = pkgs.adw-gtk3;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package =
        pkgs.runCommand "papirus-dark-red"
          {
            nativeBuildInputs = [ pkgs.gtk3 ];
          }
          ''
            mkdir -p "$out/share/icons"
            cp -rL "${pkgs.papirus-icon-theme}/share/icons/Papirus-Dark" "$out/share/icons/"
            theme="$out/share/icons/Papirus-Dark"
            chmod -R u+w "$theme"

            # Papirus has red variants for some folders, but icons such as
            # folder-open and folder-publicshare only exist in the base color.
            for icon in "$theme"/*/places/folder*.svg "$theme"/*/places/user*.svg; do
              [ -f "$icon" ] || continue
              sed -i \
                -e 's/#4877b1/#bf4b4b/g' \
                -e 's/#5294e2/#e25252/g' \
                -e 's/#1d344f/#4f1d1d/g' \
                -e 's/ColorScheme-Text { color:#dfdfdf;/ColorScheme-Text { color:#e25252;/g' \
                "$icon"
            done

            for source in "$theme"/*/places/folder-red*.svg "$theme"/*/places/user-red*.svg; do
              [ -f "$source" ] || continue
              name="''${source##*/}"
              link="''${source%/*}/''${name/-red/}"
              ln -sf "$name" "$link"
            done
            for places in "$theme"/*/places; do
              [ -f "$places/folder.svg" ] || continue
              ln -sf folder.svg "$places/inode-directory.svg"
              ln -sf folder.svg "$places/folder-empty.svg"
            done
            gtk-update-icon-cache --force "$theme"
          '';
    };
    gtk3.extraCss = builtins.readFile ../../dotfiles/gtk.css;
    gtk4.extraCss = builtins.readFile ../../dotfiles/gtk.css;
  };

  qt = {
    enable = true;
    platformTheme.name = "gtk3";
    style.name = "adwaita-dark";
  };

  dconf.settings."org/gnome/desktop/interface" = {
    color-scheme = "prefer-dark";
    gtk-theme = "adw-gtk3-dark";
  };
}
