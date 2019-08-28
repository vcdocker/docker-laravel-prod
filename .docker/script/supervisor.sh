#!/bin/sh

file=$1

if [ -f "$file" ]; then
    /usr/bin/supervisor -c $file
fi