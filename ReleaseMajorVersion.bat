call buildforpush.bat

echo Waiting 30 seconds for msbuild to let go of files before upload
sleep 30

::Get version number from the most recent release, if there is none, start at 0.0.0
powershell -Command "Invoke-WebRequest https://github.com/EC-WW/NiteLiteReleases/releases/latest/download/VERSION.txt -OutFile VERSION.txt"
if errorlevel 1 (
    echo v0.0.0 > VERSION.txt
)

::get current version and increment version file major version number
set /p version=<version.txt
for /f "tokens=1-3 delims=.v" %%a in ("%version%") do (
  set /a super=%%a
  set /a major=%%b + 1
  set /a minor=%%c
)
set new_version=%super%.%major%.%minor%
echo v%new_version% > VERSION.txt


::grab an editorless exe, and zip everything up
xcopy .\VERSION.txt ..\..\x64\Release\NiteLite\VERSION.txt /Y
echo f | xcopy ..\..\x64\Release_NoEditor\NiteLite\NiteLite.exe ..\..\x64\Release\NiteLite\NiteLite_NoEditor.exe /Y
powershell.exe Compress-Archive ..\..\x64\Release\NiteLite NiteLite.zip -Force || exit /b %errorlevel%
del ..\..\x64\Release\NiteLite\NiteLite_NoEditor.exe

if errorlevel 1 (
    echo Something went wrong
    exit /b %errorlevel%
)

::create the release on github
gh release create %new_version% --notes %new_version%

::add the zip to the release
gh release upload %new_version% VERSION.txt
gh release upload %new_version% NiteLite.zip

::delete the uploaded stuffs
del VERSION.txt
del NiteLite.zip