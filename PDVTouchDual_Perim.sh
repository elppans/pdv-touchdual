#!/bin/bash

# eDP-1 = Operador em modo 1920x1080
# DP-1 = Cliente em modo 800x600, posecionado após a largura, 1920
xrandr --auto --output eDP-1 --mode 1920x1080 --pos 0x0 --rate 60 --auto --output DP-1 --mode 800x600  --pos 1920x0 --rate 60

# Mapear o Touch via ID para a entrada específica
xinput map-to-output 10 eDP-1

# Outras opções xset (Opcional, descomentar se quiser usar):
#
# -dpms: Desativa o gerenciamento de energia (Display Power Management System). 
# s: Especifica que queremos configurar as opções do protetor de tela.
# noblank: Impede que a tela fique em branco.
# off: Desativa completamente o protetor de tela.

# xset -dpms
# xset s noblank
# xset s off

# Configura o layout do teclado para brasileiro ABNT2 usando o utilitário setxkbmap
/usr/bin/setxkbmap -layout br -variant abnt2 > /tmp/setxkbmap.log 2>&1

if ! mountpoint -q /media/root/GERSAT3/; then
    mount /media/root/GERSAT3/
fi

chmod +x /usr/local/bin/igraficaJava
chmod +x /usr/local/bin/dualmonitor_control-PDVJava
/Zanthus/Zeus/pdvJava/pdvJava2 &
nohup dualmonitor_control-PDVJava &
nohup igraficaJava &
nohup recreate-user-rabbitmq.sh &

# Inicia o Chromium em modo quiosque, ajustando escala e desativando recursos
nohup chromium-browser --force-device-scale-factor=1.3 --disable-gpu --test-type --no-sandbox --kiosk --no-context-menu --disable-translate file:////Zanthus/Zeus/Interface/index.html

