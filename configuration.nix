{ config, pkgs, ... }:

{
  # ===========================================================================
  # 1. SYSTEM CONFIGURATION & BOOT
  # ===========================================================================
  imports = [  
    ./hardware-configuration.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 10; # Purges old generations from boot menu
  boot.kernelPackages = pkgs.linuxPackages_zen;     # Desktop optimized kernel

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
  # 3. DESKTOP, AUDIO & BLUETOOTH (KDE PLASMA 6)
  # ===========================================================================
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

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
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
    nerd-fonts.hack
  ];

  # ===========================================================================
  # 4. HARDWARE, DRIVERS & VIRTUALIZATION
  # ===========================================================================
  hardware.enableRedistributableFirmware = true;
   
  services.btrfs.autoScrub = {
    enable = true;
    interval = "monthly";
    fileSystems = [ "/" ];
  };

  zramSwap = {
    enable = true;
    priority = 100;
    algorithm = "lz4";
    memoryPercent = 50;
  };

#  virtualisation.waydroid.enable = true;
  virtualisation.waydroid = {
    enable = true;
    package = pkgs.waydroid-nftables;
  };

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

  hardware.graphics = {
    enable = true;
    enable32Bit = true; # Crucial for apps like Parsec
    extraPackages = with pkgs; [
      intel-media-driver
      intel-vaapi-driver
      libvdpau-va-gl
      intel-media-sdk              # For 10th Gen Intel and older (OBS QuickSync)
      intel-compute-runtime-legacy1 # For HD 620 (Gen9 Kaby Lake) / OpenCL
    ];
    extraPackages32 = with pkgs.pkgsi686Linux; [
      intel-media-driver
      intel-vaapi-driver
    ];
  };

  # Ensures your SSD stays fast and healthy (Crucial for BTRFS)
  services.fstrim.enable = true;
   
  # Updates Intel CPU microcode on boot for security and stability
  hardware.cpu.intel.updateMicrocode = true;

  # ===========================================================================
  # 5. NIX SETTINGS & GLOBAL APPS
  # ===========================================================================
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [
    "intel-media-sdk-23.2.2"
  ];

  nix.settings = {     
    auto-optimise-store = true;
    substituters = [
      "https://cache.nixos.org/"
      "https://nix-community.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };
   
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # Fish must be enabled globally to set it as a default user shell
  programs.fish.enable = true;      

  # Only core system tools go here. User apps go in home.nix.
  environment.systemPackages = with pkgs; [
    kdePackages.partitionmanager
    unrar
    wl-clipboard
    brave
    steam-run
    nix-ld
  ];

  # ===========================================================================
  # 6. USER ACCOUNT
  # ===========================================================================
  users.users."mtoxd9" = {
    isNormalUser = true;
    description = "mtoxd9";
    extraGroups = [ "networkmanager" "wheel" "libvirtd" ];
    packages = with pkgs; [ kdePackages.kate ];
    shell = pkgs.fish;   
  };

  system.stateVersion = "26.05";
}
