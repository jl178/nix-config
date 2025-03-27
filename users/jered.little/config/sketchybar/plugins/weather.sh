#!/bin/bash

WEATHER=$(curl -s wttr.in/?format=1)

sketchybar --set "$NAME" label="$WEATHER"
