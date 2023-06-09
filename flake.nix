{
  description = "Mob Time, the most fun";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages."${system}";
      in
      {
        devShell = pkgs.mkShell {
          packages = with pkgs; [
            nodejs_20
            yarn
            nodePackages.gitmoji-cli
            lame
            imageworsener
          ];
          shellHook = ''
            yarn install
          '';
        };
      });
}
