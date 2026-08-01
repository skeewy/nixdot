{ config, pkgs, ... }:

{
  home.username = "mtoxd9";
  home.homeDirectory = "/home/mtoxd9";
  home.stateVersion = "26.05";

  # Allows unfree packages like Discord inside Home Manager
  nixpkgs.config.allowUnfree = true;

  # Ensures XDG data paths (like desktop icons) are properly linked on non-NixOS setups
  # (Safe to leave true even on NixOS for robustness)
  xdg.enable = true;

  # =========================================================================
  # 1. YOUR APPS
  # =========================================================================
  home.packages = with pkgs; [
    qbittorrent
    discord
    spotify
    vscode
    parsec-bin
    obs-studio
    qemu
    quickemu
    davinci-resolve
    ffmpeg
    vlc
    bat # Better 'cat'
    eza # Better 'ls'
    rustup
    gcc
    lldb
    telegram-desktop
  ];

  # =========================================================================
  # 2. ENVIRONMENT VARIABLES
  # =========================================================================
  home.sessionVariables = {
    EDITOR = "nano";
    VISUAL = "nano";
    SUDO_EDITOR = "nano";
    MANPAGER = "sh -c 'col -bx | bat -l man -p'";
    MANROFFOPT = "-c";
    LESS = "-R --mouse";
  };

  # =========================================================================
  # 3. NANO CONFIGURATION
  # =========================================================================
  home.file.".nanorc".text = ''
    set titlecolor bold,white,normal
    set promptcolor bold,yellow,normal
    set statuscolor bold,white,normal
    set errorcolor bold,red,normal
    set spotlightcolor black,yellow
    set selectedcolor black,cyan
    set scrollercolor cyan
    set keycolor bold,cyan,normal
    set functioncolor green,normal
    set numbercolor cyan,normal
    set minibar
    set stateflags
    set linenumbers
    set constantshow
    set indicator
    set guidestripe 80
    set tabsize 4
    set tabstospaces
    set autoindent
    set trimblanks
    set afterends
    set wordchars "_"
    set unix
    set cutfromcursor
    set wordbounds
    set mouse
    set smarthome
    set zap
    set atblanks
    set softwrap
    set multibuffer
    set nohelp
    set historylog
    set positionlog
    set locking
  '';

  # =========================================================================
  # 4. FISH SHELL CONFIGURATION
  # =========================================================================
  programs.fish = {
    enable = true;
    
    shellAbbrs = {
      df = "df -h";
      du = "du -h";
      free = "free -h";
    };
    
    shellAliases = {
      # The master update command for the separated setup
      up = "sudo nix-channel --update && nix-channel --update && home-manager switch && sudo nixos-rebuild boot --upgrade";
      cp = "cp -i";
      mv = "mv -i";
      rm = "rm -I";
      mkdir = "mkdir -pv";
      grep = "grep --color=auto";
      diff = "diff --color=auto";
      ip = "ip --color=auto";
      cd = "z";
      ls = "eza --icons --group-directories-first";
      ll = "eza -l --icons --group-directories-first --git --time-style=relative";
      la = "eza -la --icons --group-directories-first --git --time-style=relative";
      lt = "eza --tree --icons --level=2 --group-directories-first";
      cat = "bat -pp";
    };

    functions = {
      cleanup = {
        description = "Run Nix garbage collection";
        body = ''
          echo -e "\e[1;36m✨ Running Nix Garbage Collection...\e[0m"
          sudo nix-collect-garbage -d
          nix-collect-garbage -d
          echo -e "\e[1;32m✨ System cleaned!\e[0m"
        '';
      };
    };

    interactiveShellInit = ''
      set -g fish_greeting ""      
      
      if test -d ~/.local/bin
          fish_add_path -g ~/.local/bin
      end

      # Catppuccin Mocha Colors
      set -g fish_color_normal cdd6f4
      set -g fish_color_command 89b4fa --bold
      set -g fish_color_keyword f38ba8
      set -g fish_color_quote a6e3a1
      set -g fish_color_redirection f5c2e7
      set -g fish_color_end fab387
      set -g fish_color_error f38ba8 --bold
      set -g fish_color_param f9e2af
      set -g fish_color_comment 6c7086 --italics
      set -g fish_color_selection --background=45475a
      set -g fish_color_search_match --background=45475a
      set -g fish_color_operator f5c2e7
      set -g fish_color_escape 94e2d5
      set -g fish_color_autosuggestion 6c7086
      set -g fish_color_valid_path cdd6f4 --underline
      set -g fish_color_cancel f38ba8
      set -g fish_pager_color_progress 6c7086
      set -g fish_pager_color_prefix f5c2e7 --bold
      set -g fish_pager_color_completion cdd6f4
      set -g fish_pager_color_description 6c7086 --italics
      set -g fish_pager_color_selected_background --background=45475a
      set -g fish_pager_color_selected_prefix f5c2e7 --bold
      set -g fish_pager_color_selected_completion cdd6f4
      set -g fish_pager_color_selected_description a6e3a1
      
      set -g fish_completion_max_results 50
    '';
  };

  # =========================================================================
  # 5. SHELL TOOLS (Starship, Zoxide, Fzf)
  # =========================================================================
  programs.starship = {
    enable = true;
    settings = {
      add_newline = true;
      format = "$directory$git_branch$git_status$cmd_duration$line_break$character";
      directory = {
        format = "[$path]($style)[$read_only]($read_only_style) ";
        style = "bold #89b4fa";
        read_only = " 󰌾";
        read_only_style = "bold #f38ba8";
        truncation_length = 3;
        truncate_to_repo = true;
      };
      git_branch = {
        format = "[$symbol$branch]($style) ";
        symbol = " ";
        style = "bold #cba6f7";
        truncation_length = 20;
      };
      git_status = {
        format = "([$all_status$ahead_behind]($style) )";
        style = "bold #f9e2af";
        conflicted = "=";
        ahead = "⇡\${count}";
        behind = "⇣\${count}";
        diverged = "⇕";
        untracked = "?";
        stashed = "󰏗";
        modified = "!";
        staged = "+";
        renamed = "»";
        deleted = "✗";
      };
      cmd_duration = {
        format = "[$duration]($style) ";
        style = "bold #6c7086";
        min_time = 2000;
        show_milliseconds = false;
      };
      character = {
        format = "$symbol ";
        success_symbol = "[󰁔](bold #a6e3a1)";
        error_symbol = "[󰁔](bold #f38ba8)";
        vimcmd_symbol = "[󰁔](bold #cba6f7)";
      };
    };
  };

  programs.zoxide.enable = true;
  programs.fzf.enable = true;
  # home.nix (Home Manager)
#  programs.firefox = {
#    enable = true;
#    profiles.default = {
#      settings = {
#        "dom.ipc.processCount" = 2;                   # Limits background processes
#        "browser.sessionstore.restore_on_demand" = true; # Load active tab only on start
#        "browser.tabs.unloadOnLowMemory" = true;       # Auto-discard idle tabs
#        "accessibility.force_disabled" = 1;            # Disable heavy accessibility engine
#      };
#    };
#  };

programs.firefox = {
  enable = true;
  profiles = {
    "df93s7ct.default" = {
      id = 0;
      isDefault = true;
      path = "df93s7ct.default";

      settings = {
        "dom.ipc.processCount" = 2;
        "browser.sessionstore.restore_on_demand" = true;
        "browser.tabs.unloadOnLowMemory" = true;
        "accessibility.force_disabled" = 1;
      };
    };
  };
};

#  programs.firefox = {
#   enable = true;
#   profiles = {
#     "mtoxd9.default" = { # Changed from df93s7ct.default
#       id = 0;
#       isDefault = true;
#       path = "mtoxd9.default";
#       settings = {
#         "dom.ipc.processCount" = 2;
#         "browser.sessionstore.restore_on_demand" = true;
#         "browser.tabs.unloadOnLowMemory" = true;
#         "accessibility.force_disabled" = 1;
#       };
#     };
#   };
# };

  # =========================================================================
  # 6. DCONF / VIRT-MANAGER
  # =========================================================================
  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = [ "qemu:///system" ];
      uris = [ "qemu:///system" ];
    };
  };

  # Let Home Manager install and manage itself
  programs.home-manager.enable = true;
}
