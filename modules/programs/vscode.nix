{ self, inputs, ... }: {

  flake.homeModules.vvhVSCode = { config, pkgs, lib, ... }: {

    programs.vscode = {
      enable = true;
      mutableExtensionsDir = true;
      # Nix-packaged Electron apps can't use the setuid sandbox helper on this
      # non-NixOS host: /nix/store/.../chrome-sandbox can't be made setuid-root
      # (store paths are immutable, and it'd need redoing on every VS Code
      # update anyway), and Ubuntu 24.04+'s AppArmor blocks the unprivileged
      # user-namespace fallback too (kernel.apparmor_restrict_unprivileged_userns).
      # Disable Chromium's process sandbox for VS Code specifically instead of
      # loosening either of those at the system level.
      package = pkgs.vscode.override { commandLineArgs = "--no-sandbox"; };
      profiles.default.extensions = with pkgs.vscode-extensions; [
        dracula-theme.theme-dracula
        vscodevim.vim 
        ms-toolsai.jupyter
        ms-toolsai.vscode-jupyter-cell-tags
        streetsidesoftware.code-spell-checker
        james-yu.latex-workshop
        tecosaur.latex-utilities
        ltex-plus.vscode-ltex-plus # grammar/spell checking
        arcticicestudio.nord-visual-studio-code
        ms-vscode-remote.remote-ssh
        ms-python.python
        ms-python.vscode-pylance
        mkhl.direnv # auto-loads per-project direnv/nix devShell envs into VS Code
        # github.copilot
        ms-vscode-remote.vscode-remote-extensionpack
      ] ++ [
        # Windsurf (formerly Codeium) AI autocomplete. Proprietary, so nixpkgs
        # declined to package it (NixOS/nixpkgs#334229, closed "not planned") --
        # pinned by hand instead via nixpkgs' own marketplace fetcher.
        # `sha256` is a placeholder: the first `home-manager switch` after this
        # change will fail with a hash mismatch and print the real one --
        # paste that in here to replace lib.fakeHash.
        (pkgs.vscode-utils.buildVscodeMarketplaceExtension {
          mktplcRef = {
            name = "codeium";
            publisher = "Codeium";
            version = "1.48.2"; # bump this (and re-fetch the hash) to update
            sha256 = "sha256-Nj7r596RWuUNkjn06q5yEaMAqphPXWx+8oIw/GtXwFc=";
          };
        })
      ];
      profiles.default.userSettings."ltex.ltex-ls-plus.path" =
        "${pkgs.ltex-ls-plus}/bin/ltex-ls-plus";
    };

    # Home Manager manages settings.json as a read-only Nix-store symlink,
    # which makes VS Code itself unable to write to it at all (EACCES) --
    # e.g. from the Settings UI or some extension actions. Upstream is adding
    # a proper `mutableUserSettings` option for this (nix-community/home-manager
    # PR #9854, not merged yet as of writing) -- this activation script is a
    # hand-rolled stand-in for that, doing the same thing: turn off the
    # symlink for just this one file, then on every `home-manager switch`,
    # merge the declared settings (from programs.vscode.profiles.default.userSettings,
    # combined across vscode.nix and homePkgsUtdt10141.nix) into the real
    # settings.json, with declared keys always winning but anything else VS
    # Code wrote in between rebuilds left alone. Once PR #9854 merges and this
    # host's home-manager input picks it up, replace this whole block with
    # `profiles.default.mutableUserSettings = true;` above.
    home.file.".config/Code/User/settings.json".enable = lib.mkForce false;

    home.activation.vscodeMutableSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      settingsFile="$HOME/.config/Code/User/settings.json"
      declaredJson=${lib.escapeShellArg (builtins.toJSON config.programs.vscode.profiles.default.userSettings)}
      mkdir -p "$(dirname "$settingsFile")"
      if [ -e "$settingsFile" ] && ${pkgs.jq}/bin/jq empty "$settingsFile" >/dev/null 2>&1; then
        tmp=$(mktemp)
        printf '%s' "$declaredJson" | ${pkgs.jq}/bin/jq -s '.[0] * .[1]' "$settingsFile" - > "$tmp"
        mv "$tmp" "$settingsFile"
      else
        printf '%s' "$declaredJson" | ${pkgs.jq}/bin/jq '.' > "$settingsFile"
      fi
      chmod u+w "$settingsFile"
    '';
  };
}
