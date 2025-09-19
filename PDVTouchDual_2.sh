#!/bin/bash

# 127.0.0.1:8080/display2
# Saída:
# Tela principal = Cliente
# Toque na tela  = Operador

# ==============================
# Configurações iniciais
# ==============================

# Monitor do OPERADOR

XOPERADOR='HDMI-1'		        			# Porta de vídeo com Touch 
RESOLUCAO_OPERADOR="1366x768"					# Resolução suportada pelo monitor
RATE_OPERADOR="60"		        			# Frame Rate suportada pelo monitor
LARGURA_OPERADOR=$(echo "$RESOLUCAO_OPERADOR" | cut -d'x' -f1)	# Ex.: 1920
ALTURA_OPERADOR=$(echo "$RESOLUCAO_OPERADOR" | cut -d'x' -f2)	# Ex.: 1080
POSICAO_OPERADOR="${LARGURA_OPERADOR}x0"
POSICAOX1="$(echo $POSICAO_OPERADOR | sed 's/x/,/')"

# Monitor do CLIENTE
XCLIENTE='VGA-1'					        # Porta de vídeo do Cliente
RESOLUCAO_CLIENTE="800x600"					# Resolução suportada pelo monitor
RATE_CLIENTE="60"		        			# Frame Rate suportada pelo monitor
LARGURA_CLIENTE=$(echo "$RESOLUCAO_CLIENTE" | cut -d'x' -f1)	# Ex.: 800
ALTURA_CLIENTE=$(echo "$RESOLUCAO_CLIENTE" | cut -d'x' -f2)	# Ex.: 600
POSICAO_CLIENTE="${LARGURA_CLIENTE}x0"
POSICAOX2="$(echo $POSICAO_CLIENTE | sed 's/x/,/')"

# Indicar em qual monitor a aplicação deve permanecer após iniciar (Monitor 1 = POSICAOX1 / Monitor 2 = POSICAOX2)
MONITOR_JAVA="$POSICAOX1"
MONITOR_INTERFACE="$POSICAOX2"

# Número de IDENTIFICAÇÃO do Touch do PDV. 
# Para verificar qual o número, use o comando "xinput --list" (Apenas em GUI)
XINPUT_IDTOUCH="11"

export XOPERADOR
export RESOLUCAO_OPERADOR
export RATE_OPERADOR
export LARGURA_OPERADOR
export ALTURA_OPERADOR
export POSICAO_OPERADOR
export POSICAOX1
export XCLIENTE
export RESOLUCAO_CLIENTE
export RATE_CLIENTE
export LARGURA_CLIENTE
export ALTURA_CLIENTE
export POSICAO_CLIENTE
export POSICAOX2
export MONITOR_JAVA
export MONITOR_INTERFACE
export XINPUT_IDTOUCH

rm -rf /tmp/xmonitor.txt &>>/dev/null

echo -e "
XOPERADOR          = $XOPERADOR
RESOLUCAO_OPERADOR = $RESOLUCAO_OPERADOR
RATE_OPERADOR      = $RATE_OPERADOR
LARGURA_OPERADOR   = $LARGURA_OPERADOR
ALTURA_OPERADOR    = $ALTURA_OPERADOR
POSICAO_OPERADOR   = $POSICAO_OPERADOR
POSICAOX1          = $POSICAOX1
XCLIENTE           = $XCLIENTE
RESOLUCAO_CLIENTE  = $RESOLUCAO_CLIENTE
RATE_CLIENTE       = $RATE_CLIENTE
LARGURA_CLIENTE    = $LARGURA_CLIENTE
ALTURA_CLIENTE     = $ALTURA_CLIENTE
POSICAO_CLIENTE    = $POSICAO_CLIENTE
POSICAOX2          = $POSICAOX2
MONITOR_JAVA       = $MONITOR_JAVA
MONITOR_INTERFACE  = $MONITOR_INTERFACE
XINPUT_IDTOUCH     = $XINPUT_IDTOUCH
" >>/tmp/xmonitor.txt

# ==============================
# Funções
# ==============================

configurar_monitores() {
echo -e "
	xrandr --auto --output "$XOPERADOR" --mode "$RESOLUCAO_OPERADOR" --pos 0x0 --rate "$RATE_OPERADOR" \
--auto --output "$XCLIENTE" --mode "$RESOLUCAO_CLIENTE"  --pos "$POSICAO_OPERADOR" --rate "$RATE_CLIENTE"
" >>/tmp/xmonitor.txt

	xrandr --auto --output "$XOPERADOR" --mode "$RESOLUCAO_OPERADOR" --pos 0x0 --rate "$RATE_OPERADOR" \
--auto --output "$XCLIENTE" --mode "$RESOLUCAO_CLIENTE"  --pos "$POSICAO_OPERADOR" --rate "$RATE_CLIENTE"
}

adicionar_resolucao() {
    local PORTA_VIDEO="$1"   # Ex.: HDMI-1, DP-1, eDP-1
    local RES_X="$2"         # Largura, ex.: 1024
    local RES_Y="$3"         # Altura, ex.: 768
    local TAXA="$4"          # Taxa de atualização, ex.: 60

    # Gera o modeline
    local MODELINE
    MODELINE=$(cvt "$RES_X" "$RES_Y" "$TAXA" | grep Modeline | cut -d' ' -f2-)

    # Extrai o nome do modo (primeira palavra do modeline, sem aspas)
    local NOME_MODO
    NOME_MODO=$(echo "$MODELINE" | awk '{print $1}' | tr -d '"')

    # Cria e aplica a resolução
echo -e "
    xrandr --newmode $MODELINE
    xrandr --addmode "$PORTA_VIDEO" "$NOME_MODO"
    xrandr --output "$PORTA_VIDEO" --mode "$NOME_MODO"
" >>/tmp/xmonitor.txt
    xrandr --newmode $MODELINE
    xrandr --addmode "$PORTA_VIDEO" "$NOME_MODO"
    xrandr --output "$PORTA_VIDEO" --mode "$NOME_MODO"
}

# Função para definir um Loop/Tempo
sleeping() {
  local time
  time="$1"
  for i in $(seq "$time" -1 1); do
    echo -ne "$i Seg.\r"
    sleep 1
  done
}

sleeping_gui() {
  local tempo_total="$1" # Tempo total em segundos
  local num_segmentos=1  # Número de segmentos (reduzido para 5 para atingir o limite mínimo de 2 segundos) > (Fixo 1 para sem limite)

  local msg_title="Status do progresso"
  local msg_aguarde="Aguarde"
  local msg_seg="seg."
  local msg_fim="Fim da espera"

  # Cálculo dos intervalos de tempo para cada segmento
  # Troca do cálculo dos intervalos para segmento fixo,
  # Funciona melhor com seq + "tempo_total" em vez de "num_segmentos"
  # local intervalo=$(expr "$tempo_total" / "$num_segmentos")
  local intervalo="$num_segmentos"

  # Loop para exibir as mensagens de progresso
  (
    # for i in $(seq "$num_segmentos" -1 1); do
    for i in $(seq "$tempo_total" -1 1); do
      echo "# $msg_aguarde $(expr "$i" \* $intervalo) $msg_seg"
      sleeping "$intervalo"
    done
  ) |
    zenity --progress \
      --title="${msg_title}" \
      --text="${msg_fim}" \
      --percentage=0 \
      --pulsate \
      --auto-close \
      --auto-kill
}

mapear_touchscreens() {
    sleeping_gui 30
    echo -e "
    xinput map-to-output "$XINPUT_IDTOUCH" "$XOPERADOR"
    " >>/tmp/xmonitor.txt
    xinput map-to-output "$XINPUT_IDTOUCH" "$XOPERADOR"
    # xinput map-to-output 12 "$XCLIENTE" &
    ajustar_energia_tela
}

ajustar_energia_tela() {
echo -e "
    xrandr --output "$XOPERADOR" --auto
    xset -dpms
    xset s noblank
    xset s off
" >>/tmp/xmonitor.txt
    xrandr --output "$XOPERADOR" --auto
    # xrandr --output "$XCLIENTE" --auto
    xset -dpms
    xset s noblank
    xset s off
}

centralizar_monitor() {
    local SAIDA="$1"
    local RES_DESEJADA="$2"

    # Resolução física atual do monitor
    local RES_FISICA=$(xrandr | grep -A1 "^$SAIDA " | tail -n1 | awk '{print $1}')
    local LARG_FISICA=$(echo "$RES_FISICA" | cut -d'x' -f1)
    local ALT_FISICA=$(echo "$RES_FISICA" | cut -d'x' -f2)

    # Resolução desejada
    local LARG_DESEJADA=$(echo "$RES_DESEJADA" | cut -d'x' -f1)
    local ALT_DESEJADA=$(echo "$RES_DESEJADA" | cut -d'x' -f2)

    # Cálculo do deslocamento para centralizar
    local OFFSET_X=$(( (LARG_FISICA - LARG_DESEJADA) / 2 ))
    local OFFSET_Y=$(( (ALT_FISICA - ALT_DESEJADA) / 2 ))

    # Aplica resolução e centraliza
    echo -e "
    xrandr --output "$SAIDA" --mode "$RES_DESEJADA" \
           --panning "${LARG_DESEJADA}x${ALT_DESEJADA}+${OFFSET_X}+${OFFSET_Y}" \
           --transform 1,0,0,0,1,0,0,0,1
" >>/tmp/xmonitor.txt
    xrandr --output "$SAIDA" --mode "$RES_DESEJADA" \
           --panning "${LARG_DESEJADA}x${ALT_DESEJADA}+${OFFSET_X}+${OFFSET_Y}" \
           --transform 1,0,0,0,1,0,0,0,1
}

# Função para verificar e posicionar a janela Java
pdvjava_param() {
  while true; do
    WMID=$(wmctrl -l | grep "Zanthus Retail" | cut -d " " -f1)
    if [ -z "$WMID" ]; then
      echo "Aguardando 'Zanthus Retail' iniciar..."
      sleeping 5
      clear
    else
      # Garantir que o Java seja configurado na posição parametrizada.
      # wmctrl -i -r $WMID -e "0,$posicaox1,-1,-1"
      # POSICAOX1 = Monitor 1, POSICAOX2 = Monitor 2
      echo -e "
      wmctrl -i -r $WMID -e "0,$MONITOR_JAVA,-1,-1"
      " >>/tmp/xmonitor.txt
      wmctrl -i -r $WMID -e "0,$MONITOR_JAVA,-1,-1"
      echo "Janela 'Zanthus Retail' encontrada e configurada."
      break
    fi
  done
}

# Função para verificar e posicionar a janela Interface PDV
interface_param() {
  while true; do
    WMID=$(wmctrl -l | grep "Interface PDV" | cut -d " " -f1)
    if [ -z "$WMID" ]; then
      echo "Aguardando 'Interface PDV' iniciar..."
      sleeping 5
      clear
    else
      # Garantir que o Java seja configurado na posição parametrizada.
      echo -e "
      wmctrl -i -r $WMID -e "0,$MONITOR_INTERFACE,-1,-1"
      " >>/tmp/xmonitor.txt
      wmctrl -i -r $WMID -e "0,$MONITOR_INTERFACE,-1,-1"
      echo "Janela 'Interface PDV' encontrada e configurada."
      break
    fi
  done
}

ocultar_cursor() {
    /usr/bin/unclutter 1> /dev/null &
}

ajustar_permissoes() {
    chmod +x /usr/local/bin/igraficaJava
    chmod +x /usr/local/bin/dualmonitor_control-PDVJava
}

iniciar_servicos() {
    nohup dualmonitor_control-PDVJava &
    nohup igraficaJava &
    nohup recreate-user-rabbitmq.sh &
    /Zanthus/Zeus/pdvJava/pdvJava2 &
    pdvjava_param
}

abrir_chromium_kiosk() {
    setsid nohup chromium-browser \
        --disable-pinch \
        --disable-gpu \
        --test-type \
        --no-sandbox \
        --incognito \
        --kiosk \
        --no-context-menu \
        --disable-translate \
        file:////Zanthus/Zeus/Interface/index.html &
        interface_param
}

# Função para executar o Interface
iniciar_interface() {
# Configuração de Profile e Storage
local temp_profile
local local_storage
local interface

temp_profile="$HOME/.interface/chromium"
local_storage="$temp_profile/Default/Local Storage"
interface="/Zanthus/Zeus/Interface"

mkdir -p "$local_storage"
chown -R zanthus:zanthus "$interface"
echo "Iniciando interface..."
sleeping 10

# Limpar informações de profile, mas manter configuração do interface
find "$temp_profile" -mindepth 1 -not -path "$local_storage/*" -delete &>>/dev/null

# Executar Chromium com uma nova instância
setsid nohup chromium-browser --no-sandbox \
--test-type \
--no-default-browser-check \
--no-context-menu \
--disable-gpu \
--disable-session-crashed-bubble \
--disable-infobars \
--disable-background-networking \
--disable-component-extensions-with-background-pages \
--disable-features=SessionRestore \
--disable-restore-session-state \
--disable-features=DesktopPWAsAdditionalWindowingControls \
--disable-features=TabRestore \
--disable-translate \
--disk-cache-dir=/tmp/chromium-cache \
--user-data-dir="$temp_profile" \
--restore-last-session=false \
--autoplay-policy=no-user-gesture-required \
--enable-speech-synthesis \
--kiosk \
file:///"$interface"/index.html &>>/dev/null 
}

# ==============================
# Execução principal
# ==============================

main() {
    # adicionar_resolucao "$XOPERADOR" 1024 768 60           # Exemplo: criar resolução 1024x768 a 60Hz na saída DP-1 (adicionar_resolucao "HDMI-2" 1024 768 60)
    # adicionar_resolucao "$XCLIENTE" 1024 768 60            # Exemplo: criar resolução 1024x768 a 60Hz na saída DP-1 (adicionar_resolucao "DP-1" 1024 768 60)
    configurar_monitores
    # sleeping_gui        				     # Mesclado em mapear_touchscreens
    mapear_touchscreens &
    # ajustar_energia_tela      			     # Mesclado em mapear_touchscreens
    # centralizar_monitor "$XOPERADOR" "$RESOLUCAO_OPERADOR" # Centralizar o monitor do OPERADOR (Chrome)
    # centralizar_monitor "$XCLIENTE" "$RESOLUCAO_CLIENTE"   # Centralizar o monitor do CLIENTE (Java)
    sleeping 5
    ocultar_cursor
    ajustar_permissoes
    iniciar_servicos
	iniciar_interface
    # abrir_chromium_kiosk

}

main
