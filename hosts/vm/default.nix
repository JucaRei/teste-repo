#
#  Specific system configuration settings for desktop
#
#  flake.nix
#   ├─ ./hosts
#   │   └─ ./vm
#   │       ├─ default.nix *
#   │       └─ hardware-configuration.nix
#   └─ ./modules
#       └─ ./desktop
#           └─ ./bspwm
#               └─ bspwm.nix
#

{ config, pkgs, ... }:

{
  #################################
  ### Modules for this machine. ###
  #################################
  imports =  [                                  # For now, if applying to other system, swap files
    ./hardware-configuration.nix                # Current system hardware config @ /etc/nixos/hardware-configuration.nix
    ../../modules/desktop/gnome/default.nix     # Window Manager
  ];
   #####################################################
   ### Default packges on the System, for all users. ###
   #####################################################
   environment = {                               # Packages installed system wide
    systemPackages = with pkgs; [               # This is because some options need to be configured.
      # discord
      #plex
      neofetch
      duf
      exa
      htop
      git
      wget
      neovim
      # simple-scan
      # x11vnc
    ];
    # variables = {
      # LIBVA_DRIVER_NAME = "i965";
    # };
  };

  ###########################
  ### Set your time zone. ###
  ###########################
  time = {
    timeZone = "America/Sao_Paulo";
    hardwareClockInLocalTime = true;  #keep the hardware clock in local time instead of UTC.
  };

  ###############################################
  ### Select internationalisation properties. ###
  ###############################################
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_TIME = "pt_BR.UTF-8";
      LC_MONETARY = "pt_BR.UTF-8";
      LC_NUMERIC = "pt_BR.UTF-8";
      LC_NAME = "pt_BR.UTF-8";
      LC_ADDRESS = "pt_BR.UTF-8";
      LC_TELEPHONE= "pt_BR.UTF-8";
      LC_MEASUREMENT = "pt_BR.UTF-8";
    };
  };

  #######################
  ### Console options ###
  #######################
  console = {
    font = "Lat2-Terminus16";
    keyMap = "br-abnt2";
    # useXkbConfig = true; # use xkbOptions in tty.
  };
  
  #######################################
  ### Enable Default System Services. ###
  #######################################
  services = {

    ## Enable the Desktop Environment.
    xserver = {
      enable = true;

      # Default Resolutions
      resolutions = [ 
        { x = 1920; y = 1080; }
        # { x = 1600; y = 900; }
        # { x = 3840; y = 2160; }
      ];

      # Display manager
      # displayManager = {
      #   lightdm = {
      #     enable = true;
      #     greeters = {
      #       slick = {
      #         enable = true;
      #         theme.name = "Adwaita";
      #         iconTheme.name = "Adwaita";
      #       };
      #     };
      #   };
      # };
      
      # Desktop Manager
      # desktopManager = { # any DM you like
      #   # defaultSession = "xfce"; 
      #   xfce.enable = true;
      # };
      # windowManager.bspwm.enable = true;

      # Enable touchpad support (enabled default in most desktopManager).
      libinput = {
        enable = true;
        touchpad.tapping = true;
        # naturalScrolling = true;
        # ...
      };
    };

    ## Enable CUPS to print documents.
    printing.enable = true;

    ## Bluetooth
    # blueman.enable = true; 

    ## SAMBA File Sharing over local network                     
    samba = {                                   
      enable = true;                            # Don't forget to set a password:  $ smbpasswd -a <user>
      shares = {
        share = {
          "path" = "/home/${user}";
          "guest ok" = "yes";
          "read only" = "no";
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
      };
      openFirewall = true;
    };
    
    ## Enable gvfs
    gvfs = {
      enable = true;
      # package = lib.mkForce pkgs.gnome3.gvfs;    #needed for xfce Thunar
    };

    ## Openssh
    openssh = {
      enable = true;
      # permitRootLogin = "no";
      # passwordAuthentication = true;
      # hostKeys = [ 
      #   {
      #     path = "/persist/etc/ssh/ssh_host_ed25519_key";
      #     type = "ed25519";
      #   }
      #   {
      #     path = "/persist/etc/ssh/ssh_host_rsa_key";
      #     type = "rsa";
      #     bits = 4096;
      #   }
      # ];
    }
  };

  ############################
  ### Define user accounts ###
  ############################
  users.users.${user} = {
    isNormalUser = true;
    description = "Reinaldo P JR";
    group = "nix";
    createHome = true;
    uid = 1000;
    # shell = "/bin/zsh";  # for zsh
    shell = "/bin/bash";
    autoSubUidGidRange = true;  # Allocated range is currently always of size 65536
    extraGroups = [ "wheel" "video" "networkmanager" "lp" "scanner" ]; # Enable ‘sudo’ for the user.
    initialPassword = "teste";
    packages = with pkgs; [  ### Packages available only for this user;
      firefox
      gparted
      btop
    ];
  };

  programs = {
    ## ZSH Config
    # zsh.enable = true;  # if default shell is zsh
    ## Enable GnuPG Agent
    # gnupg.agent = {
    #   enable = true;
    #   enableSSHSupport = true; 
    # };
  };

  #############################
  ### Nix overlay packages. ###
  #############################

  # nixpkgs.overlays = [                          # This overlay will pull the latest version of Discord
  #   (self: super: {
  #     discord = super.discord.overrideAttrs (
  #       _: { src = builtins.fetchTarball {
  #         url = "https://discord.com/api/download?platform=linux&format=tar.gz";
  #         sha256 = "1z980p3zmwmy29cdz2v8c36ywrybr7saw8n0w7wlb74m63zb9gpi";
  #       };}
  #     );
  #   })
  # ];

  ####################
  ### System confs ###
  ####################
  system = {
    stateVersion = "22.11"; # Did you read the comment?
    autoUpgrade = {
      enable = true;
      operation = "switch";
      # channel = "https://nixos.org/channels/nixos-22.11";
      dates = "22:00";
      # flake = "/server";
      flags = [
        "--update-input" "nixpkgs" "--commit-lock-file" 
    ];
    # allowReboot = true;
    };
  };

  ###################
  ### NIX CONFIGS ###
  ###################

  nix = {
    settings.auto-optimise-store = true;
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 6d";
    };
    # Flakes
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
      keep-outputs = true
      keep-derivations = true
    '';
  };
}
