#
# Qemu/KVM with virt-manager 
#

{ config, pkgs, user, ... }:

{                                             # Add libvirtd and kvm to userGroups
  boot.extraModprobeConfig = ''
    options kvm_intel nested=1
    options kvm_intel emulate_invalid_guest_state=0
    options kvm ignore_nsrs=1
  '';                                         # Needed to run OSX-KVM 

  users.groups.libvirtd.members = [ "root" "${user}" ];

  virtualisation = {
    libvirtd = {
      enable = true;                          # Virtual drivers
      #qemuPackage = pkgs.qemu_kvm;           # Default
      qemu = {
        verbatimConfig = ''
         nvram = [ "${pkgs.OVMF}/FV/OVMF.fd:${pkgs.OVMF}/FV/OVMF_VARS.fd" ]
        '';
      };
    };
    spiceUSBRedirection.enable = true;        # USB passthrough
  };

  environment = {
    systemPackages = with pkgs; [
      virt-manager
      virt-viewer
      qemu
      OVMF
      gvfs                                    # Used for shared folders between Linux and Windows
    ];
  };

  services = {                                # Enable file sharing between OS
    gvfs.enable = true;
  };
