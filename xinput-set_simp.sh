#!/bin/bash

MONITOR=($(xrandr | grep " connected" | head -n1 | awk '{print $1}'))
TOUCH_ID=($(xinput list | grep -iv "Mouse" | grep -i "ILITEK ILITEK-TP" | grep -o "id=[0-9]*" | cut -d "=" -f 2))
export MONITOR
export TOUCH_ID
echo "MONITOR=$MONITOR" | tee /tmp/xinput-set
echo "TOUCH_ID=$TOUCH_ID" | tee -a /tmp/xinput-set
echo
echo -e "xinput --map-to-output "${TOUCH_ID}" "${MONITOR}"\n" | tee -a /tmp/xinput-set

for i in `seq 15 -1 1` ; do echo -ne "$i Seg.\r" ; sleep 1 ; done
xinput --map-to-output "${TOUCH_ID}" "${MONITOR}"
