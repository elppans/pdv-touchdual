#!/bin/bash

XOPERADOR='DP-1'
XCLIENTE='HDMI-2'

# for i in `seq 30 -1 1` ; do
#        echo -ne "Aguarde $i Segundos.\r" ; sleep 1 ;
# done

if [ -f /Zanthus/Zeus/pdvJava/sleep-gui ]; then
	chmod +x /Zanthus/Zeus/pdvJava/sleep-gui
	/Zanthus/Zeus/pdvJava/sleep-gui 30
else
	zenity --error --text "Não foi encontrado \"sleep-gui\""
fi

xinput map-to-output 11 $XOPERADOR &
xinput map-to-output 12 $XCLIENTE &

xrandr --output DP-1 --auto
#xrandr --output HDMI-2 --auto
xset -dpms
xset s noblank
xset s off
