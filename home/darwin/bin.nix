{lib, ...}:
with lib; let
  binPath = ./../../bin;
in {
  home.file =
    mapAttrs' (name: value: nameValuePair ".bin/${name}" {source = binPath + "/${name}";})
    (builtins.readDir binPath);
}
