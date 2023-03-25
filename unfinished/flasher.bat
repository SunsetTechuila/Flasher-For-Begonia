@echo off
setlocal EnableDelayedExpansion
title Flasher for Begonia

:Admin_permissions
if exist !PROGRAMFILES(X86)! set "bitness=64" || set bitness=32
>nul 2>&1 %SYSTEMROOT%\system32\icacls.exe %SYSTEMROOT%\system32\WDI
if %errorlevel% EQU 0 cd /d %~dp0 && goto :Moving_script
echo.Запрос прав администратора...
echo.Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
echo.UAC.ShellExecute "cmd.exe", "/c ""%~s0"" %bitness:"=""%", "", "runas", 1 >> %temp%\getadmin.vbs
%temp%\getadmin.vbs
del /f /q %temp%\getadmin.vbs
exit

:Moving_script
(echo.%~dp0 | find "Flasher")>nul
if %errorlevel% EQU 0 goto :Variables
mkdir Flasher
>nul copy flasher.bat Flasher
Flasher\flasher.bat
exit

:Variables
pushd..
if exist flasher.bat del /f /q flasher.bat
popd
for /f "tokens=1-10 delims=. " %%a in ('date /t') do set date=%%c%%b%%a
set "curl=%~dp0Tools\curl.exe"
set "fastboot=%~dp0Tools\fastboot.exe"
set "adb=%~dp0Tools\adb.exe"
set "zip=%~dp0Tools\7z.exe"
set "gdrive=%~dp0Tools\gdrive.exe"
set "color=%~dp0Tools\nhcolor.exe"
if exist Tools\ok (set first_run=0) else (set first_run=1)
set ver_script=3.0
set addons=0
set date_downloaded=0
set upd_script=0
set upd_custom=0
set upd_gapps=0
set renew_custom=0
set disc2_trigger=0
set "echo=echo.&&echo."
set error_flash=echo.Ошибка прошивки
set error_download=echo.Ошибка скачивания
set error_unpack=echo.Ошибка распаковки
set error_reboot=echo.Ошибка перезагрузки в
set error_erase=echo.Ошибка очистки
set error_format=echo.Ошибка форматирования
set error_check=echo.Ошибка проверки
set error_copy=echo.Ошибка копирования

:Disclaimer
%echo%ДАННАЯ УТИЛИТА ПРЕДНАЗНАЧЕНА ИСКЛЮЧИТЕЛЬНО ДЛЯ REDMI NOTE 8 PRO^^! | !color! 0c
%echo%ТАКЖЕ ВАШ ЗАГРУЗЧИК ДОЛЖЕН БЫТЬ РАЗБЛОКИРОВАН^^! | !color! 0c
%echo%Во избежание возможных проблем не забудьте сделать бекап всех важных файлов и служебных разделов^^! | !color! 0e
echo.
pause

:Check_Internet_connection
CLS
%echo%Пожалуйста, подождите...
ping 9.9.9.9>nul
if %errorlevel% NEQ 0 (set online=0) else (set online=1)
if %online%==0 (CLS
%echo%Подключение к Интернету не обнаружено^^! | !color! 0c
%echo%Для работы скрипта требуется соединение с Интернетом^^! | !color! 0e
%echo%Подключитесь к Сети и повторите попытку снова
echo.
pause && goto :Check_Internet_connection)
if %first_run%==0 goto :GDrive_token_validation

:Tools
CLS
if exist Tools rmdir /s /q Tools
mkdir Tools
%echo%Скачивание утилит...
call :PowerShell_Download "https://raw.githubusercontent.com/SunsetTechuila/Flasher-for-Begonia/main/Tools/curl_%bitness%.zip", "Tools\curl.zip"     || %error_download% curl && pause>nul && goto :Tools
call :PowerShell_Download "https://raw.githubusercontent.com/SunsetTechuila/Flasher-for-Begonia/main/Tools/7z_%bitness%.exe", "Tools\7z.exe"         || %error_download% 7zip && pause>nul && goto :Tools
call :PowerShell_Download "https://raw.githubusercontent.com/SunsetTechuila/Flasher-for-Begonia/main/Tools/nhcolor.exe", "Tools\nhcolor.exe"         || %error_download% 7zip && pause>nul && goto :Tools
call :PowerShell_Download "https://raw.githubusercontent.com/SunsetTechuila/Flasher-for-Begonia/main/Tools/gdrive_%bitness%.exe", "Tools\gdrive.exe" || %error_download% 7zip && pause>nul && goto :Tools
!zip! e "Tools\curl.zip" -o"Tools\">nul || %error_unpack% curl && pause>nul && goto :Tools
echo.
!curl! -L -o Tools\platform_tools.zip https://dl.google.com/android/repository/platform-tools-latest-windows.zip || %error_download% Platform Tools && pause>nul && goto Tools
!zip! e "Tools\platform_tools.zip" -o"Tools\">nul || %error_unpack% Platform Tools && pause>nul && goto :Tools
del /f /q Tools\platform_tools.zip
del /f /q Tools\curl.zip
REM powershell -ExecutionPolicy Bypass Scripts\CheckHash.ps1 Tools\hash.txt || %error_check% целостности утилит && pause>nul && goto :Tools
echo Che smotrish?>Tools\ok
%echo%Успешно. | !color! 0a

:GDrive_token_validation
if not exist !AppData!\.gdrive\token_v2.json goto :Authorisation
>nul !gdrive! download --path %~dp0Tools 1I-sJEVyMfHHYrpqvxEyyZJQ_-EEy4IY5
if %errorlevel% NEQ 0 (del /f /q !Temp!\dummyg&&goto :Script_update) else (del /f /q !AppData!\.gdrive\token_v2.json&&goto :Authorisation)

:Authorisation
CLS
%echo%Для скачивания файлов с Google Drive требуется аутентификация
%echo%Войдите в свой аккаунт в открывшемся окне браузера, разрешите доступ и вставьте код аутентификации:
echo.!gdrive! download --path !Temp!\ 1I-sJEVyMfHHYrpqvxEyyZJQ_-EEy4IY5^>verification.txt>gdrive.bat
powershell -Command "& {Start-Process %~dp0gdrive.bat -WindowStyle Hidden}"
ping -n 2 127.0.0.1 >nul
powershell -Command "& {Stop-Process -Name "gdrive"}"
for /f "delims=" %%a in ('type verification.txt ^| find /i "https"') do set auth_link=%%a
powershell -Command "& {Start-Process '!auth_link!'}"
echo.
>nul !gdrive! download --path %~dp0Tools 1I-sJEVyMfHHYrpqvxEyyZJQ_-EEy4IY5
if %errorlevel% NEQ 0 goto :Authorisation
del /f /q "verification.txt" && del /f /q "gdrive.bat" && del /f /q !Temp!\dummyg
pause

:Script_update
if exist versions.txt del /f /q versions.txt
if exist update.bat del /f /q update.bat
ping -n 2 127.0.0.1 >nul
call :PowerShell_Download "https://raw.githubusercontent.com/SunsetTechuila/Flasher-for-Begonia/main/versions.txt", "versions.txt" >nul
if not exist versions.txt %error_download% списка версий && pause>nul && goto :Script_update
for /f "tokens=2 delims= " %%a in ('find /i "script" versions.txt') do set new_ver_script=%%a
if not %new_ver_script% GTR %ver_script% goto :Adaptation
:Question1
CLS
%echo%Доступна новая версия Flasher, скачать?
echo.(текущая - %ver_script%; актуальная - %new_ver_script%)
echo.
echo.1) Да
echo.2) Нет
%echo%Чейнджлог:
echo.
!curl! https://raw.githubusercontent.com/SunsetTechuila/Flasher-for-Begonia/main/last_changelog
echo.
set /p upd_script="Ваш выбор: "
if %upd_script% NEQ 1 if %upd_script% NEQ 2 goto :Question1
if %upd_script%==2 set upd_script=0
if %upd_script%==0 goto :Adaptation
echo.@echo off>update.bat
echo.title Flasher updater>>update.bat
echo.echo.>>update.bat
echo.echo.Обновление...>>update.bat
echo.del /f /q flasher.bat>>update.bat
echo."%~dp0Tools\gdrive.exe" download --path "%CD%"   
echo.exit>>update.bat
pause
CLS
update.bat
exit

:Adaptation
if exist MIUI12.5    (set ex_miui=У)                  else (set ex_miui=Скачать и у)
if exist crDroid8    (set ex_crdroid8=последующей)    else (set ex_crdroid8=последующим скачиванием и)
if exist crDroid7    (set ex_crdroid7=последующей)    else (set ex_crdroid7=последующим скачиванием и)
if exist MIUI12      (set ex_miui12=У)                else (set ex_miui12=Скачать и у)
if exist crDroid6    (set ex_crdroid6=последующей)    else (set ex_crdroid6=последующим скачиванием и)

:Choice
CLS
echo. 
<nul set /p strTemp= %ex_miui%становить 
<nul set /p strTemp=MIUI 12.5 | !color! 0b
<nul set /p strTemp=1) с %ex_crdroid8% установкой 
<nul set /p strTemp=crDroid 8 UNOFFICIAL by 7Soldier (Android 12L) | !color! 0b
<nul set /p strTemp=2) с %ex_crdroid7% установкой 
<nul set /p strTemp=crDroid 7 Official by TTTT555 (Android 11) | !color! 0b
<nul set /p strTemp=3) c последующей перезагрузкой в 
<nul set /p strTemp=TWRP | !color! 0b
echo.
<nul set /p strTemp= %ex_miui12%становить 
<nul set /p strTemp=MIUI 12 | !color! 0b
<nul set /p strTemp=4) с %ex_crdroid6% установкой 
<nul set /p strTemp=crDroid 6 Official by TTTT555 (Android 10) | !color! 0b
<nul set /p strTemp=5) c последующей перезагрузкой в 
<nul set /p strTemp=TWRP | !color! 0b
echo.
echo.6) Обновить уже установленный кастом
echo.
set /p param="Ваш выбор: "
if %param% GTR 6 goto :Choice
if %param% LSS 1 goto :Choice
if %param%==1 set rom=crDroid8
if %param%==2 set rom=crDroid7
if %param%==3 set "rom=MIUI" && set android_ver=11
if %param%==4 set rom=crDroid6
if %param%==5 set "rom=MIUI" && set android_ver=10
if %param% NEQ 6 goto :ROMs_params
:Choice2
CLS
%echo%Какая кастомная прошивка у вас сейчас установлена?
%echo%1) crDroid 8
echo.2) crDroid 7
echo.3) crDroid 6
echo.
echo.4) Назад
echo.
set /p param="Ваш выбор: "
if %param% GTR 4 goto :Choice2
if %param% LSS 1 goto :Choice2
if %param%==4 goto :Choice
if %param%==1 set rom=crDroid8
if %param%==2 set rom=crDroid7
if %param%==3 set rom=crDroid6
set disc2_trigger=1
:ROMs_params
if %rom%==crDroid8 (set display_rom=crDroid 8
set "post_link=t.ly/crdroid8"
set id_rom=1GlNd-60boDxtIFzmP_vCA9wPeXOE6dbt
set android_ver=12)
if %rom%==crDroid7 (set display_rom=crDroid 7
set "post_link=https://4pda.to/forum/index.php?showtopic=974421&st=14520#entry114818456"
set id_rom=1LwFO4Ncu7GesrHC-a0lU6Ey8kxYhaIPx
set android_ver=11)
if %rom%==crDroid6 (set display_rom=crDroid 6
set "post_link=https://4pda.to/forum/index.php?showtopic=974421&st=1480#entry97822397"
set id_rom=1L6UN-keNGc_etgyzUez1mztr2NcV5qhi
set android_ver=10)
if %android_ver% GTR 10 (set "miui_ver=12.5" && set miui_link=1sAYZMdpLdxtl2rgcPLhLo7mI48fRTGvI) else (set "miui_ver=12" && set miui_link=1oFHKe3ML038JKDDQLwd_1WtzETp1fDoe)
if %disc2_trigger%==1 goto :Disclaimer2

:Custom_update
if not exist %rom%\version.txt goto :GApps_update
set /p ver_custom=<%rom%\version.txt || %error_check% скачанной версии %display_rom% && pause>nul && goto :GApps_update
for /f "tokens=2 delims= " %%a in ('find /i "%rom%" versions.txt') do set new_ver_custom=%%a
if not %new_ver_custom% GTR %ver_custom% goto :GApps_update
:Question3
CLS
%echo%Доступна новая версия %display_rom%, скачать?
echo.
echo.1) Да
echo.2) Нет
echo.
set /p upd_custom="Ваш выбор: "
if %upd_custom% NEQ 1 if %upd_custom% NEQ 2 CLS && goto :Question3
if %upd_custom%==2 set upd_custom=0

:GApps_update
if not exist GApps/gapps_a%android_ver%_*.zip (if %renew_custom%==0 (goto :Download_MIUI) else (goto :Download_Custom))
for /f "delims=" %%a in ('dir %~dp0GApps /s /b gapps_a%android_ver%_*.zip') do set "name=%%~na"
for /f "tokens=1-22 delims=_" %%a in ('echo.!name!') do set gapps_ver=%%c
for /f "tokens=1-22 delims=_" %%a in ('echo.!name!') do set date_downloaded=%%d
if %android_ver% NEQ 12 (
powershell -Command "& {[Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12;$a=Invoke-WebRequest -UseBasicParsing https://api.opengapps.org/list;$a -match 'open_gapps-arm64-%android_ver%\.0-%gapps_ver%-(\d{8})\.zip' | Out-Null;$Matches[1]}">GApps\date_download.txt
ping -n 2 127.0.0.1 >nul
for /f "delims=" %%a in (GApps\date_download.txt) do set date_download=%%a)
if %android_ver%==12 (
powershell -Command "& {[Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12;$a=Invoke-WebRequest -UseBasicParsing https://sourceforge.net/projects/nikgapps/files/Releases/NikGapps-SL;$a.RawContent -match '.{72}UTC.{24}' | Out-Null;($Matches.0).Substring(52,10) -Replace'-',''}">GApps\date_download.txt
ping -n 2 127.0.0.1 >nul
for /f "delims=" %%a in (GApps\date_download.txt) do set date_download=%%a)
if !date_download! GTR !date_downloaded! goto :Question4
if %clear_flash_custom%==1 goto :Download_Custom
if %clear_flash_custom%==0 goto :Download_MIUI
:Question4
CLS
%echo%Доступно обновление GApps, скачать?
echo.
echo.1) Да
echo.2) Нет
echo.
set /p upd_gapps="Ваш выбор: "
if %upd_gapps% NEQ 1 if %upd_gapps% NEQ 2 CLS && goto :Question4
if %upd_gapps%==2 set upd_gapps=0
if %upd_gapps%==1 del /f /q GApps\gapps_a%android_ver%_%gapps_ver%_%date_downloaded%.zip&& goto :Download_GApps
if %renew_custom%==1 goto :Download_Custom

:GApps_Question
CLS
%echo%Cкачать GApps?
echo.
if %android_ver% NEQ 12 (echo.1^) Да, pico) else (echo.1^) Да)
if %android_ver% NEQ 12 (echo.2^) Да, nano ^(вариант, если нужен OK Google^)) else (echo.2^) Да, c аддонами)
echo.3) Нет
echo.
set /p gapps="Ваш выбор: "
if %gapps% NEQ 1 if %gapps% NEQ 2 if %gapps% NEQ 3 goto :GApps_Question
if %android_ver% NEQ 12 (if %gapps%==1 set gapps_ver=pico
if %gapps%==2 set gapps_ver=nano)
if %android_ver% EQU 12 (if %gapps%==1 set gapps_ver=core
if %gapps%==2 set "gapps_ver=core" && set "addons=1")
if %gapps%==3 !adb! reboot && goto :Open_post

:Download_GApps
start Scripts\gapps_download.bat %android_ver%, %gapps_ver%, %addons%

:Download_MIUI
if exist MIUI%miui_ver% if %upd_miui%==2 goto :Unpack_MIUI
if exist MIUI%miui_ver% rmdir /s /q MIUI%miui_ver%
mkdir MIUI%miui_ver%
CLS
%echo%Скачивание MIUI %miui_ver%...
echo.
!gdrive! download --path "MIUI%miui_ver%" %miui_link% || %error_download% MIUI %miui_ver% && pause>nul && rmdir /s /q "%~dp0MIUI%miui_ver%" && goto :Tools
%echo%Успешно. | !color! 0a 

:Unpack_MIUI
if exist MIUI%miui_ver%\version.txt if not %rom%==MIUI goto :Download_Custom
if exist MIUI%miui_ver%\version.txt goto :Flash_MIUI
CLS
%echo%Распаковка MIUI %miui_ver%...
!zip! e %~dp0MIUI%miui_ver%\MIUI%miui_ver%.7z -o%~dp0MIUI%miui_ver%\ || %error_unpack% MIUI %miui_ver% && pause>nul && rmdir /s /q "%~dp0MIUI%miui_ver%" && goto :Download_MIUI
%echo%Успешно. | !color! 0a
if %rom%==MIUI goto :Flash_MIUI

:Download_Custom
if exist %rom% if %upd_custom%==0 goto :Unpack_Custom
if exist %rom% rmdir /s /q %rom%
mkdir %rom%
CLS
%echo%Скачивание %display_rom%...
echo.
!gdrive! download --path "%rom%" %id_rom% || %error_download% %rom% && pause>nul && rmdir /s /q %rom% && goto :Tools
%echo%Успешно. | !color! 0a

:Unpack_Custom
if exist %rom%\version.txt if %clear_flash_custom%==1 goto :Flash_custom
if exist %rom%\version.txt if %clear_flash_custom%==2 goto :Flash_MIUI
CLS
%echo%Распаковка %display_rom%...
!zip! e %~dp0%rom%\%rom%.7z -o%~dp0%rom%\ || %error_unpack% %rom% && pause>nul && rmdir /s /q %rom% && goto :Download_Custom
%echo%Успешно. | !color! 0a

:Flash_MIUI
CLS
REM goto skip1
%echo%Проверка модели вашего смартфона и статуса блокировки загрузчика...
%echo%Переведите ваш смартфон в режим fastboot и подключите к компьютеру
!fastboot! getvar product  2>&1 | findstr /r /c:"^product: *begonia" || echo.Неподходящее устройство && rmdir /s /q %~dp0 && pause>nul && exit
!fastboot! getvar unlocked 2>&1 | findstr /r /c:"^unlocked: *yes"    || echo.Загрузчик заблокирован  && rmdir /s /q %~dp0 && pause>nul && exit
CLS
%echo%Установка MIUI %miui_ver%...
echo.
!fastboot! erase boot     || %error_erase% boot     && pause>nul && goto :Tools
!fastboot! erase expdb    || %error_erase% expdb    && pause>nul && goto :Tools
!fastboot! erase metadata || %error_erase% metadata && pause>nul && goto :Tools
!fastboot! flash crclist       %~dp0MIUI%miui_ver%\crclist.txt           || %error_flash% crclist       && pause>nul && goto :Flash_MIUI
!fastboot! flash sparsecrclist %~dp0MIUI%miui_ver%\sparsecrclist.txt     || %error_flash% sparsecrclist && pause>nul && goto :Flash_MIUI
!fastboot! flash audio_dsp     %~dp0MIUI%miui_ver%\audio_dsp.img         || %error_flash% audio_dsp     && pause>nul && goto :Flash_MIUI
!fastboot! flash boot          %~dp0MIUI%miui_ver%\boot.img              || %error_flash% boot          && pause>nul && goto :Flash_MIUI
!fastboot! flash cam_vpu1      %~dp0MIUI%miui_ver%\cam_vpu1.img          || %error_flash% cam_vpu1      && pause>nul && goto :Flash_MIUI
!fastboot! flash cam_vpu2      %~dp0MIUI%miui_ver%\cam_vpu2.img          || %error_flash% cam_vpu2      && pause>nul && goto :Flash_MIUI
!fastboot! flash cam_vpu3      %~dp0MIUI%miui_ver%\cam_vpu3.img          || %error_flash% cam_vpu3      && pause>nul && goto :Flash_MIUI
!fastboot! flash cust          %~dp0MIUI%miui_ver%\cust.img              || %error_flash% cust          && pause>nul && goto :Flash_MIUI
!fastboot! flash dtbo          %~dp0MIUI%miui_ver%\dtbo.img              || %error_flash% dtbo          && pause>nul && goto :Flash_MIUI
!fastboot! flash efuse         %~dp0MIUI%miui_ver%\efuse.img             || %error_flash% efuse         && pause>nul && goto :Flash_MIUI
!fastboot! flash exaid         %~dp0MIUI%miui_ver%\exaid.img             || %error_flash% exaid         && pause>nul && goto :Flash_MIUI
!fastboot! flash gsort         %~dp0MIUI%miui_ver%\gsort.img             || %error_flash% gsort         && pause>nul && goto :Flash_MIUI
!fastboot! flash gz1           %~dp0MIUI%miui_ver%\gz.img                || %error_flash% gz1           && pause>nul && goto :Flash_MIUI
!fastboot! flash gz2           %~dp0MIUI%miui_ver%\gz.img                || %error_flash% gz2           && pause>nul && goto :Flash_MIUI
!fastboot! flash lk            %~dp0MIUI%miui_ver%\lk.img                || %error_flash% lk            && pause>nul && goto :Flash_MIUI
!fastboot! flash lk2           %~dp0MIUI%miui_ver%\lk.img                || %error_flash% lk2           && pause>nul && goto :Flash_MIUI
!fastboot! flash logo          %~dp0MIUI%miui_ver%\logo.bin              || %error_flash% logo          && pause>nul && goto :Flash_MIUI
!fastboot! flash md1img        %~dp0MIUI%miui_ver%\md1img.img            || %error_flash% md1img        && pause>nul && goto :Flash_MIUI
!fastboot! flash oem_misc1     %~dp0MIUI%miui_ver%\oem_misc1.img         || %error_flash% oem_misc1     && pause>nul && goto :Flash_MIUI
!fastboot! flash preloader     %~dp0MIUI%miui_ver%\preloader_begonia.bin || %error_flash% preloader     && pause>nul && goto :Flash_MIUI
!fastboot! flash recovery      %~dp0MIUI%miui_ver%\recovery.img          || %error_flash% recovery      && pause>nul && goto :Flash_MIUI
!fastboot! flash scp1          %~dp0MIUI%miui_ver%\scp.img               || %error_flash% scp1          && pause>nul && goto :Flash_MIUI
!fastboot! flash scp2          %~dp0MIUI%miui_ver%\scp.img               || %error_flash% scp2          && pause>nul && goto :Flash_MIUI
!fastboot! flash sspm_1        %~dp0MIUI%miui_ver%\sspm.img              || %error_flash% sspm_1        && pause>nul && goto :Flash_MIUI
!fastboot! flash sspm_2        %~dp0MIUI%miui_ver%\sspm.img              || %error_flash% sspm_2        && pause>nul && goto :Flash_MIUI
!fastboot! flash spmfw         %~dp0MIUI%miui_ver%\spmfw.img             || %error_flash% spmfw         && pause>nul && goto :Flash_MIUI
!fastboot! flash system        %~dp0MIUI%miui_ver%\system.img            || %error_flash% system        && pause>nul && goto :Flash_MIUI
!fastboot! flash tee1          %~dp0MIUI%miui_ver%\tee.img               || %error_flash% tee1          && pause>nul && goto :Flash_MIUI
!fastboot! flash tee2          %~dp0MIUI%miui_ver%\tee.img               || %error_flash% tee2          && pause>nul && goto :Flash_MIUI
!fastboot! flash vbmeta        %~dp0MIUI%miui_ver%\vbmeta.img            || %error_flash% vbmeta        && pause>nul && goto :Flash_MIUI
!fastboot! flash vendor        %~dp0MIUI%miui_ver%\vendor.img            || %error_flash% vendor        && pause>nul && goto :Flash_MIUI
:skip1
%echo%Успешно. | !color! 0a
if exist %~dp0MIUI%miui_ver%\MIUI%miui_ver%.7z del /f /q %~dp0MIUI%miui_ver%\MIUI%miui_ver%.7z
if %rom%==MIUI goto :Reboot_MIUI

:Flash_Custom
CLS
%echo%Установка %display_rom%...
!fastboot! reboot bootloader || %error_reboot% bootloader>nul && pause>nul && goto :Tools
ping -n 2 127.0.0.1 >nul
call %~dp0%rom%\flash.bat !fastboot!
if %errorlevel% NEQ 0 del /f /q %rom%\*.img>nul && del /f /q %rom%\*.txt>nul && del /f /q %rom%\*.bin>nul && goto :Unpack_Custom
:Clearing
if %clear_flash_custom%==2 !fastboot! -w || %error_format% data && pause>nul && goto :Tools
if %clear_flash_custom%==1 !fastboot! erase cache || %error_erase% cache && pause>nul && goto :Tools
!fastboot! reboot recovery || %error_reboot% recovery && pause>nul && goto :Tools
:skip2
%echo%Успешно. | !color! 0a
del /f /s /q %~dp0%rom%\*.7z
if not exist %~dp0GApps\gapps_a%android_ver%_*.zip goto :GApps_Question
if exist %~dp0GApps\gapps_a%android_ver%_*.zip goto :GApps_Flash

:Reboot_MIUI
CLS
%echo%Перезагрузка...
echo.
!fastboot! -w              || %error_format% data     && pause>nul && goto :Tools
!fastboot! reboot recovery || %error_reboot% recovery && pause>nul && goto :Tools
%echo%Успешно. | !color! 0a
echo.
pause>nul && exit /B 0

:GApps_Move
CLS
if not exist GApps\ok (%echo%Ожидание окончания скачивания GApps...
ping -n 11 127.0.0.1 >nul
goto :GApps_Move)
for /f "delims=" %%a in ('dir %~dp0GApps /s /b gapps_a%android_ver%_*.zip') do set "name=%%~na"
for /f "tokens=1-22 delims=_" %%a in ('echo.!name!') do set date_downloaded=%%d
for /f "tokens=1-22 delims=_" %%a in ('echo.!name!') do set gapps_ver=%%c
CLS
%echo%Перенести архив с GApps во внутреннюю память смартфона?
echo.
echo.1) Да
echo.2) Нет
echo.
set /p install_gapps="Ваш выбор: "
if %install_gapps% NEQ 1 if %install_gapps% NEQ 2 goto :GApps_Move
if %install_gapps%==2 !adb! reboot
if %install_gapps%==2 goto :Open_post
CLS
echo.
echo.Убедитесь, что вы загрузились в рекавери и ввели пароль, если требовалось
pause>nul
CLS
echo.
echo.Перенос GApps во внутренню память смартфона...
%adb% push %~dp0GApps\gapps_a%android_ver%_%gapps_ver%_%date_downloaded%.zip /sdcard/>nul || %error_copy% GApps && pause>nul && goto :GApps_Move
for /f "usebackq delims=" %%1 in (GApps\choiceAddons.txt) do (%adb% push %~dp0GApps\addon_%%1_%date_download%.zip)
echo. 
echo.Успешно. | !color! 0a
pause>nul && exit

:Open_post
CLS
%echo%Открыть пост с прошивкой?
echo.
echo.1) Да
echo.2) Нет
echo.
set /p open_post="Ваш выбор: "
if %open_post% NEQ 1 if %open_post% NEQ 2 goto :Open_post
if %open_post%==1 (powershell -Command "& {Start-Process '!post_link!'}") else (exit)

:Disclaimer2
CLS
%echo%ИСПОЛЬЗУЙТЕ ТОЛЬКО В СЛУЧАЕ, ЕСЛИ У ВАС УЖЕ УСТАНОВЛЕН %display_rom%^^!
echo.
echo.1) Продолжить
echo.2) Назад
echo.
set /p renew_custom="Ваш выбор: "
if %renew_custom% NEQ 1 if %renew_custom% NEQ 2 goto :Disclaimer2
if %renew_custom%==1 goto :Custom_update
if %renew_custom%==2 set renew_custom=0 && goto :Choice2

:PowerShell_Download
powershell -Command "& {[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12}; &"{Invoke-WebRequest "%1" -outfile "%2"}""