_: {
  services.vaultwarden = {
    enable = true;
    config = {
      domain = "https://vw.porivaev.ru";
      signupsAllowed = false;
      rocketPort = 3011;
      websocketEnabled = true;
    };
  };
}
