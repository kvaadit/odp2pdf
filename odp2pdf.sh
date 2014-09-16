#! /usr/bin/env bash

function usage()
{
    echo ""
    echo " Usage: ./odp2pdf.sh [options] /path/to/input/odp"
    echo ""
    echo " Options:"
    echo ""
    echo "   -o, --output path/to/output/PDF"
    echo "       This option specifies the output file. By default, the output PDF is "
    echo "       saved in the same directory as the input ODP, and has the same basename "
    echo "       as the input ODP."
    echo ""
    echo "   -r, --resolution widthxheight"
    echo "       If this option is present, odp2pdf first changes the resolution of your "
    echo "       display to widthxheight, and then opens LibreOffice to grab the "
    echo "       screenshots (so that the screenshots are all of size widthxheight). At "
    echo "       the end, odp2pdf changes back your display's resolution to whatever it "
    echo "       was initially."
    echo ""
    echo "   -i, --interval nseconds (default: 1)"
    echo "       This is the interval to wait between taking successive screenshots (or "
    echo "       successive presses of the Down arrow key). Sometimes, LibreOffice takes "
    echo "       a while to render your slide, and this option helps you accommodate "
    echo "       that."
    echo ""
    echo "   -l, --libreoffice-launch-interval nseconds (default: 5)"
    echo "       This is the interval to wait for LibreOffice to start up."
    echo ""
    echo "   -v, --libreoffice-version path/to/libreoffice/binary"
    echo "       This option lets you choose the version of LibreOffice to use."
    echo ""
    echo "   -s, --slideshow-launch-interval nseconds (default: 2)"
    echo "       This is the interval to wait for the slideshow to start."
    echo ""
    echo "   -n, --no-compress"
    echo "       If this option is present, the generated PDF is not compressed. Note: By "
    echo "       default, the PDF is compressed. If you use this option, be prepared to "
    echo "       get PDFs with very large file size."
    echo ""
    echo "   -f, --offset noffset (default: 1)"
    echo "       odp2pdf grabs screenshots until the LibreOffice slideshow ends. The end "
    echo "       of the slideshow is detected when there is no longer a fullscreen window "
    echo "       associated with LibreOffice. At this time, the collected screenshots are "
    echo "       merged. But the last such collected screenshot is usually an image that "
    echo "       just says 'Click to end slideshow'. So the last screenshot is ignored. "
    echo "       This option lets you specify a different number of screenshots to "
    echo "       ignore."
    echo ""
    echo "   -p, --prompt"
    echo "       If this option is present, odp2pdf prompts you (after grabbing all the "
    echo "       screenshots) to enter how many screenshots to merge. You can look at the "
    echo "       individual PDF files, change them if you like and so on before asking "
    echo "       odp2pdf to merge them."
    echo ""
    echo "   -h, --help"
    echo "       Print this usage message and exit."
    echo ""
    echo " Examples:"
    echo ""
    echo "   1. Convert test.odp into test.pdf:"
    echo ""
    echo "       $ ./odp2pdf.sh test.odp"
    echo ""
    echo "   2. Convert test.odp into test_1024x768.pdf, grabbing 1024x768 screenshots:"
    echo ""
    echo "       $ ./odp2pdf.sh -r 1024x768 -o test_1024x768.pdf test.odp"
    echo ""
    echo "   3. Convert test.odp into test.pdf, but wait 2s between taking successive "
    echo "      screenshots instead of the customary 1s:"
    echo ""
    echo "       $ ./odp2pdf.sh -i 2 test.odp"
    echo ""
}

# parse arguments

resolution=
interval="1"
outfile=
infile=
offset="1"
prompt=
lo_launch_interval="5"
slideshow_launch_interval="2"
lo_version="libreoffice"
no_compress=""
while [ $# -gt 0 ]; do
    case "$1" in
	    --resolution|-resolution|-r) shift; resolution="$1";;
        --interval|-interval|-i) shift; interval="$1";;
        --output|-output|-o) shift; outfile="$1";;
        --offset|-offset|-f) shift; offset="$1";;
        --prompt|-prompt|-p) prompt="YES";;
        --no-compress|-no-compress|-n) no_compress="YES";;
        --libreoffice-launch-interval|-libreoffice-launch-interval|-l) shift; lo_launch_interval="$1";;
        --libreoffice-version|-libreoffice-version|-v) shift; lo_version="$1";;
        --slideshow-launch-interval|-slideshow-launch-interval|-s) shift; slideshow_launch_interval="$1";;
        --help|-help|-h) usage; exit 0;;
        -*) usage; exit 0;;
        *) infile="$1";;
    esac
    shift
done

if [ "X""$outfile" = "X" ]; then
    outfile=$(dirname $(readlink -f "$infile"))"/"$(basename -s .odp "$infile")".pdf"
else
    outfile=$(readlink -f "$outfile")
fi

# arguments parsed

# how many displays are connected?
# anything other than 1 is not supported

num_xrandr_outs=$(xrandr | grep " connected" | awk {'print $1'} | wc -l)
if [ ! "$num_xrandr_outs" = "1" ]; then
    echo "ERROR: More than one connected display detected."
    exit 0
fi

# change the screen resolution if necessary

if [ ! "X""$resolution" = "X" ]; then

    # resolution argument is given

    # record current resolution, display
    xrandr_output=$(xrandr | grep " connected" | awk {'print $1'})
    xrandr_mode=$(xrandr | grep \* | awk {'print $1'})

    # change the resolution based on the given argument
    echo "Changing the resolution of ""$xrandr_output"" ..."
    xrandr --output "$xrandr_output" --mode "$resolution"
    sleep 2

fi

current_screen_resolution=$(xrandr | grep \* | awk {'print $1'})

# open the input file in libreoffice

echo "Opening ""$infile"" in LibreOffice ..."
"$lo_version" "$infile" 1>/dev/null 2>/dev/null &
# libreoffice_PID="$!"

echo "Waiting ""$lo_launch_interval""s for LibreOffice to open ..."
sleep "$lo_launch_interval"

# switch to the LibreOffice window

infile_basename=$(basename "$infile")

num_loffice_windows=$(xwininfo -tree -root | grep -i libreoffice | grep "$infile_basename" | wc -l)
if [ ! "$num_loffice_windows" = "1" ]; then
    echo "ERROR: There should be exactly one LibreOffice window detected for the given file. Now there are ""$num_loffice_windows""."
    exit 0
fi

echo "Switching to the LibreOffice window ..."
xdotool windowactivate "$(xwininfo -tree -root | grep -i libreoffice | grep "$infile_basename" | awk {'print $1'})" 1>/dev/null 2>/dev/null

# start the LibreOffice slideshow
echo "Starting the LibreOffice slideshow ..."
xdotool key F5

echo "Waiting ""$slideshow_launch_interval""s for the slideshow to start ..."
sleep "$slideshow_launch_interval"

if [ "X""$TMPDIR" = "X" ]; then
    TMPDIR="/tmp"
fi

echo "Setting up odp2pdf ..."
screenshots_dir="$TMPDIR""/odp2pdf-slideshow-screenshots-""$$"
mkdir "$screenshots_dir"
cd "$screenshots_dir"

# start recording screenshots
    # record them for as long as there is at least one libreoffice window whose
    # size (as printed out by xwininfo -tree -root) matches the screen's 
    # resolution. If there is no such window, the slideshow must have ended, so
    # stop recording screenshots

echo "Recording PDF screenshots in ""$screenshots_dir"" ..."

idx=1
while [ $(xwininfo -tree -root | grep -i libreoffice | grep -i "$current_screen_resolution" | wc -l) -ge "1" ];
do
    # record a screenshot
    xwd -root > "$idx".xwd

    # convert the screenshot from XWD to PDF
    convert "$idx".xwd "$idx".pdf

    # remove the XWD file
    rm "$idx".xwd

    # increment the idx for the next iteration
    idx=$((idx+1))

    # simulate a down arrow press for the slideshow to advance
    xdotool key Down

    # wait for an interval of time for the slideshow to advance
    sleep "$interval"
done

# done recording screenshots
echo "Done recording screenshots."

# merge screenshots into a single PDF

echo "Merging screenshots into a single PDF file (""$screenshots_dir""/all.pdf) ..."

if [ "X""$PROMPT" = "X" ]; then
    num_screenshots=$((idx-1-offset))
else
    read -p "Enter the number of screenshots to merge: " -e num_screenshots
fi

# build the pdftk command that will merge the screenshots

cmd="pdftk"
idx=1
while [ "$idx" -le "$num_screenshots" ];
do
    cmd="$cmd"" ""$idx"".pdf"
    idx=$((idx+1))
done
cmd="$cmd"" cat output all.pdf"

# run the pdftk command

eval "$cmd"

# hopefully, all.pdf should have been created by now

if [ "X""$no_compress" = "X" ]; then

    # compress all.pdf

    echo "Compressing ""$screenshots_dir""/all.pdf ..."
    pdftops all.pdf
    mv all.ps all2.ps
    ps2pdf all2.ps
    rm all2.ps all.pdf
    mv all2.pdf all.pdf

fi

# move all.pdf to outfile
echo "Moving ""$screenshots_dir""/all.pdf to ""$outfile"" ..."
mv all.pdf "$outfile"

# clean up
echo "Cleaning up ..."
cd ../
rm -fr "$screenshots_dir"

# if necessary, change the resolution back to what it was originally

if [ ! "X""$resolution" = "X" ]; then
    echo "Changing the resolution of ""$xrandr_output"" back to ""$xrandr_mode"" ..."
    xrandr --output "$xrandr_output" --mode "$xrandr_mode"
    sleep 2
fi

echo "Done!"

echo ""
echo "Note: Please close the LibreOffice window. I don't know a graceful way to do it from within a script."

