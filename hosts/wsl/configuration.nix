# NixOS-WSL specific options are documented on the NixOS-WSL repository:
# https://github.com/nix-community/NixOS-WSL

{
  pkgs,
  ...
}:

let
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/release-24.11.tar.gz";
  nixos-wsl = builtins.fetchTarball "https://github.com/nix-community/NixOS-WSL/archive/refs/tags/2411.6.0.tar.gz";
in
{
  imports = [
    ../../modules/common.nix
    (import "${nixos-wsl}/modules")
    (import "${home-manager}/nixos")
  ];

  wsl.enable = true;
  wsl.defaultUser = "nixos";

  networking.hostName = "wsl";

  users.users.nixos.isNormalUser = true;
  home-manager.users.nixos =
    { ... }:
    {
      programs.git = {
        enable = true;
        userName = "Grizzlly";
        userEmail = "standrei2003@yahoo.com";
      };

      home.stateVersion = "24.11";
    };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    nixfmt-rfc-style
    nixd
  ];

  programs.nix-ld.enable = true;
  programs.ssh.extraConfig = ''
    Host github.com
      HostName github.com
      IdentityFile ~/.ssh/github
      AddKeysToAgent yes
      StrictHostKeyChecking accept-new
  '';

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.11"; # Did you read the comment?

}
