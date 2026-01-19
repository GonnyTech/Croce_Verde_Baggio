@echo off
REM --- Script di Caricamento Universale con supporto Git LFS ---
REM Richiede get_commit_message.vbs per funzionare [cite: 3]

SET SCRIPT_NAME="upload_lezione.bat"
SET VBS_NAME="get_commit_message.vbs"

echo --------------------------------------------------------
echo   ^> Avvio Caricamento Materiali Didattici (Supporto LFS)
echo --------------------------------------------------------

REM 1. MESSAGGIO: Chiama lo script VBScript per il messaggio di commit [cite: 3]
for /f "delims=" %%i in ('cscript //nologo "%VBS_NAME%"') do set "COMMIT_MESSAGE=%%i"

IF "%COMMIT_MESSAGE%"=="ANNULLATO" (
    echo.
    echo ❌ Operazione annullata dall'utente. [cite: 3]
    echo.
    goto :eof
)

echo Messaggio di Commit: %COMMIT_MESSAGE%
echo.

REM 2. CONFIGURAZIONE LFS: Assicura che i file pesanti siano tracciati correttamente
echo [FASE 1/4] Configurazione Git LFS...
git lfs track "*.mp3"
git lfs track "*.mp4"
git lfs track "*.zip"
git add .gitattributes

REM 3. STAGE: Aggiunge i file all'area di staging 
echo [FASE 2/4] Aggiunta file all'area di staging...
git add .
IF ERRORLEVEL 1 (
    echo ❌ Errore durante l'esecuzione di git add. 
)

REM Rimuove i file dello script dall'area di staging se aggiunti accidentalmente 
git reset -- "%VBS_NAME%" 2>nul

REM Verifica se c'è materiale da committare 
IF %ERRORLEVEL% EQU 0 (
    echo ✅ Nessun nuovo materiale didattico da caricare. [cite: 6]
    goto :eof
)

REM 4. COMMIT: Crea il commit locale 
git commit -m "%COMMIT_MESSAGE%"
IF ERRORLEVEL 1 (
    echo ❌ Errore durante l'esecuzione del commit. [cite: 6]
    goto :eof
)

REM 5. PUSH: Carica i file su GitHub 
echo [FASE 4/4] Carico su GitHub (git push)...
REM Aumenta il buffer HTTP per gestire meglio i file grandi durante il caricamento
git config http.postBuffer 524288000

git push
IF ERRORLEVEL 1 (
    echo.
    echo ❌ Errore durante il push su GitHub. 
    echo Nota: Se l'errore riguarda i file sopra i 100MB, esegui prima:
    echo 'git lfs migrate import --include="*.mp3,*.mp4"' nel terminale.
    goto :eof
)

echo --------------------------------------------------------
echo   🎉 Materiali caricati con successo su GitHub!
echo --------------------------------------------------------
echo.
pause