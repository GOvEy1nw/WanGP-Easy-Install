@echo off&&cd /D "%~dp0"
set "WEI_Title=WanGP-Easy-Install v1.0.0"
Title %WEI_Title%

set GIT_LFS_SKIP_SMUDGE=1
set "PIPargs=--no-cache-dir --no-warn-script-location --timeout=1000 --retries 10"
set "UVargs=--no-cache --link-mode=copy"

for /f "delims=" %%G in ('cmd /c "where.exe git.exe 2>nul"') do (set "GIT_PATH=%%~dpG")
set "path=%GIT_PATH%;%windir%\System32;%windir%\System32\WindowsPowerShell\v1.0;%localappdata%\Microsoft\WindowsApps"

call :SET_COLORS
call :NVIDIA_DRIVER_CHECK

if exist "WanGP-Easy-Install\python_embedded\python.exe" if exist "WanGP-Easy-Install\WanGP\wgp.py" (
	echo %warning%WARNING:%reset% '%bold%WanGP-Easy-Install%reset%' folder already exists!
	echo %green%Move this file to another folder and run it again, or run Update WanGP.bat inside _EziData\_Extras\Update.%reset%
	echo Press any key to Exit...&Pause>nul
	goto :eof
)

set "HLPR_NAME=Helper-WEI.zip"
if not exist "%HLPR_NAME%" (
	echo %warning%WARNING:%reset% '%bold%%HLPR_NAME%%reset%' not found!
	echo %green%Place %HLPR_NAME% next to this installer and run again.%reset%
	echo Press any key to Exit...&Pause>nul
	goto :eof
)

for /f "delims=" %%i in ('powershell -NoProfile -ExecutionPolicy Bypass -command "Get-Date -Format yyyy-MM-dd_HH:mm:ss"') do set start=%%i

echo.
	echo    %green%WanGP Easy Install%reset% - Portable installer for %yellow%deepbeepmeep/Wan2GP%reset%
echo.

call :install_git

for /F "tokens=*" %%g in ('git --version') do (set gitversion=%%g)
echo %gitversion% | findstr /C:"version">nul&&(
	echo %bold%git%reset% %yellow%is installed%reset%
	echo.) || (
	echo %warning%WARNING:%reset% %bold%'git'%reset% is NOT installed
	echo Please install git from %yellow%https://git-scm.com/%reset% and run this installer again
	echo Press any key to Exit...&Pause>nul
	exit
)

md "WanGP-Easy-Install" 2>nul
if not exist "WanGP-Easy-Install" (
	echo %warning%WARNING:%reset% Cannot create folder %yellow%WanGP-Easy-Install%reset%
	echo Make sure you are NOT using system folders like %yellow%Program Files, Windows%reset% or system root %yellow%C:\%reset%
	echo %green%Move this file to another folder and run it again.%reset%
	echo Press any key to Exit...&Pause>nul
	exit
)

cd "WanGP-Easy-Install"

call :install_wan2gp
call :install_python_embedded

cd ".."
echo %green%::::::::::::::: Extracting%yellow% %HLPR_NAME% %green%:::::::::::::::%reset%
echo.
call :extract_zip "%HLPR_NAME%" "."
if errorlevel 1 (
	echo Press any key to Exit...&Pause>nul
	exit
)
echo.

if not exist "WanGP-Easy-Install\_EziData\Config\lib\stack_config.json" (
	echo %red%ERROR:%reset% WanGP-Easy-Install\_EziData\Config\lib\stack_config.json not found after extracting %HLPR_NAME%.
	echo %green%Re-download the package or rebuild Helper-WEI.zip.%reset%
	echo Press any key to Exit...&Pause>nul
	exit
)

cd "WanGP-Easy-Install"

if exist "python_embedded\Include" if not exist "python_embedded\Include\Python.h" rmdir /s /q "python_embedded\Include" 2>nul
if not exist "python_embedded\include\Python.h" (
	echo %warning%WARNING:%reset% python_embedded headers missing from %HLPR_NAME%.
	echo %green%Rebuild Helper-WEI.zip or re-extract the helper package.%reset%
)

if "%CURRENT_CUDA%"=="12.8" (
	set "WEI_CUDA_STACK=cu128"
) else (
	set "WEI_CUDA_STACK=cu130"
)

call :install_torch

echo %green%::::::::::::::: %yellow%Installing WanGP requirements%green% :::::::::::::::%reset%
echo.
.\python_embedded\python.exe -I -m uv pip install -r ".\WanGP\requirements.txt" %UVargs%
echo.

echo %green%::::::::::::::: %yellow%Installing EZi desktop dependencies%green% :::::::::::::::%reset%
echo.
.\python_embedded\python.exe -I -m uv pip install pywebview aiohttp %UVargs%
echo.

echo %green%::::::::::::::: %yellow%Installing acceleration kernels%green% :::::::::::::::%reset%
echo.
.\python_embedded\python.exe -I _EziData\Config\lib\install_helper.py --write-profile
.\python_embedded\python.exe -I _EziData\Config\lib\install_helper.py --auto-kernels
echo.

for /f "delims=" %%i in ('powershell -NoProfile -ExecutionPolicy Bypass -command "Get-Date -Format yyyy-MM-dd_HH:mm:ss"') do set end=%%i
for /f "delims=" %%i in ('powershell -NoProfile -ExecutionPolicy Bypass -command "$s=[datetime]::ParseExact('%start%','yyyy-MM-dd_HH:mm:ss',$null); $e=[datetime]::ParseExact('%end%','yyyy-MM-dd_HH:mm:ss',$null); if($e -lt $s){$e=$e.AddDays(1)}; ($e-$s).TotalSeconds"') do set diff=%%i

echo %green%::::::::::::::::: Installation Complete ::::::::::::::::%reset%
echo %green%::::::::::::::::: Total Running Time:%red% %diff% %green%seconds%reset%
echo.
echo %yellow%Browser:%reset%  WanGP-Easy-Install\WanGP-Browser.bat
echo %yellow%Desktop app:%reset% WanGP-Easy-Install\WanGP-EZi.bat
echo.
echo %yellow%::::::::::::::::: Press any key to exit ::::::::::::::::%reset%&Pause>nul
exit

::::::::::::::::::::::::::::::::: END :::::::::::::::::::::::::::::::::

:SET_COLORS
set warning=[33m
set    gray=[90m
set     red=[91m
set   green=[92m
set  yellow=[93m
set    blue=[94m
set   white=[97m
set    bold=[97m
set   reset=[0m
GOTO :EOF

:install_git
echo %green%::::::::::::::: Installing/Updating%yellow% Git %green%:::::::::::::::%reset%
echo.
winget.exe install --id Git.Git -e --source winget
set "path=%PATH%;%ProgramFiles%\Git\cmd"
echo.
goto :eof

:install_wan2gp
echo %green%::::::::::::::: Installing%yellow% WanGP %green%:::::::::::::::%reset%
echo.
if not exist "WanGP" (
	git.exe clone https://github.com/deepbeepmeep/Wan2GP WanGP
) else (
	echo WanGP source folder exists, skipping clone.
)
echo.
goto :eof

:install_python_embedded
set "PY_EMBED_VER=3.11.9"
set "PY_ZIP=python-%PY_EMBED_VER%-embed-amd64.zip"
set "PY_URL=https://www.python.org/ftp/python/%PY_EMBED_VER%/%PY_ZIP%"

echo %green%::::::::::::::: Installing%yellow% Python %PY_EMBED_VER% embed %green%:::::::::::::::%reset%
echo %gray%   ^(latest Windows embed build; cp311 wheels compatible with WanGP 3.11.x^)%reset%
echo.

if exist "python_embedded\python.exe" (
	echo python_embedded already exists, skipping download.
	goto :eof
)

if exist "python_embedded" (
	cd "python_embedded"
) else (
	md "python_embedded"&&cd "python_embedded"
)

curl.exe -L --progress-bar --ssl-no-revoke --retry 5 --retry-delay 2 -o "%PY_ZIP%" "%PY_URL%"
if errorlevel 1 curl.exe -L --progress-bar --ssl-no-revoke -k --retry 5 --retry-delay 2 -o "%PY_ZIP%" "%PY_URL%"
if not exist "%PY_ZIP%" (
	echo %red%Failed to download %PY_ZIP%%reset%
	echo Press any key to Exit...&Pause>nul
	exit
)

for %%A in ("%PY_ZIP%") do if %%~zA LSS 5000000 (
	echo %red%ERROR:%reset% %PY_ZIP% is too small ^(%%~zA bytes^). Download likely failed.
	echo %green%URL: %PY_URL%%reset%
	del "%PY_ZIP%" 2>nul
	echo Press any key to Exit...&Pause>nul
	exit
)

call :extract_zip "%PY_ZIP%" "."
if errorlevel 1 (
	echo %red%Failed to extract %PY_ZIP%%reset%
	echo Press any key to Exit...&Pause>nul
	exit
)
erase "%PY_ZIP%"

curl.exe -L --progress-bar --ssl-no-revoke --retry 5 --retry-delay 2 -o "get-pip.py" "https://bootstrap.pypa.io/get-pip.py"
if not exist "get-pip.py" (
	echo %red%Failed to download get-pip.py%reset%
	echo Press any key to Exit...&Pause>nul
	exit
)

echo ../WanGP> python311._pth
echo python311.zip>> python311._pth
echo .>> python311._pth
echo Lib/site-packages>> python311._pth
echo Lib>> python311._pth
echo Scripts>> python311._pth
echo # import site>> python311._pth

echo [global]> pip.ini
echo trusted-host =>> pip.ini
echo     pypi.org>> pip.ini
echo     files.pythonhosted.org>> pip.ini

.\python.exe -I get-pip.py %PIPargs%
.\python.exe -I -m pip install uv==0.9.7 %PIPargs%

cd ".."
goto :eof

:install_torch
echo %green%::::::::::::::: Installing%yellow% PyTorch %green%:::::::::::::::%reset%
echo.
if "%WEI_CUDA_STACK%"=="cu128" (
	echo %warning%   Legacy driver: installing Torch 2.9.0+cu128 via stack_config.%reset%
	echo %warning%   Updating NVIDIA drivers ^(580+^) is strongly recommended.%reset%
	echo.
)
.\python_embedded\python.exe -I _EziData\Config\lib\install_helper.py --install-torch --cuda-stack %WEI_CUDA_STACK%
echo.
goto :eof

:extract_zip
set "ZIP_PATH=%~1"
set "ZIP_DEST=%~2"
if not exist "%ZIP_PATH%" (
	echo %red%ERROR:%reset% Archive not found: %ZIP_PATH%
	exit /b 1
)
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "$b=[IO.File]::ReadAllBytes('%ZIP_PATH%'); if($b.Length -lt 4 -or $b[0] -ne 80 -or $b[1] -ne 75){exit 1}; exit 0"
if errorlevel 1 (
	echo %red%ERROR:%reset% '%ZIP_PATH%' is not a valid zip file ^(corrupt or HTML error page^).
	exit /b 1
)
tar.exe -xf "%ZIP_PATH%" -C "%ZIP_DEST%"
if errorlevel 1 (
	powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Expand-Archive -LiteralPath '%ZIP_PATH%' -DestinationPath '%ZIP_DEST%' -Force"
	if errorlevel 1 exit /b 1
)
	exit /b 0

:NVIDIA_DRIVER_CHECK
set "NV_MIN=580"
set "CURRENT_CUDA=13.0"

where.exe nvidia-smi.exe >nul 2>&1
if %errorLevel% neq 0 (
	echo %red%   NVIDIA driver not detected - GPU acceleration may not work.%reset%
	GOTO :EOF
)

for /f %%a in ('nvidia-smi --query-gpu^=driver_version --format^=csv^,noheader 2^>nul') do set "NV_FULL=%%a"
for /f "tokens=1 delims=." %%a in ("%NV_FULL%") do set "NV_MAJOR=%%a"

if not defined NV_MAJOR GOTO :EOF

if %NV_MAJOR% LSS %NV_MIN% (
	echo.
	echo %warning%   NVIDIA driver %yellow%^(%NV_FULL%^)%warning% is below %yellow%%NV_MIN%%reset%
	echo %warning%   Installing CUDA 12.8 / Torch 2.9.0 fallback stack.%reset%
	echo.
	set "CURRENT_CUDA=12.8"
)

for /f "delims=" %%g in ('nvidia-smi --query-gpu^=name --format^=csv^,noheader 2^>nul') do set "GPU_NAME=%%g"
echo %green%   GPU:%yellow% %GPU_NAME%%reset%
echo %green%   CUDA stack:%yellow% %CURRENT_CUDA%%reset%
echo.

set "GTX_WARN=0"
echo %GPU_NAME% | findstr /I "GTX 10 GTX 16" >nul && set "GTX_WARN=1"
if "%GTX_WARN%"=="1" (
	echo %warning%   GTX 10xx detected: this installer targets Python 3.11 / Torch 2.10 for RTX 20+.%reset%
	echo %warning%   Consider upgrading to RTX 20 series or newer for best results.%reset%
	echo.
)
GOTO :EOF
