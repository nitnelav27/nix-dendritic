{ self, inputs, ... }: {

  flake.homeModules.vvhMediaPlayers = { config, pkgs, lib, ... }: {

    programs.mpv = {
      enable = true;
      config = {
        vo = "gpu";
        gpu-context = "wayland";
        hwdec = "vaapi";
      };
    };
  };
}
