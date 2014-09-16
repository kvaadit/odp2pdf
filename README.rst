Convert LibreOffice slides to PDF while preserving animations
#############################################################

:author: "Aadithya V. Karthik" <aadithya@berkeley.edu>
:date: Sep 11, 2014

This is ``odp2pdf``, a simple bash script that converts an odp presentation into
PDF while preserving animations. (Well, fancy transitions in the animations are
not supported, but the vanilla appear and disappear effects should work.).

You give ``odp2pdf`` the name of your odp file, and ``odp2pdf`` automatically
does the following: 

#. It opens the file in LibreOffice.
#. It switches LibreOffice to slideshow mode. 
#. It forces the slideshow to proceed along as though you were repeatedly 
   pressing the down arrow key.
#. At each (animated) turn of the slideshow, it grabs a screenshot of the 
   slideshow.
#. It stitches all these screenshots into a single PDF.
#. Finally, it compresses the PDF so you're not left with a file that's hundreds 
   of MB in size.

Dependencies
============

In addition to standard things like ``mv``, ``cp``, ``awk``, ``grep``, *etc.*,
this script needs ``xrandr``, ``xwininfo``, ``xwd``, imagemagick's ``convert``
utility, ``xdotool``, ``pdftk``, ``pdftops``, and ``ps2pdf``. If you use a
popular Linux distribution, your package manager probably provides all these. If
you use an esoteric distribution that nobody has heard of, you probably know how
to get these for said distribution.

Installation
============

#. Get ``odp2pdf``:

   ``$ git clone https://github.com/aadithyakv/odp2pdf.git``

#. Put the ``odp2pdf.sh`` script somewhere on your path and make sure you have 
   execute permissions on it.

Usage
=====

``$ ./odp2pdf.sh [options] /path/to/input/odp``

+------------------------------------------------+-----------------------------------------------------------------------+
|                    Option                      |                              Description                              |
+================================================+=======================================================================+
| ``-o, --output path/to/output/PDF``            | This option specifies the output file. By default, the output PDF is  |
|                                                | saved in the same directory as the input ODP, and has the same        |
|                                                | basename as the input ODP.                                            |
+------------------------------------------------+-----------------------------------------------------------------------+
| ``-r, --resolution widthxheight``              | If this option is present, ``odp2pdf`` first changes the resolution   |
|                                                | of your display to widthxheight, and then opens LibreOffice to grab   |
|                                                | the screenshots (so that the screenshots are all of size              |
|                                                | ``widthxheight``). At the end, ``odp2pdf`` changes back your          |
|                                                | display's resolution to whatever it was initially.                    |
+------------------------------------------------+-----------------------------------------------------------------------+
| ``-i, --interval nseconds``                    | Default: 1. This is the interval to wait between taking successive    |
|                                                | screenshots (or successive presses of the Down arrow key). Sometimes, |
|                                                | LibreOffice takes a while to render your slide, and this option helps |
|                                                | you accommodate that.                                                 |
+------------------------------------------------+-----------------------------------------------------------------------+
| ``-l, --libreoffice-launch-interval nseconds`` | Default: 5. This is the interval to wait for LibreOffice to start up. |
+------------------------------------------------+-----------------------------------------------------------------------+
| ``-s, --slideshow-launch-interval nseconds``   | Default: 2. This is the interval to wait for the slideshow to start.  |
+------------------------------------------------+-----------------------------------------------------------------------+
| ``-n, --no-compress``                          | If this option is present, the generated PDF is not compressed. Note: |
|                                                | By default, the PDF is compressed. If you use this option, be         |
|                                                | prepared to get PDFs with very large file size.                       |
+------------------------------------------------+-----------------------------------------------------------------------+
| ``-f, --offset noffset``                       | Default: 1. ``odp2pdf`` grabs screenshots until the LibreOffice       |
|                                                | slideshow ends. The end of the slideshow is detected when there is no |
|                                                | longer a fullscreen window associated with LibreOffice. At this time, |
|                                                | the collected screenshots are merged. But the last such collected     |
|                                                | screenshot is usually an image that just says 'Click to end           |
|                                                | slideshow'. So the last screenshot is ignored. This option lets you   |
|                                                | specify a different number of screenshots to ignore.                  |
+------------------------------------------------+-----------------------------------------------------------------------+
| ``-p, --prompt``                               | If this option is present, ``odp2pdf`` prompts you (after grabbing    |
|                                                | all the screenshots) to enter how many screenshots to merge. You can  |
|                                                | look at the individual PDF files, change them if you like and so on   |
|                                                | before asking ``odp2pdf`` to merge them.                              |
+------------------------------------------------+-----------------------------------------------------------------------+
| ``-h, --help``                                 | Print this usage message and exit.                                    |
+------------------------------------------------+-----------------------------------------------------------------------+

Examples
========

#. Convert test.odp into test.pdf:

   ``$ ./odp2pdf.sh test.odp``

#. Convert test.odp into test_1024x768.pdf, grabbing 1024x768 screenshots:

   ``$ ./odp2pdf.sh -r 1024x768 -o test_1024x768.pdf test.odp``

#. Convert test.odp into test.pdf, but wait 2s between taking successive 
   screenshots instead of the customary 1s:

   ``$ ./odp2pdf.sh -i 2 test.odp``


Limitations
===========

#. No support for multiple displays. If you have a dual monitor setup, this 
   script won't work (because the end-of-slideshow detection will fail).

#. End-of-slideshow detection is a kludge at best.

#. The output PDF is just a bunch of images. There are no finer aspects like 
   arrows, shapes, text, etc. in this PDF.

#. Script requires xrandr to work, which is not always the case (especially 
   with certain Nvidia graphics cards).
 
#. The main LibreOffice window is not closed at the end of the slideshow. I 
   don't know a graceful way to do this from within a script.

