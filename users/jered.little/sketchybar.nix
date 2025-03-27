{ config, pkgs, libs, ... }: {
  home.packages = with pkgs; [ aerospace jankyborders sketchybar ];
  xdg.configFile."sketchybar/sketchybarrc".executable = true;
  xdg.configFile."sketchybar/sketchybarrc".source =
    ./config/sketchybar/sketchybarrc;

  xdg.configFile."sketchybar/items".source = ./config/sketchybar/items;
  xdg.configFile."sketchybar/plugins".source = ./config/sketchybar/plugins;
  xdg.configFile."sketchybar/colors.sh".source = ./config/sketchybar/colors.sh;
  xdg.configFile."sketchybar/colors.sh".executable = true;
}
