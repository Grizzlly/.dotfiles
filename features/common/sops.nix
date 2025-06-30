{ config, ... }:

let
  defaultSopsSecretsFile = ./../../hosts/${config.networking.hostName}/secrets.yaml;
in
{
  imports = [ ];

  sops.defaultSopsFile =
    if builtins.pathExists defaultSopsSecretsFile then defaultSopsSecretsFile else null;
}
