CollaboRhythm Developer Setup Instructions
==========================================

To prepare your machine for CollaboRhythm development:
------------------------------------------------------

1. Download IntelliJIDEA 11.0.1 (Ultimate version – 30 day trial, note
   that it is free for open-source projects, they have some qualifications
   that we do not yet meet but hope to meet soon)

      [http://www.jetbrains.com/idea/download/download\_thanks.jsp](http://www.jetbrains.com/idea/download/download_thanks.jsp)

2. Install IntelliJIDEA 11.0.1

3. Run IntelliJ, It will run an “Initial Configuration Wizard”

     a. VCS - disable all except Git.

     b. Web/JavaEE Technology Plugins - disable all

     c. HTML/JavaScript Dev Plugins - leave them all enabled

     d. Maven - disable

     e. Other - leave them all enabled

4. Download Git (Git-1.7.8-preview20111206 or whatever version is
   recommended for your OS)

      [http://code.google.com/p/msysgit/downloads/list?can=3](http://code.google.com/p/msysgit/downloads/list?can=3)

5. Install Git and set up Git by following the official guide here:
      [http://help.github.com/win-set-up-git/](http://help.github.com/win-set-up-git/)

6. In IntelliJ, set the location of the Git executable in the Git page
   of the Settings dialog box

     a. File -\> Settings

     b. Version Control -\> VCSs -\> Git

     c. Path to git executable: C:\\Program Files (x86)\\Git\\bin\\git.exe

7. Download the latest Flex SDK version 4.6.0.23201B

      [http://opensource.adobe.com/wiki/display/flexsdk/download?build=4.6.0.23201B&pkgtype=1](http://opensource.adobe.com/wiki/display/flexsdk/download?build=4.6.0.23201B&pkgtype=1)

8. Unzip the file and place the contents of the zip file (readme.htm,
   ant, asdoc, frameworks, etc.) in a new directory named “4.6.0” in the
   following location “C:\\Program Files (x86)\\Adobe\\Flex\\sdks\\4.6.0”
   (you will need to create this directory). After copying the SDK files
   you should have the following: “C:\\Program Files
   (x86)\\Adobe\\flex\\sdks\\4.6.0\\readme.htm”

9. In IntelliJ, import settings.

     a. Click File -\> Export Settings… and backup your own settings first.

     b. Save the provided settings JAR file to your desktop or somewhere
       convenient.

     c. Download the CollaboRhythm settings from [https://github.com/downloads/newmediamedicine/CollaboRhythm/CollaboRhythm_IntelliJIdea11_Settings_2012.01.10.jar](https://github.com/downloads/newmediamedicine/CollaboRhythm/CollaboRhythm_IntelliJIdea11_Settings_2012.01.10.jar)

     d. Click File -\> Import Settings…

     e. Select the settings JAR file you downloaded from CollaboRhythm and click OK.

     f. Click OK to import all settings.

     g. Click OK to restart IntelliJ.

10. In IntelliJ, set the location of the Flex sdk in the Path Variable
    page of the Settings dialog box

     a. Click File -\> Settings

     b. Select “Path Variable”

     c. PROJECT\_FRAMEWORKS: C:\\Program Files (x86)\\Adobe\\Flex\\sdks\\4.6.0\\frameworks

11. Ensure that the SDK settings are correct.

     a. Click File -\> Project Structure…

     b. Select “SDKs” under “Platform Settings”

     c. Select “4.6.0 AIR”. AIR SDK home path should be “C:\\Program Files
(x86)\\Adobe\\flex\\sdks\\4.6.0”. If “4.6.0 AIR” does not exist, add it
by clicking the Add New SDK button (+) and specifying the correct path.

     d. Select “4.6.0 AIR Mobile”. AIR SDK home path should be “C:\\Program
Files (x86)\\Adobe\\flex\\sdks\\4.6.0”. If “4.6.0 AIR Mobile” does not
exist, add it by clicking the Add New SDK button (+) and specifying the
correct path.

12. Download Java SE Development Kit Update 25 (Windows x64)

      [http://www.oracle.com/technetwork/java/javase/downloads/jdk-6u25-download-346242.html](http://www.oracle.com/technetwork/java/javase/downloads/jdk-6u25-download-346242.html)

      (This is a dependency for the Android SDK)

13. Install the Java SE Development Kit

14. Download Android SDK (the recommended windows installer)

      [http://developer.android.com/sdk/index.html](http://developer.android.com/sdk/index.html)

15. Install the Android SDK – This will automatically open the Android
    SDK and AVD Manager. Accept All and Install. (Note that if the Android
    SDK does not detect that the JDK was installed, click back and then
    forward again or restart the installation.)

To fork CollaboRhythm:
----------------------

1. Decide who on your team will create and manage the fork.

2. Login to GitHub (create an account if you don’t have one already).

3. Navigate to
      [https://github.com/newmediamedicine/CollaboRhythm](https://github.com/newmediamedicine/CollaboRhythm)

4. Click on the Fork button in the top right of the page.

5. Click on the Admin button

6. Rename your forked repository appropriately, such as
   “CollaboRhythmMayo”. Avoid using spaces in the repository name.

7. Add collaborators (you can repeat this process at a later time to
   give write access to other team members)

     a. Ensure that each team member has created a GitHub account

     b. Click on the Admin button

     c. Click Collaborators

     d. For each collaborator, enter the GitHub account name you wish to add
        and click Add

     e. When you are done, click on Back to Source

8. Note the SSH (Read+Write access) URI for your repository, such as
   git@github.com:user1/CollaboRhythmMayo.git (you can use this to clone
   the repository locally; for the process below using IntelliJ you won’t
   need this)

To clone and use a fork of CollaboRhythm:
-----------------------------------------

1. Open IntelliJ

2. Click on Version Control -\> Checkout from Version Control -\>
   GitHub

3. Enter or create a master password if prompted

4. Enter your GitHub credentials and click Login

5. You will prompted to “Select repository to clone”. Select the forked
   repository that you created (or was created for your team), such as
   CollaboRhythmMayo

6. Choose and specify an appropriate location for the Parent Directory
   to store your git repositories, such as
   C:\\Users\\user1\\Documents\\GitRepositories\\ (create the directory if
   it does not exist).

7. Specify the Directory Name. You should probably choose the same name
   as the forked repository, such as CollaboRhythmMayo

8. You will be prompted for the SSH Key Passphrase. Specify your local
   SSH passphrase that you defined when you set up Git.

9. The repository will be downloaded. You will then be prompted “You
   have checked out an IntelliJ IDEA project: <your path\> Would you like
   to open it?”. Click Yes to open the existing project.

10. If you have another project open you will be prompted to open the
    project in a new or existing window. Make an appropriate choice to
    continue and the project will open.

11. If you want to build CollaboRhythm.Android.DeviceGateway you will
    need to copy the file BluetoothSocketThread.java to the following
    location:
      <CollaboRhythmRepositoryLocation\>\\CollaboRhythm.Android.DeviceGateway\\src\\collaboRhythm\\android\\deviceGateway\\BluetoothSocketThread.java.
    If you do not have this file and do not need to build this module, you
    can skip this step and ignore the corresponding build error (step 13
    below). If you do not build CollaboRhythm.Android.DeviceGateway you can
    still install it by downloading the latest build and installing the APK
    file.

12. Click Build -\> Make Project.

13. If everything is configured correctly, all of the modules in the
    project should build successfully, with some warnings but no errors.
    Confirm that all modules are built and resolve any errors if necessary.

14. Click View -\> Tool Windows -\> Ant Build

15. Select PluginDeployment and run it by clicking on the green run
    arrow icon in the Ant Build window. This will deploy all the plugin
    files (except CataractMap, which we are excluding for now) to the
    appropriate folders locally and on a connected Android device (if any).

16. Confirm that the plugins successfully deployed be inspecting the
    following locations:

     a. %APPDATA%\\CollaboRhythm.Workstation\\Local Store\\plugins

     b. %APPDATA%\\CollaboRhythm.Mobile.debug\\Local Store\\plugins

     c. %APPDATA%\\CollaboRhythm.Tablet.debug\\Local Store\\plugins

17. Unzip the provided settings.zip file to %APPDATA%. This should
    create the following files:

     a. %APPDATA%\\CollaboRhythm.Workstation\\Local Store\\settings.xml

     b. %APPDATA%\\CollaboRhythm.Mobile.debug\\Local Store\\settings.xml

     c. %APPDATA%\\CollaboRhythm.Tablet.debug\\Local Store\\settings.xml

18. Select the run configuration for CollaboRhythm.Workstation

19. Debug CollaboRhythm.Workstation

20. The application should open with no errors. You should see Robert
    Pool’s record open and various widgets. Scroll to the far right of the
    widgets to find the clock and click on it. You should see the medication
    scheduling app open below the widgets.

21. Press the Esc key to exit CollaboRhythm.Workstation.

22. You can also test “CollaboRhythm.Tablet Emulator” and
    “CollaboRhythm.Mobile Emulator”, and if you have a properly configured
    Android device connected, you can try “CollaboRhythm.Tablet Device” and
    “CollaboRhythm.Mobile Device”.

To pull upstream changes from the main CollaboRhythm repository:
----------------------------------------------------------------

1. Open Git Bash

2. Navigate to your repository, such as `cd Documents/GitRepositories/CollaboRhythmMayo`

3. `git remote add upstream git://github.com/newmediamedicine/CollaboRhythm.git`

4. `git fetch upstream`

5. Open IntelliJ

6. Click Version Control -\> Git -\> Pull Changes

7. For Remote, select “upstream” (default is origin)

8. Check the box next to “master”.

9. Click Pull.

10. You should get all changes from the main repository. If there are
    any merge conflicts, you should be prompted to resolve them manually.

Ensuring that the ActionScript documentation is accessible from within IntelliJ
-------------------------------------------------------------------------------

1. Click File -\> Project Structure

2. Click SDKs

3. Click 4.6.0 AIR

4. Click the “Documentation Paths” tab

5. Click the “Specify URL…” button

6. Specify
      [http://help.adobe.com/en\_US/FlashPlatform/reference/actionscript/3/index.html?filter\_flex=4.6&filter\_flashplayer=11.1&filter\_air=3.1](http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/index.html?filter_flex=4.6&filter_flashplayer=11.1&filter_air=3.1)

7. Click “OK”

8. Click “Apply”

9. Repeat 3-8 on 4.6.0 AIR Mobile

To debug to a Motorola Xoom tablet
----------------------------------

1. Do no connect the Motorola Xoom via USB yet.

2. Download the Motorola USB drivers for Windows 7 64-bit on the
    development PC (Note that you may have to create an account)

      [http://developer.motorola.com/docstools/USB_Drivers/Handset_USB_Driver_64/](http://developer.motorola.com/docstools/USB_Drivers/Handset_USB_Driver_64/)

3. Install the Motorola USB drivers on the development PC

4. On the Motorola Xoom tablet, go to Settings -\> Applications
    -\>Development and check off “USB debugging”

5. Connect the Xoom to the development PC via USB

6. On the development PC, it should say that it is installing drivers

7. Using the “CollaboRhythm.Tablet Device” run configuration to run or
    debug the CollaboRhythm.Tablet application on the tablet.
