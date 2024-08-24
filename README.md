# pdv-touchdual

---

# Configuração da Tela Touchscreen

Para configurar a tela touchscreen em seu PDV, siga os passos abaixo:

1. **Instale os pacotes necessários:**
   Abra o terminal e execute os seguintes comandos para verificar e instalar o pacote `xinput-calibrator`:

   ```bash
   # Verifique se o pacote está instalado:
   dpkg -l xinput-calibrator

   # Se não estiver instalado, instale o pacote:
   sudo apt install xinput-calibrator
   ```

2. **Identifique a tela touchscreen:**
   Execute o comando abaixo no terminal para listar as telas conectadas ao seu PDV:

   ```bash
   xrandr
   ```

   Anote o identificador da tela touchscreen (geralmente é `LVDS1` ou `eDP` em laptops).

3. **Encontre o número da touchscreen:**
   Execute o comando abaixo no terminal para listar os dispositivos de entrada (incluindo a touchscreen):

   ```bash
   xinput --list
   ```

   1. Procure o dispositivo que contém "touchscreen" no nome e anote o número que aparece depois de `id=`.
   2. Calibre a tela: Agora, execute o seguinte comando no terminal para mapear a touchscreen para a tela identificada na etapa 2:

      ```bash
      xinput map-to-output <número_da_touchscreen> <identificador_da_tela>
      ```

      Substitua `<número_da_touchscreen>` pelo número obtido na etapa 1 e `<identificador_da_tela>` pelo identificador da tela.

   3. Reative a tela: Finalmente, reative a tela com o seguinte comando:

      ```bash
      xrandr --output <identificador_da_tela> --auto
      ```

