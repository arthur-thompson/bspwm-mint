#!/usr/bin/env bash

# Colors
COLOR_BG="#000000"
COLOR_FG="#ffffff"
COLOR_FOCUSED="#ffffff"
COLOR_OCCUPIED="#aaaaaa"
COLOR_FREE="#555555"

# Bitmap Font
FONT="fixed"

# Parse bspc subscribe report for workspace updates
workspaces() {
    bspc subscribe report | while read -r line; do
        ws_out=""
        IFS=':' read -ra PARTS <<< "$line"
        
        for item in "${PARTS[@]}"; do
            type="${item:0:1}"
            name="${item:1}"
            
            case "$type" in
                O|F) # Focused desktop (White with brackets)
                    ws_out+="%{A1:bspc desktop -f \"$name\":}%{F$COLOR_FOCUSED}[$name]%{F-}%{A}"
                    ;;
                o)   # Unfocused occupied (Light gray)
                    ws_out+="%{A1:bspc desktop -f \"$name\":}%{F$COLOR_OCCUPIED} $name %{F-}%{A}"
                    ;;
                f)   # Unfocused free (Dark gray)
                    ws_out+="%{A1:bspc desktop -f \"$name\":}%{F$COLOR_FREE} $name %{F-}%{A}"
                    ;;
            esac
        done
        echo "WS:$ws_out"
    done
}

# Date and time updater
clock() {
    while true; do
        echo "CLK:%{F$COLOR_FG}$(date '+%a %b %d  %I:%M %p')%{F-}"
        sleep 5
    done
}

# Aggregate asynchronous streams into bar layout
main() {
    ws_str=""
    clk_str=""

    while read -r line; do
        case "$line" in
            WS:*)  ws_str="${line#WS:}" ;;
            CLK:*) clk_str="${line#CLK:}" ;;
        esac
        echo "%{l}${ws_str}%{r}${clk_str}  "
    done
}

# Terminate background subshells when main script stops
trap 'kill 0' EXIT

# Execute loops and pipe to lemonbar
(workspaces & clock &) | main | lemonbar -p -g x20 -f "$FONT" -B "$COLOR_BG" -F "$COLOR_FG" | sh
