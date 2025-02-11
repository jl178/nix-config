#!/usr/bin/env bash

source "$CONFIG_DIR/colors.sh"

front_app=(
    icon.background.drawing=on
    icon.drawing=on
    label.font="$FONT:Bold:14.0" # Make text bold and adjust size
    background.color="$GREY"
    background.height=30
    label.color="$LAVENDER"
    display=active
    script="$PLUGIN_DIR/front_app.sh"
    click_script="open -a 'Mission Control'"
)
sketchybar --add item front_app center \
    --set front_app "${front_app[@]}" \
    --subscribe front_app front_app_switched
