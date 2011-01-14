@echo off
echo Copying installer to deployment location...
xcopy /Y .\WorkstationApplication.air "\\records.media.mit.edu\web\CollaboRhythm.Workstation\"
@pause
