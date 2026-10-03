{
  description = "Zig project";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { nixpkgs, ... }:
    let
      systems = [
        "aarch64-linux"
        "x86_64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          # Add project-specific system libraries here, for example pkgs.openssl.
          systemLibraries = with pkgs; [ ];
        in
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              zig
              zls
              pkg-config
            ];
            buildInputs = systemLibraries;
          };
        }
      );
    };
}
