Ahk2Exe.exe /in RunAwayCoreKeeper.ahk /out RunAwayCoreKeeper-x32.exe /bin "%AHK%\v2\AutoHotkey32.exe"
if %errorlevel% neq 0 exit /b %errorlevel%
Ahk2Exe.exe /in RunAwayCoreKeeper.ahk /out RunAwayCoreKeeper-x64.exe /bin "%AHK%\v2\AutoHotkey64.exe"
if %errorlevel% neq 0 exit /b %errorlevel%
