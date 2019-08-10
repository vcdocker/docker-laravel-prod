dir=$1

if [ -d "$dir" -a ! -h "$dir" ]
    for entry in `ls $dir`; do
        cat ./.config/$entry | sh
    done
fi