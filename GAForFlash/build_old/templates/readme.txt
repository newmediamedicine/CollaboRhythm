@project_fullname@
=========================================
The @project_name@ component files are compressed into a single ZIP file 
that you can download from @project.download@

The @project_name@ components can be used either within Flex builder, or the Flash IDE for 
AS3 based projects. The installation and usage of the gaforflash components differ depending 
on which environment you are using. 

Installation for Flash CS3/CS4
==========================
Before you begin to use @project_name@ to add Analytics tracking within Flash CS3/CS4,
you first need to add the @project_name@ SWC to Flash CS3.

To do so you have 2 options:
1. If you have Flash CS3/CS4 currently open, quit the application.

2. Use the Adobe Extension Manager to install the analytics.mxp extension file. 
   This will copy all the component library files into the user-based component location

-or-

1. If you have the Adobe Flash IDE currently open, quit the application. 

2. Create a Google directory in the following application-level locations: 

   For Flash CS3 users:
       Windows:  C:\Program Files\Adobe\Adobe Flash CS3\<language>\Configuration\Components 
       Mac OS X: Macintosh HD/Applications/Adobe Flash CS3/Configuration/Components 

   For Flash CS4 users:
       Windows:  C:\Program Files\Adobe\Adobe Flash CS4\<language>\Configuration\Components 
       Mac OS X: Macintosh HD/Applications/Adobe Flash CS4/Configuration/Components 

3. Navigate to the location where you unzipped the @project_name@ component ZIP file and copy the 
   following files to the Google folder you created in the previous step: 
       lib/@gaffa.swcfla@ — The Analytics Component 
       lib/@gaffa.swc@ — The Analytics Library Component 

4. Restart the Flash IDE.

To find and use the @project_name@ components, open the components panel by selecting 
Window -> Components. There will now be a Google folder which can be expanded to show 
the @project_name@ components. A @project_name@ component can now be dragged onto the stage 
for use in a Flash project.

Flash CS3/CS4 is now set up to support @project_fullname@.

Alternatively if you want to use @project_name@ in code-only mode
you can do the same as the above and add the lib/analytics.swc,
you will then need to drag the "AnalyticsLibrary" component in your Library.

Installation for Flex Builder 3
===============================
Flex builder utilizes .SWC component files on a per-project basis. In order to include 
the @project_name@ SWC in a Flex Builder project you can either add it to your project library:

1. Select Project->Properties. 
   A Properties dialog box will appear for your project.
   Click on Flex Build Path and then select the Library Path tab.

2. Click Add SWC... within the Library Path pane. 
   An Add SWC dialog box will appear.
   Navigate to the location where you unzipped the Google Analytics zip 
   and select lib/analytics.swc file and click OK.

or

Just drop the analytics.swc file into your Flex project /libs directory

Documentation
=============
Documentation of the @project_name@ code is in the /doc directory.

You can also consult the getting started documentation
http://code.google.com/apis/analytics/docs/flashTrackingIntro.html

and the project wiki for more advanced usage
@project_wiki@

Problems
=======
Please send any usage questions to @project_group@
Please report issues to @project_maintenance@ (with the precise version @release_version@)
