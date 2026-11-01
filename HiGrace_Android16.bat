@echo off
setlocal
cd /d "%~dp0"
title HiGrace OC101 - Android 16 (LineageOS 23.2)

rem ==================================================================
rem  HiGrace OC101 (Allwinner A523) - installazione di
rem  LineageOS 23.2 (Android 16) gia' sistemata e ottimizzata.
rem  Leggi LEGGIMI.txt prima di usare questo file.
rem ==================================================================

set "TOOLS=%~dp0strumenti"
set "LOGDIR=%~dp0log"
set "ROMIMG=%~dp0rom\LineageOS-23.2-HiGrace-OC101.img"
set "ROMSIZE=1491709952"
set "ROMSHA=828D0D982A27C9567592FE0D2C9E15134B7CCBD83514748FB5C1F0B76810F8E5"
set "VBM=%TOOLS%\vbmeta_disabled.img"
set "FPRINT=HIGRACE/OC101/OC101_EEA"
set "BOOTORIG=%TOOLS%\init_boot_originale.img"
set "BOOTORIGSHA=E96204371B1C9937CCE293D1542098F902AA4A38D55676565F3838420797E8A6"
set "BOOTMAGISK=%TOOLS%\init_boot_magisk.img"
set "BOOTMAGISKSHA=83A5D7359E80035B2C90985FB8B416B0BABB4C2594140D3AE81FE7ADA1520DCB"
set "MAGISKAPK=%TOOLS%\Magisk-v30.7.apk"
set "KERNELID=5.15.78-android13-8-00001-gfe86c885b0db"
set "PATH=%TOOLS%;%PATH%"
if not exist "%LOGDIR%" mkdir "%LOGDIR%"

where adb >nul 2>&1
if errorlevel 1 goto manca_adb
where fastboot >nul 2>&1
if errorlevel 1 goto manca_adb
goto menu

:manca_adb
echo [ERRORE] Non trovo adb.exe e fastboot.exe nella cartella "strumenti".
pause
exit /b 1

rem ==================================================================
:menu
cls
echo ==================================================================
echo   HiGrace OC101 (Allwinner A523)
echo   LineageOS 23.2 - Android 16, gia' ottimizzata
echo ==================================================================
echo.
echo   1  Controlla il collegamento del tablet
echo   2  INSTALLA Android 16                   (CANCELLA TUTTI I DATI)
echo   3  ROOT con Magisk                (facoltativo, A TUO RISCHIO)
echo   4  Togli il root, rimette l'init_boot originale
echo   0  Esci
echo.
echo   Prima di iniziare leggi LEGGIMI.txt
echo.
choice /c 12340 /n /m "Scegli un numero: "
if errorlevel 5 exit /b 0
if errorlevel 4 goto togli_root
if errorlevel 3 goto root
if errorlevel 2 goto installa
goto controlla

:fine_menu
echo.
pause
goto menu

rem ==================================================================
rem  1 - CONTROLLO COLLEGAMENTO
rem ==================================================================
:controlla
cls
set "LOG=%LOGDIR%\1_controllo_log.txt"
echo [%date% %time%] Controllo collegamento > "%LOG%"
echo === Dispositivi visti da adb ===
adb devices -l > "%TEMP%\hg_adb.txt" 2>&1
type "%TEMP%\hg_adb.txt"
type "%TEMP%\hg_adb.txt" >> "%LOG%"
echo === Dispositivi visti da fastboot ===
fastboot devices > "%TEMP%\hg_fbd.txt" 2>&1
type "%TEMP%\hg_fbd.txt"
type "%TEMP%\hg_fbd.txt" >> "%LOG%"
echo.
findstr /c:"unauthorized" "%TEMP%\hg_adb.txt" >nul
if not errorlevel 1 (
  echo Il tablet e' collegato ma NON autorizzato: sul tablet accetta
  echo "Consentire debug USB?" e spunta "Consenti sempre da questo computer".
  goto fine_menu
)
adb get-state >nul 2>&1
if errorlevel 1 goto ctrl_fastboot
echo Il tablet e' collegato con adb. Sistema installato:
<nul adb shell getprop ro.vendor.build.fingerprint > "%TEMP%\hg_fp.txt" 2>&1
<nul adb shell getprop ro.build.version.release > "%TEMP%\hg_rel.txt" 2>&1
<nul adb shell getprop ro.boot.flash.locked > "%TEMP%\hg_lock.txt" 2>&1
type "%TEMP%\hg_fp.txt"
type "%TEMP%\hg_fp.txt" >> "%LOG%"
type "%TEMP%\hg_rel.txt" >> "%LOG%"
type "%TEMP%\hg_lock.txt" >> "%LOG%"
echo.
findstr /c:"%FPRINT%" "%TEMP%\hg_fp.txt" >nul
if errorlevel 1 (
  echo ATTENZIONE: questo NON sembra un HiGrace OC101.
  echo Non usare questo pacchetto su altri modelli.
  goto fine_menu
)
echo OK: e' un HiGrace OC101.
findstr /x /c:"0" "%TEMP%\hg_lock.txt" >nul || echo ATTENZIONE: il bootloader risulta BLOCCATO, vedi LEGGIMI.txt
findstr /x /c:"16" "%TEMP%\hg_rel.txt" >nul && ( echo Android 16 gia' installata. Facoltativo: opzione 3 per il root. & goto fine_menu )
echo Sistema attuale: Android originale. Prossimo passo: opzione 2.
goto fine_menu

:ctrl_fastboot
findstr /c:"fastboot" "%TEMP%\hg_fbd.txt" >nul
if errorlevel 1 (
  echo Il tablet NON e' visto dal PC. Controlla:
  echo  - che sia acceso e collegato con un cavo USB DATI
  echo  - che il Debug USB sia attivo, vedi LEGGIMI.txt
  echo  - i driver USB, vedi LEGGIMI.txt
  goto fine_menu
)
echo Il tablet e' in modalita' fastboot:
call :leggi_fastboot
findstr /b /c:"product:" /c:"is-userspace:" /c:"unlocked:" /c:"current-slot:" "%TEMP%\hg_fb.txt"
goto fine_menu

rem ==================================================================
rem  2 - INSTALLAZIONE
rem ==================================================================
:installa
cls
set "LOG=%LOGDIR%\2_installa_log.txt"
echo [%date% %time%] Installazione Android 16 > "%LOG%"
echo ==================================================================
echo  INSTALLAZIONE LineageOS 23.2 - Android 16
echo  ATTENZIONE: cancella TUTTO il contenuto del tablet:
echo  foto, video, app, account. Salva prima quello che ti serve.
echo  Consigliato: avere il backup del sistema originale.
echo ==================================================================
echo.
echo === 1/6 Verifico la ROM sul PC, circa un minuto ===
set "CHK=%ROMIMG%"
set "CHKSHA=%ROMSHA%"
call :verifica_file
if errorlevel 1 goto fine_menu
echo ROM OK.

echo.
echo === 2/6 Porto il tablet in modalita' fastbootd ===
call :vai_fastboot
if errorlevel 1 goto fine_menu
fastboot getvar partition-size:product_a > "%TEMP%\hg_prod.txt" 2>&1
type "%TEMP%\hg_prod.txt" >> "%LOG%"
set "DELPROD=0"
findstr /c:"partition-size:product_a: 0x" "%TEMP%\hg_prod.txt" >nul && set "DELPROD=1"
echo Controlli OK.

echo.
echo ==================================================================
echo  Sto per scrivere sul tablet, SOLO nello slot "a":
echo   1. eliminare la partizione product_a, per fare spazio
echo   2. scrivere Android 16 nella partizione system_a, circa 1 minuto
echo   3. disattivare le verifiche in vbmeta_a e vbmeta_system_a
echo  Poi il tablet va nel recovery per cancellare i dati.
echo  Il sistema attuale verra' sostituito.
echo ==================================================================
set "OK="
set /p OK=Scrivi SI e premi Invio per procedere:
if /i not "%OK%"=="SI" ( echo Annullato, non ho scritto nulla. & echo Annullato >> "%LOG%" & goto fine_menu )

echo.
echo === 3/6 Elimino product_a ===
if "%DELPROD%"=="0" ( echo product_a e' gia' stata eliminata. & goto inst_flash )
fastboot delete-logical-partition product_a >> "%LOG%" 2>&1
if errorlevel 1 ( echo [ERRORE] Non riesco a eliminare product_a. Il tablet non e' stato modificato. & echo ERRORE delete product_a >> "%LOG%" & goto fine_menu )
:inst_flash
echo === 4/6 Scrivo Android 16: NON scollegare ===
echo  Il messaggio "Invalid sparse file format" e' normale.
fastboot flash system_a "%ROMIMG%" >> "%LOG%" 2>&1
if errorlevel 1 ( echo [ERRORE] Scrittura fallita. NON spegnere il tablet e ripeti l'opzione 2. & echo ERRORE flash system_a >> "%LOG%" & goto fine_menu )
echo === 5/6 Disattivo le verifiche vbmeta ===
fastboot --disable-verity --disable-verification flash vbmeta_a "%VBM%" >> "%LOG%" 2>&1
if errorlevel 1 ( echo [ERRORE] Scrittura di vbmeta_a fallita. NON spegnere il tablet e ripeti l'opzione 2. & echo ERRORE vbmeta_a >> "%LOG%" & goto fine_menu )
fastboot --disable-verity --disable-verification flash vbmeta_system_a "%VBM%" >> "%LOG%" 2>&1
if errorlevel 1 ( echo [ERRORE] Scrittura di vbmeta_system_a fallita. NON spegnere il tablet e ripeti l'opzione 2. & echo ERRORE vbmeta_system_a >> "%LOG%" & goto fine_menu )
echo Scrittura completata.

echo.
echo === 6/6 Cancellazione dati dal recovery ===
fastboot reboot recovery >> "%LOG%" 2>&1
echo [%date% %time%] Scrittura completata, riavvio nel recovery >> "%LOG%"
echo.
echo ==================================================================
echo  ORA SUL TABLET, nel menu del recovery:
echo    tasti VOLUME = spostarsi      tasto POWER = confermare
echo.
echo   1. scegli  "Wipe data/factory reset"
echo   2. conferma
echo   3. alla fine scegli  "Reboot system now"
echo.
echo  Il primo avvio dura alcuni minuti. Completa la configurazione
echo  iniziale (lingua, Wi-Fi...). Non serve altro: le correzioni e le
echo  ottimizzazioni sono gia' dentro la ROM.
echo.
echo  Facoltativo: opzione 3 per il root con Magisk.
echo ==================================================================
goto fine_menu

rem ==================================================================
rem  3 - ROOT CON MAGISK
rem ==================================================================
:root
cls
set "LOG=%LOGDIR%\3_root_log.txt"
echo [%date% %time%] Root con Magisk > "%LOG%"
echo ==================================================================
echo  ROOT CON MAGISK - FACOLTATIVO, A TUO RISCHIO
echo.
echo  Scrive nella partizione init_boot un'immagine modificata con
echo  Magisk 30.7, ricavata dall'init_boot originale dell'HiGrace OC101.
echo  Lo script controlla modello e kernel e si ferma se non
echo  corrispondono. Serve Android 16 avviata con il Debug USB attivo.
echo  Per tornare indietro: opzione 4 del menu.
echo ==================================================================
set "CHK=%BOOTMAGISK%"
set "CHKSHA=%BOOTMAGISKSHA%"
call :verifica_file
if errorlevel 1 goto fine_menu
call :verifica_android
if errorlevel 1 goto fine_menu
<nul adb shell cat /proc/version > "%TEMP%\hg_kv.txt" 2>&1
type "%TEMP%\hg_kv.txt" >> "%LOG%"
findstr /c:"%KERNELID%" "%TEMP%\hg_kv.txt" >nul || ( echo [STOP] Il kernel del tablet non e' quello originale: l'init_boot non e' adatto, mi fermo. & echo STOP: kernel diverso >> "%LOG%" & goto fine_menu )
echo Kernel originale riconosciuto.
echo.
set "OK="
set /p OK=Scrivi SI per installare il root a tuo rischio:
if /i not "%OK%"=="SI" ( echo Annullato, non ho scritto nulla. & echo Annullato >> "%LOG%" & goto fine_menu )
call :vai_fastboot
if errorlevel 1 goto fine_menu
echo Scrivo l'init_boot con Magisk...
fastboot flash init_boot_a "%BOOTMAGISK%" >> "%LOG%" 2>&1
if errorlevel 1 ( echo [ERRORE] Scrittura fallita. NON spegnere il tablet: usa l'opzione 4. & echo ERRORE flash init_boot >> "%LOG%" & goto fine_menu )
fastboot reboot >> "%LOG%" 2>&1
echo Riavvio, 1-2 minuti...
call :attendi_avvio
if exist "%MAGISKAPK%" ( echo Installo l'app Magisk... & adb install -r "%MAGISKAPK%" >> "%LOG%" 2>&1 )
<nul adb shell ls /debug_ramdisk/su > "%TEMP%\hg_mgk.txt" 2>&1
type "%TEMP%\hg_mgk.txt" >> "%LOG%"
findstr /c:"No such file" "%TEMP%\hg_mgk.txt" >nul && ( echo ATTENZIONE: non riesco a confermare Magisk, controlla il log. ) || ( echo Root attivo: Magisk funziona. )
echo [%date% %time%] Fine >> "%LOG%"
echo.
echo  Apri l'app Magisk sul tablet: se chiede una configurazione
echo  aggiuntiva accetta. Per usare su da adb: Magisk, Impostazioni,
echo  Accesso Superuser = "App e ADB".
goto fine_menu

rem ==================================================================
rem  4 - TOGLI IL ROOT
rem ==================================================================
:togli_root
cls
set "LOG=%LOGDIR%\4_togli_root_log.txt"
echo [%date% %time%] Tolgo il root > "%LOG%"
set "CHK=%BOOTORIG%"
set "CHKSHA=%BOOTORIGSHA%"
call :verifica_file
if errorlevel 1 goto fine_menu
echo ==================================================================
echo  Rimetto l'init_boot ORIGINALE di fabbrica: il root di Magisk
echo  sparisce, Android 16 e i tuoi dati restano.
echo ==================================================================
set "OK="
set /p OK=Scrivi SI e premi Invio per procedere:
if /i not "%OK%"=="SI" ( echo Annullato, non ho scritto nulla. & echo Annullato >> "%LOG%" & goto fine_menu )
call :vai_fastboot
if errorlevel 1 goto fine_menu
fastboot flash init_boot_a "%BOOTORIG%" >> "%LOG%" 2>&1
if errorlevel 1 ( echo [ERRORE] Scrittura fallita. NON spegnere il tablet e riprova l'opzione 4. & echo ERRORE flash init_boot >> "%LOG%" & goto fine_menu )
fastboot reboot >> "%LOG%" 2>&1
echo [%date% %time%] init_boot originale scritto >> "%LOG%"
echo Fatto: init_boot originale rimesso, il tablet si riavvia senza root.
goto fine_menu

rem ==================================================================
rem  SUBROUTINE
rem ==================================================================
:verifica_file
if not exist "%CHK%" ( echo [STOP] Manca un file della ROM o della cartella strumenti, vedi LEGGIMI.txt & echo STOP: manca file >> "%LOG%" & exit /b 1 )
powershell -NoProfile -Command "if ((Get-FileHash -LiteralPath $env:CHK -Algorithm SHA256).Hash -eq $env:CHKSHA) { exit 0 } else { exit 1 }" <nul
if errorlevel 1 ( echo [STOP] Un file della ROM o della cartella strumenti e' danneggiato: non lo uso. & echo STOP: sha errato >> "%LOG%" & exit /b 1 )
exit /b 0

:verifica_android
adb get-state >nul 2>&1
if errorlevel 1 (
  echo [STOP] adb non vede il tablet: deve essere acceso, sbloccato,
  echo collegato e con il Debug USB attivo. Usa l'opzione 1.
  echo STOP: adb non vede il tablet >> "%LOG%"
  exit /b 1
)
<nul adb shell getprop ro.vendor.build.fingerprint > "%TEMP%\hg_fp.txt" 2>&1
type "%TEMP%\hg_fp.txt" >> "%LOG%"
findstr /c:"%FPRINT%" "%TEMP%\hg_fp.txt" >nul || ( echo [STOP] Questo non e' un HiGrace OC101. Mi fermo. & echo STOP: modello diverso >> "%LOG%" & exit /b 1 )
exit /b 0

:leggi_fastboot
fastboot getvar product > "%TEMP%\hg_fb.txt" 2>&1
fastboot getvar is-userspace >> "%TEMP%\hg_fb.txt" 2>&1
fastboot getvar unlocked >> "%TEMP%\hg_fb.txt" 2>&1
fastboot getvar current-slot >> "%TEMP%\hg_fb.txt" 2>&1
fastboot getvar super-partition-name >> "%TEMP%\hg_fb.txt" 2>&1
type "%TEMP%\hg_fb.txt" >> "%LOG%"
exit /b 0

rem Porta il tablet in fastbootd e controlla. Partendo da Android il modello
rem viene verificato con adb; partendo gia' da fastboot serve product OC101.
:vai_fastboot
set "DAADB=0"
fastboot devices 2>nul | find "fastboot" >nul
if not errorlevel 1 goto vf_controlli
call :verifica_android
if errorlevel 1 exit /b 1
set "DAADB=1"
adb reboot fastboot
echo Attendo il tablet in modalita' fastboot, fino a 2 minuti...
call :attendi_fastboot
if errorlevel 1 ( echo [STOP] Il tablet non risulta in fastboot: se lo schermo mostra "fastbootd" il problema sono i driver, vedi LEGGIMI.txt & echo STOP: fastboot non visto >> "%LOG%" & exit /b 1 )
:vf_controlli
call :leggi_fastboot
findstr /b /c:"product:" /c:"is-userspace:" /c:"unlocked:" /c:"current-slot:" "%TEMP%\hg_fb.txt"
if "%DAADB%"=="1" goto vf_resto
findstr /i /c:"product: OC101" "%TEMP%\hg_fb.txt" >nul || ( echo [STOP] Non riesco a confermare che sia un HiGrace OC101: riavvia il tablet in Android e riprova. & echo STOP: product >> "%LOG%" & exit /b 1 )
:vf_resto
findstr /c:"is-userspace: yes" "%TEMP%\hg_fb.txt" >nul || ( echo [STOP] Il tablet e' nel fastboot del bootloader: serve fastbootd. Scrivi "fastboot reboot fastboot" oppure riavvia in Android e riprova. & echo STOP: non fastbootd >> "%LOG%" & exit /b 1 )
findstr /c:"unlocked: yes" "%TEMP%\hg_fb.txt" >nul || ( echo [STOP] Il bootloader e' BLOCCATO, vedi LEGGIMI.txt & echo STOP: bootloader bloccato >> "%LOG%" & exit /b 1 )
findstr /c:"current-slot: a" "%TEMP%\hg_fb.txt" >nul || ( echo [STOP] Lo slot attivo non e' "a", mi fermo. & echo STOP: slot non a >> "%LOG%" & exit /b 1 )
findstr /c:"super-partition-name: super" "%TEMP%\hg_fb.txt" >nul || ( echo [STOP] Partizione super non trovata, mi fermo. & echo STOP: super >> "%LOG%" & exit /b 1 )
exit /b 0

:attendi_fastboot
set /a N=0
:af_loop
fastboot devices 2>nul | find "fastboot" >nul
if not errorlevel 1 ( ping -n 4 127.0.0.1 >nul & exit /b 0 )
set /a N+=1
if %N% GEQ 40 exit /b 1
ping -n 4 127.0.0.1 >nul
goto af_loop

:attendi_avvio
ping -n 31 127.0.0.1 >nul
adb wait-for-device
set /a N=0
:aa_loop
<nul adb shell getprop sys.boot_completed 2>nul | find "1" >nul
if not errorlevel 1 ( ping -n 11 127.0.0.1 >nul & exit /b 0 )
set /a N+=1
if %N% GEQ 60 exit /b 1
ping -n 6 127.0.0.1 >nul
goto aa_loop
