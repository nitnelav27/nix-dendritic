{
  description = "Per-project Python data-science dev shell";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };

        ## Edit this list per project -- that's the whole point of the
        ## template. Add/remove python packages here, then `direnv reload`
        ## (or just cd out and back in) to rebuild the environment.
        pythonEnv = pkgs.python3.withPackages (ps: with ps; [
          numpy
          scipy
          pandas
          matplotlib
          networkx
          sqlalchemy
          jupyter
          jupyterlab
          ipykernel
          pip
          black
          flake8
          mypy
          debugpy
          isort
        ]);
      in
      {
        devShells.default = pkgs.mkShell {
          packages = [ pythonEnv ];

          shellHook = ''
            echo "python-ds devShell active: $(python3 --version)"
          '';
        };
      });
}
