{ pkgs, ... }:
let
  sops-nix = builtins.fetchTarball "https://github.com/Mic92/sops-nix/archive/master.tar.gz";
in
{
  imports = [
    (import "${sops-nix}/modules/sops")
    ../features/common
  ];

  # Use the latest time zone
  time.timeZone = "UTC";

  # Default environment packages
  environment.systemPackages = with pkgs; [
    git
    wget
    curl
    vim
    bash
    openssh
  ];

  networking.networkmanager.enable = true;

  # Set default shell for all users
  users.defaultUserShell = pkgs.bash;
}
