{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    roc = {
      url = "github:roc-lang/roc?dir=src";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-linux"
      ];
      perSystem =
        {
          inputs',
          pkgs,
          system,
          ...
        }:
        {
          devShells.default = pkgs.mkShell {
            packages = [
              inputs'.roc.packages.roc
              pkgs.actionlint
              pkgs.check-jsonschema
              pkgs.just
              pkgs.nixfmt
              pkgs.prettier
              pkgs.pre-commit
              pkgs.python3Packages.pre-commit-hooks
              pkgs.ratchet
            ];
            enterShell = "pre-commit install --overwrite";
          };
          formatter = pkgs.nixfmt-tree;
        };
    };
}
