@ECHO OFF
REM To use, drag and drop .imf parameter files onto this batch file.
%~d1
CD %~dp0
CALL modelkit template-compose --files=%1 --output="../../runs/%~n1/instance.cibd19" ..\..\templates\root.pxt
COPY /Y ..\..\bin\_run.bat "..\..\runs\%~n1"
PAUSE
