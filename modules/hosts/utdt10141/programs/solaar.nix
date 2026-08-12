{ self, inputs, ... }: {

  flake.homeModules.utdt10141Solaar = { pkgs, ... }: {

    home.packages = [ pkgs.solaar ];

    # Autostart the tray applet, minimized, on login
    systemd.user.services.solaar = {
      Unit.Description = "Solaar - Logitech device manager";
      Install.WantedBy = [ "graphical-session.target" ];
      Service = {
        ExecStart = "${pkgs.solaar}/bin/solaar --window=hide";
        Restart = "on-failure";
      };
    };
  };
}
