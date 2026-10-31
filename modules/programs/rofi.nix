{ self, inputs, ... }: {

  flake.homeModules.vvhRofi = { config, lib, pkgs, ... }: {

    programs.rofi = {
      enable = true;
      package = pkgs.rofi;
      theme = ./rofi-launcher-theme.rasi;
      settings = {
        cycle = true;
        font = "Fira Sans 15";
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
