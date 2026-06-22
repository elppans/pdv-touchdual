REM @cmdow @ /DIS


IF NOT EXIST echoon.txt @echo off
echo Carregando requisitos...
REM Carrega se Modo de atualizacao eh PathComum ou Manager
set /p CANOA_ZEUS_MODE_UPDATE=<C:\opt\webadmin\extra\path_comum_sinc\path_comum_sinc.conf

rem start c:\Zanthus\Zeus\pdvJava\path_comum.bat
start c:\Zanthus\Zeus\pdvJava\driver.bat

echo Iniciando Zeus PDV...
set DaTaAtual=%date:~6,4%-%date:~3,2%-%date:~0,2%_%time:~0,2%-%time:~3,2%-%time:~6,2%		
echo Aguardando..
if exist %Z_PATH_COMUM%\ZArqConfig copy %Z_PATH_COMUM%\ZArqConfig\*.* .
if exist %Z_PATH_COMUM%\ctsat xcopy %Z_PATH_COMUM%\ctsat c:\Zanthus\Zeus\ctsat /s /e /y
if exist %Z_PATH_COMUM%\Interface xcopy %Z_PATH_COMUM%\Interface c:\Zanthus\Zeus\Interface /s /e /y
if exist %Z_PATH_COMUM%\moduloPHPPDV xcopy %Z_PATH_COMUM%\moduloPHPPDV c:\Zanthus\Zeus\pdvJava\GERAL\SINCRO\WEB\moduloPHPPDV /s /e /y
if exist %Z_PATH_COMUM%\pdvConfig xcopy %Z_PATH_COMUM%\pdvConfig c:\Zanthus\Zeus\pdvJava\pdvConfig /s /e /y
if exist %Z_PATH_COMUM%\pdvGUI xcopy %Z_PATH_COMUM%\pdvGUI c:\Zanthus\Zeus\pdvJava\pdvGUI /s /e /y

set "CONFIG_FILE=C:\Zanthus\Zeus\pdvJava\EXEC_PAF.CFG"


for /f "usebackq tokens=2 delims==" %%a in ("%CONFIG_FILE%") do (
    set "NOME_PROCESSO=%%~a"
)


for /f "tokens=* delims= " %%b in ("%NOME_PROCESSO%") do set "NOME_PROCESSO=%%b"

echo Valor lido do EXEC_PAF.CFG: [%EXECUTAVEL%]

REM Atualizacao via Manager
if %CANOA_ZEUS_MODE_UPDATE%==Manager (
	for /f "delims= skip=3" %%a in (c:\Zanthus\Zeus\pdvJava\ATULIB_0.TXT) do ( 
		set PURO_ZTAR=%%a 		
	)
	echo Parando o serviço exec_pdv...
	sc stop exec_pdv
	taskkill /IM w_receb.exe /F
	taskkill /IM w_pafnfce.exe /F
	dorme 5

	cd c:\Zanthus\Zeus\pdvJava\
	libpdv_separa.exe c:\Zanthus\Zeus\dll_inter
	if exist "c:\Zanthus\Zeus\dll_inter\ExecLibs.exe" (		
		echo -e "[Backup das Bibliotecas (dll) realizada com sucesso!]\n"
		forfiles /P c:\Zanthus\Zeus\ /M Backup_dll*.zip /D -15 /c "cmd /c del @file"		
		cd c:\Zanthus\Zeus\pdvJava\
		7za.exe a -tzip Backup_dll_%DaTaAtual%.zip c:\Zanthus\Zeus\dll\*.*
		move /Y c:\Zanthus\Zeus\pdvJava\Backup_dll*.zip c:\Zanthus\Zeus\
		rem del /Q c:\Zanthus\Zeus\dll\*.*
		cd c:\Zanthus\Zeus\dll_inter
		ExecLibs.exe -y
		copy c:\Zanthus\Zeus\dll_inter\*.* c:\Zanthus\Zeus\dll
		del /Q c:\Zanthus\Zeus\dll\ExecLibs.exe
		del /Q c:\Zanthus\Zeus\dll_inter\*.*

	)
)
REM Atualizacao via PathComum
if %CANOA_ZEUS_MODE_UPDATE%==PathComum (
	if not exist %Z_PATH_COMUM%\DLL goto verifica
	echo Parando o serviço exec_pdv...
	timeout /t 5 /nobreak > null
	copy %Z_PATH_COMUM%\DLL\*.dll ..\DLL    
	timeout /t 5 /nobreak > null
	echo Iniciando o serviço exec_pdv...
    sc start exec_pdv
)
:verifica
	if not exist %Z_PATH_COMUM%\veratu.exe goto continua
	if not exist veratu.exe goto atualiza
	comparqW.exe %Z_PATH_COMUM%\veratu.exe veratu.exe
	if errorlevel 1 goto atualiza
	goto continua
:atualiza
	if not exist W_CONV.EXE goto antigo
	W_CONV /t
	goto feito
:antigo
	ZFRECONV /t
:feito
	del /q old
	md old
	rem    copy *.* old
	rem    del *.1vn
	rem    del *.nvw
	rem    del *.tra
	copy %Z_PATH_COMUM%\veratu.exe c:\Zanthus\Zeus\pdvJava\
	veratu.exe -y
	W_CONV /b
:continua
cd c:\Zanthus\Zeus\pdvJava\
w_senh.exe /z2291755
rem start /b "PDV Zanthus" /min %Z_FREE_EXEC% PATH_COMUM=%Z_PATH_COMUM% PATH_SS=%Z_PATH_SS% run
timeout /t 5 /nobreak > null
sc stop exec_pdv
taskkill /IM w_receb.exe /F
taskkill /IM w_pafnfce.exe /F
timeout /t 5 /nobreak > null
rem echo Valor lido momento if : %EXECUTAVEL%
sc start exec_pdv
dorme 5
timeout /t 20 /nobreak > null
dorme 10
cd pdvGUI
echo %Z_PATH_COMUM%\DESCANSO > path_comum.cfg
rem taskkill /f /im javaw.exe >nul
REM start "IGraficaJava" java -jar jpdvgui6.jar
start "IGraficaJava" jpdvgui6.jar
dorme 10
cd c:\Zanthus\Zeus\pdvJava\pdvGUI2
echo %Z_PATH_COMUM%\DESCANSO > path_comum.cfg
start "IGraficaJava2" jpdvgui6.jar
REM start "IGraficaJava" java -jar jpdvgui6.jar

REM Posiciona a janela do cliente na tela de número 2.
timeout /t 10 /nobreak > null
C:\opt\webadmin\extra\zpoja.exe "Zanthus Retail" "2"

REM @cmdow @ /ENA