#!/bin/bash

TEMPO='45'
MONITOR=($(xrandr | grep " connected" | head -n1 | awk '{print $1}'))
TOUCH_ID=($(xinput list | grep -iv "Mouse" | grep -i "ILITEK ILITEK-TP" | grep -o "id=[0-9]*" | cut -d "=" -f 2))
export MONITOR
export TOUCH_ID
echo "MONITOR=$MONITOR" | tee /tmp/xinput-set
echo "TOUCH_ID=$TOUCH_ID" | tee -a /tmp/xinput-set
echo
echo -e "xinput --map-to-output "${TOUCH_ID}" "${MONITOR}"\n" | tee -a /tmp/xinput-set

if [ -f /Zanthus/Zeus/pdvJava/sleep-gui ]; then
	chmod +x /Zanthus/Zeus/pdvJava/sleep-gui
	/Zanthus/Zeus/pdvJava/sleep-gui "$TEMPO"
else
	for i in `seq "$TEMPO" -1 1` ; do echo -ne "$i Seg.\r" ; sleep 1 ; done
fi

xinput --map-to-output "${TOUCH_ID}" "${MONITOR}"
