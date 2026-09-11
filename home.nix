{ config, pkgs, ... }:

{
  imports = [
    (fetchTarball "https://github.com/gmodena/nix-flatpak/archive/latest.tar.gz" + "/modules/home-manager.nix")
  ];

  home.username = "mtoxd9";
  home.homeDirectory = "/home/mtoxd9";
  home.stateVersion = "26.05";

  # nixpkgs.config.allowUnfree = true;
  xdg.enable = true;
  programs.home-manager.enable = true;

  # =========================================================================
  # 1. FLATPAK CONFIGURATION
  # =========================================================================
  services.flatpak = {
    enable = true;
    remotes = [
      {
        name = "flathub";
        location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
      }
    ];
    packages = [];
    update = {
      onActivation = true;
      auto = {
        enable = false;
        onCalendar = "weekly";
      };
    };
  };

  # =========================================================================
  # 2. USER PACKAGES (GUI & Dev Tools)
  # =========================================================================
  home.packages = with pkgs; [
    # -- Development & Code --

    # -- Utilities --
    libnotify
    unzip

    # -- Media & Communication --
    spotify
    telegram-desktop
    vlc

    # -- Virtualization & Gaming --
    kdePackages.kate
    qbittorrent
    qemu
    quickemu
  ];

  # =========================================================================
  # 3. FIREFOX CONFIGURATION
  # =========================================================================
  programs.firefox = {
    enable = true;
    profiles = {
      default = {
        id = 0;
        isDefault = true;
        settings = {
          "dom.ipc.processCount" = 2;
          "browser.sessionstore.restore_on_demand" = true;
          "browser.tabs.unloadOnLowMemory" = true;
          "accessibility.force_disabled" = 1;
        };
      };
    };
  };

  # =========================================================================
  # 4. DCONF / VIRT-MANAGER
  # =========================================================================
  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = [ "qemu:///system" ];
      uris = [ "qemu:///system" ];
    };
  };
}
