#!/usr/bin/env bash

source "$CONFIG_DIR/colors.sh"

calendar=(
    # label
    label.color="$CALENDAR"
    label.shadow.drawing=off
    label.font="$FONT:Bold:14.0" # Make text bold and adjust size
    background.color="$GREY"
    background.height=30

    # functionality
    update_freq=30
    script="$PLUGIN_DIR/calendar.sh"
    click_script="$PLUGIN_DIR/zen.sh"
)

sketchybar --add item calendar right \
    --set calendar "${calendar[@]}" \
    --subscribe calendar system_woke
