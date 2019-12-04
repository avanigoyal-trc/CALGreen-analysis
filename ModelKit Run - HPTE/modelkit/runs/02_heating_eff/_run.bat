@ECHO OFF
REM To use, drag and drop .cibd19 input files onto this batch file.
%~d1
CD %~dp0
CALL "C:\Program Files (x86)\CBECC-Com 2019\CBECC-Com19.exe" -pa -nogui "%1"
PAUSE
