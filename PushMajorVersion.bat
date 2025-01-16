call buildforpush.bat

echo Waiting 30 seconds for msbuild to let go of files before upload
sleep 30

::make sure we have the most up to date version number
git fetch
git pull

::get current version and increment version file major version number
set /p version=<version.txt
for /f "tokens=1-2 delims=.v" %%a in ("%version%") do (
  set /a major=%%a + 1
  set /a minor=%%b
)
set new_version=%major%.%minor%
echo v%new_version% > version.txt


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

::delete the uploaded zip
del NiteLite.zip

::push updated version number to github
git add VERSION.txt
git commit -m "Released version v%new_version%"
git push