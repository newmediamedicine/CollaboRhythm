::cls
@echo off

:: ***************************************************************************************
:: Note: before using this install script you should change the variables below

set AndroidADBFolder=C:\Program Files (x86)\Android\android-sdk\platform-tools
:: Android default path used to include the word "windows", so you might need this depending on the version you have
::set AndroidADBFolder=C:\Program Files (x86)\Android\android-sdk-windows\platform-tools
::set SettingsFile=my_settings_debug.xml
set SettingsFile=%USERPROFILE%\AppData\Roaming\CollaboRhythm.Tablet.debug\Local Store\settings.xml

:: ***************************************************************************************

color f9
echo -----------------------------------------------------------------------
echo Removing CollaboRhythm Tablet settings from your Android device...
echo.
echo Please do not close this window.
echo.
echo Settings: %SettingsFile%
echo.

"%AndroidADBFolder%"\adb shell rm "/data/local/air.CollaboRhythm.Tablet.debug/CollaboRhythm.Tablet.debug/Local Store/settings.xml"
				  
echo.
echo Remove complete for %SettingsFile%
echo.

pause
