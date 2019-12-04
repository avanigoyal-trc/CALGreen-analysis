@ECHO OFF
FOR /D %%d IN (..\runs\*.*) DO CALL "C:\Program Files (x86)\CBECC-Com 2019\CBECC-Com19.exe" -pa -nogui "%%d/instance.cibd19"
PAUSE
