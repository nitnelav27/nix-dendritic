{ self, inputs, ... }: {

  flake.homeModules.vvhRofi = { config, lib, pkgs, ... }: {

    programs.rofi = {
      enable = true;
      package = pkgs.rofi;
      cycle = true;
      font = "Fira Sans 15";
      theme = ./rofi-launcher-theme.rasi;
      extraConfig = {
        modi = "drun,filebrowser,window,run";
        show-icons = true;
        icon-theme = "Paper";
        display-window = "  ";
        display-run =  " ";
	      display-drun =  " ";
	      display-filebrowser = "  ";
        drun-display-format = "{name}";
        hover-select = false;
        scroll-method = 1;
        me-select-entry = "";
        me-accept-entry = "MousePrimary";
        window-format = "{w} · {c} · {t}";
      };
    };
  };
}
