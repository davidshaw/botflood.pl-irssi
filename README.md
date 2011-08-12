# botflood.pl
## A botflood prevention script for irssi

botflood.pl is a script to akill botnets that join channels on IRC to ruin everyone's fun. This script assumes that you are an IRCOp on a network with OperServ. If you're on a network without OperServ but can still akill/k-line/g-line, you can probably just look around in the source of this file, edit a line, and call it good. However, the networks that I'm an oper on have an OperServ that I can easily message, so that's why I designed the script this way.

Usage is simple. Put the script in `~/.irssi/scripts/` and type `/script load botflood.pl` in your running irssi client. From here, just wait for a botflood and type `/botflood` in the flooded channel to ban the last 25 joins, or `botflood <number>` where <number> is the number of offenders that joined. **BE CAREFUL** with this function, as you don't want to accidentally akill people who don't deserve it.

## How it works

This script works by registering irssi join events and keeping them in a <= 25 index buffer. Will it protect you from the biggest botfloods? Probably not, but it's enough to repel most kiddies trying to give you a hard time.
