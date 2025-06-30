{ config, ... }:

let
  sops-nix = builtins.fetchTarball "https://github.com/Mic92/sops-nix/archive/master.tar.gz";
  defaultSopsSecretsFile = ./../../hosts/${config.networking.hostName}/secrets.yaml;
in
{
  imports = [ (import "${sops-nix}/modules/sops") ];

  sops.defaultSopsFile =
    if builtins.pathExists defaultSopsSecretsFile then defaultSopsSecretsFile else null;
}
