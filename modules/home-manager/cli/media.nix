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

          if [[ "$#" -eq 0 ]]; then
            echo "Usage: get-playlist <spotify-url> [additional-args...]"
            exit 1
          fi

          target_url="$1"

          music_dir="$HOME/Music"
          playlists_dir="$music_dir/playlists"
          library_dir="$music_dir/library"

          output_template="$library_dir/{artist}/{album}/{track-number} - {title}.{output-ext}"

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

          if [[ "$#" -gt 1 ]]; then
            spotdl_args+=("''${@:2}")
          fi

          mkdir -p "$playlists_dir"
          mkdir -p "$library_dir"

          cd "$playlists_dir"

          exec spotdl "$target_url" "''${spotdl_args[@]}"
        '';
      })

      (writeShellApplication {
        name = "find-music";
        runtimeInputs = [
          deno
          fzf
          mpv
          spotdl
          yt-dlp
          (python3.withPackages (ps: [ ps.ytmusicapi ]))
        ];
        text = ''
          # find-music
          #
          # Terminal-based YouTube Music browser with continuous search, radio mix,
          # streaming preview, and track downloader.
          #
          # Usage:
          #   find-music <playlist-name> [initial search terms...]
          #
          # Controls inside fzf:
          #   enter   : Stream preview using mpv (press 'q' in mpv to stop)
          #   ctrl-a  : Download track and append to <playlist-name>.m3u
          #   ctrl-r  : Load YouTube Music Radio (similar/recommended tracks for highlighted song)
          #   esc     : Finish current search and prompt for a new search query

          music_dir="$HOME/Music"
          playlists_dir="$music_dir/playlists"
          library_dir="$music_dir/library"

          add_track() {
            local query="$1"
            local m3u="$playlists_dir/$find_music_playlist.m3u"
            local export_log="$playlists_dir/$find_music_playlist.export.txt"
            local tmpdir

            mkdir -p "$playlists_dir" "$library_dir"
            touch "$m3u" "$export_log"
            tmpdir="$(mktemp -d)"

            echo "Downloading: $query"
            (
              cd "$tmpdir"
              spotdl download "$query" \
                --output "$library_dir/{artist}/{album}/{track-number} - {title}.{output-ext}" \
                --format opus \
                --bitrate disable \
                --audio youtube-music youtube \
                --sponsor-block \
                --lyrics synced musixmatch genius \
                --m3u track.m3u
            )

            local new_lines
            if [[ -s "$tmpdir/track.m3u" ]]; then
              new_lines="$(grep -v '^#' "$tmpdir/track.m3u" | grep -vxFf "$m3u" || true)"
              if [[ -n "$new_lines" ]]; then
                printf '%s\n' "$new_lines" >> "$m3u"
              fi
            else
              echo "warning: spotdl wrote no m3u, track not added to playlist"
            fi

            grep -qxF "$query" "$export_log" || printf '%s\n' "$query" >> "$export_log"
            rm -rf "$tmpdir"
            echo "Added to $find_music_playlist"
            sleep 1
          }

          py_helper() {
            python3 - "$1" "$2" <<'PY'
          import sys
          from ytmusicapi import YTMusic

          mode = sys.argv[1]
          query_or_id = sys.argv[2]
          yt = YTMusic()

          if mode == "search":
              if not query_or_id.strip():
                  sys.exit(0)
              results = yt.search(query_or_id, filter="songs", limit=30)
              for r in results:
                  if not r.get("videoId") or not r.get("artists"):
                      continue
                  title = r["title"]
                  artist = r["artists"][0]["name"]
                  print(f"{title} - {artist}\t{r['videoId']}\t{artist} - {title}")

          elif mode == "radio":
              playlist = yt.get_watch_playlist(videoId=query_or_id, limit=30)
              for r in playlist.get("tracks", []):
                  if not r.get("videoId") or not r.get("artists"):
                      continue
                  title = r["title"]
                  artist = r["artists"][0]["name"]
                  print(f"{title} - {artist}\t{r['videoId']}\t{artist} - {title}")
          PY
          }

          if [[ "''${1:-}" == "--py" ]]; then
            py_helper "$2" "$3"
            exit 0
          fi

          if [[ "''${1:-}" == "--add" ]]; then
            add_track "$2"
            exit 0
          fi

          if [[ "$#" -eq 0 ]]; then
            echo "Usage: find-music <playlist-name> [search terms...]"
            exit 1
          fi

          find_music_playlist="$(basename "$1" .m3u)"
          export find_music_playlist
          shift

          current_query="$*"

          while true; do
            if [[ -z "$current_query" ]]; then
              echo ""
              read -rp "Search YT Music (or 'q' to quit): " current_query
              if [[ "$current_query" == "q" || -z "$current_query" ]]; then
                break
              fi
            fi

            find-music --py search "$current_query" | fzf \
              --with-shell "bash -c" \
              --delimiter '\t' \
              --with-nth 1 \
              --header "enter: stream | ctrl-a: add to $find_music_playlist | ctrl-r: load YT radio mix | esc: new search" \
              --bind "enter:execute(mpv --really-quiet https://music.youtube.com/watch?v={2})" \
              --bind "ctrl-a:execute(find-music --add {3} || read -rsp 'failed, press enter')" \
              --bind "ctrl-r:reload(find-music --py radio {2})" || true

            current_query=""
          done
        '';
      })
    ];
  };
}
