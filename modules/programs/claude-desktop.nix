{ inputs, ... }: {
  flake.homeModules.vvhClaudeDesktop = { pkgs, ... }: {
    home.packages = [
      inputs.claude-desktop.packages.${pkgs.stdenv.hostPlatform.system}.claude-desktop-fhs
    ];
  };
}
