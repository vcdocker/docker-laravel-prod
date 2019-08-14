#!/bin/sh

dir=$1

if [ -d "$dir" -a ! -h "$dir" ]; then
    for entry in `ls $dir`; do
        cat ./.config/$entry | sh
    done
fi