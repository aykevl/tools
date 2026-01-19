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
    flags = [
      "--print-build-logs"
    ];
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
    certs."ruby.aykevl.nl" = {
      group = "tlsgroup";
      reloadServices = [ "nginx" "soju" ];
    };
  };

  # Web service
  services.nginx = {
    enable = true;
    virtualHosts."ruby.aykevl.nl" = {
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
  };

  # IRC
  services.soju = {
    enable = true;
    adminSocket.enable = true;
    tlsCertificateKey = "/var/lib/acme/ruby.aykevl.nl/key.pem";
    tlsCertificate = "/var/lib/acme/ruby.aykevl.nl/fullchain.pem";
    hostName = "ruby.aykevl.nl";
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
