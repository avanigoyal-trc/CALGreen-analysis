@ECHO OFF
FOR /D /r %%G in (..\runs\*.*) DO copy ..\runs\%%~nxG\"instance - run"\"instance - ab - HVACSecondary.csv" ..\parameters\cases\autosizing\%%~nxG.csv
PAUSE
