::make sure we have the most up to date version number
git fetch
git pull

::get current version and increment version file major version number
set /p version=<version.txt
for /f "tokens=1-2 delims=.v" %%a in ("%version%") do (
  set /a major=%%a
  set /a minor=%%b + 1
)
set new_version=%major%.%minor%
echo v%new_version% > version.txt

git add VERSION.txt

git commit -m "Updated version number to v%new_version%"

::create the release on github
gh release create %version% --notes %version%

::grab an editorless exe, and zip everything up
xcopy ..\..\x64\Release_NoEditor\NiteLite\NiteLite.exe ..\..\x64\Release\NiteLite\NiteLite_NoEditor.exe /Y /S /I
powershell.exe Compress-Archive ..\..\x64\Release\NiteLite NiteLite.zip -Force
del ..\..\x64\Release_NoEditor\NiteLite\NiteLite_NoEditor.exe

::add the zip to the release
gh release upload %version% NiteLite.zip

::delete the uploaded zip
del NiteLite.zip