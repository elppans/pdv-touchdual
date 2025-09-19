#!/bin/bash

# 127.0.0.1:8080/display2
# Saída:
# Tela principal = Operador ()
# Toque na tela = Cliente

# ==============================
# Configurações iniciais
# ==============================

# Monitor do OPERADOR

XOPERADOR='HDMI-2'		        # Porta de vídeo com Touch 
RESOLUCAO_OPERADOR="1366x768"	# Resolução suportada pelo monitor
RATE_OPERADOR="60"		        # Frame Rate suportada pelo monitor
LARGURA_OPERADOR=$(echo "$RESOLUCAO_OPERADOR" | cut -d'x' -f1)	# Ex.: 1920
ALTURA_OPERADOR=$(echo "$RESOLUCAO_OPERADOR" | cut -d'x' -f2)	# Ex.: 1080
POSICAO_OPERADOR="${LARGURA_OPERADOR}x0"
POSICAOX1="$(echo $POSICAO_OPERADOR | sed 's/x/,/')"

# Monitor do CLIENTE
XCLIENTE='DP-1'			        # Porta de vídeo do Cliente
RESOLUCAO_CLIENTE="1024x768"	# Resolução suportada pelo monitor
RATE_CLIENTE="60"		        # Frame Rate suportada pelo monitor
LARGURA_CLIENTE=$(echo "$RESOLUCAO_CLIENTE" | cut -d'x' -f1)	# Ex.: 800
ALTURA_CLIENTE=$(echo "$RESOLUCAO_CLIENTE" | cut -d'x' -f2)	# Ex.: 600
POSICAO_CLIENTE="${LARGURA_CLIENTE}x0"
POSICAOX2="$(echo $POSICAO_CLIENTE | sed 's/x/,/')"

# ==============================
# Funções
# ==============================

configurar_monitores() {
    xrandr --auto --output "$XOPERADOR" --mode "$RESOLUCAO_OPERADOR" --pos 0x0--rate "$RATE_OPERADOR"
    xrandr --auto --output "$XCLIENTE" --mode "$RESOLUCAO_CLIENTE"  --pos "$POSICAO_OPERADOR" --rate "$RATE_CLIENTE"
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
    xrandr --newmode $MODELINE
    xrandr --addmode "$PORTA_VIDEO" "$NOME_MODO"
    xrandr --output "$PORTA_VIDEO" --mode "$NOME_MODO"
}

aguardar_sleep_gui() {
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
      sleep "$intervalo"
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
    aguardar_sleep_gui 30
    xinput map-to-output 11 "$XOPERADOR" &
    # xinput map-to-output 12 "$XCLIENTE" &
    ajustar_energia_tela
}

ajustar_energia_tela() {
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
      wmctrl -i -r $WMID -e "0,"$POSICAOX2",-1,-1"
      echo "Janela 'Zanthus Retail' encontrada e configurada."
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
}

abrir_chromium_kiosk() {
    nohup chromium-browser \
        --disable-pinch \
        --disable-gpu \
        --test-type \
        --no-sandbox \
        --incognito \
        --kiosk \
        --no-context-menu \
        --disable-translate \
        file:////Zanthus/Zeus/Interface/index.html &
}

# ==============================
# Execução principal
# ==============================

main() {
    # adicionar_resolucao "$XOPERADOR" 1024 768 60    # Exemplo: criar resolução 1024x768 a 60Hz na saída DP-1 (adicionar_resolucao "HDMI-2" 1024 768 60)
    # adicionar_resolucao "$XCLIENTE" 1024 768 60     # Exemplo: criar resolução 1024x768 a 60Hz na saída DP-1 (adicionar_resolucao "DP-1" 1024 768 60)
    configurar_monitores
    # aguardar_sleep_gui        # Mesclado em mapear_touchscreens
    mapear_touchscreens
    # ajustar_energia_tela      # Mesclado em mapear_touchscreens
    # centralizar_monitor "$XOPERADOR" "$RESOLUCAO_OPERADOR" # Centralizar o monitor do OPERADOR (Chrome)
    centralizar_monitor "$XCLIENTE" "$RESOLUCAO_CLIENTE"     # Centralizar o monitor do CLIENTE (Java)
    sleep 5
    ocultar_cursor
    ajustar_permissoes
    iniciar_servicos
    abrir_chromium_kiosk
}

main
