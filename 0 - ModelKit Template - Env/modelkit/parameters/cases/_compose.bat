@ECHO OFF
REM To use, drag and drop .pxv parameter files onto this batch file.
%~d1
CD %~dp0
CALL modelkit template-compose --files=%1 --output=ConsAssm-test.cibd19 ConsAssm-test.pxt
PAUSE
