{
  services.comin = {
    enable = true;
    remotes = [
      {
        name = "origin";
        url = "https://github.com/MidasVanVeen/nixos";
        branches.main.name = "main";
      }
    ];
  };
}
