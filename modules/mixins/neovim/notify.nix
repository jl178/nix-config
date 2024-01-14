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
}
