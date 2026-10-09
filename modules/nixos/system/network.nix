/*
  Cloudflare WARP through sing-box.
  To get it working, it needs to be registered per host.

  + Make a free WARP account:
    cd $(mktemp -d) && nix shell nixpkgs#wgcf
    wgcf register --accept-tos && wgcf generate && cat wgcf-profile.conf

    IMPORTANT: Don't share wgcf-account.toml or wgcf-profile.conf as they hold
    your account token.

    Store the PrivateKey in your secrets manager. Stay in this folder for the
    next step.

  + Get your reserved numbers. Without them, the tunnel may only connect some
    of the time. Run this whole block at once:

    id=$(grep '^device_id' wgcf-account.toml | sed -E "s|.*= *['\"]?([^'\"]*).*|\1|")
    token=$(grep '^access_token' wgcf-account.toml | sed -E "s|.*= *['\"]?([^'\"]*).*|\1|")
    curl -s "https://api.cloudflareclient.com/v0a2158/reg/$id" \
      -H 'User-Agent: okhttp/3.12.1' \
      -H 'CF-Client-Version: a-6.10-2158' \
      -H "Authorization: Bearer $token" \
      | nix run nixpkgs#jq -- -r .config.client_id | base64 -d | od -An -tu1

    Put the three numbers in sys.network.warp.reserved in your host configuration.

  + Once everything is set and working, remove the files from tmp directory.
    rm -f wgcf-account.toml wgcf-profile.conf

  Start:  sudo systemctl start sing-box
  Check:  sudo systemctl is-active sing-box
  Stop:   sudo systemctl stop sing-box   (do this first if the internet hangs)
*/

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
        description = "Tunnel IPs from the Address lines of wgcf-profile.conf.";
      };

      endpointAddress = lib.mkOption {
        type = lib.types.str;
        default = "188.114.97.4";
        description = "Cloudflare's WARP endpoint IP address.";
      };

      endpointPort = lib.mkOption {
        type = lib.types.int;
        default = 1701;
        description = "Cloudflare WARP endpoint port.";
      };

      peerPublicKey = lib.mkOption {
        type = lib.types.str;
        default = "bmXOC+F1FxEMF9dyiK2H5/1SUtzH0JuVo51h2wPfgyo=";
        description = "Cloudflare's WARP public key, from wgcf-profile.conf.";
      };

      reserved = lib.mkOption {
        type = lib.types.listOf lib.types.int;
        default = [
          0
          0
          0
        ];
        description = "Three numbers from your WARP account.";
        example = [
          12
          34
          56
        ];
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
      warnings =
        lib.optional
          (
            cfg.warp.reserved == [
              0
              0
              0
            ]
          )
          "sys.network.warp.reserved is unset. The tunnel may only connect some of the time on your network; see the top of network.nix on how to look up your numbers.";

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
