{ self, inputs, ... }: {

  flake.homeModules.vvhVSCode = { config, pkgs, lib, ... }: {

    programs.vscode = {
      enable = true;
      mutableExtensionsDir = true;
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
        # github.copilot
        ms-vscode-remote.vscode-remote-extensionpack
      ];
    };
  };
}
