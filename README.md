# pdv-touchdual

---

# Configuração do PDVTouchDual

Certifique-se de ter as seguintes dependências instaladas:

1. **Instale as dependências:**
   Verifique se você tem os pacotes **git** e **zenity** instalados. Caso contrário, execute os seguintes comandos:

   ```bash
   # Instale o git:
   sudo apt install git

   # Instale o zenity:
   sudo apt install zenity
   ```

2. **Instale o sleep-gui:**
   Para instalar o **sleep-gui**, siga estas etapas:

   ```bash
   cd /tmp
   git clone https://github.com/elppans/sleep-gui.git
   cp -a /tmp/sleep-gui/sleep-gui /Zanthus/Zeus/pdvJava
   rm -rf /tmp/sleep-gui
   ```
---

## Configurando sua Tela Touchscreen no PDV

**O que você vai precisar:**

* **Terminal:** Um aplicativo para executar comandos no seu sistema.
* **Permissões de administrador:** Você precisará ter permissão para instalar programas e fazer alterações no sistema.

**Passo a Passo:**

1. **Abra o Terminal:**
   * Procure por "Terminal" no menu de aplicativos do seu sistema e abra-o.

2. **Verifique e Instale o Ferramenta de Calibração:**
   * Cole o seguinte comando no terminal e pressione Enter:
     ```bash
     sudo apt install xinput-calibrator
     ```
     * **O que isso faz:** Essa ferramenta nos ajuda a calibrar a tela touchscreen para que os toques sejam registrados no lugar certo.
   * **Digite sua senha:** Você será solicitado a digitar sua senha de administrador.

3. **Identifique sua Tela Touchscreen:**
   * Cole o seguinte comando no terminal e pressione Enter:
     ```bash
     xrandr
     ```
     * **O que isso faz:** Este comando lista todas as telas conectadas ao seu computador.
   * **Anote o nome:** Procure o nome da sua tela touchscreen. Geralmente é algo como "LVDS1", "eDP" ou um nome similar.

4. **Encontre o Número da Touchscreen:**
   * Cole o seguinte comando no terminal e pressione Enter:
     ```bash
     xinput --list
     ```
     * **O que isso faz:** Este comando lista todos os dispositivos de entrada, incluindo a touchscreen.
   * **Anote o número:** Procure a linha que contém "touchscreen" e anote o número que vem depois de "id=".

- **Observação:**
A afirmação sobre o item 4: "Procure a linha que contém "touchscreen" "

Nem sempre aparece algo com "TouchScreen". Exeplo:

```
root@pdv141:~# cat xinput_list
⎡ Virtual core pointer                          id=2    [master pointer  (3)]
⎜   ↳ Virtual core XTEST pointer                id=4    [slave  pointer  (2)]
⎜   ↳ ILITEK ILITEK-TP Mouse                    id=11   [slave  pointer  (2)]
⎜   ↳ ILITEK ILITEK-TP                          id=12   [slave  pointer  (2)]
⎣ Virtual core keyboard                         id=3    [master keyboard (2)]
    ↳ Virtual core XTEST keyboard               id=5    [slave  keyboard (3)]
    ↳ Power Button                              id=6    [slave  keyboard (3)]
    ↳ Video Bus                                 id=7    [slave  keyboard (3)]
    ↳ Power Button                              id=8    [slave  keyboard (3)]
    ↳ Sleep Button                              id=9    [slave  keyboard (3)]
    ↳ Datalogic S.r.I and its affiliates Point of Sale Fixed Barcode Scanner   id=10    [slave  keyboard (3)]
```
Neste caso, o Toutch é o *id 12*.


5. **Mapeie a Touchscreen para a Tela:**
   * Cole o seguinte comando no terminal, substituindo os valores entre os colchetes:
     ```bash
     xinput map-to-output <número_da_touchscreen> <nome_da_tela>
     ```
     * **Exemplo:** Se o número da sua touchscreen for 13 e o nome da sua tela for "LVDS1", o comando ficaria assim:
       ```bash
       xinput map-to-output 13 LVDS1
       ```

6. **Reative a Tela:**
   * Cole o seguinte comando no terminal, substituindo "<nome_da_tela>" pelo nome que você anotou na etapa 3:
     ```bash
     xrandr --output <nome_da_tela> --auto
     ```
___
## Gerenciamento de energia com comando xset:

```bash
xset -dpms
xset s noblank
xset s off
```
Os comandos, `xset -dpms`, `xset s noblank` e `xset s off`, são utilizados para **controlar o gerenciamento de energia da tela** em sistemas operacionais baseados em X Window, como o Linux. Essencialmente, eles servem para **impedir que a tela se apague ou entre em modo de suspensão** após um período de inatividade.

### O que cada comando faz:

* **xset -dpms:**
    * `xset`: É o comando principal para configurar diversas opções do ambiente X.
    * `-dpms`: Desativa o gerenciamento de energia (Display Power Management System). Isso significa que a tela não entrará em modo de suspensão ou se apagará automaticamente.

* **xset s noblank:**
    * `xset s`: Especifica que queremos configurar as opções do protetor de tela.
    * `noblank`: Impede que a tela fique em branco.

* **xset s off:**
    * `xset s off`: Desativa completamente o protetor de tela.

### Por que usar esses comandos?

* **Evitar que a tela se apague:** Em situações como apresentações, monitoramento constante ou uso remoto, é importante que a tela permaneça sempre ligada.
* **Manter a tela ativa:** Se você estiver trabalhando em um sistema sem interrupções e não quiser que a tela se apague, esses comandos são úteis.
* **Personalizar o comportamento da tela:** Ao desativar o gerenciamento de energia, você tem mais controle sobre quando a tela se apaga ou entra em modo de suspensão.
