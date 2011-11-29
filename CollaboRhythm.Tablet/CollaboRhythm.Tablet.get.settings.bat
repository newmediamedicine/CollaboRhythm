::cls
@echo off

:: ***************************************************************************************
:: Note: before using this install script you should change the variables below

set AndroidADBFolder=C:\Program Files (x86)\Android\android-sdk\platform-tools
:: Android default path used to include the word "windows", so you might need this depending on the version you have
::set AndroidADBFolder=C:\Program Files (x86)\Android\android-sdk-windows\platform-tools
::set SettingsFile=my_settings_debug.xml
set SettingsFile=settings_2011.11.15.xml

:: ***************************************************************************************

color f9
echo -----------------------------------------------------------------------
echo Copying CollaboRhythm Tablet settings from your Android device...
echo.
echo Please do not close this window.
echo.
echo Settings: %SettingsFile%
echo.

"%AndroidADBFolder%"\adb pull "/data/local/air.CollaboRhythm.Tablet.debug/CollaboRhythm.Tablet.debug/Local Store/settings.xml" %SettingsFile%
				  
echo.
echo Copy complete for %SettingsFile%
echo.

pause
