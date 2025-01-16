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

::create the release on github
gh release create %new_version% --notes %new_version%

::grab an editorless exe, and zip everything up
xcopy .\VERSION.txt ..\..\x64\Release\NiteLite\VERSION.txt /Y /S /I
xcopy ..\..\x64\Release_NoEditor\NiteLite\NiteLite.exe ..\..\x64\Release\NiteLite\NiteLite_NoEditor.exe /Y /S /I
powershell.exe Compress-Archive ..\..\x64\Release\NiteLite NiteLite.zip -Force
del ..\..\x64\Release_NoEditor\NiteLite\NiteLite_NoEditor.exe

::add the zip to the release
gh release upload %new_version% VERSION.txt
gh release upload %new_version% NiteLite.zip

::delete the uploaded zip
del NiteLite.zip

::push updated version number to github
git add VERSION.txt
git commit -m "Released version v%new_version%"
git push