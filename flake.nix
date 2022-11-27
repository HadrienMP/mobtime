{
  description = "Mob Time, the most fun";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages."${system}";
        update_sounds_requirements = with pkgs; [
          curl
          gnutar
          gnused
          gawk
        ];
      in
      {
        devShell = pkgs.mkShell {
          packages = with pkgs; [
            nodejs-18_x
            yarn
            nodePackages.gitmoji-cli
            lame
            audacity
            imageworsener
            elmPackages.elm
            elmPackages.elm-test
            elmPackages.elm-json
            elmPackages.elm-format
            elmPackages.elm-review
          ] ++ update_sounds_requirements;
          shellHook = ''
            yarn install
          '';
        };
      });
}
