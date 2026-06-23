@echo off
chcp 65001 > nul
setlocal enabledelayedexpansion

:: =================================================================
:: CORE TOOLKIT GLOBAL INITIALIZATION
:: =================================================================
set "CONFIG_FILE=%~dp0config.txt"
if not defined ACTIVE_PROFILE set "ACTIVE_PROFILE=Decks"

:INIT_CHECK
if not exist "%CONFIG_FILE%" goto RUN_SETUP_ROUTINE
for /f "usebackq delims=" %%I in ("%CONFIG_FILE%") do set "%%I"

if "%ROOT_DIR%"=="" goto RUN_SETUP_ROUTINE
if "%EDITOR_PATH%"=="" goto RUN_SETUP_ROUTINE
if "%ENGINE_PATH%"=="" goto RUN_SETUP_ROUTINE
if "%COOKED_DIR%"=="" goto RUN_SETUP_ROUTINE
if "%GAME_MOD_DIR%"=="" goto RUN_SETUP_ROUTINE

set "PROFILE_BASE_DIR=%ROOT_DIR%\Projects\%ACTIVE_PROFILE%\Base"
set "PACK_TXT=%ROOT_DIR%\pack.txt"

:INIT_CHECK
cls
echo =================================================================
echo                  VERIFY WORKING WORKSPACE PATHS
echo =================================================================
echo   [Workspace]   %ROOT_DIR%
echo   [Editor EXE]  %EDITOR_PATH%
echo   [Engine Pak]  %ENGINE_PATH%
echo   [Cooked Dir]  %COOKED_DIR%
echo   [Game mod]    %GAME_MOD_DIR%
echo   [Shortcut]    %GAME_SHORTCUT%
echo =================================================================
echo   [1] CONFIRM: Launch Mod Control Center Menu
echo   [2] QUICK EDIT: Modify a single path definition
echo   [3] RE-SETUP: Wipe all paths and rerun full setup
echo =================================================================
echo.
set "init_choice="
set /p init_choice="Select an option (1-3): "

if "%init_choice%"=="1" goto MAIN_MENU
if "%init_choice%"=="2" goto QUICK_EDIT_MENU
if "%init_choice%"=="3" (del /q "%CONFIG_FILE%" 2>nul & goto RUN_SETUP_ROUTINE)
goto INIT_CHECK

:QUICK_EDIT_MENU
cls
echo =================================================================
echo                       QUICK PATH EDIT ROUTINE
echo =================================================================
echo    [1] Edit Workspace Path
echo    [2] Edit Editor Executable Path
echo    [3] Edit Cooked Content Directory
echo    [4] Edit Game Mods Folder
echo    [5] Edit Steam Launch Shortcut
echo    [B] Back to Verification Screen
echo =================================================================
echo.
set "edit_choice="
set /p "edit_choice=Which path would you like to update? "

:: Set the flag to 1 so the script knows to save immediately afterward
if "%edit_choice%"=="1" set "quick_edit=1" & goto INTERACTIVE_PS_ROOT
if "%edit_choice%"=="2" set "quick_edit=1" & goto INTERACTIVE_PS_ENGINE
if "%edit_choice%"=="3" set "quick_edit=1" & goto INTERACTIVE_PS_COOKED
if "%edit_choice%"=="4" set "quick_edit=1" & goto INTERACTIVE_PS_GAME_MODS
if "%edit_choice%"=="5" set "quick_edit=1" & goto INTERACTIVE_PS_SHORTCUT
if /i "%edit_choice%"=="B" set "quick_edit=" & goto INIT_CHECK
goto QUICK_EDIT_MENU

:: =================================================================
:: MAIN SYSTEM MENU
:: =================================================================
:MAIN_MENU
cls
echo =================================================================
echo                 THPS 1+2 MOD CONTROL CENTER v1.4
echo =================================================================
echo   Workspace Dir:  %ROOT_DIR%
echo   Active Target Profile: [ %ACTIVE_PROFILE% ]
echo.
echo   Unreal Projects Directory  
echo   %COOKED_DIR%
echo.
echo   THPS 1+2 Mods: %GAME_MOD_DIR%
echo =================================================================
echo   [1] Project Profile ^& Asset Ingestion Sub-Menu
echo   [2] .PAK File Assembly Utility Pipeline
echo   [3] System Maintenance ^& Workspace Directories
echo   [4] Play game (Launch with or without mods toggle)
echo   [X] Exit Utility safely
echo =================================================================
echo.
set "main_choice="
set /p main_choice="Select system operation: "
if "%main_choice%"=="1" goto MENU_PROFILES
if "%main_choice%"=="2" goto MENU_PAK_PIPELINE
if "%main_choice%"=="3" goto MENU_MAINTENANCE
if "%main_choice%"=="4" goto MENU_LAUNCH_GAME
if /i "%main_choice%"=="X" exit
goto MAIN_MENU

:: ===================================================
:: [1] PROJECT PROFILE & ASSET INGESTION SUB-MENU
:: ===================================================
:MENU_PROFILES
cls
echo =================================================================
echo             [1] PROJECT PROFILE MANAGEMENT
echo =================================================================
echo   Active Profile Target: [ %ACTIVE_PROFILE% ]
echo   Target Local Path:     %PROFILE_BASE_DIR%
echo   Active Projects Path   %COOKED_DIR%
echo -----------------------------------------------------------------
echo   [1] Switch Profile Slot (Toggle Decks / Logos)
echo   [2] Create a Brand New Custom Profile Name
echo   [3] IMPORT: Pull Fresh Files from UE4 Cooked Path
echo   [4] DELETE: Remove an Old Custom Profile Folder
echo   [5] Back to Main Menu
echo =================================================================
echo.
set "sub_choice="
set /p sub_choice="Select an option: "
if /i "%sub_choice%"=="1" goto TOGGLE_PROFILE
if /i "%sub_choice%"=="2" goto CREATE_PROFILE
if /i "%sub_choice%"=="3" goto MENU_PROFILE_IMPORT
if /i "%sub_choice%"=="4" goto DELETE_PROFILE
if /i "%sub_choice%"=="5" goto MAIN_MENU
goto MENU_PROFILES

:TOGGLE_PROFILE
if /i "%ACTIVE_PROFILE%"=="Decks" (set "ACTIVE_PROFILE=Logos") else (set "ACTIVE_PROFILE=Decks")
set "PROFILE_BASE_DIR=%ROOT_DIR%\Projects\!ACTIVE_PROFILE!\Base"
if not exist "!PROFILE_BASE_DIR!" mkdir "!PROFILE_BASE_DIR!"
goto MENU_PROFILES

:CREATE_PROFILE
set /p new_prof="Enter new unique profile folder name: "
if not "!new_prof!"=="" (set "ACTIVE_PROFILE=!new_prof!" & set "PROFILE_BASE_DIR=%ROOT_DIR%\Projects\!ACTIVE_PROFILE!\Base" & if not exist "!PROFILE_BASE_DIR!" mkdir "!PROFILE_BASE_DIR!")
goto MENU_PROFILES

:: =================================================================
:: PROFILE MANAGEMENT: IMPORT & PREVIEW ROUTINE
:: =================================================================
:MENU_PROFILE_IMPORT
cls
echo =================================================================
echo                 IMPORTING COOKED UNREAL ASSETS
echo =================================================================
echo  Syncing Content assets into Profile: [ %ACTIVE_PROFILE% ]...
echo  Source: %COOKED_DIR%
echo  Dest:   %ACTIVE_PROFILE%
echo -----------------------------------------------------------------

:: Safety check for Source Directory
if not exist "%COOKED_DIR%" (
    echo  [ERROR] Cooked source path not found!
    echo  Please verify your path in Settings.
    pause
    goto :MENU_PROFILES
)

:: Create destination directory if it doesn't exist
if not exist "%PROFILE_DIR%\%ACTIVE_PROFILE%\Base" mkdir "%PROFILE_DIR%\%ACTIVE_PROFILE%\Base"

:: Run the sync copy operation quietly but efficiently
xcopy "%COOKED_DIR%\*" "%PROFILE_BASE_DIR%\" /E /I /Y /Q >nul

echo.
echo  [DONE] Cooking sync completed successfully
echo -----------------------------------------------------------------
echo  Press [1] to Preview raw files in project folder
echo  Press [2] to Run UnrealPak List Engine on a target .pak
echo  Press [3] to return to Profile Menu...
echo -----------------------------------------------------------------
set /p "POST_IMPORT_CHOICE=>>> Selection: "

if "%POST_IMPORT_CHOICE%"=="1" goto PREVIEW_RAW_FILES
if "%POST_IMPORT_CHOICE%"=="2" goto PREVIEW_PAK_ENGINE
if "%POST_IMPORT_CHOICE%"=="3" goto MENU_PROFILES
goto MENU_PROFILES


:: -----------------------------------------------------------------
:: PREVIEW OPTION 1: RAW FILE ENGINE (LOOSE ASSETS)
:: -----------------------------------------------------------------
:PREVIEW_RAW_FILES
cls
echo =================================================================
echo    PROJECT VIEW ENGINE: INTERNAL RAW MOD PATHS
echo =================================================================
echo  Target: %PROFILE_BASE_DIR%
echo -----------------------------------------------------------------
echo.

:: Jump into the actual active profile directory
pushd "%PROFILE_BASE_DIR%"
:: Loop through files and apply custom clean tagging based on extensions
for /R %%F in (*) do (
    set "FILE_EXT=%%~xF"
    set "FILE_PATH=%%~pF%%~nxF"
    
    :: Clean up double slashes or local pathing noise for display
    setlocal enabledelayedexpansion
    set "DISPLAY_PATH=!FILE_PATH!"
    
    if /I "!FILE_EXT!"==".uasset" (
        echo  [ASSET] -^> !DISPLAY_PATH!
    ) else if /I "!FILE_EXT!"==".uexp" (
        echo  [MODEL] -^> !DISPLAY_PATH!
    ) else if /I "!FILE_EXT!"==".ubulk" (
        echo  [TEXTR] -^> !DISPLAY_PATH!
    ) else (
        echo  [FILE]  -^> !DISPLAY_PATH!
    )
    endlocal
)
popd

echo.
echo -----------------------------------------------------------------
pause
goto MENU_PROFILE_IMPORT


:: -----------------------------------------------------------------
:: PREVIEW OPTION 2: UNREALPAK LIST ENGINE
:: -----------------------------------------------------------------
:PREVIEW_PAK_ENGINE
cls
echo =================================================================
echo    RUNNING UNREALPAK LIST ENGINE ON TARGET
echo =================================================================
echo.
echo  [1] Scan standard Profile Output Pak
echo  [2] Drag-and-Drop a specific custom .pak file to scan
echo.
set /p "PAK_SCAN_CHOICE=>>> Selection: "

set "TARGET_PAK_PATH="
if "%PAK_SCAN_CHOICE%"=="1" set "TARGET_PAK_PATH=%PROFILE_DIR%\%ACTIVE_PROFILE%\%ACTIVE_PROFILE%.pak"
if "%PAK_SCAN_CHOICE%"=="2" (
    echo.
    set /p "TARGET_PAK_PATH=>>> Drag ^& Drop .pak file here and press Enter: "
)

:: Strip quotes if user dragged and dropped
set "TARGET_PAK_PATH=%TARGET_PAK_PATH:"=%"

if not exist "%TARGET_PAK_PATH%" (
    echo.
    echo  [ERROR] Target .pak file not found at: "%TARGET_PAK_PATH%"
    pause
    goto :MENU_PROFILE_IMPORT
)

echo.
echo =================================================================
echo  EXECUTING: UnrealPak.exe -list "%TARGET_PAK_PATH%"
echo =================================================================
echo.

:: Execute UnrealPak wrapper log call directly to screen
"%UNREALPAK_EXE%" "%TARGET_PAK_PATH%" -list

echo.
echo =================================================================
echo    PAK SCROLL COMPLETE
echo =================================================================
pause
goto :MENU_PROFILE_IMPORT

:DELETE_PROFILE
cls
echo =================================================================
echo                     [4] DELETE PROFILE FOLDER
echo =================================================================
echo   Available Custom Projects:
echo.
set count=0
for /d %%D in ("%ROOT_DIR%\Projects\*") do (
    set "folder_name=%%~nD"
    if /i not "!folder_name!"=="Decks" (
        if /i not "!folder_name!"=="Logos" (
            if /i not "!folder_name!"=="%ACTIVE_PROFILE%" (
                set /a count+=1
                set "del_prof[!count!]=%%D"
                set "del_name[!count!]=!folder_name!"
                echo   [!count!] !folder_name!
            )
        )
    )
)
if !count!==0 (
    echo   No eligible custom profile folders found to delete.
    echo   (Note: You cannot delete your currently active profile!)
    goto BACK_TO_PROFILE_MENU
)
echo.
set "del_choice="
set /p del_choice="Select a profile number to permanently DELETE: "
if not defined del_prof[%del_choice%] (
    echo   Invalid choice.
    goto BACK_TO_PROFILE_MENU
)
set "TARGET_DEL_DIR=!del_prof[%del_choice%]!"
set "TARGET_DEL_NAME=!del_name[%del_choice%]!"
echo.
echo -----------------------------------------------------------------
echo   ⚠️  WARNING: You are about to permanently delete "!TARGET_DEL_NAME!"
echo -----------------------------------------------------------------
set "confirm_del="
set /p confirm_del="Type 'DELETE' to confirm absolute wipeout: "
if "!confirm_del!"=="DELETE" (
    rmdir /s /q "!TARGET_DEL_DIR!"
    echo.
    echo   [SUCCESS] Profile "!TARGET_DEL_NAME!" removed completely.
) else (
    echo.
    echo   [ABORTED] Deletion cancelled safely.
)
goto BACK_TO_PROFILE_MENU

:: ===================================================
:: [2] .PAK FILE PIPELINE SUB-MENU
:: ===================================================
:MENU_PAK_PIPELINE
cls
:: ===================================================
:: [2] .PAK FILE PIPELINE SUB-MENU (UPDATED WITH QUICK-TOGGLE)
:: ===================================================
:MENU_PAK_PIPELINE
cls
echo =================================================================
echo            [2] .PAK FILE UTILITY PIPELINE
echo =================================================================
echo   Active Profile Target: [ %ACTIVE_PROFILE% ]
echo -----------------------------------------------------------------
echo   [1] TOGGLE PROFILE SLOT (Switch Decks / Logos)
echo.
echo   [2] Pack Current Profile (Step-by-Step Scan ^& Pack)
echo   [3] Unpack/Extract .pak (Menu Selection)
echo   [4] Verify/List .pak Contents (Staging vs Game)
echo -----------------------------------------------------------------
echo   [B] Back to Main Menu
echo =================================================================
echo.
set "sub_choice="
set /p sub_choice="Select an option: "

if "%sub_choice%"=="1" goto PIPELINE_TOGGLE_PROFILE
if "%sub_choice%"=="2" goto OPTION_PACK_STAGE1
if "%sub_choice%"=="3" goto OPTION_UNPACK
if "%sub_choice%"=="4" goto OPTION_VERIFY
if /i "%sub_choice%"=="B" goto MAIN_MENU
goto MENU_PAK_PIPELINE

:PIPELINE_TOGGLE_PROFILE
if /i "%ACTIVE_PROFILE%"=="Decks" (set "ACTIVE_PROFILE=Logos") else (set "ACTIVE_PROFILE=Decks")
set "PROFILE_BASE_DIR=%ROOT_DIR%\Projects\!ACTIVE_PROFILE!\Base"
if not exist "!PROFILE_BASE_DIR!" mkdir "!PROFILE_BASE_DIR!"
goto MENU_PAK_PIPELINE

:OPTION_PACK_STAGE1
cls
echo =================================================================
echo                [1] RUNNING AUTOMATIC ASSET SCAN
echo =================================================================
echo   Scanning current profile directory [%ACTIVE_PROFILE%]...
echo.

if exist "%PACK_TXT%" del /q "%PACK_TXT%"

:: Cleaned up inline PowerShell execution
powershell -NoProfile -ExecutionPolicy Bypass -Command "$b='%PROFILE_BASE_DIR%'.TrimEnd('\'); if(Test-Path $b){$fs=Get-ChildItem -Path $b -Recurse -Include *.uasset,*.uexp,*.ubulk; foreach($f in $fs){$fp=$f.FullName; $rp=$fp.Substring($b.Length+1).Replace('\','/'); $l='\"'+$fp+'\" \"../../../Base/Content/'+$rp+'\"'; Out-File -FilePath '%PACK_TXT%' -InputObject $l -Append -Encoding ascii}}"

:: Verify the file was generated successfully
if not exist "%PACK_TXT%" (
    echo   ---------------------------------------------------------------
    echo   ⚠️  Convert is fine! Please switch to your appropriate profile
    echo   ---------------------------------------------------------------
    echo   %PROFILE_BASE_DIR%
    echo.
    echo   Make sure your cooked assets are placed inside that folder!
    goto BACK_TO_PAK_MENU
)

echo.
echo   [DONE] Manifest database synchronized safely!
echo   (Verified pack.txt layout inside: %ROOT_DIR%)
echo -----------------------------------------------------------------
echo.
goto OPTION_PACK_STAGE2

:OPTION_PACK_STAGE2
echo =================================================================
echo                [1] STAGE 2: UNREALPAK COMPILATION
echo =================================================================
echo   [1] Proceed and compress files into a .pak mod
echo   [2] Cancel and return to Pipeline Menu
echo =================================================================
echo.
set "stage2_choice="
set /p stage2_choice="Choose an action (1-2): "
if "%stage2_choice%"=="2" goto MENU_PAK_PIPELINE
if not "%stage2_choice%"=="1" goto OPTION_PACK_STAGE2

cls
echo =================================================================
echo                 [1] STAGE 3: RUNNING COMPRESSION
echo =================================================================
echo.
:: Smart Name Suggester: Pre-fills suggestion based on active target profile
set "SUGGESTED_NAME=THPS_%ACTIVE_PROFILE%_Mod"

echo   💡 Suggested name based on your active profile: %SUGGESTED_NAME%
set "modname="
set /p modname="Enter mod name [Press Enter for '%SUGGESTED_NAME%']: "
if "%modname%"=="" set "modname=%SUGGESTED_NAME%"

set "PAK_PATH=%ROOT_DIR%\%modname%.pak"
echo.
echo   Packing %modname% with standard Unreal compression...
echo -----------------------------------------------------------------
"%ENGINE_PATH%" "%PAK_PATH%" -create="%PACK_TXT%" -compress
if %ERRORLEVEL% EQU 0 (
    echo -----------------------------------------------------------------
    echo   CONVERT DONE: %modname%.pak is ready!
    echo -----------------------------------------------------------------
    if /i "%GAME_MOD_DIR%"=="DISABLED" goto BACK_TO_PAK_MENU
    if not exist "%GAME_MOD_DIR%" goto BACK_TO_PAK_MENU
    echo.
    echo =================================================================
    echo                AUTO-DEPLOY TO LIVE GAME FOLDER
    echo =================================================================
    echo   Would you like to instantly copy %modname%.pak 
    echo   over to your active game mod folder?
    echo.
    set "deploy_choice="
    set /p deploy_choice="Deploy asset file? (Y/N): "
    if /i "!deploy_choice!"=="Y" (
        echo.
        copy /y "%PAK_PATH%" "%GAME_MOD_DIR%\" > nul
        if !ERRORLEVEL! EQU 0 (
            echo   [SUCCESS] Mod deployed straight to game directory!
        ) else (
            echo   [ERROR] Copy operation failed. Check directory permissions.
        )
    )
) else (
    echo   [ERROR] UnrealPak execution failed.
)
goto BACK_TO_PAK_MENU

:OPTION_UNPACK
cls
echo =================================================================
echo                         [2] UNPACK .PAK FILE
echo =================================================================
echo   Scanning folder for available .pak files...
echo.
set count=0
for %%P in ("%ROOT_DIR%\*.pak") do (
    set /a count+=1
    set "pak[!count!]=%%P"
    set "pakname[!count!]=%%~nP"
    
    :: FIX: Use the loop token %%~nP directly for the echo display!
    echo   [!count!] %%~nP.pak
)
if %count%==0 (
    echo   No .pak files discovered in %ROOT_DIR%
    goto BACK_TO_PAK_MENU
)
echo.
set "unpack_choice="
set /p unpack_choice="Select a .pak number to unpack: "
if not defined pak[%unpack_choice%] (
    echo   Invalid choice.
    goto BACK_TO_PAK_MENU
)
for %%I in (!unpack_choice!) do (
    set "TARGET_PAK=!pak[%%I]!"
    set "TARGET_NAME=!pakname[%%I]!"
)
set "OUTPUT_DIR=%ROOT_DIR%\!TARGET_NAME!_Extracted"
echo.
echo   Extraction running...
echo -----------------------------------------------------------------
"%ENGINE_PATH%" "!TARGET_PAK!" -Extract "!OUTPUT_DIR!"
if %ERRORLEVEL% EQU 0 (
    echo -----------------------------------------------------------------
    echo   [DONE] Extraction complete! Opening folder...
    explorer "!OUTPUT_DIR!"
) else (
    echo   [ERROR] Unpacking failed.
)
goto BACK_TO_PAK_MENU

:OPTION_VERIFY
cls
echo =================================================================
echo                        [3] VERIFY / LIST ARCHIVES
echo =================================================================
echo   Choose which target folder you want to inspect:
echo.
echo   [1] Staging Workspace Directory (%ROOT_DIR%)
if /i "%GAME_MOD_DIR%"=="DISABLED" (
    echo   [2] Live Game Mod Folder        (SELECTION SKIPPED)
) else (
    echo   [2] Live Game Mod Folder        (%GAME_MOD_DIR%)
)
echo.
echo   [3] Cancel ^& Return to Pipeline Menu
echo =================================================================
echo.
set "verify_target_choice="
set "TARGET_SCAN_PATH="
set /p verify_target_choice="Select an option (1-3): "

if "%verify_target_choice%"=="3" goto MENU_PAK_PIPELINE
if "%verify_target_choice%"=="1" set "TARGET_SCAN_PATH=%ROOT_DIR%"
if "%verify_target_choice%"=="2" (
    if /i "%GAME_MOD_DIR%"=="DISABLED" (
        echo.
        echo   [ERROR] Target path is disabled.
        timeout /t 2 > nul
        goto OPTION_VERIFY
    )
    set "TARGET_SCAN_PATH=%GAME_MOD_DIR%"
)
if not defined TARGET_SCAN_PATH goto OPTION_VERIFY

:VERIFY_FILE_LIST
cls
echo =================================================================
echo                        SCANNING FOR .PAK ARCHIVES
echo =================================================================
echo.

set count=0
for %%P in ("%TARGET_SCAN_PATH%\*.pak") do (
    set /a count+=1
    set "pak[!count!]=%%P"
    echo    [!count!] %%~nP.pak
)

if %count%==0 (
    echo    [NOTICE] No .pak files discovered in this location.
    goto BACK_TO_PAK_MENU
)

echo.
set "verify_choice="
set /p verify_choice="Select a .pak number to view internal structure: "

if not defined verify_choice goto BACK_TO_PAK_MENU

:: This clean loop handles the delayed expansion perfectly, even with folder spaces
for %%I in (!verify_choice!) do set "TARGET_PAK=!pak[%%I]!"

cls
echo =================================================================
echo    RUNNING UNREALPAK LIST ENGINE ON TARGET:
echo    "%TARGET_PAK%"
echo =================================================================
echo.

:: 👇 THE SAFETY CHECK: Stop the execution if the engine path is disabled
if /i "%ENGINE_PATH%"=="DISABLED" goto ERROR_NO_UNREALPAK
if /i "%ENGINE_PATH%"=="" goto ERROR_NO_UNREALPAK

"%ENGINE_PATH%" "%TARGET_PAK%" -list
goto BACK_TO_PAK_MENU

:ERROR_NO_UNREALPAK
cls
echo =================================================================
echo             [ERROR] UNREALPAK DEPENDENCY MISSING
echo =================================================================
echo   This specific feature requires UnrealPak.exe to extract and
echo   read the compressed file structure of your mods.
echo.
echo   Because you chose to 'skip' the Unreal Engine setup earlier,
echo   this tool is currently unavailable.
echo.
echo   👉 To fix this: Go to 'QUICK EDIT' on the welcome screen 
echo      and locate your UE4Editor.exe to enable this feature.
echo =================================================================
echo.
pause
goto BACK_TO_PAK_MENU

:: ===================================================
:: [3] SYSTEM MAINTENANCE SUB-MENU
:: ===================================================
:MENU_MAINTENANCE
cls
echo =================================================================
echo             [3] SYSTEM MAINTENANCE ^& QUICK LINKS
echo =================================================================
echo    [1] Maintenance (Clean up pack.txt build manifests)
echo    [2] Open Workspace Folder      (%ROOT_DIR%)
echo    [3] Open Live Game Mod Folder  (%GAME_MOD_DIR%)
echo    [4] Launch Unreal Engine Editor (.EXE)
echo    [5] UNINSTALL TOOLKIT (Deletes configuration data)
echo -----------------------------------------------------------------
echo    [B] Back to Main Menu
echo =================================================================
echo.
set "sub_choice="
set /p sub_choice="Select an option: "
if "%sub_choice%"=="1" goto OPTION_CLEAN
if "%sub_choice%"=="2" (
    if exist "%ROOT_DIR%" (explorer "%ROOT_DIR%") else (echo    [ERROR] Folder not found. & timeout /t 2 > nul)
    goto MENU_MAINTENANCE
)
if "%sub_choice%"=="3" (
    if /i "%GAME_MOD_DIR%"=="DISABLED" (
        echo    [NOTICE] Live game mod path is currently disabled.
        timeout /t 2 > nul
    ) else if exist "%GAME_MOD_DIR%" (
        explorer "%GAME_MOD_DIR%"
    ) else (
        echo    [ERROR] Folder not found.
        timeout /t 2 > nul
    )
    goto MENU_MAINTENANCE
)
if "%sub_choice%"=="4" (
    cls
    echo =================================================================
    echo                  LAUNCHING UNREAL ENGINE EDITOR
    echo =================================================================
    echo.
    if /i "%EDITOR_PATH%"=="DISABLED" goto MAINTENANCE_NO_ENGINE
    if /i "%EDITOR_PATH%"=="" goto MAINTENANCE_NO_ENGINE
    
    if exist "%EDITOR_PATH%" (
        echo    [FOUND] Starting Unreal Engine Editor...
        start "" "%EDITOR_PATH%"
        timeout /t 2 > nul
    ) else (
        :MAINTENANCE_NO_ENGINE
        echo    [ERROR] Unreal Engine Editor executable path not found or disabled.
        echo    Go to Quick Edit from the Welcome screen to configure it!
        timeout /t 4 > nul
    )
    goto MENU_MAINTENANCE
)
if "%sub_choice%"=="5" goto OPTION_SELF_DESTRUCT
if /i "%sub_choice%"=="B" goto MAIN_MENU
goto MENU_MAINTENANCE

:OPTION_CLEAN
cls
echo =================================================================
echo                        [3] MAINTENANCE CLEAN
echo =================================================================
echo.
if exist "%PACK_TXT%" (
    del /q "%PACK_TXT%"
    echo   [REMOVED] Deleted local build manifest: pack.txt
) else (
    echo   Workspace is already clean!
)
goto BACK_TO_MAINTENANCE_MENU

:OPTION_SELF_DESTRUCT
cls
echo =================================================================
echo                  WARNING: UNINSTALLING UTILITY
echo =================================================================
echo.
echo   This will completely wipe out your configuration text paths.
echo.
set /p confirm_del="Type 'Y' to confirm configuration reset, or any other key to abort: "
if /i "%confirm_del%"=="Y" (
    if exist "%CONFIG_FILE%" del /q "%CONFIG_FILE%"
    echo.
    echo   [DONE] Configuration data wiped out. Closing tool.
    timeout /t 2 > nul
    exit
)
goto MENU_MAINTENANCE

:BACK_TO_PAK_MENU
echo.
set /p pause_dummy="Press Enter to return to Pipeline Menu..."
goto MENU_PAK_PIPELINE

:BACK_TO_PROFILE_MENU
echo.
set /p pause_dummy="Press Enter to return to Profile Menu..."
goto MENU_PROFILES

:BACK_TO_MAINTENANCE_MENU
echo.
set /p pause_dummy="Press Enter to return to Maintenance Menu..."
goto MENU_MAINTENANCE

:: ===================================================
:: INITIALIZATION (Setup Routine)
:: ===================================================
:RUN_SETUP_ROUTINE
cls
echo =================================================================
echo               THPS 1+2 TOOLKIT INITIAL SETUP WIZARD v1.4
echo =================================================================
echo   [1] Standard CMD Mode (Copy and paste file paths manually)
echo.
echo   [2] PowerShell Mode   (Launch Windows pop-up dialog boxes)
echo =================================================================
echo.
set "mode_choice="
set /p "mode_choice=Select entry mode (1-2): "
if "%mode_choice%"=="1" goto CMD_ROOT
if "%mode_choice%"=="2" goto INTERACTIVE_PS_ROOT
goto RUN_SETUP_ROUTINE

:CMD_ROOT
cls
echo =================================================================
echo                      [CMD MODE] SET WORKSPACE
echo =================================================================
set /p "ROOT_DIR=Workspace Path (Or type 'close' to exit): "
if /i "%ROOT_DIR%"=="close" goto EMER_SAVE_AND_EXIT
goto INTERACTIVE_CMD_ENGINE

:INTERACTIVE_CMD_ENGINE
cls
echo =================================================================
echo              [CMD MODE] SELECT UNREAL EDITOR EXE
echo =================================================================
echo   📌 This program is used to convert and pack your mods.
echo.
echo   👉 Paste/Type your path and press ENTER to save...
echo   👉 Type 'I' for critical info on why you need this tool.
echo   👉 Type 'D' if you need step-by-step help downloading Unreal.
echo   👉 Type 'skip' to bypass locating the engine.
echo =================================================================
echo.
set "engine_choice="
set /p "engine_choice=Selection or Command: "

if not defined engine_choice goto INTERACTIVE_CMD_ENGINE
if /i "%engine_choice%"=="I" goto ENGINE_INFO_SCREEN
if /i "%engine_choice%"=="D" goto GUIDE_DOWNLOAD_UNREAL
if /i "%engine_choice%"=="skip" set "EDITOR_PATH=DISABLED" & set "ENGINE_PATH=DISABLED" & goto ENGINE_REDIRECT

:: Input is treated as the direct path if it isn't a command key
set "EDITOR_PATH=%engine_choice%"

:ENGINE_REDIRECT
if "%EDITOR_PATH%"=="DISABLED" goto ENGINE_SKIP_CALC
set "EDITOR_PATH=%EDITOR_PATH:"=%"

:: Quick validation check to catch typos
if not exist "%EDITOR_PATH%" (
    cls
    echo =================================================================
    echo                      [ERROR] FILE NOT FOUND
    echo =================================================================
    echo   The path you entered does not exist or is invalid:
    echo   "%EDITOR_PATH%"
    echo.
    pause
    goto INTERACTIVE_CMD_ENGINE
)

for %%A in ("%EDITOR_PATH%") do set "ENGINE_BIN_DIR=%%~dpA"
set "ENGINE_PATH=%ENGINE_BIN_DIR%UnrealPak.exe"

:ENGINE_SKIP_CALC
if "%quick_edit%"=="1" set "quick_edit=" & goto WRITE_CONFIG_FILE
goto INTERACTIVE_CMD_COOKED


:: =================================================================
:: CMD AUTOMATION: DOWNLOAD DEPENDENCIES & RUN EXE
:: =================================================================
:CMD_COOKED
cls
echo =================================================================
echo                [CMD MODE] AUTOMATION ENGINE
echo =================================================================
echo  Target Binaries Dir: %ENGINE_BIN_DIR%
echo  Target Editor Path:  %EDITOR_PATH%
echo -----------------------------------------------------------------

:: 1. CHECK & DOWNLOAD DEPENDENCY IN CMD
if not exist "%ENGINE_PATH%" (
    echo.
    echo  [MISSING] UnrealPak.exe was not found in your Win64 folder.
    echo  Attempting background web retrieval via curl...
    echo.
    
    :: SET YOUR DOWNLOAD URL HERE (Example placeholder URL)
    set "DOWNLOAD_URL=https://example.com/downloads/UnrealPak.exe"
    
    :: Use native curl to fetch the file directly to their engine directory
    curl -L -o "%ENGINE_PATH%" "!DOWNLOAD_URL!"
    
    :: Verify if the download actually completed successfully
    if exist "%ENGINE_PATH%" (
        echo.
        echo  [SUCCESS] UnrealPak.exe downloaded and placed in asset directory!
    ) else (
        echo.
        echo  [ERROR] Background download failed. Please place UnrealPak.exe 
        echo          manually inside: %ENGINE_BIN_DIR%
        pause
    )
) else (
    echo  [FOUND] UnrealPak.exe dependency verified.
)

echo -----------------------------------------------------------------
echo  [1] Launch Unreal Editor Executable right now
echo  [2] Skip Launch and save settings
echo -----------------------------------------------------------------
set /p "LAUNCH_CHOICE=>>> Selection: "

if "%LAUNCH_CHOICE%"=="1" (
    echo.
    echo  Launching Editor process in decoupled background space...
    :: 'start' prevents the CMD window from freezing while the editor runs
    start "" "%EDITOR_PATH%"
)

echo.
echo  Settings committed to memory. Returning to Main Toolkit Menu...
pause
goto :MENU_MAIN

:INTERACTIVE_CMD_COOKED
cls
echo =================================================================
echo            [CMD MODE] SELECT UE4 COOKED CONTENT DIR
echo =================================================================
echo   📌 IMPORTANT: Make sure you have actually started Unreal Engine 
echo      and successfully "cooked" your mod before continuing!
echo.
echo   👉 Paste/Type your path and press ENTER to save...
echo   👉 Type 'U' to launch Unreal Editor right now to cook files!
echo   👉 Type 'skip' or 'no' to completely bypass this setup.
echo   👉 Type 'close' to save current progress and exit the script.
echo =================================================================
echo.
set "COOKED_DIR="
set /p COOKED_DIR="Selection or Command: "

if not defined COOKED_DIR goto INTERACTIVE_CMD_COOKED
if /i "%COOKED_DIR%"=="U" goto LAUNCH_UNREAL_TO_COOK
if /i "%COOKED_DIR%"=="skip" set "COOKED_DIR=DISABLED" & goto COOKED_REDIRECT
if /i "%COOKED_DIR%"=="no" set "COOKED_DIR=DISABLED" & goto COOKED_REDIRECT
if /i "%COOKED_DIR%"=="close" goto EMER_SAVE_AND_EXIT

set "COOKED_DIR=%COOKED_DIR:"=%"

:: Validate directory if they didn't skip it
if not "%COOKED_DIR%"=="DISABLED" (
    if not exist "%COOKED_DIR%" (
        cls
        echo =================================================================
        echo                      [ERROR] FOLDER NOT FOUND
        echo =================================================================
        echo   The directory path you entered does not exist:
        echo   "%COOKED_DIR%"
        echo.
        pause
        goto INTERACTIVE_CMD_COOKED
    )
)

:COOKED_REDIRECT
if "%quick_edit%"=="1" set "quick_edit=" & goto WRITE_CONFIG_FILE
goto CMD_GAME_MODS

:CMD_GAME_MODS
cls
echo =================================================================
echo                  [CMD MODE] SET GAME MODS PATH
echo =================================================================
set /p "GAME_MOD_DIR=Game Mods Path (Type 'skip' to bypass, or 'close' to exit): "
if /i "%GAME_MOD_DIR%"=="skip" set "GAME_MOD_DIR=DISABLED"
if /i "%GAME_MOD_DIR%"=="no" set "GAME_MOD_DIR=DISABLED"
if /i "%GAME_MOD_DIR%"=="close" goto EMER_SAVE_AND_EXIT
goto CMD_STEAM_SHORTCUT

:CMD_STEAM_SHORTCUT
cls
echo =================================================================
echo                [CMD MODE] SET STEAM LAUNCH SHORTCUT
echo =================================================================
echo   Paste the full path to your Tony Hawk Steam desktop shortcut.
echo.
echo   💡 Default Suggestion (Press Enter to use):
echo   "%USERPROFILE%\Desktop\Games\Tony Hawk's™ Pro Skater™ 1 + 2.url"
echo =================================================================
echo.
set "SHORTCUT_INPUT="
set /p "SHORTCUT_INPUT=Shortcut Path: "

:: If they just hit enter, use the smart default path natively
if "%SHORTCUT_INPUT%"=="" set "SHORTCUT_INPUT=%USERPROFILE%\Desktop\Games\Tony Hawk's™ Pro Skater™ 1 + 2.url"

:: Strip out any accidental quotes
set "GAME_SHORTCUT=%SHORTCUT_INPUT:"=%"
goto ATTACH_CONFIG_DONE

:INTERACTIVE_PS_ROOT
cls
set "ps_folder_cmd=Add-Type -AssemblyName System.Windows.Forms; $f = New-Object System.Windows.Forms.FolderBrowserDialog; $f.Description = 'Select your Mod Stage Directory'; if($f.ShowDialog() -eq 'OK') { Write-Output $f.SelectedPath }"
for /f "usebackq delims=" %%I in (`powershell -NoProfile -ExecutionPolicy Bypass -Command "%ps_folder_cmd%" 2^>nul`) do set "ROOT_DIR=%%I"
if "%ROOT_DIR%"=="" goto INTERACTIVE_PS_ROOT

:: Strip quotes if there are any, then intercept if this is a Quick Edit
set "ROOT_DIR=%ROOT_DIR:"=%"
if "%quick_edit%"=="1" set "quick_edit=" & goto WRITE_CONFIG_FILE
goto INTERACTIVE_PS_ENGINE

:INTERACTIVE_PS_ENGINE
cls
echo =================================================================
echo              [POWERSHELL MODE] SELECT UNREAL EDITOR EXE
echo =================================================================
echo   📌 This program is used to convert and pack your mods.
echo.
echo   👉 Press ENTER to open the file selection window...
echo   👉 Type 'I' for critical info on why you need this tool.
echo   👉 Type 'D' if you need step-by-step help downloading Unreal.
echo   👉 Type 'skip' to bypass locating the engine.
echo =================================================================
echo.
set "engine_choice="
set /p "engine_choice=Selection or Command: "

if /i "%engine_choice%"=="I" goto ENGINE_INFO_SCREEN
if /i "%engine_choice%"=="D" goto GUIDE_DOWNLOAD_UNREAL
if /i "%engine_choice%"=="skip" set "EDITOR_PATH=DISABLED" & set "ENGINE_PATH=DISABLED" & goto ENGINE_REDIRECT

set "ps_file_cmd=Add-Type -AssemblyName System.Windows.Forms; $f = New-Object System.Windows.Forms.OpenFileDialog; $f.Filter = 'Unreal Editor (UE4Editor.exe;UnrealEditor.exe)|UE4Editor.exe;UnrealEditor.exe'; if($f.ShowDialog() -eq 'OK') { Write-Output $f.FileName }"
for /f "usebackq delims=" %%I in (`powershell -NoProfile -ExecutionPolicy Bypass -Command "%ps_file_cmd%" 2^>nul`) do set "EDITOR_PATH=%%I"

if "%EDITOR_PATH%"==" " set "EDITOR_PATH="
if not defined EDITOR_PATH (
    cls
    echo =================================================================
    echo                      [NOTICE] WINDOW POPUP CLOSED
    echo =================================================================
    echo   You didn't select an Editor executable file.
    echo   Let's try again, or type 'skip' to bypass.
    echo.
    timeout /t 3 > nul
    goto INTERACTIVE_PS_ENGINE
)

:ENGINE_REDIRECT
:: Strip quotes, extract engine folder path, and auto-set UnrealPak location
if "%EDITOR_PATH%"=="DISABLED" goto ENGINE_SKIP_CALC
set "EDITOR_PATH=%EDITOR_PATH:"=%"
for %%A in ("%EDITOR_PATH%") do set "ENGINE_BIN_DIR=%%~dpA"
set "ENGINE_PATH=%ENGINE_BIN_DIR%UnrealPak.exe"

:ENGINE_SKIP_CALC
:: THE INTERCEPT FLAG: If quick-editing, clear the flag and save immediately!
if "%quick_edit%"=="1" set "quick_edit=" & goto WRITE_CONFIG_FILE
goto INTERACTIVE_PS_COOKED

:ENGINE_INFO_SCREEN
cls
echo =================================================================
echo                       UNREAL ENGINE TOOL INFO
echo =================================================================
echo   Downloading Unreal Engine isn't 100%% required just to use this
echo   Control Center, but it is required to cook, list mod file
echo   contents, and pack new mods!
echo.
echo   Without it, this tool can still do other useful tasks, like:
echo   ✔️ Verify your workspace directory paths.
echo   ✔️ List your currently downloaded mod files.
echo   ✔️ Show active status of your game mods.
echo   ✔️ Play your game with or without mods (sub-menu)
echo.
echo   If you don't have it yet, you can choose to skip it for now.
echo   Don't worry! The Welcome Screen will let you easily rerun
echo   this engine setup once it is downloaded.
echo =================================================================
echo.
echo   👉 Press ENTER to try locating your engine setup.
echo   👉 Type 'D' to see how to download and install it.
echo   👉 Type 'skip' to bypass this setup and the cooked path setup.
echo =================================================================
echo.
set "info_choice="
set /p "info_choice=What would you like to do? "

if /i "%info_choice%"=="D" goto GUIDE_DOWNLOAD_UNREAL
if /i "%info_choice%"=="skip" set "EDITOR_PATH=DISABLED" & set "ENGINE_PATH=DISABLED" & goto ENGINE_REDIRECT
goto INTERACTIVE_PS_ENGINE

:GUIDE_DOWNLOAD_UNREAL
cls
echo =================================================================
echo                HOW TO DOWNLOAD UNREAL ENGINE (STEP-BY-STEP)
echo =================================================================
echo   [Step 1] Download and install the Epic Games Launcher.
echo   [Step 2] Sign in, then click on the 'Unreal Engine' tab on the left.
echo   [Step 3] Go to 'Library' at the top, and click the '+' sign next 
echo            to 'Engine Versions'.
echo   [Step 4] Select version 4.24 (recommended for THPS 1+2 modding)
echo            and click Install.
echo.
echo   👉 Press 'B' to go back to the selection screen.
echo   👉 Press 'O' to automatically open the Epic Games website.
echo =================================================================
echo.
set "guide_choice="
set /p "guide_choice=Select an option: "

if /i "%guide_choice%"=="B" goto INTERACTIVE_PS_ENGINE
if /i "%guide_choice%"=="O" (
    echo   🌐 Opening browser...
    start "" "https://store.epicgames.com/download"
    timeout /t 3 >nul
    goto GUIDE_DOWNLOAD_UNREAL
)
goto GUIDE_DOWNLOAD_UNREAL

:INTERACTIVE_PS_COOKED
cls
echo =================================================================
echo         [POWERSHELL MODE] SELECT UE4 COOKED CONTENT DIR
echo =================================================================
echo   📌 IMPORTANT: Make sure you have actually started Unreal Engine 
echo      and successfully "cooked" your mod before continuing!
echo.
echo   👉 Press ENTER to open the folder popup selection window...
echo   👉 Type 'U' to launch Unreal Editor right now to cook files!
echo   👉 Type 'skip' or 'no' to completely bypass this setup.
echo   👉 Type 'close' to save current progress and exit the script.
echo =================================================================
echo.
set "COOKED_DIR="
set /p COOKED_DIR="Selection or Command: "

:: Handle menu options and commands
if /i "%COOKED_DIR%"=="U" goto LAUNCH_UNREAL_TO_COOK
if /i "%COOKED_DIR%"=="skip" set "COOKED_DIR=DISABLED" & goto COOKED_REDIRECT
if /i "%COOKED_DIR%"=="no" set "COOKED_DIR=DISABLED" & goto COOKED_REDIRECT
if /i "%COOKED_DIR%"=="close" goto EMER_SAVE_AND_EXIT

set "ps_cooked_cmd=Add-Type -AssemblyName System.Windows.Forms; $f = New-Object System.Windows.Forms.FolderBrowserDialog; $f.Description = 'Select your Unreal Project Content Folder'; if($f.ShowDialog() -eq 'OK') { Write-Output $f.SelectedPath }"
for /f "usebackq delims=" %%I in (`powershell -NoProfile -ExecutionPolicy Bypass -Command "%ps_cooked_cmd%" 2^>nul`) do set "COOKED_DIR=%%I"

if not defined COOKED_DIR (
    cls
    echo =================================================================
    echo                      [NOTICE] WINDOW POPUP CLOSED
    echo =================================================================
    echo   You didn't select a folder in the popup window.
    echo   Type the path manually below, or type 'skip' to bypass.
    echo.
    set /p COOKED_DIR="UE4 Cooked Path: "
)

if /i "%COOKED_DIR%"=="U" goto LAUNCH_UNREAL_TO_COOK
if /i "%COOKED_DIR%"=="skip" set "COOKED_DIR=DISABLED" & goto COOKED_REDIRECT
if /i "%COOKED_DIR%"=="no" set "COOKED_DIR=DISABLED" & goto COOKED_REDIRECT
if /i "%COOKED_DIR%"=="close" goto EMER_SAVE_AND_EXIT
if "%COOKED_DIR%"=="" goto INTERACTIVE_PS_COOKED

:COOKED_REDIRECT
set "COOKED_DIR=%COOKED_DIR:"=%"
if "%quick_edit%"=="1" set "quick_edit=" & goto WRITE_CONFIG_FILE
goto INTERACTIVE_PS_GAME_MODS

:LAUNCH_UNREAL_TO_COOK
cls
echo =================================================================
echo                    LAUNCHING UNREAL EDITOR
echo =================================================================
if "%EDITOR_PATH%"=="NOT_CONFIGURED" (
    echo   [ERROR] Can't launch editor. Path is not configured yet!
    timeout /t 4 >nul
    goto INTERACTIVE_PS_COOKED
)
if "%EDITOR_PATH%"=="" (
    echo   [ERROR] Can't launch editor. Path is not configured yet!
    timeout /t 4 >nul
    goto INTERACTIVE_PS_COOKED
)

echo   🚀 Starting Unreal Editor via:
echo   %EDITOR_PATH%
echo.
echo   Once you finish cooking your mod files inside the engine,
echo   return here to pick your folder location.
echo =================================================================
start "" "%EDITOR_PATH%"
timeout /t 10 >nul
goto INTERACTIVE_PS_COOKED

:INTERACTIVE_PS_GAME_MODS
cls
set "ps_game_folder_cmd=Add-Type -AssemblyName System.Windows.Forms; $f = New-Object System.Windows.Forms.FolderBrowserDialog; $f.Description = 'Select your Live Game ~mods Directory'; if($f.ShowDialog() -eq 'OK') { Write-Output $f.SelectedPath }"
for /f "usebackq delims=" %%I in (`powershell -NoProfile -ExecutionPolicy Bypass -Command "%ps_game_folder_cmd%" 2^>nul`) do set "GAME_MOD_DIR=%%I"
if "%GAME_MOD_DIR%"=="" set "GAME_MOD_DIR=DISABLED"

:: Strip quotes if there are any, then intercept if this is a Quick Edit
set "GAME_MOD_DIR=%GAME_MOD_DIR:"=%"
if "%quick_edit%"=="1" set "quick_edit=" & goto WRITE_CONFIG_FILE
goto INTERACTIVE_PS_SHORTCUT

:INTERACTIVE_PS_SHORTCUT
cls
echo =================================================================
echo          [POWERSHELL MODE] SELECT STEAM LAUNCH SHORTCUT
echo =================================================================
echo    📌 A Windows file selection dialog box is opening...
echo.
echo    👉 ACTION REQUIRED: 
echo       Navigate to your desktop (or wherever your game launcher lives)
echo       and select your official Tony Hawk's Pro Skater 1+2 shortcut.
echo.
echo    (If the window is hidden, check your Windows taskbar!)
echo =================================================================
echo.

set "ps_shortcut_cmd=Add-Type -AssemblyName System.Windows.Forms; $f = New-Object System.Windows.Forms.OpenFileDialog; $f.Title = 'Select your THPS 1+2 Steam Desktop Shortcut'; $f.Filter = 'Steam Internet Shortcuts (*.url)|*.url'; if($f.ShowDialog() -eq 'OK') { Write-Output $f.FileName }"
for /f "usebackq delims=" %%I in (`powershell -NoProfile -ExecutionPolicy Bypass -Command "%ps_shortcut_cmd%" 2^>nul`) do set "GAME_SHORTCUT=%%I"

if "%GAME_SHORTCUT%"=="" (
    cls
    echo =================================================================
    echo                      [NOTICE] WINDOW POPUP CLOSED
    echo =================================================================
    echo    You didn't select a launch shortcut. Let's try again.
    echo.
    timeout /t 3 > nul
    goto INTERACTIVE_PS_SHORTCUT
)

set "GAME_SHORTCUT=%GAME_SHORTCUT:"=%"
if "%quick_edit%"=="1" set "quick_edit=" & goto WRITE_CONFIG_FILE
goto WRITE_CONFIG_FILE

:EMER_SAVE_AND_EXIT
cls
echo =================================================================
echo                      SAVING PROGRESS ^& EXITING
echo =================================================================
echo   Saving current path configurations to config.txt...
if "%ROOT_DIR%"=="" set "ROOT_DIR=NOT_CONFIGURED"
if "%EDITOR_PATH%"=="" set "EDITOR_PATH=NOT_CONFIGURED"
if "%ENGINE_PATH%"=="" set "ENGINE_PATH=NOT_CONFIGURED"
if "%COOKED_DIR%"=="" set "COOKED_DIR=NOT_CONFIGURED"
if "%GAME_MOD_DIR%"=="" set "GAME_MOD_DIR=NOT_CONFIGURED"
if "%GAME_SHORTCUT%"=="" set "GAME_SHORTCUT=NOT_CONFIGURED"
goto WRITE_CONFIG_FILE

:ATTACH_CONFIG_DONE
cls
set "ROOT_DIR=%ROOT_DIR:"=%"
set "EDITOR_PATH=%EDITOR_PATH:"=%"
set "ENGINE_PATH=%ENGINE_PATH:"=%"
set "COOKED_DIR=%COOKED_DIR:"=%"
set "GAME_MOD_DIR=%GAME_MOD_DIR:"=%"

for /f "tokens=* delims= " %%A in ("%ROOT_DIR%") do set "ROOT_DIR=%%A"
for /f "tokens=* delims= " %%A in ("%EDITOR_PATH%") do set "EDITOR_PATH=%%A"
for /f "tokens=* delims= " %%A in ("%ENGINE_PATH%") do set "ENGINE_PATH=%%A"
for /f "tokens=* delims= " %%A in ("%COOKED_DIR%") do set "COOKED_DIR=%%A"
for /f "tokens=* delims= " %%A in ("%GAME_MOD_DIR%") do set "GAME_MOD_DIR=%%A"

:STRIP_LOOP1
if "%ROOT_DIR:~-1%"==" " set "ROOT_DIR=%ROOT_DIR:~0,-1%" & goto STRIP_LOOP1
:STRIP_LOOP2
if "%EDITOR_PATH:~-1%"==" " set "EDITOR_PATH=%EDITOR_PATH:~0,-1%" & goto STRIP_LOOP2
:STRIP_LOOP3
if "%ENGINE_PATH:~-1%"==" " set "ENGINE_PATH=%ENGINE_PATH:~0,-1%" & goto STRIP_LOOP3
:STRIP_LOOP4
if "%COOKED_DIR:~-1%"==" " set "COOKED_DIR=%COOKED_DIR:~0,-1%" & goto STRIP_LOOP4
:STRIP_LOOP5
if "%GAME_MOD_DIR:~-1%"==" " set "GAME_MOD_DIR=%GAME_MOD_DIR:~0,-1%" & goto STRIP_LOOP5

:WRITE_CONFIG_FILE
set "ROOT_DIR=%ROOT_DIR:"=%"
set "EDITOR_PATH=%EDITOR_PATH:"=%"
set "ENGINE_PATH=%ENGINE_PATH:"=%"
set "COOKED_DIR=%COOKED_DIR:"=%"
set "GAME_MOD_DIR=%GAME_MOD_DIR:"=%"
set "GAME_SHORTCUT=%GAME_SHORTCUT:"=%"

for /f "tokens=* delims= " %%A in ("%ROOT_DIR%") do set "ROOT_DIR=%%A"
for /f "tokens=* delims= " %%A in ("%EDITOR_PATH%") do set "EDITOR_PATH=%%A"
for /f "tokens=* delims= " %%A in ("%ENGINE_PATH%") do set "ENGINE_PATH=%%A"
for /f "tokens=* delims= " %%A in ("%COOKED_DIR%") do set "COOKED_DIR=%%A"
for /f "tokens=* delims= " %%A in ("%GAME_MOD_DIR%") do set "GAME_MOD_DIR=%%A"
for /f "tokens=* delims= " %%A in ("%GAME_SHORTCUT%") do set "GAME_SHORTCUT=%%A"

:STRIP_SPACES
if "%ROOT_DIR:~-1%"==" " set "ROOT_DIR=%ROOT_DIR:~0,-1%" & goto STRIP_SPACES
:STRIP_SPACES2
if "%EDITOR_PATH:~-1%"==" " set "EDITOR_PATH=%EDITOR_PATH:~0,-1%" & goto STRIP_SPACES2
:STRIP_SPACES3
if "%ENGINE_PATH:~-1%"==" " set "ENGINE_PATH=%ENGINE_PATH:~0,-1%" & goto STRIP_SPACES3
:STRIP_SPACES4
if "%COOKED_DIR:~-1%"==" " set "COOKED_DIR=%COOKED_DIR:~0,-1%" & goto STRIP_SPACES4
:STRIP_SPACES5
if "%GAME_MOD_DIR:~-1%"==" " set "GAME_MOD_DIR=%GAME_MOD_DIR:~0,-1%" & goto STRIP_SPACES5
:STRIP_SPACES6
if "%GAME_SHORTCUT:~-1%"==" " set "GAME_SHORTCUT=%GAME_SHORTCUT:~0,-1%" & goto STRIP_SPACES6

(
    echo ROOT_DIR=%ROOT_DIR%
    echo EDITOR_PATH=%EDITOR_PATH%
    echo ENGINE_PATH=%ENGINE_PATH%
    echo COOKED_DIR=%COOKED_DIR%
    echo GAME_MOD_DIR=%GAME_MOD_DIR%
    echo GAME_SHORTCUT=%GAME_SHORTCUT%
) > "%CONFIG_FILE%"

if "%1"=="EMER_EXIT" exit

cls
echo =================================================================
echo                    CONFIGURATION SAVED SUCCESSFULLY
echo =================================================================
echo.
echo   All path definitions have been compiled to config.txt!
echo.
echo -----------------------------------------------------------------
echo   👉 Press any key to initialize the verification menu...
pause > nul
goto INIT_CHECK

:: ===================================================
:: [4] GAME LAUNCH PIPELINE (DYNAMIC SHORTCUT MODE)
:: ===================================================
:: Set a default state if it hasn't been defined yet in the script initialization
if not defined MODS_TOGGLE set "MODS_TOGGLE=ENABLED"

:MENU_LAUNCH_GAME
cls
echo =================================================================
echo                 [4] PLAY TONY HAWK'S PRO SKATER 1+2
echo =================================================================
echo   Current Active Game Mods Path:
echo   %GAME_MOD_DIR%    
echo   %GAME_SHORTCUT%
echo -----------------------------------------------------------------
echo   Mods Are:  [ %MODS_TOGGLE% ]
echo =================================================================
echo   [1] 🚀 LAUNCH GAME NOW
echo   [2] 🔄 TOGGLE MODS STATUS (Enable / Disable)
echo   [3] Back to Main Control Center Menu
echo =================================================================
echo.
set "launch_mode="
set /p "launch_mode=Select an option: "

if "%launch_mode%"=="1" goto EXECUTE_GAME_LAUNCH
if "%launch_mode%"=="2" goto TOGGLE_MODS_STATE
if "%launch_mode%"=="3" goto MAIN_MENU
goto MENU_LAUNCH_GAME


:: -----------------------------------------------------------------
:: OPTION 2: TOGGLE CODE (Changes status without launching)
:: -----------------------------------------------------------------
:TOGGLE_MODS_STATE
if /i "%MODS_TOGGLE%"=="ENABLED" (
    set "MODS_TOGGLE=DISABLED"
) else (
    set "MODS_TOGGLE=ENABLED"
)
goto MENU_LAUNCH_GAME


:: -----------------------------------------------------------------
:: OPTION 1: ACTUAL LAUNCH EXECUTION
:: -----------------------------------------------------------------
:EXECUTE_GAME_LAUNCH
cls
echo =================================================================
echo                     INITIALIZING GAME LAUNCH
echo =================================================================
echo.

:: PATH A: LAUNCH WITH MODS ACTIVE
if "%MODS_TOGGLE%"=="ENABLED" (
    :: Check if the 'off' folder exists, and instantly restore mods back to live
    if exist "%GAME_MOD_DIR%\..\off" (
        echo    [+] Restoring parked mods to active directory...
        move /y "%GAME_MOD_DIR%\..\off\*.pak" "%GAME_MOD_DIR%\" >nul 2>&1
        rmdir "%GAME_MOD_DIR%\..\off" >nul 2>&1
    )
    echo    🚀 Launching game WITH mods active...
)

:: PATH B: LAUNCH PURE VANILLA (MODS DISABLED)
if "%MODS_TOGGLE%"=="DISABLED" (
    if /i "%GAME_MOD_DIR%"=="DISABLED" (
        echo    [NOTICE] Game mods folder is unconfigured. Launching stock game...
    ) else (
        echo    [-] Temporarily parking loose mods into 'off' sandbox...
        if not exist "%GAME_MOD_DIR%\..\off" mkdir "%GAME_MOD_DIR%\..\off"
        move /y "%GAME_MOD_DIR%\*.pak" "%GAME_MOD_DIR%\..\off\" >nul 2>&1
    )
    echo    🔒 Launching pure vanilla game...
)

echo -----------------------------------------------------------------
start "" "%GAME_SHORTCUT%"
timeout /t 3 > nul
goto MAIN_MENU
)

if /i "%launch_mode%"=="B" goto MAIN_MENU
goto MENU_LAUNCH_GAME