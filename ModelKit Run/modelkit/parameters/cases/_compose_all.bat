@ECHO OFF
FOR %%f IN (*.pxv) DO CALL modelkit template-compose --files="%%f" --output="../../runs/%%~nf/instance.cibd19" ../../templates/root.pxt
FOR /D %%d IN (..\..\runs\*.*) DO COPY /Y ..\..\bin\_run.bat "%%d"
PAUSE
