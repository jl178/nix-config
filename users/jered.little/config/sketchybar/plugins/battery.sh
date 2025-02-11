#!/usr/bin/env bash

source "$CONFIG_DIR/colors.sh"

PERCENTAGE="$(pmset -g batt | grep -o "[0-9]\+%" | cut -d% -f1)"
CHARGING="$(pmset -g batt | grep 'AC Power')"

if [ "$PERCENTAGE" = "" ]; then
    exit 0
fi

case ${PERCENTAGE} in
[3-9][0-9] | 100)
    COLOR=$GREEN
    OUTPUT=" ${PERCENTAGE}%"
    ;;
[1-2][0-9])
    COLOR=$YELLOW
    OUTPUT=" ${PERCENTAGE}%"
    ;;
[0-9])
    COLOR=$RED
    OUTPUT=" ${PERCENTAGE}%"
    ;;
esac

if [[ "$CHARGING" != "" ]]; then
    OUTPUT=" ${PERCENTAGE}%"
fi

sketchybar --set "$NAME" label="$OUTPUT" "label.color=$COLOR"
