{ config, pkgs, inputs, ... }:

{
  config = {
    home-manager.users.jered = { pkgs, ... }: {
  services.picom = {
    enable = true;
    activeOpacity = 1;
    inactiveOpacity = .75;
    fade = true;
    settings = {
      corner-radius = 8;
      # blur = {
      #   method = "gaussian";
      #   # size = "20";
      #   # deviation = 15;
      # };
    };

    # extraOptions = ''
    #   corner-radius = 8;
    #   rounded-corners-exclude = [
    #     "class_i = 'polybar'"
    #   ];
    # '';
  };
    };
  };
}
