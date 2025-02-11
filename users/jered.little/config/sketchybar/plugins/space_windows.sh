#!/usr/bin/env bash

echo AEROSPACE_PREV_WORKSPACE: $AEROSPACE_PREV_WORKSPACE, \
    AEROSPACE_FOCUSED_WORKSPACE: $AEROSPACE_FOCUSED_WORKSPACE \
    SELECTED: $SELECTED \
    BG2: $BG2 \
    INFO: $INFO \
    SENDER: $SENDER \
    NAME: $NAME \
    >>~/aaaa
source "$CONFIG_DIR/colors.sh"

if [ "$SENDER" = "aerospace_workspace_change" ]; then
    # current workspace space border color
    monitors=($(aerospace list-monitors | awk '{print $1}'))

    # Set the target monitor
    if [[ ${#monitors[@]} -gt 1 ]]; then
        TARGET_MONITOR="${monitors[1]}" # Assume the external monitor is the second one
    else
        TARGET_MONITOR="${monitors[0]}" # Default to the laptop screen
    fi
    # Assign workspaces only to the selected monitor

    workspace_updates=()
    for i in $(aerospace list-workspaces --monitor "$TARGET_MONITOR"); do
        workspace_updates+=(--set "space.$i" "label.color=$SPACE" "background.color=$SPACE_BACKGROUND")
    done

    # Update all workspaces in a single call
    sketchybar "${workspace_updates[@]}" --set "space.$AEROSPACE_FOCUSED_WORKSPACE" "label.color=$SPACE_SELECTED" "background.color=$SPACE_SELECTED_BACKGROUND"

    # for i in $AEROSPACE_FOCUSED_MONITOR; do
    #     sketchybar --set "space.$i" "display=$AEROSPACE_FOCUSED_MONITOR"
    # done

    # for i in $AEROSPACE_EMPTY_WORKESPACE; do
    #     sketchybar --set "space.$i" "display=0"
    # done

    # sketchybar --set space.$AEROSPACE_FOCUSED_WORKSPACE display=$AEROSPACE_FOCUSED_MONITOR
fi
