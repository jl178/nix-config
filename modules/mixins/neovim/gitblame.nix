{
  programs.nixvim.plugins.gitblame = {
    enable = true;
    settings.delay = 3000;
    settings.dateFormat = "%r";
    settings.messageTemplate = " <author>, <date>";
  };
}
