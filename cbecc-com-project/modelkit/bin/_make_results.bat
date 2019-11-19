@ECHO OFF
REM NOTE: Must set Storage of Simulation Output to 7 for "ALL simulation input and output" file.
CALL modelkit-energyplus energyplus-sql --query=../results/results.txt --output=../results/results.csv "..\runs\**\instance - ap.sql"
PAUSE
