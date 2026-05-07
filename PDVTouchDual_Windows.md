# Instalação PDV Dual

Antes de ir para o Dual Touch, vou começar utilizando o PDV Dual Java, para aprender como enviar uma janela específica para o 2º monitor. 

- Instale o PDV conforme as instruções do manual [gcit0037-manual-de-instalacao-pdv-windows](https://docs.zanthusonline.com.br/documentacao/gcit0037-manual-de-instalacao-pdv-windows/)

- Ao chegar na parte de informar o "Tipo de Interface", escolher Dual Java

Quando instala o PDV usando a opção Dual Java, ao inciar é executado 2 janelas:

1. Janela Java com o nome "Zeus Retail"
2. Janela Java com o nome "IGraficaJava"

Então era para o Windows jogar a janela secundádia para o 2º monitor, mas não faz. Para resolver isso, deve usar um executável com o nome "zpoja.exe" (Zanthus Posicionador de Janela)

## Zanthus Posicionador de Janela

Para usar deve seguir o procedimento a seguir:

- Copie o arquivo zpoja.exe para o diretório `C:\opt\webadmin\extra\`

- Edite o arquivo `C:\Zanthus\Zeus\pdvJava\w_pdv.cmd`

Na última linha, logo após o último "start ..." adicione um tempo de espera de 10 segundos e logo após, uma linha para executar o aplicativo zpoja.exe utilizando 2 parâmetros:

> Se o computador for lento, coloque 20 ou 30 segundos para o timeout

1. Deve indicar o nome da janela que irá para o 2º monitor.
   Este parâmetro aceita expressão regular como "Zeus*", mas recomendo utilizar o nome exato da janela.

2. Deve indicar o número da tela onde a janela deve ser movida, como "2" para o 2º monitor.

Com isso as linhas iro ficar com esta configuração:

```bash
timeout /t 10 /nobreak > null
C:\opt\webadmin\extra\zpoja.exe "Zanthus Retail" "2"
```







# PDV Dual Touch

Se ainda não instalou, durante a instalação do PDV, ao chegar na parte de informar o "Tipo de Interface", escolha "Touch". Depois Prossiga 

Se já fez o passo anterior e instalou o PDV, apenas prossiga.

- Após a instalação, edite o arquivo w_pdv.cmd e no final do arquivo, logo após a linha "cd pdvGUI", configure a ordem de execução:

### PDV Touch+Java

1. Execução do PDV Java (Cliente)
2. Execução do PDV Interface Web (Operador)
3. zpoja.exe

Esta edição ficará desta forma:

```bash
cd c:\Zanthus\Zeus\pdvJava\pdvGUI2
echo %Z_PATH_COMUM%\DESCANSO > path_comum.cfg
start "IGraficaJava2" jpdvgui6.jar
dorme 10
start "Zeus PDV" chrome.exe --disable-gpu --test-type --no-sandbox --kiosk --no-context-menu --disable-translate C:\Zanthus\Zeus\Interface\index.html

REM Posiciona a janela do cliente na tela de número 2.
timeout /t 10 /nobreak > null
C:\opt\webadmin\extra\zpoja.exe "Zanthus Retail" "2"
```

![alt text](DualTouch-Java.png)

### PDV Touch Full Web

Para 2 interfaces Web, deve configurar 2 linhas com o mesmo comando porém, apontando para páginas diferentes.

- C:\Zanthus\Zeus\Interface\index.html = Operador
- C:\Zanthus\Zeus\Interface\index.html = Cliente

```bash
start "Zeus PDV" chrome.exe --new-window --disable-gpu --test-type --no-sandbox --kiosk --no-context-menu --disable-translate C:\Zanthus\Zeus\Interface\index.html
dorme 10
start "Cliente PDV" chrome.exe --new-window --disable-gpu --test-type --no-sandbox --kiosk --no-context-menu --disable-translate C:\Zanthus\Zeus\Interface\cliente.html

REM Posiciona a janela do cliente na tela de número 2.
timeout /t 10

C:\opt\webadmin\extra\zpoja.exe "Cliente - Google Chrome" "2"
```

![alt text](DualTouch-WEB.png)
