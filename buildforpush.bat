REM Configuration
set LAUNCHER_SLN_PATH="..\..\NiteLaunch.sln"
set ENGINE_SLN_PATH="..\..\NiteLite.sln"
set NO_EDITOR_CONFIG="Release_NoEditor"
set RELEASE_CONFIG="Release"
set PLATFORM="x64"

REM set up developer command enviornment
if not exist "C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\Tools\VsDevCmd.bat" (
  echo Couldn't automatically start developer command prompt, run this batch file from a developer command prompt
  exit
)
call "C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\Tools\VsDevCmd.bat"


REM Build the engine without the editor so the engine has a copy for exporting
echo Building %NO_EDITOR_CONFIG% configuration...
msbuild /nr:false %ENGINE_SLN_PATH% /p:Configuration=%NO_EDITOR_CONFIG% /p:Platform=%PLATFORM%
if %errorlevel% neq 0 (
    echo Build failed for %NO_EDITOR_CONFIG%.
    exit /b %errorlevel%
)

REM Build the engine w/editor
echo Building %RELEASE_CONFIG% configuration...
msbuild /nr:false %ENGINE_SLN_PATH% /p:Configuration=%RELEASE_CONFIG% /p:Platform=%PLATFORM%
if %errorlevel% neq 0 (
    echo Build failed for %RELEASE_CONFIG%.
    exit /b %errorlevel%
)

REM Build the launcher
echo Building launcher
msbuild /nr:false %LAUNCHER_SLN_PATH% /p:Configuration=%RELEASE_CONFIG% /p:Platform=%PLATFORM%
if %errorlevel% neq 0 (
    echo Build failed for launcher.
    exit /b %errorlevel%
)