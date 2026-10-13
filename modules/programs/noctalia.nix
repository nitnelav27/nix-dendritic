{ self, inputs, ... }: {
  perSystem = { pkgs, ... }: {
    packages.vvhNoctalia = inputs.wrapper-modules.wrappers.noctalia-shell.wrap {
      inherit pkgs;
      ## breakpad currently fails to link on nixos-unstable (vtable for
      ## FastSourceLineResolver::Module). noctalia-qs only lists it as a
      ## buildInput -- its CRASH_HANDLER cmake option defaults to OFF -- so
      ## dropping it is a no-op functionally. Remove once breakpad builds again.
      package = pkgs.noctalia-shell.override {
        noctalia-qs = pkgs.noctalia-qs.override { breakpad = null; };
      };
      settings =
        (builtins.fromJSON
          (builtins.readFile ./noctalia.json)).settings;
    };
  };
}
