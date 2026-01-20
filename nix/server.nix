{ config, pkgs, ... }: {
  # All installed packages
  environment.systemPackages = with pkgs; [
    bat
    byobu
    delta
    dig
    docker-compose
    eza
    fish
    git
    htop
    hugo
    neovim
    optipng
    pwgen
    ripgrep
    tig
    tmux
    wget
  ];
  programs.neovim.enable = true;
  programs.neovim.defaultEditor = true;

  # Security
  services.openssh.settings.PasswordAuthentication = false;
  networking.firewall.allowedTCPPorts = [ 80 443 6697 ];

  # Automatic updates
  system.autoUpgrade = {
    enable = true;
    dates = "04:00";
    randomizedDelaySec = "45min";
    allowReboot = true;
  };

  # User management
  programs.fish.enable = true;
  users.users.maaike = {
    isNormalUser = true;
    home = "/home/maaike";
    shell = pkgs.fish;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEkqGExf0OKNa+Fzq09JRYQjelMK3CjkqUiQEtrnZAry ayke@elstar-linux'' ];
  };
  users.users.unprivileged = {
    isNormalUser = true;
    home = "/home/unprivileged";
    linger = true;
  };

  # TLS
  users.groups.tlsgroup.members = [ "nginx" "soju"];
  security.acme = {
    acceptTerms = true;
    defaults.email = "acme@aykevl.nl";
    certs."aykevl.nl" = {
      group = "tlsgroup";
      reloadServices = [ "nginx" "soju" ];
      extraDomainNames = [
        "photos.aykevl.nl"
        "ruby.aykevl.nl"
        "www.aykevl.nl"
      ];
    };
  };

  # Web service
  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    virtualHosts."aykevl.nl" = {
      default = true;
      enableACME = true;
      forceSSL = true;
      root = "/srv/aykevl.nl";
      locations."^~ /apps/led-editor/".proxyPass = "http://localhost:8080/";
      locations."/".extraConfig = ''
        try_files /blog/$uri /blog/$uri/index.html $uri $uri/ =404;
      '';
      locations."~ ^/apps/visor/web/".extraConfig = ''
        add_header Cross-Origin-Opener-Policy same-origin;
        add_header Cross-Origin-Embedder-Policy require-corp;
      '';
    };
    virtualHosts."photos.aykevl.nl" = {
      enableACME = true;
      forceSSL = true;
      locations."/".proxyPass = "http://localhost:2283/";
      extraConfig = ''
        client_max_body_size 50000M;
        proxy_read_timeout   600s;
        proxy_send_timeout   600s;
        send_timeout         600s;
      '';
    };
    virtualHosts."www.aykevl.nl" = {
      enableACME = true;
      forceSSL = true;
      locations."/".return = "301 https://aykevl.nl$request_uri";
    };
  };

  # Self hosted Google Photos alternative, yay :D
  services.immich = {
    enable = true;
    port = 2283;
    mediaLocation = "/mnt/storagebox/immich";
  };
  fileSystems."/mnt/storagebox" = {
    device = "u534655@u534655.your-storagebox.de:/";
    fsType = "fuse.sshfs";
    options = [
      "IdentityFile=/root/keys/storage-box"
      "nodev"
      "noatime"
      "allow_other"
      "reconnect"
    ];
  };

  # IRC
  services.soju = {
    enable = true;
    adminSocket.enable = true;
    tlsCertificateKey = "/var/lib/acme/aykevl.nl/key.pem";
    tlsCertificate = "/var/lib/acme/aykevl.nl/fullchain.pem";
    hostName = "aykevl.nl";
  };

  # Allow users to run Docker (this should be more secure than running Docker
  # as root).
  virtualisation.docker = {
    enable = false;
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };
}

# Manually configured:
# - initial setup
# - /root/keys/storage-box
# - soju account
# - containers:
#   - led-editor-builder
