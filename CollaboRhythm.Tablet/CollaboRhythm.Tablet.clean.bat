::cls
@echo off

:: ***************************************************************************************
:: Note: before using this install script you should change the variables below

set AndroidADBFolder=C:\Program Files (x86)\Android\android-sdk\platform-tools
:: Android default path used to include the word "windows", so you might need this depending on the version you have
::set AndroidADBFolder=C:\Program Files (x86)\Android\android-sdk-windows\platform-tools
::set SettingsFile=my_settings_debug.xml
set SettingsFile=%USERPROFILE%\AppData\Roaming\CollaboRhythm.Tablet.debug\Local Store\settings.xml
set CollaboRhythmTabletApk=CollaboRhythm.Tablet.apk

:: ***************************************************************************************

color f9
echo -----------------------------------------------------------------------
echo Removing CollaboRhythm Tablet on your Android device...
echo.
echo Please do not close this window.
::echo   After the application is installed and launched this screen will close automatically.
echo.
echo Settings: %SettingsFile%
echo.

"%AndroidADBFolder%"\adb shell rm "/data/local/air.CollaboRhythm.Tablet.debug/CollaboRhythm.Tablet.debug/Local Store/settings.xml"
"%AndroidADBFolder%"\adb shell rm "/data/local/air.CollaboRhythm.Tablet.debug/CollaboRhythm.Tablet.debug/Local Store/plugins/*"
"%AndroidADBFolder%"\adb shell rmdir "/data/local/air.CollaboRhythm.Tablet.debug/CollaboRhythm.Tablet.debug/Local Store/plugins"

"%AndroidADBFolder%"\adb -d uninstall air.CollaboRhythm.Tablet.debug

echo.
echo Remove complete for %CollaboRhythmTabletApk%
echo.

pause
