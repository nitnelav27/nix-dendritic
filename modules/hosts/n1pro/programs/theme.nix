{ self, inputs, ... }: {

  ## Colour theme for n1pro. Everything -- niri's focus ring, waybar, fuzzel,
  ## mako, swaylock, ghostty, sway borders -- reads Material-style role names
  ## (primary, surface, on_surface, outline_variant, ...) from `n1proTheme`,
  ## so swapping the palette here recolours the whole desktop.
  ##
  ## Current: Nord, with the "ice" (Frost) blues as accents -- the same
  ## palette nvf uses (theme.name = "nord", i.e. gbprod/nord.nvim).
  ## Alternative kept below: `wallpaperTheme`, which derives the palette from
  ## the wallpaper with matugen (daru's "colours follow the wallpaper").
  flake.lib = rec {

    ## Shared helpers on top of a { role = "#rrggbb"; } attrset.
    mkTheme = { pkgs, wallpaper, colors, ansi ? null }:
      let
        inherit (pkgs) lib;
        rgb = color:
          let h = lib.removePrefix "#" color;
          in map (i: lib.fromHexString (builtins.substring i 2 h)) [ 0 2 4 ];
      in {
        inherit wallpaper colors ansi;
        ## "#rrggbb" -> "rrggbb"
        hex = name: lib.removePrefix "#" colors.${name};
        ## "#rrggbb" -> "rgba(r, g, b, a)" (CSS)
        rgba = name: alpha:
          let v = rgb colors.${name};
          in "rgba(${lib.concatMapStringsSep ", " toString v}, ${toString alpha})";
      };

    ## https://www.nordtheme.com/docs/colors-and-palettes
    nord = {
      nord0 = "#2e3440"; nord1 = "#3b4252"; nord2 = "#434c5e"; nord3 = "#4c566a"; # Polar Night
      nord4 = "#d8dee9"; nord5 = "#e5e9f0"; nord6 = "#eceff4";                    # Snow Storm
      nord7 = "#8fbcbb"; nord8 = "#88c0d0"; nord9 = "#81a1c1"; nord10 = "#5e81ac"; # Frost ("ice")
      nord11 = "#bf616a"; nord12 = "#d08770"; nord13 = "#ebcb8b";                 # Aurora
      nord14 = "#a3be8c"; nord15 = "#b48ead";
    };

    nordTheme = { pkgs, wallpaper }:
      let n = nord; in
      mkTheme {
        inherit pkgs wallpaper;
        colors = {
          surface_container_lowest = "#242933"; # Nord's "darker" background
          surface = n.nord0;
          surface_container = n.nord1;
          surface_container_high = n.nord2;
          outline_variant = n.nord3;
          outline = "#616e88";                   # Nord comment grey
          on_surface = n.nord6;
          on_surface_variant = n.nord4;

          primary = n.nord8;                     # ice blue accent
          on_primary = n.nord0;
          primary_container = n.nord10;
          on_primary_container = n.nord6;
          tertiary = n.nord9;

          error = n.nord11;
          error_container = n.nord11;
          on_error_container = n.nord6;
        };
        ## Nord's terminal mapping (ANSI 0-15).
        ansi = [
          n.nord1 n.nord11 n.nord14 n.nord13 n.nord9 n.nord15 n.nord8 n.nord5
          n.nord3 n.nord11 n.nord14 n.nord13 n.nord9 n.nord15 n.nord7 n.nord6
        ];
      };

    ## Palette from the wallpaper via matugen at build time (IFD).
    wallpaperTheme = { pkgs, wallpaper, scheme ? "scheme-tonal-spot", prefer ? "value" }:
      let
        json = pkgs.runCommand "wallpaper-palette.json" { nativeBuildInputs = [ pkgs.matugen ]; } ''
          export HOME=$TMPDIR
          matugen image ${wallpaper} \
            --type ${scheme} --prefer ${prefer} --mode dark \
            --json hex --dry-run --quiet > $out
        '';
      in mkTheme {
        inherit pkgs wallpaper;
        colors = pkgs.lib.mapAttrs (_: v: v.dark.color) (pkgs.lib.importJSON json).colors;
      };

    ## n1pro's theme. Point `wallpaper` at your own image, e.g.
    ##   wallpaper = self + "/extra/wallpapers/nord.png";
    ## To go back to wallpaper-derived colours:
    ##   n1proTheme = pkgs: wallpaperTheme { inherit pkgs; wallpaper = ...; };
    n1proTheme = pkgs: nordTheme {
      inherit pkgs;
      wallpaper = pkgs.nixos-artwork.wallpapers.nineish-dark-gray.gnomeFilePath;
    };
  };
}
