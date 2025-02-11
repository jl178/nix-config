#!/usr/bin/env bash

source "$CONFIG_DIR/colors.sh"

volume=(
    # label
    "label.color=$RED"
    background.color="$GREY"

    background.height=30
    label.font="$FONT:Bold:14.0" # Make text bold and adjust size
    # functionality
    update_freq=120
    script="$PLUGIN_DIR/volume.sh"
)

sketchybar --add item volume right \
    --set volume "${volume[@]}" \
    --subscribe volume volume_change
