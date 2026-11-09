{ self, inputs, ... }: {
  ## Noctalia v5 (native rewrite; replaced the Quickshell-based v4
  ## `noctalia-shell`, which nixpkgs removed). Config lives in ./noctalia.toml
  ## and is written to $NOCTALIA_CONFIG_HOME/noctalia/settings.toml.
  ## Runtime edits from the Settings window go to
  ## ~/.local/state/noctalia/settings.toml and layer on top.
  perSystem = { pkgs, ... }: {
    packages.vvhNoctalia = inputs.wrapper-modules.wrappers.noctalia.wrap {
      inherit pkgs;
      settings = builtins.fromTOML (builtins.readFile ./noctalia.toml);
    };
  };
}
