@echo off
color 0a
cd ..
echo Preparing Windows...
lime build windows -debug
echo Preparing Android...
lime build android -debug
echo Preparing HashLink...
lime build hl -debug
echo Ready!
pause
