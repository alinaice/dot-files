#!/usr/bin/env sh

# Unfortunately it's not easy to directly use Polybar colour values in this
# script so I have to redefine some of my colours here. See the link below for
# more details:
# https://github.com/polybar/polybar/wiki/Formatting#format-tags-inside-polybar-config
blue=#00b3ff

configs_path="/etc/wireguard"
connected_interface=$(networkctl | grep -P "\d+ .* wireguard routable" -o | cut -d " " -f 2)

connect() {
    selected_config=$(ls $configs_path/*.conf | xargs basename -a -s .conf | rofi -show drun -theme /home/alina/.config/rofi/launchers/type-1/style-10.rasi -dmenu)
    [[ $selected_config ]] && sudo wg-quick up "$configs_path"/"$selected_config".conf
}

disconnect() {
    # Normally we should have a single connected interface but technically
    # there's nothing stopping us from having multiple active intgerfaces so
    # let's do this in a loop:
    for connected_config in $(networkctl | grep -P "\d+ .* wireguard routable" -o | cut -d " " -f 2)
    do
        sudo wg-quick down $connected_config
    done
}

toggle() {
    if [[ $connected_interface ]]
    then
        disconnect
    else
        connect
    fi
}

print() {
    if [[ $connected_interface ]]
    then
        echo %{u"$blue"}%{+u}%{T4}%{F"$blue"}%{T-}%{F-} "$connected_interface"
    else
        echo -e %{T4}";~;"%{T-}
    fi
}

case "$1" in
    --connect)
        connect
        ;;
    --disconnect)
        disconnect
        ;;
    --toggle)
        toggle
        ;;
    *)
        print
        ;;
esac
