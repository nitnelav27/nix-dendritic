{ self, inputs, ... }: {

  flake.darwinModules.mbproSystem = { config, lib, pkgs, ... }: {

    system.primaryUser = "vvh";
    system.defaults = {
      LaunchServices.LSQuarantine = false;
      NSGlobalDomain = {
        AppleICUForce24HourTime = true;
        AppleInterfaceStyle = "Dark";
        AppleMeasurementUnits = "Centimeters";
        AppleMetricUnits = 1;
        AppleShowAllExtensions = true;
        AppleTemperatureUnit = "Celsius";
        "com.apple.mouse.tapBehavior" = 1;
      };
      SoftwareUpdate.AutomaticallyInstallMacOSUpdates = true;
      controlcenter = {
        BatteryShowPercentage = true;
        Bluetooth = true;
        Sound = true;
      };
      dock = {
        autohide = true;
        mineffect = "suck";
        orientation = "right";
        static-only = true;
      };
      finder = {
        AppleShowAllExtensions = true;
        CreateDesktop = false;
        FXRemoveOldTrashItems = true;
        ShowPathbar = true;
      };
      iCal = {
        "TimeZone support enabled" = true;
        "first day of week" = "Monday";
      };
      loginwindow = {
        GuestEnabled = false;
        SHOWFULLNAME = false;
      };
      menuExtraClock = {
        Show24Hour = true;
        ShowDate = 1;
      };
      trackpad.Clicking = true;
    };
  };
}
