@echo off
chcp 65001 > nul
setlocal enabledelayedexpansion

:INIT_CHECK
set "CONFIG_FILE=%~dp0config.txt"
if not exist "%CONFIG_FILE%" (
    goto RUN_SETUP_ROUTINE
)

:: Read configuration variables dynamically
for /f "usebackq tokens=1,2 delims==" %%A in ("%CONFIG_FILE%") do (
    if "%%A"=="ROOT_DIR" set "ROOT_DIR=%%B"
    if "%%A"=="ENGINE_PATH" set "ENGINE_PATH=%%B"
    if "%%A"=="GAME_MOD_DIR" set "GAME_MOD_DIR=%%B"
)

:: Validate variables are filled
if "%ROOT_DIR%"=="" goto RUN_SETUP_ROUTINE
if "%ENGINE_PATH%"=="" goto RUN_SETUP_ROUTINE
if "%GAME_MOD_DIR%"=="" goto RUN_SETUP_ROUTINE
set "PACK_TXT=%ROOT_DIR%\pack.txt"

:MAIN_MENU
cls
echo ===================================================
echo           THPS 1+2 MOD CONTROL CENTER v1.3
echo ===================================================
echo  Working Dir : %ROOT_DIR%
echo  Using Engine: %ENGINE_PATH%
echo  Live Game   : %GAME_MOD_DIR%
echo ---------------------------------------------------
echo  [1] Pack Mod Pipeline (Step-by-Step)
echo  [2] Unpack/Extract .pak (Menu selection)
echo  [3] Verify/List .pak Contents (Staging vs Game)
echo  [4] Maintenance (Clean up pack.txt / Workspace)
echo  [5] UNINSTALL TOOLKIT (Deletes configuration data)
echo  [6] Exit
echo ===================================================
echo.
set "menu_choice="
set /p menu_choice="Select an option (1-6): "

if "%menu_choice%"=="1" goto OPTION_PACK_STAGE1
if "%menu_choice%"=="2" goto OPTION_UNPACK
if "%menu_choice%"=="3" goto OPTION_VERIFY
if "%menu_choice%"=="4" goto OPTION_CLEAN
if "%menu_choice%"=="5" goto OPTION_SELF_DESTRUCT
if "%menu_choice%"=="6" exit
goto MAIN_MENU

:OPTION_PACK_STAGE1
cls
echo ===================================================
echo              [1] RUNNING AUTOMATIC ASSET SCAN
echo ===================================================
echo  Scanning directories for asset modifications...
echo.

if exist "%PACK_TXT%" del /q "%PACK_TXT%"
set "SCAN_DIR=%ROOT_DIR%\Base"
if not exist "%SCAN_DIR%" mkdir "%SCAN_DIR%"

:: Background scanning loop (Runs instantly when Option 1 is chosen)
for /r "%SCAN_DIR%" %%F in (*.uasset *.uexp *.ubulk) do (
    set "FULL_PATH=%%F"
    set "REL_PATH=!FULL_PATH!"
    for /f "tokens=*" %%A in ("%ROOT_DIR%\") do set "REL_PATH=!REL_PATH:%%A=!"
    set "GAME_PATH=!REL_PATH:\=/!"
    echo "!FULL_PATH!" "../../../!GAME_PATH!" >> "%PACK_TXT%"
)

echo  [DONE] Manifest database synchronized!
echo ---------------------------------------------------
echo.

:OPTION_PACK_STAGE2
echo ===================================================
echo          [1] STAGE 2: UNREALPAK COMPILATION
echo ===================================================
echo  [1] Proceed and compress files into a .pak mod
echo  [2] Cancel and return to Main Menu (Keeps pack.txt)
echo ===================================================
echo.
set "stage2_choice="
set /p stage2_choice="Choose an action (1-2): "
if "%stage2_choice%"=="2" goto MAIN_MENU
if not "%stage2_choice%"=="1" goto OPTION_PACK_STAGE2

cls
echo ===================================================
echo          [1] STAGE 3: RUNNING COMPRESSION
echo ===================================================
echo.
set /p modname="Enter the name for your mod (e.g., GoldGrip): "
if "%modname%"=="" set "modname=THPS_Custom_Mod"
set "PAK_PATH=%ROOT_DIR%\%modname%.pak"
echo.
echo Packing %modname% with standard Unreal compression...
echo ---------------------------------------------------
:: The quotes here are the secret to handling spaces in folders
"%ENGINE_PATH%" "%PAK_PATH%" -create="%PACK_TXT%" -compress
if %ERRORLEVEL% EQU 0 (
    echo ---------------------------------------------------
    echo CONVERT DONE: %modname%.pak is ready!
    echo ---------------------------------------------------
    
    :: Automated deployment integration check
    if /i "%GAME_MOD_DIR%"=="DISABLED" goto BACK_TO_MENU
    if not exist "%GAME_MOD_DIR%" goto BACK_TO_MENU
    
    echo.
    echo ===================================================
    echo          AUTO-DEPLOY TO LIVE GAME FOLDER
    echo ===================================================
    echo  Would you like to instantly copy %modname%.pak 
    echo  over to your active game mod folder?
    echo.
    set "deploy_choice="
    set /p deploy_choice="Deploy asset file? (Y/N): "
    if /i "!deploy_choice!"=="Y" (
        echo.
        copy /y "%PAK_PATH%" "%GAME_MOD_DIR%\" > nul
        if !ERRORLEVEL! EQU 0 (
            echo [SUCCESS] Mod deployed straight to game directory!
        ) else (
            echo [ERROR] Copy operation failed. Check directory permissions.
        )
    )
) else (
    echo [ERROR] UnrealPak execution failed.
)
goto BACK_TO_MENU

:OPTION_UNPACK
cls
echo ===================================================
echo                [2] UNPACK .PAK FILE
echo ===================================================
echo Scanning folder for available .pak files...
echo.
set count=0
for %%P in ("%ROOT_DIR%\*.pak") do (
    set /a count+=1
    set "pak[!count!]=%%P"
    set "pakname[!count!]=%%~nP"
    echo  [!count!] !pakname[%count%]!.pak
)
if %count%==0 (
    echo No .pak files discovered in %ROOT_DIR%
    goto BACK_TO_MENU
)
echo.
set "unpack_choice="
set /p unpack_choice="Select a .pak number to unpack: "
if not defined pak[%unpack_choice%] (
    echo Invalid choice.
    goto BACK_TO_MENU
)
set "TARGET_PAK=!pak[%unpack_choice%]!"
set "TARGET_NAME=!pakname[%unpack_choice%]!"
set "OUTPUT_DIR=%ROOT_DIR%\!TARGET_NAME!_Extracted"
echo.
echo Extracting !TARGET_NAME!.pak to !OUTPUT_DIR!...
echo ---------------------------------------------------
"%ENGINE_PATH%" "!TARGET_PAK!" -Extract "!OUTPUT_DIR!"
if %ERRORLEVEL% EQU 0 (
    echo [DONE] Extraction complete! Opening folder...
    explorer "!OUTPUT_DIR!"
) else (
    echo [ERROR] Unpacking failed.
)
goto BACK_TO_MENU

:OPTION_VERIFY
cls
echo ===================================================
echo              [3] VERIFY / LIST ARCHIVES
echo ===================================================
echo  Choose which target folder you want to inspect:
echo.
echo  [1] Staging Workspace Directory (%ROOT_DIR%)
if /i "%GAME_MOD_DIR%"=="DISABLED" (
    echo  [2] Live Game Mod Folder        (SELECTION SKIPPED)
) else (
    echo  [2] Live Game Mod Folder        (%GAME_MOD_DIR%)
)
echo  [3] Cancel & Return to Main Menu
echo ===================================================
echo.
set "verify_target_choice="
set "TARGET_SCAN_PATH="
set /p verify_target_choice="Select an option (1-3): "

if "%verify_target_choice%"=="3" goto MAIN_MENU
if "%verify_target_choice%"=="1" set "TARGET_SCAN_PATH=%ROOT_DIR%"
if "%verify_target_choice%"=="2" (
    if /i "%GAME_MOD_DIR%"=="DISABLED" (
        echo.
        echo [ERROR] Target path is disabled. Run option [5] to update.
        timeout /t 3 > nul
        goto OPTION_VERIFY
    )
    set "TARGET_SCAN_PATH=%GAME_MOD_DIR%"
)
if not defined TARGET_SCAN_PATH goto OPTION_VERIFY

:VERIFY_FILE_LIST
cls
echo ===================================================
echo  SCANNING FOR .PAK ARCHIVES
echo ===================================================
echo  Target Path: %TARGET_SCAN_PATH%
echo.
set count=0
for %%P in ("%TARGET_SCAN_PATH%\*.pak") do (
    set /a count+=1
    set "pak[!count!]=%%P"
    set "pakname[!count!]=%%~nP"
    echo  [!count!] !pakname[%count%]!.pak
)
if %count%==0 (
    echo [NOTICE] No .pak files discovered in this location.
    goto BACK_TO_MENU
)
echo.
set "verify_choice="
set /p verify_choice="Select a .pak number to view internal structure: "
if not defined pak[%verify_choice%] (
    echo Invalid choice.
    goto BACK_TO_MENU
)
set "TARGET_PAK=!pak[%verify_choice%]!"
cls
echo ===================================================
echo INTERNAL FILE LIST: !pakname[%verify_choice%]!.pak
echo ===================================================
echo.
"%ENGINE_PATH%" "!TARGET_PAK!" -list
echo.
echo --------------------------------------------------
echo ^^^ Review the internal game paths above ^^^
echo --------------------------------------------------
goto BACK_TO_MENU

:OPTION_CLEAN
cls
echo ===================================================
echo                 [4] MAINTENANCE CLEAN
echo ===================================================
echo Cleaning temp files to keep directories pristine...
if exist "%PACK_TXT%" (
    del /q "%PACK_TXT%"
    echo [REMOVED] Deleted local build manifest: pack.txt
) else (
    echo Workspace is already clean! No temporary manifests found.
)
goto BACK_TO_MENU

:OPTION_SELF_DESTRUCT
cls
echo ===================================================
echo              WARNING: UNINSTALLING UTILITY
echo ===================================================
echo  This action will permanently wipe your locked tool settings.
echo  Your active mod folder paths will clear out.
echo.
set /p confirm_del="Type 'Y' to confirm configuration reset, or any other key to abort: "
if /i "%confirm_del%"=="Y" (
    if exist "%CONFIG_FILE%" del /q "%CONFIG_FILE%"
    echo [DONE] Configuration data wiped out. Closing tool.
    timeout /t 3 > nul
    exit
)
goto MAIN_MENU

:BACK_TO_MENU
echo.
echo --------------------------------------------------
echo  Press any key to return to the Main Menu...
echo --------------------------------------------------
pause > nul
goto MAIN_MENU


:: --- EMBEDDED CONFIGURATION SYSTEM (WITH SANITIZATION) ---
:RUN_SETUP_ROUTINE
cls
echo ===================================================
echo         THPS 1+2 TOOLKIT INITIAL SETUP WIZARD
echo ===================================================
echo  Choose how you want to locate your folders:
echo.
echo  [1] Standard CMD Mode (Copy and paste your file paths manually)
echo  [2] PowerShell Mode   (Launch native Windows pop-up dialog boxes)
echo ===================================================
echo.
set /p mode_choice="Select entry mode (1-2): "

if "%mode_choice%"=="1" goto CMD_ROOT
if "%mode_choice%"=="2" goto INTERACTIVE_PS_ROOT
goto RUN_SETUP_ROUTINE

:CMD_ROOT
cls
echo ===================================================
echo        [CMD MODE] SET WORKING MOD STAGE DIRECTORY
echo ===================================================
echo  Paste or type the full path to your active modding folder:
echo.
echo  EXAMPLE: C:\Users\YourName\Documents\THPS_Mod_Workspace
echo.
set /p ROOT_DIR="Workspace Path: "
goto CMD_ENGINE

:CMD_ENGINE
cls
echo ===================================================
echo           [CMD MODE] SET UNREALPAK.EXE LOCATION
echo ===================================================
echo  Paste or type the full path directly to your 'UnrealPak.exe':
echo.
echo  EXAMPLE: C:\Program Files\Epic Games\UE_4.24\Engine\Binaries\Win64\UnrealPak.exe
echo.
set /p ENGINE_PATH="UnrealPak Path: "
goto CMD_GAME_MODS

:CMD_GAME_MODS
cls
echo ===================================================
echo         [CMD MODE] SET ACTUAL GAME MOD DIRECTORY
echo ===================================================
echo  Paste or type the path to the game's actual ~mods folder.
echo  (Or type 'skip' or 'no' to bypass this configuration)
echo.
echo  EXAMPLE: C:\Program Files\Epic Games\TonyHawksProSkater12\GameName\Content\Paks\~mods
echo.
set /p GAME_MOD_DIR="Game Mods Path: "
if /i "%GAME_MOD_DIR%"=="skip" set "GAME_MOD_DIR=DISABLED"
if /i "%GAME_MOD_DIR%"=="no" set "GAME_MOD_DIR=DISABLED"
goto ATTACH_CONFIG_DONE

:INTERACTIVE_PS_ROOT
cls
echo ===================================================
echo     [POWERSHELL MODE] SELECT MOD STAGE DIRECTORY
echo ===================================================
echo  A folder selection window will now open...
echo.
echo  WHAT TO SELECT: Your custom working project directory.
echo  EXAMPLE TARGET: C:\Users\YourName\Documents\THPS_Mod_Workspace
echo.
set "ps_folder_cmd=Add-Type -AssemblyName System.Windows.Forms; $f = New-Object System.Windows.Forms.FolderBrowserDialog; $f.Description = 'Select your Mod Stage Directory'; if($f.ShowDialog() -eq 'OK') { Write-Output $f.SelectedPath }"
set "ROOT_DIR="
for /f "usebackq delims=" %%I in (`powershell -NoProfile -ExecutionPolicy Bypass -Command "%ps_folder_cmd%" 2^>nul`) do set "ROOT_DIR=%%I"
if not defined ROOT_DIR (
    echo [NOTICE] Window popup closed. Enter path manually:
    set /p ROOT_DIR="Workspace Path: "
)
if "%ROOT_DIR%"=="" goto INTERACTIVE_PS_ROOT
goto INTERACTIVE_PS_ENGINE

:INTERACTIVE_PS_ENGINE
cls
echo =================================================================
echo         UNREALPAK REQUIREMENTS ^& DOCUMENTATION GUIDE
echo =================================================================
echo  * VERSION REQUIREMENT: THPS 1+2 runs on Unreal Engine v4.24.
echo  * DEFAULT PATH EXAMPLE: 
echo    C:\Program Files\Epic Games\UE_4.24\Engine\Binaries\Win64\UnrealPak.exe
echo =================================================================
echo.
echo  [READY] Press any key to open the file browser window...
pause > nul
echo.
set "ps_file_cmd=Add-Type -AssemblyName System.Windows.Forms; $f = New-Object System.Windows.Forms.OpenFileDialog; $f.Filter = 'UnrealPak (UnrealPak.exe)|UnrealPak.exe'; if($f.ShowDialog() -eq 'OK') { Write-Output $f.FileName }"
set "ENGINE_PATH="
for /f "usebackq delims=" %%I in (`powershell -NoProfile -ExecutionPolicy Bypass -Command "%ps_file_cmd%" 2^>nul`) do set "ENGINE_PATH=%%I"
if not defined ENGINE_PATH (
    echo [NOTICE] Window popup closed. Enter path manually:
    set /p ENGINE_PATH="UnrealPak Path: "
)
if "%ENGINE_PATH%"=="" goto INTERACTIVE_PS_ENGINE
goto INTERACTIVE_PS_GAME_MODS

:INTERACTIVE_PS_GAME_MODS
cls
echo ===================================================
echo     [POWERSHELL MODE] SELECT GAME MOD DIRECTORY
echo ===================================================
echo  A folder selection window will now open.
echo  Select your live game '~mods' installation directory.
echo.
echo  WHAT TO SELECT: The live game '~mods' installation directory.
echo  EXAMPLE TARGET: C:\Program Files\Epic Games\THPS12\Base\Content\Paks\~mods
echo.
echo  📌 To SKIP this configuration, type 'skip' or 'no' below now.
echo     Otherwise, press Enter to open the folder popup selection...
echo.
set "GAME_MOD_DIR="
set /p GAME_MOD_DIR="Selection or Skip Command: "
if /i "%GAME_MOD_DIR%"=="skip" set "GAME_MOD_DIR=DISABLED" & goto ATTACH_CONFIG_DONE
if /i "%GAME_MOD_DIR%"=="no" set "GAME_MOD_DIR=DISABLED" & goto ATTACH_CONFIG_DONE

echo Opening folder selection window...
set "ps_game_folder_cmd=Add-Type -AssemblyName System.Windows.Forms; $f = New-Object System.Windows.Forms.FolderBrowserDialog; $f.Description = 'Select your Live Game ~mods Directory'; if($f.ShowDialog() -eq 'OK') { Write-Output $f.SelectedPath }"
for /f "usebackq delims=" %%I in (`powershell -NoProfile -ExecutionPolicy Bypass -Command "%ps_game_folder_cmd%" 2^>nul`) do set "GAME_MOD_DIR=%%I"
if not defined GAME_MOD_DIR (
    echo [NOTICE] Window popup closed. Enter path manually:
    set /p GAME_MOD_DIR="Game Mods Path: "
)
if /i "%GAME_MOD_DIR%"=="skip" set "GAME_MOD_DIR=DISABLED" & goto ATTACH_CONFIG_DONE
if /i "%GAME_MOD_DIR%"=="no" set "GAME_MOD_DIR=DISABLED" & goto ATTACH_CONFIG_DONE
if "%GAME_MOD_DIR%"=="" goto INTERACTIVE_PS_GAME_MODS
goto ATTACH_CONFIG_DONE

:ATTACH_CONFIG_DONE
cls
:: 1. Strip quotes completely
set "ROOT_DIR=%ROOT_DIR:"=%"
set "ENGINE_PATH=%ENGINE_PATH:"=%"
set "GAME_MOD_DIR=%GAME_MOD_DIR:"=%"

:: 2. Forcibly strip leading spaces
for /f "tokens=* delims= " %%A in ("%ROOT_DIR%") do set "ROOT_DIR=%%A"
for /f "tokens=* delims= " %%A in ("%ENGINE_PATH%") do set "ENGINE_PATH=%%A"
for /f "tokens=* delims= " %%A in ("%GAME_MOD_DIR%") do set "GAME_MOD_DIR=%%A"

:: 3. Forcibly strip trailing spaces looping backward character-by-character
:STRIP_LOOP1
if "%ROOT_DIR:~-1%"==" " set "ROOT_DIR=%ROOT_DIR:~0,-1%" & goto STRIP_LOOP1

:STRIP_LOOP2
if "%ENGINE_PATH:~-1%"==" " set "ENGINE_PATH=%ENGINE_PATH:~0,-1%" & goto STRIP_LOOP2

:STRIP_LOOP3
if "%GAME_MOD_DIR:~-1%"==" " set "GAME_MOD_DIR=%GAME_MOD_DIR:~0,-1%" & goto STRIP_LOOP3

:: 4. SAFETY AUTO-CORRECT: Append UnrealPak.exe ONLY if it isn't anywhere in the path string yet
echo "%ENGINE_PATH%" | findstr /I "UnrealPak.exe" > nul
if %ERRORLEVEL% NEQ 0 (
    if "%ENGINE_PATH:~-1%"=="\" (
        set "ENGINE_PATH=%ENGINE_PATH%UnrealPak.exe"
    ) else (
        set "ENGINE_PATH=%ENGINE_PATH%\UnrealPak.exe"
    )
)

:: Double check if files actually exist after trimming spaces
if not exist "%ENGINE_PATH%" (
    cls
    echo [ERROR] UnrealPak.exe could not be verified at:
    echo "%ENGINE_PATH%"
    echo.
    echo Please rerun the setup and check the path.
    timeout /t 5 > nul
    goto RUN_SETUP_ROUTINE
)

:: Write clean configuration lines with zero hidden whitespace characters
(
    echo ROOT_DIR=%ROOT_DIR%
    echo ENGINE_PATH=%ENGINE_PATH%
    echo GAME_MOD_DIR=%GAME_MOD_DIR%
) > "%CONFIG_FILE%"

if not exist "%ROOT_DIR%\Base" mkdir "%ROOT_DIR%\Base"

echo ===================================================
echo             CONFIGURATION SETUP COMPLETE
echo ===================================================
echo  [DONE] A 'Base' folder has been automatically verified/created.
echo         Place your custom assets inside it so the tool can pack them!
echo.
echo  [DONE] Sanitized paths locked into config.txt.
echo.
echo ---------------------------------------------------
echo  Toolkit initialized successfully! 
echo  Press any key to load the main menu...
echo ---------------------------------------------------
pause > nul
goto INIT_CHECK
