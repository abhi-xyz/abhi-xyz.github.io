{
  description = "A Nix-flake-based hugo development environment";

  inputs.nixpkgs.url = "nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forEachSupportedSystem = f: nixpkgs.lib.genAttrs supportedSystems (system: f {
        pkgs = import nixpkgs { inherit system; };
      });
    in
      {
      devShells = forEachSupportedSystem ({ pkgs }: {
        default = pkgs.mkShell {
          packages = with pkgs; [
            deno
            hugo
            tailwindcss
            tailwindcss-language-server
            go
            nodejs
            neovim
          ];
          shellHook = ''
      export PATH=$PATH:''${CARGO_HOME:-~/.cargo}/bin
      echo "Environment ready!" | ${pkgs.lolcat}/bin/lolcat
      '';
          runcmd = "fish";
        };
      });
    };
}
