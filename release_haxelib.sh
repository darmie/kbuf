#!/bin/sh
rm -f kbuf.zip
zip -r kbuf.zip src *.hxml *.json *.md run.n
haxelib submit kbuf.zip $HAXELIB_PWD --always