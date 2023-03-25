@echo off
title Flasher updater
echo.
echo.Обновление...
del /f /q flasher.bat
"D:\Flasher\Tools\gdrive.exe" download --path "D:\Flasher" 1aph-zom1uNnqbLB-eQOZ7g0kpPU6L-de>nul
flasher.bat
exit
