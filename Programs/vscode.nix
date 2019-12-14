with import <unstable>{};
vscode-with-extensions.override {
      # When the extension is already available in the default extensions set.
      vscode = vscodium;
      vscodeExtensions = with vscode-extensions; [
        alanz.vscode-hie-server
      ];
      # Concise version from the vscode market place when not available in the default set.
    }

