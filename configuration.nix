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
    after = ["sysinit.target"];
    requires =  ["sysinit.target"];
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
    printing.enable = true;
    pipewire = {
      enable = true;
      pulse.enable = true;
    };
    openssh.enable = true;
  };


  environment.systemPackages = with pkgs; [
    tuigreet
  ];
  
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
      
      firefox
      thunderbird
      nautilus
      discord
      zed
      hyfetch
      steam
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
    ];  
  };
  
  system.stateVersion = "26.05"; # Did you read the comment?
}

