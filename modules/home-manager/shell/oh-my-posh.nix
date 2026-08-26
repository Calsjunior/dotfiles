{ config, lib, ... }:
{
  options = {
    cli.oh-my-posh.enable = lib.mkEnableOption "Enable Oh My Posh Prompt";
  };

  config = lib.mkIf config.cli.oh-my-posh.enable {
    programs.oh-my-posh = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        version = 2;
        blocks = [
          {
            type = "prompt";
            alignment = "left";
            newline = true;
            segments = [
              {
                type = "path";
                style = "diamond";
                leading_diamond = "";
                trailing_diamond = "";
                background = "black";
                foreground = "white";
                # truncates to ../<reponame> if inside a git directory but ignores properties.style
                template = "{{ if .Segments.Git }}../{{ .Segments.Git.RepoName }}{{ if .Segments.Git.RelativeDir }}/{{ .Segments.Git.RelativeDir }}{{ end }}{{ else }}{{ .Path }}{{ end }}";
                properties = {
                  style = "agnoster_short";
                  max_depth = 4;
                };
              }
              {
                type = "git";
                style = "diamond";
                leading_diamond = " ";
                trailing_diamond = "";
                background = "black";
                foreground = "blue";
                template = " {{ .HEAD }}";
              }
              {
                type = "git";
                style = "plain";
                foreground = "magenta";
                template = " {{ if .Working.Modified }} {{ end }}{{ if .Working.Deleted }} {{ end }}{{ if .Working.Untracked }} {{ end }}{{ if gt .Ahead 0 }} {{ end }}{{ if gt .Behind 0 }} {{ end }}{{ if and (not .Working.Modified) (not .Working.Deleted) (not .Working.Untracked) (eq .Ahead 0) (eq .Behind 0) }} {{ end }}";
              }
            ];
          }
          {
            type = "prompt";
            alignment = "right";
            segments = [
              {
                type = "python";
                style = "plain";
                foreground = "yellow";
                template = "  {{ .Full }}";
              }
              {
                type = "lua";
                style = "plain";
                foreground = "blue";
                template = "  {{ .Full }}";
              }
              {
                type = "node";
                style = "plain";
                foreground = "green";
                template = "  {{ .Full }}";
              }
              {
                type = "go";
                style = "plain";
                foreground = "cyan";
                template = "  {{ .Full }}";
              }
              {
                type = "rust";
                style = "plain";
                foreground = "red";
                template = "  {{ .Full }}";
              }
              {
                type = "executiontime";
                style = "plain";
                foreground = "yellow";
                properties = {
                  threshold = 500;
                };
                template = " {{ .FormattedMs }}";
              }
            ];
          }
          {
            type = "prompt";
            alignment = "left";
            newline = true;
            segments = [
              {
                type = "text";
                style = "plain";
                foreground = "magenta";
                foreground_templates = [
                  "{{ if gt .Code 0 }}red{{ end }}"
                  "{{ if eq .Code 0}}magenta{{ end }}"
                ];
                template = "{{ if gt .Code 0 }}{{ else }}{{ end }}  ";
              }
            ];
          }
        ];
        transient_prompt = {
          background = "transparent";
          foreground = "magenta";
          foreground_templates = [
            "{{ if gt .Code 0 }}red{{ end }}"
            "{{ if eq .Code 0}}magenta{{ end }}"
          ];
          template = "{{ if gt .Code 0 }}{{ else }}{{ end }}  ";
        };
        secondary_prompt = {
          background = "transparent";
          foreground = "magenta";
          template = "   ";
        };
      };
    };
  };
}
