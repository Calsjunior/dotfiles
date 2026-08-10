{
  config,
  lib,
  pkgs,
  ...
}:
{
  options = {
    cli.media.enable = lib.mkEnableOption "Enable media related CLI";
  };

  config = lib.mkIf config.cli.media.enable {
    home.packages = with pkgs; [
      kew

      (writeShellApplication {
        name = "get-playlist";
        runtimeInputs = [
          deno
          spotdl
        ];
        text = ''
          # get-playlist
          #
          # Downloads a Spotify playlist, album, or track, organizes the audio
          # files into ~/Music/library/<Artist Name>/<Album Name>/ structure,
          # and automatically generates the .m3u playlist in ~/Music/playlists/.
          #
          # spotdl uses yt-dlp, which recommends deno for JS execution to prevent errors.

          if [ "$#" -eq 0 ]; then
            echo "Usage: get-playlist <spotify-url> [additional-args...]"
            exit 1
          fi

          target_url="$1"
          output_template="../library/{artist}/{album}/{track-number} - {title}.{output-ext}"
          spotdl_args=(
            "--output" "$output_template"
            "--threads" "8"
            "--preload"
            "--detect-formats" "mp3" "m4a" "opus"
            "--format" "opus"
            "--bitrate" "disable"
            "--audio" "youtube-music" "youtube"
            "--sponsor-block"
            "--lyrics" "synced" "musixmatch" "genius"
            "--create-skip-file"
            "--respect-skip-file"
          )

          case "$target_url" in
            *spotify.com/album/*)
              spotdl_args+=("--m3u" "{artist} - {album}.m3u")
              ;;
            *spotify.com/playlist/*)
              spotdl_args+=("--m3u" "{list}.m3u")
              ;;
            *spotify.com/artist/*)
              spotdl_args+=("--m3u" "{artist} - All Tracks.m3u")
              ;;
            *)
              ;;
          esac

          if [ "$#" -gt 1 ]; then
            spotdl_args+=("''${@:2}")
          fi

          mkdir -p "$HOME/Music/playlists"
          mkdir -p "$HOME/Music/library"

          cd "$HOME/Music/playlists"

          exec spotdl "$target_url" "''${spotdl_args[@]}"
        '';
      })
    ];
  };
}
