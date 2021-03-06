#!/usr/bin/env bash
# inspired by https://github.com/keroserene/rickrollrc

tmpdir=$(mktemp -d /tmp/christma.sh-XXXXX)

audio=$tmpdir/faithnoel # nonexistant file to be downloaded later
audioOgg="https://drive.google.com/uc?id=0B2wzVJ8L65DfV250ZGN6aHREZWs&export=download"
audioMp3="https://drive.google.com/uc?id=0B2wzVJ8L65DfVjJ0aWYxUWREVVk&export=download"
audioWavUrls=( # this is an array of all .wav files to be iterated through
    "https://drive.google.com/uc?id=0B2wzVJ8L65DfYmFQZDI5WU5aQ3M&export=download"
    "https://drive.google.com/uc?id=0B2wzVJ8L65DfaUVMZmFBQ2tYblk&export=download"
)
audioPid=0

frames="$tmpdir/frames" # nonexistant directory to be created and filled later
framesUrl="https://raw.githubusercontent.com/severus-tux/personal/master/frames.tar.xz"
currentFrame=0
totalFrames=0

########## functions

function quit() {
    kill -9 $audioPid 2> /dev/null
    rm -rf $tmpdir
    tput cnorm
    clear
    ! [ -z "$1" ] && echo "$1"
    echo "Hope you have a Merry Christmas and a Happy New Year!"
    exit 0
}

function checkcmd() {
    command -v $1 > /dev/null
}
function grab() {
    # grab /path/to/output http://path/to/source
    if checkcmd wget; then
        wget -qO "$2" $1
    elif checkcmd curl; then
        curl -Lso "$2" $1
    else
        quit "curl and wget are not available; cannot download resources."
    fi
}

########## play

trap quit SIGINT SIGTERM
tput civis

# setup frames
mkdir -p $frames

echo "Downloading frames..."
grab "$framesUrl" $tmpdir/frames.tar.xz

ls $tmpdir

echo "Decompressing frames..."
tar -xvf $tmpdir/frames.tar.xz -C $frames/
rm $tmpdir/frames.tar.xz
find $frames -type f -exec mv {} $frames \; 2> /dev/null
totalFrames=$(find $frames -type f | wc -l)

# setup and play music
function grabAudio() {
    # this could just run once before the media player checks, but then systems
    # with audio players that don't support ogg would have to download twice.
    echo "Downloading audio..."
    grab "$audioOgg" $audio
}
if checkcmd ffplay; then
    grabAudio
    ffplay -autoexit -nodisp -loglevel 8 $audio &
elif checkcmd play; then
    grabAudio
    play -q $audio &
elif checkcmd mpv; then
    grabAudio
    mpv --really-quiet $audio &
elif checkcmd mplayer; then
    grabAudio
    mplayer -really-quiet -noconsolecontrols $audio 2> /dev/null &
elif checkcmd clvc; then
    grabAudio
    cvlc --no-osd --quiet $audio 2> /dev/null &
elif checkcmd afplay; then
    grab "$audioMp3" $audio
    afplay $audio &
elif checkcmd aplay; then

    (
        for part in "${audioWavUrls[@]}"; do
            grab "$part" - | aplay -q
        done
    ) &
else
    echo "No suitable audio player found."
fi
audioPid=$!

wget  -q -O- https://raw.githubusercontent.com/severus-tux/personal/master/snow.lua >./snow.lua
chmod +x snow.lua
# main animation loop
while true :; do
    if ! [ $audioPid -eq 0 ] && ! [ -z "$audioPid" ] && ! [ $(ps -p $audioPid | wc -l) -gt 1 ]; then
        quit
    fi
    clear
    currentFrame=$(($currentFrame+1))
    #echo -e "audioPid: $audioPid | currentFrame: $currentFrame | currentFrame mod total: $(($currentFrame%$totalFrames))"
    ./snow.lua $frames/$(($currentFrame%$totalFrames))
    sleep 0.5
done
