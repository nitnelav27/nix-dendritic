{ lib, ... }: {

  options.flake.darwinModules = lib.mkOption {

    type = lib.types.lazyAttrsOf lib.types.unspecified;
    default = {};
    description = "darwin modules exported by this flake";
  };

}
