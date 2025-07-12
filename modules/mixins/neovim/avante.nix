{
  programs.nixvim.plugins.avante = {
    enable = true;
    autoLoad = true;
    settings = {
      provider = "ollama";
      use_absolute_path = true;
      auto_suggestions_provider = "ollama";
      vendors = {
        ollama = {
          __inherited_from = "openai";
          api_key_name = "";
          endpoint = "http://127.0.0.1:11434/v1";
          model = "codegemma";
          disable_tools = true;
        };
      };
    };
  };
}
