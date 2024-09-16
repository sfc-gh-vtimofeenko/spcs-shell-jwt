{
  description = "Description for the project";

  inputs = {
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixpkgs.follows = "nixpkgs-stable";

    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    git-hooks-nix = {
      url = "github:cachix/git-hooks.nix";
      inputs = {
        nixpkgs.follows = "nixpkgs-unstable";
        nixpkgs-stable.follows = "nixpkgs-stable";
      };
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.devshell.flakeModule
        inputs.git-hooks-nix.flakeModule
        inputs.treefmt-nix.flakeModule
      ];
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];
      perSystem =
        { config, pkgs, ... }:
        {
          packages.default = pkgs.writeShellApplication {
            name = "spcs-jwt-connect";

            runtimeInputs = builtins.attrValues {
              inherit (pkgs)
                curl
                jwt-cli
                coreutils-full
                openssl
                ;

            };
            text = builtins.readFile ./src/spcs-jwt-connect.sh;
          };

          treefmt = {
            programs = {
              nixfmt.enable = true;
              shfmt.enable = true;
            };
            projectRootFile = "flake.nix";
          };

          pre-commit.settings = {
            hooks = {
              treefmt = {
                enable = true;
                package = config.treefmt.build.wrapper;
              };
              shellcheck = {
                enable = true;
              };
            };
          };

          devshells.default = {
            commands = [
              {
                help = "run all checks";
                name = "ci-check";
                command =
                  # bash
                  ''
                    pushd $PRJ_ROOT
                    nix flake check
                    popd
                  '';
              }
            ];
          };

          devShells.pre-commit = config.pre-commit.devShell;
        };
    };
}
