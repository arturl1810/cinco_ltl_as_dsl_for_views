#!/bin/bash
convert box_checked.png -resize x$1 ../box_checked.png
convert box_unchecked.png -resize x$1 ../box_unchecked.png
convert error.png -resize x$1 ../error.png
convert info.png -resize x$1 ../info.png
convert ok.png -resize x$1 ../ok.png
convert warning.png -resize x$1 ../warning.png
