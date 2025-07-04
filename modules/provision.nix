{ pkgs, lib, ... }:

{
  config,
  ...
}:

let
  defaultJSONPath = config.provision.defaultJSONPath;
  envJSONPath = builtins.getEnv "PROVISION_JSON";

  readJson =
    path:
    if path != "" && builtins.pathExists path then builtins.fromJSON (builtins.readFile path) else { };

  defaultConfig = readJson defaultJSONPath;
  envConfig = if envJSONPath == "" then { } else readJson envJSONPath;

  mergedConfig = lib.recursiveUpdate defaultConfig envConfig;
in
{
  options.provision = {
    defaultJSONPath = lib.mkOption {
      type = lib.types.path;
      default = "/etc/nixos/default.json";
      description = "Path to the default JSON configuration file.";
    };

    mergedConfig = lib.mkOption {
      type = lib.types.attrs;
      default = mergedConfig;
      description = "Merged configuration from default JSON and environment variables.";
    };
  };

  config = {
    networking.hostName = mergedConfig.hostName;

    users.users = {
      "${mergedConfig.userName}" = {
        isNormalUser = true;
        home = "/home/${mergedConfig.userName}";
        shell = pkgs.bash;
        openssh.authorizedKeys.keys = mergedConfig.sshAuthorizedKeys or [ ];
      };
    };

    services.openssh.enable = true;
    services.openssh.settings.PasswordAuthentication = false;

    environment.systemPackages = [ pkgs.openssh ];
  };

  # Ensure the default JSON file exists
  # assertions = [
  #   (lib.assertions.assertPathExists defaultJSONPath "Default JSON configuration file does not exist.")
  # ];
}
