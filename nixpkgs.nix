let
  inherit ((import <nixpkgs> {}).pkgs) fetchFromGitHub lib;
  lock = builtins.fromJSON (builtins.readFile ./nixpkgs.lock.json);
  bootstrap = fetchFromGitHub {
    inherit (lock) owner repo rev sha256 fetchSubmodules;
  };
  defaultOverrides =
    let file = ./default.overrides.nix; in
    lib.optional
    (builtins.pathExists file)
    (import file);
  shellOverrides =
    let file = ./shell.overrides.nix; in
    lib.optional
    (lib.inNixShell && builtins.pathExists file)
    (import file);
  userShellOverrides =
    let
      file =
        builtins.getEnv "HOME" + "/.config/nixpkgs/shell.overrides.nix";
    in
      lib.optional
      (lib.inNixShell && builtins.pathExists file)
      (import file);
in
  import bootstrap
  {
    config.allowUnfree = true;
    overlays = defaultOverrides ++ shellOverrides ++ userShellOverrides;
  }
