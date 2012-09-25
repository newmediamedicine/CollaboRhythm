ActionScript Test Unit compact edition CLI
==========================================
You can find the latest version of ASTUce on http://astuce.googlecode.com

ASTUce as an AS3 library is a regression testing framework inspired by the xUnit architecture.
This framework is intended for developers who wish to implement unit tests in ActionScript 3.0.
(you can also find other implementation on the project page for JS/AS1/AS2)

ASTUce as an executable reuse the AS3 library and
provide 3 executables to run AS3 unit tests on the command line.

  ASTUce     for OS X
  ASTUce.nix for Linux
  ASTUce.exe for Windows

Dependencies
============
ASTUce reuse part of the maashaack framework (http://maashaack.googlecode.com).
ASTUce reuse the edenrr library (http://edenrr.googlecode.com).
ASTUce reuse the redtamarin shell (http://redtamarin.googlecode.com).

We reuse the debug version of redshell so you'll have a full error stacktrace when needed.

The exe on all operating system have no dependencies (just drag n drop n use).

Installation from sources
=========================

from subversion you can do
$svn co http://astuce.googlecode.com/svn/cli/trunk/ astuce-cli
or
$svn co http://astuce.googlecode.com/svn/cli/tags/0.1 astuce-cli-v0.1

and then use ant to build

Some basic usage and infos
==========================

if you run the exe without any arguments or with -? you will obtain this help

ASTUce: [-?] [-s] [-v] [-d] [-l:<filepath>] <classname> [, <classnameN>]
             -?    show this help
             -s    run ASTUce self tests
             -v    verbose
             -d    dump the config file 'config.eden'
  -l:<filepath>    load a precompiled library
                   either an *.abc or a *.swf file
                   [repeatable]
    <classname>    the unit test(s) class(es) to execute


ASTUce work in sync with the AS3 library of the same name,
that means no it will not run unit tests written with FlexUnit, AsUnit, etc.

ASTUce is not an AS3 compiler, so to be able to run
your AS3 unit tests you will need to compile them first
or provide *.swf or *.abc files that contains pre-compiled unit tests.

example:
  1. use Flex Builder or Flash IDE
  2. define your unit tests with the ASTUce library
  3. generate a *.swf, mytests.swf
  4. use ASTUce
     to load the *.swf containing the tests
     and to execute your TestCase or TestSuite (or static suite() method)
     $ ./ASTUce -l:mytests.swf my.package.AllTests

At first-run the executable autogenerate (if not found)
its configuration 'config.eden' which is a simple text file
(based on the eden format, see: http://code.google.com/p/edenrr/wiki/edenFeatures)

you can find more infos on the different settings here:
http://code.google.com/p/astuce/source/browse/trunk/as3/src/buRRRn/ASTUce/ASTUceConfigurator.as

you can edit the config file 'config.eden' as it was JS file,
it supports types, comments, etc.

example:
  1. run the ASTUce exe
  2. oh shoo, no error stacktrace ?
  3. edit config.eden
     change:
     allowStackTrace     = false;
     to:
     allowStackTrace     = true;
  4. re-run the ASTUce exe
  5. yipeee error stacktrace

Now if you want to use it in Ant here a very basic example

        <exec executable="./build/bin/ASTUce" failonerror="true">
            <arg line="-l:mytests.swf" />
            <arg line="my.package.AllTests" />
        </exec>


And if you want to do the same for different OS

    <condition property="ASTUCE" value="build/bin/ASTUce">
        <os family="mac"/>
    </condition>
    
    <condition property="ASTUCE" value="build/bin/ASTUce.exe">
        <os family="windows" />
    </condition>
    
    <condition property="ASTUCE" value="build/bin/ASTUce.nix">
        <os family="unix" />
    </condition>

        <exec executable="${ASTUCE}" failonerror="true">
            <arg line="-l:mytests.swf" />
            <arg line="my.package.AllTests" />
        </exec>

Ideally you would want to have mxmlc generating a *.swf of your unit tests
and then pass this *.swf to the ASTUce executable.


Documentation
=============
You can also find more informations on the project wiki
http://code.google.com/p/astuce/wiki

Problem
=======
Please send any usage questions to http://groups.google.com/group/FCNG
Please report issues to http://code.google.com/p/astuce/issues (precise the version CLI 0.1.0.130)

