{ config, lib, ... }:
{
  options = {
    cli.starship.enable = lib.mkEnableOption "Enable Starship Prompt";
  };

  config = lib.mkIf config.cli.starship.enable {
    programs.starship = {
      enable = true;
      enableTransience = true;

      settings = {
        add_newline = false;

        format = "$directory$git_branch$git_status$fill$python$lua$nodejs$golang$haskell$rust$ruby$package$aws$docker_context$jobs$cmd_duration$line_break$character";

        character = {
          success_symbol = "[ ](bold fg:purple)";
          error_symbol = "[ ](bold fg:red)";
          vimcmd_symbol = "[ ](bold fg:yellow)";
          vimcmd_visual_symbol = "[ ](bold fg:blue)";
          vimcmd_replace_symbol = "[ ](bold fg:green)";
          vimcmd_replace_one_symbol = "[ ](bold fg:green)";
        };

        directory = {
          style = "bold bg:black fg:bright-white";
          truncation_length = 6;
          truncation_symbol = "../";
          format = "[](bold fg:black)[$path]($style)[](bold fg:black)";
        };

        git_branch = {
          symbol = "";
          truncation_length = 12;
          truncation_symbol = "";
          format = "[](bold fg:black)[$symbol $branch(:$remote_branch)](bold fg:blue bg:black)[](bold fg:black)";
        };

        git_status = {
          style = "bold purple";
          format = "[$modified$deleted$untracked$ahead_behind]($style) ";
          modified = " ";
          deleted = " ";
          untracked = " ";
          ahead = " ";
          behind = " ";
          up_to_date = " ";
        };

        fill = {
          symbol = " ";
        };

        profiles = {
          transient = "$character";
          rtransient = "$status$cmd_duration$time";
        };
      };
    };
  };
}
