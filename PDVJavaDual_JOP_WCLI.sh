#!/bin/bash
# Desabilitar em ECF9F.CFG a opção "TOUCH_OBRIGATORIO"

#xrandr --output VGA-1 --mode 1024x768 --pos 0x0 --output HDMI-1 --mode 1920x1080i --pos 1024x0 &
xrandr --output HDMI-1 --mode 1024x768 --pos 0x0 --output VGA-1 --mode 1024x768 --pos 1024x0 &
sleep 5

/usr/bin/setxkbmap -layout br -variant abnt2 > /tmp/setxkbmap.log 2>&1
/usr/bin/unclutter 1> /dev/null &

if ! mountpoint -q /media/root/GERSAT3/; then
    mount /media/root/GERSAT3/
fi

chmod +x /usr/local/bin/igraficaJava
chmod +x /usr/local/bin/dualmonitor_control-PDVJava
/Zanthus/Zeus/pdvJava/pdvJava2 &
nohup dualmonitor_control-PDVJava &
nohup igraficaJava &
nohup recreate-user-rabbitmq.sh &
sleep 30
nohup chromium-browser --disable-gpu \
--disable-pinch \
--test-type \
--no-sandbox \
--kiosk \
--no-context-menu \
--disable-translate 
file:////Zanthus/Zeus/Interface/cliente.html --window-position=1024x0
