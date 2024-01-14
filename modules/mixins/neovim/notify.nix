{
  programs.nixvim.plugins.notify = {
    enable = true;
    fps = 75;
    backgroundColour = "#000000";
    maxWidth = 40;
    extraOptions = {
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
