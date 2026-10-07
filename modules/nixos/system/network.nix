# Warp via sing-box. To get it working, it needs to be registered per host:
# cd $(mktemp -d) && nix shell nixpkgs#wgcf
# wgcf register --accept-tos && wgcf generate && cat wgcf-profile.conf
#
# Usage: sudo systemctl start sing-box
# Check: sudo systemctl is-active sing-box

{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.sys.network;
in
{
  options.sys.network = {
    enable = lib.mkEnableOption "NetworkManager with fixed DNS resolvers";

    warp = {
      enable = lib.mkEnableOption "Cloudflare WARP via sing-box (WireGuard, wgcf account)";

      autostart = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Automatically manage tunnel state via NetworkManager. Set to false for manual control via systemctl.";
      };

      gateways = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "List of gateway IPs (e.g. ['192.168.0.1' '10.0.0.1']) where WARP should automatically run. If empty, WARP runs on all Wi-Fi/Ethernet networks.";
        example = [
          "192.168.0.1"
          "10.0.0.1"
        ];
      };

      privateKeyFile = lib.mkOption {
        type = lib.types.str;
        description = "Path to the WireGuard private key.";
        example = "/run/secrets/wg_private_key";
      };

      address = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ "172.16.0.2/32" ];
        description = "Tunnel IPs from the Address lines of wgcf-profile.conf";
      };

      endpointAddress = lib.mkOption {
        type = lib.types.str;
        default = "188.114.97.4";
        description = "Cloudflare's WARP endpoint IP address";
      };

      endpointPort = lib.mkOption {
        type = lib.types.int;
        default = 1701;
        description = "Cloudflare WARP endpoint port";
      };

      peerPublicKey = lib.mkOption {
        type = lib.types.str;
        default = "bmXOC+F1FxEMF9dyiK2H5/1SUtzH0JuVo51h2wPfgyo=";
        description = "Cloudflare's WARP peer public key from wgcf-profile.conf";
      };

      reserved = lib.mkOption {
        type = lib.types.listOf lib.types.int;
        default = [
          0
          0
          0
        ];
        description = "Three reserved bytes for your WARP account; zeros if you don't have them";
      };
    };
  };

  config = lib.mkMerge [
    {
      assertions = [
        {
          assertion = cfg.warp.enable -> cfg.enable;
          message = "sys.network.warp.enable requires sys.network.enable = true.";
        }
      ];
    }

    (lib.mkIf cfg.enable {
      networking = {
        networkmanager = {
          enable = true;
          dns = "none";
        };
        nameservers = [
          "1.1.1.1"
          "1.0.0.1"
        ];
      };
    })

    (lib.mkIf (cfg.enable && cfg.warp.enable) {
      services.sing-box = {
        enable = true;
        settings = {
          log.level = "info";
          inbounds = [
            {
              type = "tun";
              address = [ "172.19.0.1/30" ];
              auto_route = true;
              strict_route = true;
            }
          ];
          endpoints = [
            {
              type = "wireguard";
              tag = "warp";
              address = cfg.warp.address;
              private_key._secret = cfg.warp.privateKeyFile;
              mtu = 1280;
              peers = [
                {
                  address = cfg.warp.endpointAddress;
                  port = cfg.warp.endpointPort;
                  public_key = cfg.warp.peerPublicKey;
                  allowed_ips = [ "0.0.0.0/0" ];
                  reserved = cfg.warp.reserved;
                }
              ];
            }
          ];
          route = {
            final = "warp";
            auto_detect_interface = true;
          };
        };
      };

      systemd.services.sing-box.wantedBy = lib.mkForce [ ];

      # Only install the NetworkManager script if autostart is true
      networking.networkmanager.dispatcherScripts = lib.mkIf cfg.warp.autostart [
        {
          source = pkgs.writeShellScript "warp-network-run" ''
            iface="$1"
            action="$2"
            systemctl_cmd="${pkgs.systemd}/bin/systemctl"

            case "$iface" in
              tun*|tap*|docker*|veth*) exit 0 ;;
            esac

            # Only process wireless and ethernet connections
            case "$iface" in
              wl*|en*|eth*) ;;
              *) exit 0 ;;
            esac

            # Stop service on connection drop
            if [[ "$action" = "down" ]]; then
              $systemctl_cmd stop sing-box.service
              exit 0
            fi

            if [[ "$action" != "up" ]]; then
              exit 0
            fi

            target_gws="${lib.concatStringsSep " " cfg.warp.gateways}"
            current_gw="''${IP4_GATEWAY:-$DHCP4_ROUTERS}"

            if [[ -n "$target_gws" ]] && [[ " $target_gws " != *" $current_gw "* ]]; then
              $systemctl_cmd stop sing-box.service
              exit 0
            fi

            $systemctl_cmd restart --no-block sing-box.service
          '';
        }
      ];
    })
  ];
}
