odp2pdf: Convert LibreOffice slides to PDF while preserving animations
######################################################################

:author: "Aadithya V. Karthik" <aadithya@berkeley.edu>
:date: Sep 11, 2014

This is odp2pdf, a simple bash script that converts an odp presentation into PDF
while preserving animations. Well, fancy transitions in the animations are not
supported, but the vanilla appear and disappear effects should work.

If you're like me, you use LibreOffice to make presentations. Not necessarily
because it's the best tool for the job, but because it's (pretty much) the only
presentation tool available on Linux.

But from time to time, you find that can't work purely in LibreOffice, with an
ODP version of your slides: you also need a PPT/PDF version.

Much of the time, you're asked for PPT/PDF slides because you're required to
present from a laptop that someone else provides. This is often the case if the
presentation is being webcast live to a wider audience. Also sometimes, you are
just one in a long line of presenters, and there is no time to switch laptops in
the middle. So you have to use the same laptop as everyone else, and that laptop
may not have LibreOffice installed. Another situation where PPT/PDF slides come
in handy is when you need to share your presentation with someone who wants to
view it on a device/platform where LibreOffice is not available or too much of a
bother to get working correctly (e.g., on an iPad/iPhone).

"So what's the problem?", I hear you ask. After all, LibreOffice has the ability
to export to PowerPoint (PPT) and PowerPoint has the ability to import
LibreOffice (ODP) slides. The problem is that, unfortunately, neither of these
export/import functions works very well, and neither is likely to ever be able
to work flawlessly in the future. Why? Because these programs use widely
different formats, they often come with very different sets of fonts, the
features available on one are not available on the other, the styles and
templates available on them are not the same, etc.

So, unless you're willing to spend a lot of time manually tweaking the
appearance of the PPT exported from LibreOffice or imported by PowerPoint (not
to mention the headache of keeping the two versions in sync everytime you modify
either one of them), the only sane solution is to skip PowerPoint altogether and
use only PDF. LibreOffice's PDF export works much better than its PPT export,
and life is good.

Until you realize that when LibreOffice converts your slides into PDF, it
doesn't keep any of your animations. That wonderful slide that starts simple
and incrementally adds layers of complexity? Forget it, that's just one
complex mess now. The other slide where elements are disappearing and
appearing all over the place one on top of another? That's now one ugly page
where everything is drawn on top of everything else.

So what's the solution? odp2pdf.

What odp2pdf does is so simple that I'm amazed it didn't exist already. Or maybe
it did, but I just didn't know where to look for it. Anyway, you give this
script the name of your odp file, and it opens the file in LibreOffice, switches
to slideshow mode, forces the slideshow to proceed along as though you were
repeatedly pressing the down arrow key, grabs a screenshot at each turn,
stitches all these screenshots into a single PDF, and finally compresses the PDF
so you're not left with a file that's 100s of MB in size.

Dependencies
============

In addition to standard things like mv, cp, awk, grep, etc., this script needs
xrandr, xwininfo, xwd, imagemagick's convert utility, xdotool, pdftk, pdftops,
and ps2pdf. If you use a popular Linux distribution, your package manager
probably provides all these. If you use an esoteric distribution that nobody has
heard of, you probably know how to get these for said distribution.

Usage
=====

    $ ./odp2pdf.sh [options] /path/to/input/odp

Options
=======

-o, --output path/to/output/PDF
    This option specifies the output file. By default, the output PDF is 
    saved in the same directory as the input ODP, and has the same basename 
    as the input ODP.
-r, --resolution widthxheight
    If this option is present, odp2pdf first changes the resolution of your 
    display to widthxheight, and then opens LibreOffice to grab the 
    screenshots (so that the screenshots are all of size widthxheight). At 
    the end, odp2pdf changes back your display's resolution to whatever it 
    was initially.
-i, --interval nseconds (default: 1)
    This is the interval to wait between taking successive screenshots (or 
    successive presses of the Down arrow key). Sometimes, LibreOffice takes 
    a while to render your slide, and this option helps you accommodate 
    that.
-l, --libreoffice-launch-interval nseconds (default: 5)
    This is the interval to wait for LibreOffice to start up.
-s, --slideshow-launch-interval nseconds (default: 2)
    This is the interval to wait for the slideshow to start.
-n, --no-compress
    If this option is present, the generated PDF is not compressed. Note: By 
    default, the PDF is compressed. If you use this option, be prepared to 
    get PDFs with very large file size.
-f, --offset noffset (default: 1)
    odp2pdf grabs screenshots until the LibreOffice slideshow ends. The end 
    of the slideshow is detected when there is no longer a fullscreen window 
    associated with LibreOffice. At this time, the collected screenshots are 
    merged. But the last such collected screenshot is usually an image that 
    just says 'Click to end slideshow'. So the last screenshot is ignored. 
    This option lets you specify a different number of screenshots to 
    ignore.
-p, --prompt
    If this option is present, odp2pdf prompts you (after grabbing all the 
    screenshots) to enter how many screenshots to merge. You can look at the 
    individual PDF files, change them if you like and so on before asking 
    odp2pdf to merge them.
-h, --help
    Print this usage message and exit.


Examples
========

#. Convert test.odp into test.pdf:

       $ ./odp2pdf.sh test.odp

#. Convert test.odp into test_1024x768.pdf, grabbing 1024x768 screenshots:

       $ ./odp2pdf.sh -r 1024x768 -o test_1024x768.pdf test.odp

#. Convert test.odp into test.pdf, but wait 2s between taking successive 
   screenshots instead of the customary 1s:

       $ ./odp2pdf.sh -i 2 test.odp


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

