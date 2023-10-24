{ pkgs, ... }:

let
  description = "CouchDB";
  name = "couchdb";
  image = "couchdb:3";
  configOpt =
    "-v /home/cloud/couchdb/config:/opt/couchdb/etc/local.d/ -v /home/cloud/couchdb/data:/opt/couchdb/data";
  extraOpt = "--pull=always -v /etc/localtime:/etc/localtime:ro --net=host";
in {
  systemd.services.couchdb = {
    description = description;

    wantedBy = [ "multi-user.target" ];
    requires = [ "docker.service" ];
    after = [ "network.target" ];

    serviceConfig = {
      Restart = "always";
      RestartSec = "3";
      ExecStart = "${pkgs.docker}/bin/docker run --name=${name} ${configOpt} ${extraOpt} ${image}";
      ExecStop = "${pkgs.docker}/bin/docker stop -t 2 ${name}";
      ExecStopPost = "${pkgs.docker}/bin/docker rm -f ${name}";
    };
  };
}
