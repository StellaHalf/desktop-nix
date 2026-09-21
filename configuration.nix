{ config, lib, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

    
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  
  boot.loader = {
    grub = {
      enable = true;
      device = "nodev";
      efiSupport = true;
    };
    efi.canTouchEfiVariables = true;
  };

  boot.initrd.luks.devices = {
    luksroot = {
      device = "/dev/disk/by-uuid/8b8b2817-53a0-4eb9-8665-be15ec611e40";
      allowDiscards = true;
    };
  };

  environment.etc = {
    cpuconfig = {
      text = ''#!/bin/sh
        echo "0" > /sys/devices/system/cpu/cpu4/online
        echo "0" > /sys/devices/system/cpu/cpu5/online
        echo "disabled faulty CPU cores"
      '';
      mode = "0777";
    };
  };

  systemd.services.cpuconfig = {
    enable = true;
    wantedBy = ["default.target"];
    description = "disable faulty CPU cores";
    after = ["systemd-ask-password-wall"];
    requires =  ["systemd-ask-password-wall"];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "/etc/cpuconfig";
    };
  };

  networking = {
    hostName = "mother-brain";
    networkmanager.enable = true;
  };

  time.timeZone = "Europe/Berlin";

  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "de";

  services = {
    greetd = {
      enable = true;
      settings.default_session = {
        command = "tuigreet --remember --remember-user-session --asterisks";
        user = "greeter";
      };
    };
    printing = {
      enable = true;
      drivers = [ pkgs.hplipWithPlugin ];
    };
    pipewire = {
      enable = true;
      pulse.enable = true;
    };
    openssh.enable = true;
    udisks2.enable = true;
  };
  
  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
    };
    bluetooth.enable = true;
  };
  
  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "discord"
      "steam"
      "steam-unwrapped"
      "hplip"
    ];
    
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk pkgs.xdg-desktop-portal-gnome ];
    config.common = {
      "org.freedesktop.impl.portal.Screencast" = [ "gnome" ];
      default = [ "gtk" ];
    };
  };

  environment.systemPackages = with pkgs; [
    tuigreet
  ];
  
  users.users.mika = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      vim
      helix
      
      niri
      xwayland-satellite
      noctalia-shell
      xdg-desktop-portal-gnome
      xdg-desktop-portal-gtk
      
      kitty
      fish
      tree
      wget
      curl
      git

      gpu-screen-recorder
      obs-studio
      
      rustup
      gcc
      godot
      wineWow64Packages.waylandFull
      typst
      tinymist

      fd
      usbutils
      firefox
      thunderbird
      nautilus
      discord
      zed
      hyfetch
      steam
      heroic
      amdgpu_top
      lmms
      openutau
      musescore-evolution
      dolphin-emu
      zsnes
      libreoffice
      gtop
      htop
      gnome-characters
      shotcut
      celluloid
      loupe
      gnome-calculator
      gnome-system-monitor
      gnome-disk-utility
      evince
      signal-desktop
      rhythmbox
      gimp
      android-file-transfer
    ];  
  };
  
  system.stateVersion = "26.05"; # Did you read the comment?
}

