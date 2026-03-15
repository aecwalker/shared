#!/bin/bash

[[ ! -f "$HOME/.config/autostart/macchanger.desktop" ]] && \
    mkdir -p "$HOME/.config/autostart" && \
    cat > "$HOME/.config/autostart/macchanger.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=MAC Changer
Exec=qterminal -e $HOME/macchanger.sh
EOF

if ! command -v macchanger &>/dev/null; then
    echo "error: macchanger is not installed"
    exit 1
fi

wlan=$(ip -o link show | awk -F': ' '{print $2}' | grep '^wl' | head -1)
eth=$(ip -o link show | awk -F': ' '{print $2}' | grep -E '^(en|eth)' | head -1)

ip a s

if [[ -n "$wlan" ]]; then
    echo "wireless: $wlan -- change MAC? 1=yes  2=no  3=quit"
    read -rp "> " w
    if [[ "$w" == 1 ]]; then
        sudo ip link set dev "$wlan" down
        sudo macchanger -r "$wlan"
        sudo ip link set dev "$wlan" up
        sleep 3
    elif [[ "$w" == 3 ]]; then
        kill -9 $PPID
    fi
fi

if [[ -n "$eth" ]]; then
    echo "wired: $eth -- change MAC? 1=yes  2=quit"
    read -rp "> " e
    if [[ "$e" == 1 ]]; then
        sudo ip link set dev "$eth" down
        sudo macchanger -r "$eth"
        sudo ip link set dev "$eth" up
        sleep 3
    fi
    [[ "$e" == 2 ]] && kill -9 $PPID
fi
