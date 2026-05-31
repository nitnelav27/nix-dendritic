{ self, inputs, ... }: {

  flake.homeModules.vvhGit = { config, lib, pkgs, ... }: {
    programs.git = {
      enable = true;
      settings = {
        credential.helper = "store";
        user = {
          name = "Valentín Vergara Hidd";
          email = "valentinvergara@gmail.com";
        };
      };
    };
  };
}
