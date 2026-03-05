#!/bin/bash

MONITOR=($(xrandr | grep " connected" | head -n1 | awk '{print $1}'))
TOUCH_ID=($(xinput list | grep -iv "Mouse" | grep -i "ILITEK ILITEK-TP" | grep -o "id=[0-9]*" | cut -d "=" -f 2))
export MONITOR
export TOUCH_ID
echo "MONITOR=$MONITOR" | tee /tmp/xinput-set
echo "TOUCH_ID=$TOUCH_ID" | tee -a /tmp/xinput-set
echo
echo -e "xinput --map-to-output "${TOUCH_ID}" "${MONITOR}"\n" | tee -a /tmp/xinput-set

xterm -e "for i in `seq 15 -1 1` ; do echo -ne "$i Seg.\r" ; sleep 1 ; done && xinput --map-to-output "${TOUCH_ID}" "${MONITOR}"" &

if ! mountpoint -q /media/root/GERSAT3/; then
    mount /media/root/GERSAT3/
fi

chmod +x /usr/local/bin/igraficaJava
chmod +x /usr/local/bin/dualmonitor_control-PDVJava
/Zanthus/Zeus/pdvJava/pdvJava2 &
nohup dualmonitor_control-PDVJava &
nohup igraficaJava &
nohup recreate-user-rabbitmq.sh &
nohup chromium-browser --disable-gpu --disk-cache-dir=/tmp/chromium-cache --user-data-dir=$(mktemp -d) --test-type --no-sandbox --kiosk --no-context-menu --disable-translate file:////Zanthus/Zeus/Interface/index.html
