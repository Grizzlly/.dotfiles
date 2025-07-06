{
  pkgs,
  lib,
  config,
  ...
}:

let
  provisionModule = import ../../modules/provision.nix { inherit pkgs lib; };
in
{
  imports = [
    ../../modules/common.nix
    provisionModule
  ];

  config = {
    provision.defaultJSONPath = ./default.json;

    virtualisation.docker = {
      enable = true;
      enableOnBoot = true;
      enableSwarm = true;
    };

    networking.firewall = {
      enable = true;
      allowedTCPPorts = [
        22
        80
        443
      ];
    };

    environment.systemPackages = with pkgs; [
      docker-compose
    ];

    users.users.${config.provision.mergedConfig.userName}.extraGroups = [
      "wheel"
      "docker"
    ];

    services.traefik = {
      enable = true;
      package = pkgs.traefik;
      staticConfigOptions = {
        entryPoints = {
          web.address = ":80";
          websecure.address = ":443";
        };

        providers.docker = {
          endpoint = "unix:///var/run/docker.sock";
          exposedByDefault = false;
          swarmMode = true;
        };

        api.dashboard = true;
      };

      dynamicConfigOptions = {
        http.routers.api = {
          rule = "Host(`traefik.example.com`)";
          service = "api@internal";
          entryPoints = [ "web" ];
          # tls.certResolver = "le";
        };
      };
    };

    systemd.services.traefik.serviceConfig.SupplementaryGroups = [ "docker" ];

    systemd.services.portainer = {
      wantedBy = [ "multi-user.target" ];
      after = [ "docker.service" ];
      serviceConfig = {
        ExecStart = ''
          ${pkgs.docker}/bin/docker run \
            --name portainer \
            --restart always \
            -p 9000:9000 \
            -p 8000:8000 \
            -v /var/run/docker.sock:/var/run/docker.sock \
            -v portainer_data:/data \
            -l "traefik.enable=true" \
            -l "traefik.http.routers.portainer.rule=Host(`portainer.example.com`)" \
            -l "traefik.http.routers.portainer.entrypoints=web" \
            portainer/portainer-ce
        '';
        ExecStop = "${pkgs.docker}/bin/docker stop portainer";
        Restart = "always";
      };
    };

    systemd.tmpfiles.rules = [
      "d /var/lib/docker/volumes/portainer_data/_data 0755 root root -"
    ];

    system.stateVersion = "24.11";
  };
}
