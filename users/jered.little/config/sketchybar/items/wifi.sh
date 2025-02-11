#!/usr/bin/env bash

source "$CONFIG_DIR/colors.sh"

wifi=(
    # label
    "label.color=$YELLOW"

    label.font="$FONT:Bold:14.0" # Make text bold and adjust size

    background.height=30
    background.color="$GREY"

    # functionality
    update_freq=120
    script="$PLUGIN_DIR/wifi.sh"
)

sketchybar --add item wifi right \
    --set wifi "${wifi[@]}" \
    --subscribe wifi
