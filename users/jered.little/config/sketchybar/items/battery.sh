#!/usr/bin/env bash

source "$CONFIG_DIR/colors.sh"

battery=(
    # label
    "label.color=$GREEN"
    background.color="$GREY"
    label.font="$FONT:Bold:14.0" # Make text bold and adjust size
    background.height=30

    # functionality
    update_freq=120
    updates=on
    script="$PLUGIN_DIR/battery.sh"
)
sketchybar --add item battery right \
    --set battery "${battery[@]}" \
    --subscribe battery power_source_change system_woke
