{
  programs.nixvim.plugins.avante = {
    enable = true;
    autoLoad = true;
    settings = {
      provider = "ollama";
      ollama = {
        endpoint = "http://127.0.0.1:11434";
        model = "codegemma";
      };
      # use_absolute_path = true;
      auto_suggestions_provider = "ollama";
    };
  };
}
