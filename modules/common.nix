{ config, pkgs, ... }:

{
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

  # Allow unfree packages (like vscode, some drivers, etc.)
  nixpkgs.config.allowUnfree = true;

  # Set default shell for all users
  users.defaultUserShell = pkgs.bash;
}

