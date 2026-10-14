{ pkgs, ... }:

let
  artcraftBundle =
    {
      name,
      version,
      hash,
    }:
    {
      appId = "ai.storyteller.${name}";
      sha256 = hash;
      bundle = toString (
        pkgs.fetchurl {
          url = "https://github.com/storytold/${name}/releases/download/v${version}/${name}-${version}-linux-aarch64.flatpak";
          inherit hash;
        }
      );
    };
in
{
  services.flatpak = {
    enable = true;
    remotes = [
      {
        name = "flathub";
        location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
      }
    ];
    packages = [
      (artcraftBundle {
        name = "photocraft";
        version = "0.8.2";
        hash = "sha256-RnNFFWBD8gxWC/RqQxGzEiyIzt3Mnkw4wvYd8oc75Uo=";
      })
      (artcraftBundle {
        name = "vectorcraft";
        version = "0.10.0";
        hash = "sha256-0kGKRi0EepWTMXGje8HL8OFMeEQHVnycIAAYea6A4Uk=";
      })
      (artcraftBundle {
        name = "filmcraft";
        version = "0.7.2";
        hash = "sha256-mfoEEzfEk8B7OK3CX6zqQ0jnzqddEVmevJe/l4pPABA=";
      })
      (artcraftBundle {
        name = "pdfcraft";
        version = "0.7.1";
        hash = "sha256-/YoHhwLXJMICwP6Wqeo5/cgepzWkpcYeWKAxMVn71MU=";
      })
      # (artcraftBundle {
      #   name = "lightcraft";
      #   version = "0.7.1";
      #   hash = "sha256-kh2mdiaba3QHIrgLs2C4GrsABucfu2af+3EEK+LgMPE=";
      # })
      # (artcraftBundle {
      #   name = "designcraft";
      #   version = "0.7.1";
      #   hash = "sha256-hwVBIqar4ekR9yKtfX8hrCrtxqciN8HR8YxFAZ+7s4g=";
      # })
      # (artcraftBundle {
      #   name = "effectcraft";
      #   version = "0.6.0";
      #   hash = "sha256-22Uj+AJnpYcryusJOMDBVMxOln34URcc2o4bGXI9+cg=";
      # })
      # (artcraftBundle {
      #   name = "figcraft";
      #   version = "0.5.1";
      #   hash = "sha256-FmvCibOi+ZvSi5PiAcqJZ4kbGJ8TBZih9iBLzBFmeLE=";
      # })
      # (artcraftBundle {
      #   name = "wordcraft";
      #   version = "0.5.0";
      #   hash = "sha256-KDv61HG3XRNQUPKQouWDxL19k5Ot6MOubnDxoHPU5t4=";
      # })
      # (artcraftBundle {
      #   name = "soundcraft";
      #   version = "0.5.0";
      #   hash = "sha256-RQT7u4P4PfpfcBk2TV7RF6bya62hMFrBlDS2as4qOxc=";
      # })
      # (artcraftBundle {
      #   name = "deckcraft";
      #   version = "0.6.1";
      #   hash = "sha256-66ekZVjrTGfbQaHfwa823vMztz7QEqq/QioDptlUSkY=";
      # })
      # (artcraftBundle {
      #   name = "cadcraft";
      #   version = "0.5.0";
      #   hash = "sha256-R34kLRy9hhkGbfztLvMaTlJnnFylF4Osk9KTM3Dz7J4=";
      # })
      (artcraftBundle {
        name = "gridcraft";
        version = "0.6.1";
        hash = "sha256-/5SFZsabTBu8VejgJgJQA5YGojXAslAZ2zSk5Bk9lSw=";
      })
    ];
  };
}
