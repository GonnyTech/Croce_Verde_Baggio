@echo off
REM --- Script di Caricamento Universale per Windows (Richiede get_commit_message.vbs) ---

SET SCRIPT_NAME="upload_lezione.bat"
SET VBS_NAME="get_commit_message.vbs"

echo --------------------------------------------------------
echo   ^> Avvio Caricamento Materiali Didattici
echo --------------------------------------------------------

REM Chiama lo script VBScript per aprire la finestra di dialogo e salvare l'output
for /f "delims=" %%i in ('cscript //nologo "%VBS_NAME%"') do set "COMMIT_MESSAGE=%%i"

REM Verifica se l'utente ha premuto Annulla (il VBScript restituisce 'ANNULLATO')
IF "%COMMIT_MESSAGE%"=="ANNULLATO" (
    echo.
    echo ❌ Operazione annullata dall'utente.
    echo.
    goto :eof
)

echo Messaggio di Commit: %COMMIT_MESSAGE%
echo.

REM 1. STAGE: Aggiunge tutti i file nuovi e modificati all'area di staging ESCLUDENDO gli script
echo [FASE 1/3] Aggiungo i file all'area di staging (escludendo gli script .bat e .vbs)

REM Aggiunge tutti i file (nuovi e modificati)
git add .
IF ERRORLEVEL 1 (
    echo ❌ Errore durante l'esecuzione di git add.
    goto :eof
)

REM Rimuove i file dello script dall'area di staging se sono stati aggiunti accidentalmente
git reset -- "%SCRIPT_NAME%" 2>nul
git reset -- "%VBS_NAME%" 2>nul

REM Verifica se c'è altro materiale da committare (esclusi gli script)
REM 'git diff --cached --quiet' verifica se l'area di staging è vuota.
git diff --cached --quiet
IF %ERRORLEVEL% EQU 0 (
    echo ✅ Nessun nuovo materiale didattico o modifica da caricare. Esco.
    echo.
    goto :eof
)


REM 2. COMMIT: Crea il commit con il messaggio fornito
echo [FASE 2/3] Eseguo il commit...
git commit -m "%COMMIT_MESSAGE%"
IF ERRORLEVEL 1 (
    echo ❌ Errore durante l'esecuzione del commit. Verifica i file.
    goto :eof
)
echo ✅ Commit eseguito con successo.

REM 3. PUSH: Carica i cambiamenti sul repository remoto (GitHub)
echo [FASE 3/3] Carico su GitHub (git push)...
git push
IF ERRORLEVEL 1 (
    echo ❌ Errore durante il push su GitHub. Controlla la tua connessione o le credenziali.
    goto :eof
)

echo --------------------------------------------------------
echo   🎉 Materiali caricati con successo su GitHub!
echo --------------------------------------------------------
echo.