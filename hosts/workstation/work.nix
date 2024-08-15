{
  inputs,
  pkgs,
  lib,
  ...
}:

{
  boot.kernelParams = [ "intel_iommu=on" ];

  security.pki.certificateFiles = [
    "${/avito/avito/ca.crt}"
    "${/avito/avito/root.crt}"
    "${/avito/avito-dev/ca.crt}"
  ];

  services.nfs.server.enable = true;
  services.nfs.server.exports = ''
    /home/g 192.168.39.0/24(rw,async,no_subtree_check,all_squash,anonuid=1000,anongid=1000)
    /home/g 192.168.122.0/24(rw,async,no_subtree_check,all_squash,anonuid=1000,anongid=1000)

    /home/g 10.0.2.0/24(rw,async,insecure,no_root_squash,no_subtree_check)
    /home/g 127.0.0.0/24(rw,async,insecure,no_root_squash,no_subtree_check)
  '';

  services.k3s = {
    enable = true;
    package = inputs.k3s.legacyPackages.${pkgs.system}.k3s_1_29;

    extraFlags = "--write-kubeconfig-mode 644 --disable=traefik --disable=metrics-server --docker";
  };

  virtualisation.libvirtd.enable = true;
  users.users.g.extraGroups = [
    "libvirtd"
    "adbusers"
  ];

  environment.systemPackages = with pkgs; [
    git-lfs
    ktalk
  ];

  virtualisation.lxc.enable = true;
  virtualisation.lxd.enable = true;
  virtualisation.lxd.recommendedSysctlSettings = true;

  systemd.services.k3s.wantedBy = lib.mkForce [ ];
  systemd.services.libvirtd.wantedBy = lib.mkForce [ ];
  systemd.services.libvirt-guests.wantedBy = lib.mkForce [ ];
  systemd.services.lxd.wantedBy = lib.mkForce [ ];

  environment.etc.hosts.mode = "0644";
  services.resolved.dnssec = "false";

  networking.firewall.enable = false;
  networking.firewall.extraCommands = ''
    iptables -I INPUT -i virbr+ -j ACCEPT
  '';

  virtualisation.docker.daemon.settings = {
    dns = [
      "10.0.0.1"
      "10.0.0.10"
      "8.8.8.8"
    ];
    dns-search = [ "msk.avito.ru" ];
  };
}
