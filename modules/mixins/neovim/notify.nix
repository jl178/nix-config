{
  programs.nixvim.plugins.notify = {
    enable = true;
    settings = {
      fps = 75;
      background_colour = "#000000";
      max_width = 40;
      render = "wrapped-compact";
      stages = "slide";
    };
  };
  programs.nixvim = {
    # Annoying, incorrect message with tsserver. Ignore it.
    extraConfigLua = ''
      local banned_messages = { "No information available" }
      vim.notify = function(msg, ...)
        for _, banned in ipairs(banned_messages) do
          if msg == banned then
            return
          end
        end
        return require("notify")(msg, ...)
      end
    '';
  };
}
