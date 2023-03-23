#
# Hardware settings for a general VM.
# Works on QEMU Virt-Manager and Virtualbox
#
# flake.nix
#  └─ ./hosts
#      └─ ./vm
#          └─ hardware-configuration.nix *
#
# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
#

{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ 
      # (modulesPath + "/installer/scan/not-detected.nix")
    ];

  ### BOOT
  boot = {

    ### Kernel options
    kernelPackages = pkgs.linuxPackages_latest;
    # kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages; # zfs
    kernel.sysctl = { "vm.vfs_cache_pressure"= 500; "vm.swappiness"=100; "vm.dirty_background_ratio"=1; "vm.dirty_ratio"=50; "dev.i915.perf_stream_paranoid"=0; };

    ### systemd-boot
    # loader = {                                  # For legacy boot:
    #   systemd-boot = {
    #     enable = true;
    #     configurationLimit = 5;                 # Limit the amount of configurations
    #   };
    #   efi.canTouchEfiVariables = true;
    #   timeout = 6;                              # Grub auto select time
    # };

    ### Grub
    loader = {
      grub = {
        enable = true;
        version = 2;
        # default = 0;              # "saved";
        devices = [ "nodev" ];      # device = "/dev/sda"; or "nodev" for efi only
        # device = "/dev/vda";      # legacy
        efiSupport = true;
        efiInstallAsRemovable = true;
        configurationLimit = 5;     # do not store more than 5 gen backups
        forceInstall = true;
        copyKernels = true;
        splashMode = "stretch";
        # zfsSupport = true;        # enable zfs
        # copyKernels = true;       # https://nixos.wiki/wiki/NixOS_on_ZFS
        useOSProber = false;         # check for other systems
        fsIdentifier = "label";     # mount devices config using label
        gfxmodeEfi = "1920x1080";
        # gfxmodeBios = "1920x1080";
        # trustedBoot.systemHasTPM = "YES_TPM_is_activated"
        # trustedBoot.enable = true;
        # extraModulePackages = [ config.boot.kernelPackages.nvidia_x11 ];
        # theme = "";               # set theme
        # enableCryptodisk = true;  # 
        extraEntries = ''
          menuentry "Reboot" {
            reboot
          }
          menuentry "Poweroff" {
            halt
          }
        '';
      };
      timeout = 6;
      efi = {
        efiSysMountPoint = "/mnt/boot/efi";
        canTouchEfiVariables = false;
      };
    };
      
    ### Enable plymouth
    plymouth = {
      theme = "breeze";
      enable = true;
    };

    ### Enabled filesystem
    # supportedFilesystems = [ "vfat" "zfs" ];
    supportedFilesystems = [ "vfat" "btrfs" ];

    # initrd early load modules
    initrd = {
      availableKernelModules = [ "ahci" "xhci_pci" "virtio_pci" "sr_mod" "virtio_blk" ];
      # kernelModules = [ "i915" "nvidia" ];
      checkJournalingFS = false;  # for vm
    };
    kernelModules = [ "kvm-intel" "z3fold" "crc32c-intel" "lz4hc" "lz4hc_compress" "zram" ];
    extraModulePackages = with config.boot.kernelPackages; [ ];
    # zfs.requestEncryptionCredentials = true;  
  };

  ### BTRFS ###
  fileSystems."/" =
    { device = "/dev/disk/by-label/NIXOS";
      fsType = "btrfs";
      options = [ "subvol=@root" "rw" "noatime" "ssd" "compress-force=zstd:15" "space_cache=v2" "commit=120" "autodefrag" "discard=async" ];
    };

  fileSystems."/home" =
    { device = "/dev/disk/by-label/NIXOS";
      fsType = "btrfs";
      options = [ "subvol=@home" "rw" "noatime" "ssd" "compress-force=zstd:15" "space_cache=v2" "commit=120" "autodefrag" "discard=async" ];
    };

  fileSystems."/.snapshots" =
    { device = "/dev/disk/by-label/NIXOS";
      fsType = "btrfs";
      options = [ "subvol=@snapshots" "rw" "noatime" "ssd" "compress-force=zstd:15" "space_cache=v2" "commit=120" "autodefrag" "discard=async" ];
    };

  fileSystems."/var/tmp" =
    { device = "/dev/disk/by-label/NIXOS";
      fsType = "btrfs";
      options = [ "subvol=@tmp" "rw" "noatime" "ssd" "compress-force=zstd:15" "space_cache=v2" "commit=120" "autodefrag" "discard=async" ];
    };

  fileSystems."/nix" =
    { device = "/dev/disk/by-label/NIXOS";
      fsType = "btrfs";
      options = [ "subvol=@nix" "rw" "noatime" "ssd" "compress-force=zstd:15" "space_cache=v2" "commit=120" "autodefrag" "discard=async" ];
    };

  fileSystems."/boot/efi" =
    { device = "/dev/disk/by-label/GRUB";
      fsType = "vfat";
      options = [ "rw" "defaults" "noatime" "nodiratime" ];
    };

    swapDevices = [ ];

  networking = {
    # useDHCP = false;                        # Deprecated
    hostName = "vm";
    # interfaces = {
    #   enp1s0.useDHCP = true;
    # };
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;  
}
