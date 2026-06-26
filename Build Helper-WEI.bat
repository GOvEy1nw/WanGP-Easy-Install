@echo off
cd /D "%~dp0"
Title Build Helper-WEI.zip

if not exist "WanGP-Easy-Install\_EziData\Config\lib\stack_config.json" (
    echo WanGP-Easy-Install source folder not found.
    pause
    exit /b 1
)

if exist "Helper-WEI.zip" del "Helper-WEI.zip"

echo Building Helper-WEI.zip from WanGP-Easy-Install\ ...
tar.exe -a -cf "Helper-WEI.zip" -C "." "WanGP-Easy-Install"

if not exist "Helper-WEI.zip" (
    echo Failed to create Helper-WEI.zip
    pause
    exit /b 1
)

powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "$b=[IO.File]::ReadAllBytes('Helper-WEI.zip'); if($b.Length -lt 4 -or $b[0] -ne 80 -or $b[1] -ne 75){Write-Error 'Invalid zip'; exit 1}; $td=Join-Path $env:TEMP 'wei-zip-test'; if(Test-Path $td){Remove-Item $td -Recurse -Force}; New-Item -ItemType Directory -Path $td | Out-Null; tar.exe -xf 'Helper-WEI.zip' -C $td; if(-not (Test-Path (Join-Path $td 'WanGP-Easy-Install\_EziData\Config\lib\stack_config.json'))){Write-Error 'Missing stack_config'; exit 1}; if(-not (Test-Path (Join-Path $td 'WanGP-Easy-Install\python_embedded\include\Python.h'))){Write-Error 'Missing Python.h'; exit 1}; if(Test-Path (Join-Path $td 'WanGP-Easy-Install\python_embedded\python.exe')){Write-Error 'python_embedded runtime must not be bundled in Helper-WEI.zip'; exit 1}; Remove-Item $td -Recurse -Force"
if errorlevel 1 (
    echo Helper-WEI.zip failed validation.
    del "Helper-WEI.zip" 2>nul
    pause
    exit /b 1
)

echo.
echo Created Helper-WEI.zip
for %%F in ("Helper-WEI.zip") do echo Size: %%~zF bytes
pause
exit /b 0
