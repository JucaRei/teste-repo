#
#  Main system configuration. More information available in configuration.nix(5) man page.
#
#  flake.nix
#   ├─ ./hosts
#   │   └─ configuration.nix *
#   └─ ./modules
#       ├─ ./editors
#       │   └─ default.nix
#       └─ ./shell
#           └─ default.nix
#

{ config, lib, pkgs, inputs, user, ... }:

let 
 user = "juca";
in

{
  imports =
    (import ../modules/editors) ++          # Native doom emacs instead of nix-community flake
    (import ../modules/shell);

  # users.users.${user} = {                   # System User
  #   isNormalUser = true;
  #   uid = 1000;
  #   initialPassword = "teste";
  #   extraGroups = [ "wheel" "video" "audio" "camera" "networkmanager" "lp" "scanner" "kvm" "libvirtd" "plex" ];
  #   # shell = pkgs.zsh;                       # Default shell
  # };


  time.timeZone = "America/Sao_Paulo";        # Time zone and internationalisation
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {                 # Extra locale settings that need to be overwritten
      LC_TIME = "pt_BR.UTF-8";
      LC_MONETARY = "pt_BR.UTF-8";
    };
  };

  console = {
    font = "Lat2-Terminus16";
    keyMap = "br-abnt2";                          # or us/azerty/etc
  };

  security = {
    rtkit.enable = true;
    polkit.enable = true;
    sudo.wheelNeedsPassword = false; # User does not need to give password when using sudo.
  };

  fonts.fonts = with pkgs; [                # Fonts
    carlito                                 # NixOS
    vegur                                   # NixOS
    source-code-pro
    jetbrains-mono
    font-awesome                            # Icons
    corefonts                               # MS
    (nerdfonts.override {                   # Nerdfont Icons override
      fonts = [
        "FiraCode"
      ];
    })
  ];

  environment = {
    variables = {
      TERMINAL = "alacritty";
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
    systemPackages = with pkgs; [           # Default packages installed system-wide
      vim
      git
      killall
      nano
      pciutils
      usbutils
      wget
      duf
      neofetch
      cifs-utils
    ];
  };

  ### Virt-manager
  # virtualisation.libvirtd.enable = true; 
  # programs.dconf.enable = true; 

  services = {

    ## Enable the Desktop Environment.
    xserver = {
      enable = true;
      resolutions = [ 
        { x = 1920; y = 1080; }
        # { x = 1600; y = 900; }
        # { x = 3840; y = 2160; }
      ];
      libinput = {
        enable = true;
        touchpad.tapping = true;
        # naturalScrolling = true;
        # ...
      };
    };

    ## SAMBA File Sharing over local network                     
    samba = {                                   
      enable = true;  
      shares = {                          # Don't forget to set a password:  $ smbpasswd -a <user>
        public = {
          "path" = "/home/${user}/Samba";
          "guest ok" = "yes";
          "create mask" = "0644";
          "directory mask" = "0755";
          "read only" = "no";
        };
      };
      extraConfig = ''
        workgroup = WORKGROUP
        server string = smbnix
        netbios name = smbnix
        security = user 
        #use sendfile = yes
        min protocol =  NT1
        #max protocol = smb2
        # note: localhost is the ipv6 localhost ::1
        hosts allow = 192.168.1. 127.0.0.1 localhost
        # hosts deny = 0.0.0.0/0
        guest account = nobody
        map to guest = bad user
      '';
      openFirewall = true;
    };

    ## Enable gvfs
    gvfs = {
      enable = true;
      # package = lib.mkForce pkgs.gnome3.gvfs;    #needed for xfce Thunar
    };

    printing = {                                # Printing and drivers for TS5300
      enable = true;
      #drivers = [ pkgs.cnijfilter2 ];          # There is the possibility cups will complain about missing cmdtocanonij3. I guess this is just an error that can be ignored for now. Also no longer need required since server uses ipp to share printer over network.
    };
    avahi = {                                   # Needed to find wireless printer
      enable = true;
      nssmdns = true;
      publish = {                               # Needed for detecting the scanner
        enable = true;
        addresses = true;
        userServices = true;
      };
    };
    pipewire = {                            # Sound
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
      jack.enable = true;
    };
    openssh = {                             # SSH: secure shell (remote connection to shell of server)
      enable = true;                        # local: $ ssh <user>@<ip>
                                            # public:
                                            #   - port forward 22 TCP to server
                                            #   - in case you want to use the domain name insted of the ip:
                                            #       - for me, via cloudflare, create an A record with name "ssh" to the correct ip without proxy
                                            #   - connect via ssh <user>@<ip or ssh.domain>
                                            # generating a key:
                                            #   - $ ssh-keygen   |  ssh-copy-id <ip/domain>  |  ssh-add
                                            #   - if ssh-add does not work: $ eval `ssh-agent -s`
      allowSFTP = true;                     # SFTP: secure file transfer protocol (send file to server)
                                            # connect: $ sftp <user>@<ip/domain>
                                            #   or with file browser: sftp://<ip address>
                                            # commands:
                                            #   - lpwd & pwd = print (local) parent working directory
                                            #   - put/get <filename> = send or receive file
      extraConfig = ''
        HostKeyAlgorithms +ssh-rsa
      '';                                   # Temporary extra config so ssh will work in guacamole
    };
    flatpak.enable = true;                  # download flatpak file from website - sudo flatpak install <path> - reboot if not showing up
                                            # sudo flatpak uninstall --delete-data <app-id> (> flatpak list --app) - flatpak uninstall --unused
                                            # List:
                                            # com.obsproject.Studio
                                            # com.parsecgaming.parsec
                                            # com.usebottles.bottles
  };

  nix = {                                   # Nix Package Manager settings
    settings ={
      auto-optimise-store = true;           # Optimise syslinks
    };
    gc = {                                  # Automatic garbage collection
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 2d";
    };
    package = pkgs.nixVersions.unstable;    # Enable nixFlakes on system
    # package = pkgs.nixVersions.stable;    # Enable nixFlakes on system
    registry.nixpkgs.flake = inputs.nixpkgs;
    extraOptions = ''
      experimental-features = nix-command flakes
      keep-outputs          = true
      keep-derivations      = true
    '';
  };
   nixpkgs.config = {
    # allowUnsupportedSystem = true; # For permanently allowing unsupported packages to be built.
    allowUnfree = true; # unfree packages
    # allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [   # allow only selected unfree packages
    #   "roon-server"
    #   "vscode"
    # ];
    # permittedInsecurePackages = [
    # "balenaetcher"
    # ];
    # NIXPKGS_ALLOW_INSECURE = 1;

    # overlays = [
    #   (self: super: {
    #     discord = super.discord.overrideAttrs (
    #       _: { src = builtins.fetchTarball {
    #         url = "https://discord.com/api/download?platform=linux&format=tar.gz"
    #         ;
    #         sha256 =
    #         "0000000000000000000000000000000000000000000000000000";
    #       };}
    #     );
    #   })
    # ];
  };

  system = {                                # NixOS settings
    autoUpgrade = {                         # Allow auto update (not useful in flakes)
      enable = true;
      # operation = "switch";
      channel = "https://nixos.org/channels/nixos-unstable";
      # channel = "https://nixos.org/channels/nixos-22.11";
      dates = "22:00";
      flags = [
        "--update-input" "nixpkgs" "--commit-lock-file" 
      ];
      # allowReboot = true;
    };
    stateVersion = "22.11";
  };
}
