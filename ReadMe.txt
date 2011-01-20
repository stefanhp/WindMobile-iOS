iPhone client
=============

How to build
------------
iPhone targets need to be build/tested for several base SDK (3.1.3, 3.2, 4) and several architectures (armv6, armv7, x86 for simulator).
For that reason, it is more convenient to link sub-projects rather than libraries (otherwise we need several versions of the libraries for each SDK/architecture combination).

The WindMobile iPhone client uses several linked projects. You need to check them out in the current directory or create a symbolic link from here to those projects. They are:

1/ ReST framework:
     folder/link name: cps-rest
     check out: svn checkout https://cps-rest.googlecode.com/svn/trunk/ cps-rest --username yourname
     read-only: svn checkout http://cps-rest.googlecode.com/svn/trunk/ cps-rest
     project: http://code.google.com/p/cps-rest/  

2/ Graphing framework:
     folder/link name: core-plot
     local repository: hg clone https://core-plot.googlecode.com/hg/ core-plot
     project: http://code.google.com/p/core-plot/  

After that the list of items in this folder should be:
core-plot     (Graphing framework or symbolic link to it)
cps-rest      (ReST framework or symbolic link to it)
Images-source (Source files, typically photoshop, of icons and other resources)
ReadMe.txt    (This file)
WindMobile    (The iPhone client project)

To build, either open WindMobile/WindMobile.xcodeproj with xCode and choose the target to build, or run the "xcodebuild" command line from the WindMobile directory.

Enjoy.


2010-04-16