#!/bin/bash

# 127.0.0.1:8080/display2
# Saída:
# Tela principal = Operador ()
# Toque na tela = Cliente

# ==============================
# Configurações iniciais
# ==============================

# Monitor do OPERADOR

XOPERADOR='HDMI-2'		# Porta de vídeo com Touch 
RESOLUCAO_OPERADOR="1366x768"	# Resolução suportada pelo monitor
RATE_OPERADOR="60"		# Frame Rate suportada pelo monitor

# Monitor do CLIENTE
XCLIENTE='DP-1'			# Porta de vídeo do Cliente
RESOLUCAO_CLIENTE="1024x768"	# Resolução suportada pelo monitor
RATE_CLIENTE="60"		# Frame Rate suportada pelo monitor

# ==============================
# Funções
# ==============================

configurar_monitores() {
    xrandr --auto --output "$XOPERADOR" --mode $RESOLUCAO_OPERADOR --rate $RATE_OPERADOR
    xrandr --auto --output "$XCLIENTE" --mode $RESOLUCAO_CLIENTE  --rate $RATE_CLIENTE
}

aguardar_sleep_gui() {
    if [ -f /Zanthus/Zeus/pdvJava/sleep-gui ]; then
        chmod +x /Zanthus/Zeus/pdvJava/sleep-gui
        /Zanthus/Zeus/pdvJava/sleep-gui 30
    else
        zenity --error --text "Não foi encontrado \"sleep-gui\""
    fi
}

mapear_touchscreens() {
    aguardar_sleep_gui
    xinput map-to-output 11 "$XOPERADOR" &
    xinput map-to-output 12 "$XCLIENTE" &
    ajustar_energia_tela
}

ajustar_energia_tela() {
    xrandr --output "$XOPERADOR" --auto
    #xrandr --output "$XCLIENTE" --auto
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
    configurar_monitores
    # aguardar_sleep_gui # Mesclado em mapear_touchscreens
    mapear_touchscreens
    # ajustar_energia_tela #Mesclado em mapear_touchscreens
    # centralizar_monitor "$XOPERADOR" "$RESOLUCAO_OPERADOR" # Centralizar o monitor do OPERADOR (Chrome)
    centralizar_monitor "$XCLIENTE" "$RESOLUCAO_CLIENTE" # Centralizar o monitor do CLIENTE (Java)
    sleep 5
    ocultar_cursor
    ajustar_permissoes
    iniciar_servicos
    abrir_chromium_kiosk
}

main
