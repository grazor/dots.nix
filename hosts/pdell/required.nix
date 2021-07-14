{ pkgs, ... }:

{
    security.pki.certificateFiles = [ "/root/cert" ];

    services.nfs.server.enable = true;
    services.nfs.server.exports = ''
        /home/g 192.168.39.0/24(rw,async,no_subtree_check,all_squash,anonuid=1000,anongid=1000)
        /home/g 192.168.122.0/24(rw,async,no_subtree_check,all_squash,anonuid=1000,anongid=1000)
    '';

    virtualisation.libvirtd.enable = true;
    users.users.g.extraGroups = ["libvirtd"];
    #boot.extraModprobeConfig = "options kvm_intel nested=1"; # enable nested virtualization

    environment.packages = with pkgs; [
	git-lfs jq curl 
    ];
}
