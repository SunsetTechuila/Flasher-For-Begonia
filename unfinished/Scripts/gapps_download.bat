@echo off
setlocal EnableDelayedExpansion
title Скачивание GApps
set "color=%cd%\Tools\nhcolor.exe"
set "curl=%cd%\Tools\curl.exe"
set "echo=echo.&&echo."

:GApps_Download
if not exist GApps mkdir GApps
if %android_ver% NEQ 12 (
powershell -Command "& {[Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12;$a=Invoke-WebRequest -UseBasicParsing https://api.opengapps.org/list;$a -match 'open_gapps-arm64-%android_ver%\.0-%gapps_ver%-(\d{8})\.zip' | Out-Null;$Matches[1]}">GApps\date_download.txt
ping -n 2 127.0.0.1 >nul
for /f "delims=" %%a in (GApps\date_download.txt) do set date_download=%%a
set "gapps_link=https://downloads.sourceforge.net/project/opengapps/arm64/!date_download!/open_gapps-arm64-!android_ver!.0-!gapps_ver!-!date_download!.zip")
if %android_ver%==12 (
powershell -Command "& {[Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12;$a=Invoke-WebRequest -UseBasicParsing https://sourceforge.net/projects/nikgapps/files/Releases/NikGapps-SL;$a.RawContent -match '.{72}UTC.{24}' | Out-Null;($Matches.0).Substring(52,10) -Replace'-',''}">GApps\date_download.txt
powershell -Command "& {[Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12;$a=Invoke-WebRequest -UseBasicParsing https://sourceforge.net/projects/nikgapps/files/Releases/NikGapps-SL;$a.RawContent -match '.tr title=............. class=.folder ..' | Out-Null;($Matches.0).Substring(11,11)}">GApps\date_download_2.txt
ping -n 2 127.0.0.1 >nul
for /f "delims=" %%a in (GApps\date_download.txt) do set date_download=%%a
for /f "delims=" %%a in (GApps\date_download_2.txt) do set date_download_2=%%a
set "gapps_link=https://sourceforge.net/projects/nikgapps/files/Releases/NikGapps-SL/!date_download_2!/NikGapps-core-arm64-12.1-!date_download!-signed.zip/download")
CLS
%echo%Скачивание GApps...
echo.
!curl! -L -o GApps\gapps_a%android_ver%_%gapps_ver%_%date_download%.zip !gapps_link!
if %addons%==0 goto :End

:Choose_addons
CLS
powershell -ExecutionPolicy Bypass %cd%\Scripts\ChooseAddon.ps1
if not exist GApps\choiceAddons.txt goto :Choose_Addons
title Скачивание GApps

:Download_addons
for /f "usebackq delims=" %%1 in (%cd%\GApps\choiceAddons.txt) do (
cls
%echo%Скачивание %%1...
echo.
!curl! -L -o GApps\addon_%%1_%date_download%.zip https://sourceforge.net/projects/nikgapps/files/Releases/Addons-SL/%date_download_2%/NikGapps-Addon-12.1-%%1-%date_download%-signed.zip/download
)

:End
CLS
powershell -ExecutionPolicy Bypass %cd%\Scripts\GetHashFromSF.ps1 %android_ver% %gapps_ver% %addons%
powershell -ExecutionPolicy Bypass %cd%\Scripts\CheckHash.ps1 %cd%\GApps\hash.txt || echo.Файлы повреждены && pause>nul && goto :GApps_Download
echo tim>GApps\ok
%echo%Успешно. | !color! 0a
exit