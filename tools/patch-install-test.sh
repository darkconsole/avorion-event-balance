#/bin/sh

cat ../avorion-event-balance/patches/* | patch -p2 --dry-run
