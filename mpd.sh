#!/bin/sh
MPDCONF=/etc/mpd.conf
exec mpd --stdout --no-daemon $MPDCONF
