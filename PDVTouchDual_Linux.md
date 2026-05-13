## Configurando sua Tela Touchscreen no PDV

**O que você vai precisar:**

* **Terminal:** Um aplicativo para executar comandos no seu sistema.
* **Permissões de administrador:** Você precisará ter permissão para instalar programas e fazer alterações no sistema.

**Passo a Passo:**

1 - **Abra o Terminal:**
   * Procure por "Terminal" no menu de aplicativos do seu sistema e abra-o.

2 - **Identifique sua Tela Touchscreen:**
   * Cole o seguinte comando no terminal e pressione Enter:
```
xrandr
```
     * **O que isso faz:** Este comando lista todas as telas conectadas ao seu computador.
   * **Anote o nome:** Procure o nome da sua tela touchscreen. Geralmente é algo como "LVDS1", "eDP" ou um nome similar.

3 - **Encontre o Número da Touchscreen:**
   * Cole o seguinte comando no terminal e pressione Enter:
```
xinput --list
```
     * **O que isso faz:** Este comando lista todos os dispositivos de entrada, incluindo a touchscreen.
   * **Anote o número:** Procure a linha que contém "touchscreen" e anote o número que vem depois de "id=".

- **Observação:**

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

4 - Edite o arquivo `/Zanthus/Zeus/pdvJava/PDVTouchDual.sh` e adicione logo após a linha `#!/bin/bash` o parâmetro para mapear o Touchscreen para a tela.

   * Use o seguinte comando, substituindo os valores entre os colchetes:
```
xinput map-to-output <número_da_touchscreen> <nome_da_tela>
```
     * **Exemplo:** Se o número da sua touchscreen for 13 e o nome da sua tela for "LVDS1", o comando ficaria assim:
```
xinput map-to-output 13 LVDS1
```

---

## CONFIGURAÇÃO OPCIONAL: Gerenciamento de energia com comando xset:

```
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

---

## Execução de comandos GUI e via Putty/SSH


Os comandos xrandr e xinput exigem execução via Terminal em Interface Gráfica, mas não é sempre que estamos utilizando.
Se executar estes comandos via acesso Putty/SSH, vai dar uma mensagem de erro e não vai listar o que quer.
Como contornar este problema? Utilizando a variável DISPLAY com o valor da tela utilizada, que geralmente é :0 . Exemplos:

```
DISPLAY=:0 xrandr
DISPLAY=:0 xinput list
```
