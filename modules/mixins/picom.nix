{ config, pkgs, inputs, ... }:

{
  config = {
    home-manager.users.jered = { pkgs, ... }: {
      services.picom = {
        enable = true;
        activeOpacity = 1;
        inactiveOpacity = 0.95;
        fade = true;
        fadeExclude = [ "class_g = 'Brave-browser'" ];
        opacityRules = [
          "100:class_g = 'Brave-browser'" # Make Brave fully opaque
        ];
        settings = {
          corner-radius = 8;
          # blur = {
          #   method = "gaussian";
          #   # size = "20";
          #   # deviation = 15;
          # };
        };

        # extraOptions = ''
        #   blur-background-exclude = [ "class_g = 'Brave-browser'" ]
        # '';
      };
    };
  };
}
