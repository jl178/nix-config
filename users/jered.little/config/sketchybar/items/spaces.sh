#!/usr/bin/env bash

SPACE_ICONS=("1" "2" "3" "4" "5" "6" "7" "8" "9" "10" "11")

sketchybar --add event aerospace_workspace_change

# Get monitor list
monitors=($(aerospace list-monitors | awk '{print $1}'))

# Set the target monitor
if [[ ${#monitors[@]} -gt 1 ]]; then
    TARGET_MONITOR="${monitors[1]}" # Assume the external monitor is the second one
else
    TARGET_MONITOR="${monitors[0]}" # Default to the laptop screen
fi
# Adjust for 0-based index in Sketchybar
SKETCHYBAR_DISPLAY=$((TARGET_MONITOR - 1))

# Assign workspaces only to the selected monitor
for i in $(aerospace list-workspaces --monitor "$TARGET_MONITOR"); do
    sid=$i
    name_idx=$((i - 1))
    name=${SPACE_ICONS[$name_idx]}

    space=(
        space="$sid"
        display="$TARGET_MONITOR"

        label="$name"
        label.color="$SPACE"

        padding_left=2
        padding_right=2

        script="$PLUGIN_DIR/space.sh"
    )

    sketchybar --add space "space.$sid" left \
        --set "space.$sid" display="$SKETCHYBAR_DISPLAY" \
        --set "space.$sid" label="$name" \
        --set "space.$sid" label.color="$SPACE" \
        --set "space.$sid" padding_left=2 \
        --set "space.$sid" padding_right=2 \
        --set "space.$sid" script="$PLUGIN_DIR/space.sh" \
        --subscribe "space.$sid" aerospace_workspace_change
done

# Hide empty workspaces from the other monitor
for m in "${monitors[@]}"; do
    if [[ "$m" != "$TARGET_MONITOR" ]]; then
        for i in $(aerospace list-workspaces --monitor "$m" --empty); do
            echo "HIDING ${i}"
            sketchybar --set "space.$i" "display=0"
        done
    fi
done

# Space Creator (remains the same)
space_creator=(
    icon=􀆊
    icon.font="$FONT:Heavy:16.0"
    padding_left=0
    padding_right=0
    label.drawing=off
    display=active
    script="$PLUGIN_DIR/space_windows.sh"
    icon.color=$WHITE
)

sketchybar --add item space_creator left \
    --set space_creator "${space_creator[@]}" \
    --subscribe space_creator aerospace_workspace_change
