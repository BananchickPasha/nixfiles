with import <nixpkgs> { };
let
  defaultPackages = [ coreutils-full diffutils gawk gnugrep gnused ];
  path = lib.foldl (x: y: "${x}" + "${y}/bin:") "export PATH=";
in rec {
  scriptWriterFull = { scriptPath, depends, textToAdd ? "", shell ? zsh }:
    derivation {
      name = "mydrv";
      builder = "${bash}/bin/bash";
      inherit coreutils;
      inherit zsh;
      #TODO add textToAdd and shell realisation
      args = [ ./builder.sh scriptPath (path (defaultPackages ++ depends)) ];
      system = builtins.currentSystem;
    };
  scriptWriter = scriptPath: depends:
    scriptWriterFull { inherit scriptPath depends; };

  alias = from: to:
    pkgs.runCommand to { } ''
      mkdir -p $out/bin
      ln -s ${from} $out/bin/${to}
    '';
  aliasPath = from: to: packages:
    pkgs.runCommand to { } ''
      mkdir -p $out/bin
      cat > $out/bin/${to} <<EOF
      #!${pkgs.bash}/bin/bash
      ${path packages}:/run/current-system/sw/bin:$(echo '$PATH')
      ${from} "$(echo '$@')"
      EOF
      chmod +x $out/bin/${to}
    '';
}
