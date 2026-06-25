#!/bin/bash

#xrandr --output VGA-1 --mode 1024x768 --pos 0x0 --output HDMI-1 --mode 1920x1080i --pos 1024x0 &
xrandr --output HDMI-1 --mode 1024x768 --pos 0x0 --output VGA-1 --mode 1024x768 --pos 1024x0 &

export POSICAO_OPERADOR="0,0"
export POSICAO_CLIENTE="1024,0"

sleeping() {
  local time
  time="$1"
  for i in $(seq "$time" -1 1); do
    echo -ne "$i Seg.\r"
    sleep 1
  done
}
# Função para verificar e posicionar a janela Interface PDV (OPERADOR)
interface_operador() {
  setsid nohup chromium-browser --new-window --disable-gpu --disable-pinch --test-type --no-sandbox --kiosk --no-context-menu --disable-translate file:////Zanthus/Zeus/Interface/index.html &
  clear
  while true; do
    WMID=$(wmctrl -l | grep "Interface PDV" | cut -d " " -f1)
    if [ -z "$WMID" ]; then
      echo "Aguardando 'Interface Operador' iniciar..."
      sleep 5
      clear
    else
      # Garantir que o Java seja configurado na posição parametrizada.
      echo -e "
      wmctrl -i -r $WMID -e "0,$POSICAO_OPERADOR,-1,-1"
      " >>/tmp/xmonitor_operador.txt
      wmctrl -i -r $WMID -e "0,$POSICAO_OPERADOR,-1,-1"
      echo "Janela 'Interface Operador' encontrada e configurada."
      break
    fi
  done
}
# Função para verificar e posicionar a janela Interface PDV (CLIENTE)
interface_cliente() {
  setsid nohup chromium-browser --new-window --disable-gpu --disable-pinch --test-type --no-sandbox --kiosk --no-context-menu --disable-translate file:////Zanthus/Zeus/Interface/cliente.html &
  clear
  while true; do
    WMID=$(wmctrl -l | grep "Cliente" | cut -d " " -f1)
    if [ -z "$WMID" ]; then
      echo "Aguardando 'Interface Cliente' iniciar..."
      sleep 5
      clear
    else
      # Garantir que o Java seja configurado na posição parametrizada.
      echo -e "
      wmctrl -i -r $WMID -e "0,$POSICAO_CLIENTE,-1,-1"
      " >>/tmp/xmonitor_cliente.txt
      wmctrl -i -r $WMID -e "0,$POSICAO_CLIENTE,-1,-1"
      echo "Janela 'Interface Cliente' encontrada e configurada."
      break
    fi
  done
}

sleep 2
/usr/bin/setxkbmap -layout br -variant abnt2 > /tmp/setxkbmap.log 2>&1
/usr/bin/unclutter 1> /dev/null &

if ! mountpoint -q /media/root/GERSAT3/; then
    mount /media/root/GERSAT3/ 2>/dev/null
fi

echo "Preparando execuão do PDV..."
chmod -x /usr/local/bin/igraficaJava
chmod +x /usr/local/bin/dualmonitor_control-PDVJava
/Zanthus/Zeus/pdvJava/pdvJava2 &>/tmp/pdvJava2.log &
nohup dualmonitor_control-PDVJava &>/tmp/dualmonitor_control-PDVJava.log &
nohup igraficaJava &>/tmp/igraficaJava.log &
nohup recreate-user-rabbitmq.sh &>/tmp/recreate-user-rabbitmq.sh.log &
sleep 5
#clear
sleeping 30
interface_operador
sleeping 5
clear
interface_cliente
sleeping 5
clear
# read -p "-_-"
