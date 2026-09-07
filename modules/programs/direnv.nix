{ self, inputs, ... }: {

  flake.homeModules.vvhDirenv = { pkgs, ... }: {

    ## direnv + nix-direnv, hooked into zsh, so that `.envrc` files with
    ## `use flake` in a project folder auto-activate that project's
    ## devShell (see templates/python-ds for the per-project python
    ## template). Pairs with the mkhl.direnv VS Code extension in
    ## vvhVSCode, which loads the same env into VS Code.
    programs.direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };
  };
}
