#!/usr/bin/env bash

source "$CONFIG_DIR/colors.sh"

weather=(
    label.color="$RED"
    background.color="$GREY"

    background.height=30
    label.font="$FONT:Bold:14.0" # Make text bold and adjust size

    update_freq=60
    script="$PLUGIN_DIR/weather.sh"

)

sketchybar --add item weather left \
    --set weather "${weather[@]}" \
    --subscribe calendar system_woke
