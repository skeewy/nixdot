{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    # Pulls in the home-manager module via tarball
    # (fetchTarball "https://github.com/gmodena/nix-flatpak/archive/latest.tar.gz" + "/modules/home-manager.nix")
    ((fetchTarball "https://github.com/nix-community/home-manager/archive/release-26.05.tar.gz") + "/nixos")
  ];

  # Tie home.nix to user mtoxd9
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.mtoxd9 = import ./home.nix;
  };

  # ===========================================================================
  # 1. SYSTEM, BOOT & PERFORMANCE
  # ===========================================================================
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.kernelPackages = pkgs.linuxPackages_zen;

  boot.kernelParams = [ "quiet" "loglevel=3" ];
  powerManagement.cpuFreqGovernor = "performance";

  system.stateVersion = "26.05";

  # ===========================================================================
  # 2. NETWORKING, TIME & LOCALE
  # ===========================================================================
  networking.hostName = "nixtaha";
  networking.networkmanager.enable = true;
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 45670 ];
    allowedUDPPorts = [ 45670 ];
  };

  time.timeZone = "Africa/Casablanca";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # ===========================================================================
  # 3. DESKTOP, AUDIO & BLUETOOTH
  # ===========================================================================
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;
  services.xserver.xkb.layout = "us";

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  hardware.bluetooth.enable = true;

  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.hack
    nerd-fonts.jetbrains-mono
  ];

  # ===========================================================================
  # 4. HARDWARE, DRIVERS & STORAGE
  # ===========================================================================
  hardware.enableRedistributableFirmware = true;
  hardware.cpu.intel.updateMicrocode = true;

  services.btrfs.autoScrub = {
    enable = true;
    interval = "monthly";
    fileSystems = [ "/" ];
  };
  services.fstrim.enable = true;
  services.thermald.enable = true;

  zramSwap = {
    enable = true;
    priority = 100;
    algorithm = "lz4";
    memoryPercent = 50;
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      intel-compute-runtime      # Replaced legacy1: Kaby Lake uses the modern standard OpenCL runtime
      intel-media-driver         # Primary VA-API driver (iHD) for Gen8 and newer
      # vpl-gpu-rt               # Replaced intel-media-sdk: Modern QuickSync/VPL support [1]
      intel-vaapi-driver         # Fallback driver (i965)
      libvdpau-va-gl
    ];
    extraPackages32 = with pkgs.pkgsi686Linux; [
      intel-media-driver
      intel-vaapi-driver
    ];
  };

  # ===========================================================================
  # 5. VIRTUALIZATION & FLEXIBILITY
  # ===========================================================================
  programs.virt-manager.enable = true;
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = true;
    };
  };
  virtualisation.spiceUSBRedirection.enable = true;
  services.spice-vdagentd.enable = true;

  virtualisation.waydroid = {
    enable = true;
    package = pkgs.waydroid-nftables;
  };

  programs.appimage.binfmt = true;
  services.flatpak.enable = true;

  # ===========================================================================
  # 6. NIX CORE SETTINGS
  # ===========================================================================
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowUnfreePredicate = pkg: true;

  nix.settings = {
    auto-optimise-store = true;
    experimental-features = [ "nix-command" "flakes" ];
    cores = 0;
    max-jobs = "auto";
    extra-substituters = [
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  # ===========================================================================
  # 7. GLOBAL TERMINAL ENVIRONMENT & SYSTEM APPS
  # ===========================================================================
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  environment.variables = {
    EDITOR = "nano";
    VISUAL = "nano";
    SUDO_EDITOR = "nano";
    MANPAGER = "sh -c 'col -bx | bat -l man -p'";
    MANROFFOPT = "-c";
    LESS = "-R --mouse";
  };

  # Systemd limits & security sandboxing
  systemd.services.tor = {
    serviceConfig = {
      LimitNOFILE = 65536;
      ProtectSystem = "strict";
      ProtectHome = true;
      PrivateTmp = true;
      ProtectKernelTunables = true;
      ProtectKernelModules = true;
      ProtectControlGroups = true;
      NoNewPrivileges = true;
      CapabilityBoundingSet = "";
    };
  };

  environment.systemPackages = with pkgs; [
    # Core CLI (Available to Root & User)
    bat
    eza
    fzf
    nix-ld
    starship
    unrar
    wl-clipboard
    zoxide

    # System & GUI
    brave
    kdePackages.partitionmanager
    steam-run
    kdePackages.plasma-browser-integration
  ];

  # Global Nano Configuration
  programs.nano = {
    syntaxHighlight = true;
    nanorc = ''
      # Global settings (4-space tabs for all standard files)
      set tabsize 4
      set tabstospaces

      # Override tab size to 2 spaces ONLY for Nix files
      extendsyntax nix tabgives "  "

      # Interface styling
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

      # Behaviour
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
  };

  # Global Starship Configuration
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
      };
      cmd_duration = {
        format = "[$duration]($style) ";
        style = "bold #6c7086";
        min_time = 2000;
      };
      character = {
        format = "$symbol ";
        success_symbol = "[󰁔](bold #a6e3a1)";
        error_symbol = "[󰁔](bold #f38ba8)";
        vimcmd_symbol = "[󰁔](bold #cba6f7)";
      };
    };
  };

  # Global Fish Configuration
  programs.fish = {
    enable = true;
    shellAbbrs = {
      df = "df -h";
      du = "du -h";
      free = "free -h";
    };
    shellAliases = {
      up = "sudo nix-channel --update && nix-channel --update && sudo nixos-rebuild switch --upgrade";
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
    interactiveShellInit = ''
      set -g fish_greeting ""

      # Initialize tools globally
      zoxide init fish | source
      fzf --fish | source

      function cleanup --description "Run Nix garbage collection"
        echo -e "\e[1;36m✨ Running Nix Garbage Collection...\e[0m"
        sudo nix-collect-garbage -d
        nix-collect-garbage -d
        echo -e "\e[1;32m✨ System cleaned!\e[0m"
      end

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

  users.users."mtoxd9" = {
    isNormalUser = true;
    description = "mtoxd9";
    # Added "kvm" and "input" for full QEMU/Quickemu hardware access
    extraGroups = [ "libvirtd" "networkmanager" "wheel" "kvm" "input" ];
    shell = pkgs.fish;
  };
}
