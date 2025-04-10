{
  lib,
  config,
  ...
}: let
  cfg = config.grazor.services;
in {
  options.grazor.services.ollama.enable = lib.mkEnableOption "ollama service";
  config = lib.mkIf cfg.ollama.enable {
    services = {
      ollama.enable = true;
      ollama.environmentVariables = {};
      nextjs-ollama-llm-ui.enable = true;
      nextjs-ollama-llm-ui.hostname = "0.0.0.0";
    };
  };
}
