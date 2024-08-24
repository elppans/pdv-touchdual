#!/bin/bash

XOPERADOR='DP-1'
XCLIENTE='HDMI-2'

xrandr --auto --output $XOPERADOR --mode 1024x768 &
xrandr --auto --output $XCLIENTE --mode 800x600  &

chmod +x /Zanthus/Zeus/pdvJava/xinput-set.sh
xterm -e "/Zanthus/Zeus/pdvJava/xinput-set.sh"

sleep 5
/usr/bin/unclutter 1> /dev/null &
chmod +x /usr/local/bin/igraficaJava
chmod +x /usr/local/bin/dualmonitor_control-PDVJava
nohup dualmonitor_control-PDVJava &
nohup igraficaJava &
nohup recreate-user-rabbitmq.sh &
/Zanthus/Zeus/pdvJava/pdvJava2 &

nohup chromium-browser --disable-pinch --disable-gpu --test-type --no-sandbox --incognito --kiosk --no-context-menu --disable-translate file:////Zanthus/Zeus/Interface/index.html
