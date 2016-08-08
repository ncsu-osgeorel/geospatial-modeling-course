#!/bin/bash

# builds pages from source

# URL of the new version
URL="http://ncsu-geoforall-lab.github.io/geospatial-modeling-course/"

function build_page {
    FILE_SOURCE=$1
    FILE_TARGET=$2
    cat $HEAD_FILE > $OUTDIR/$FILE_TARGET
    echo "<!-- This is a generated file. Do not edit. -->" >> $OUTDIR/$FILE_TARGET
    FILE=$FILE_TARGET
    echo "<div style=\"background-color: #FA8; border: 4px solid #F00; padding: 10px;\"><p>This is an unmaintained course material, please see current material at:<ul><li><a href=\"$URL\">$URL</a></li><li><a href=\"$URL$FILE\">$URL$FILE</a> (likely URL)</li></ul></div>" >> $OUTDIR/$FILE_TARGET
    ./edit.py < $FILE_SOURCE >> $OUTDIR/$FILE_TARGET
    cat $FOOT_FILE >> $OUTDIR/$FILE_TARGET
}

HEAD_FILE=head.html
FOOT_FILE=foot.html

OUTDIR=build

if [ ! -d "$OUTDIR" ]; then
    echo "The directory $OUTDIR does not exists and it will be created for you."
    mkdir $OUTDIR
fi

for FILE in `ls *.html|grep -v foot|grep -v head`
do
    build_page $FILE $FILE
done

# for backwards compatibility, remove next semester
build_page "index.html" "syllabus.html"
build_page "logistics.html" "intro.html"

for DIR in grass arcgis resources project_titles
do
    mkdir -p $OUTDIR/$DIR

    for FILE in `ls $DIR/*.html`
    do
        TGT_FILE=$OUTDIR/$DIR/`basename $FILE`
        ./increase-link-depth.py < $HEAD_FILE > $TGT_FILE
        echo "<!-- This is a generated file. Do not edit. -->" >> $TGT_FILE
        echo "<div style=\"background-color: #FA8; border: 4px solid #F00; padding: 10px;\"><p>This is an unmaintained course material, please see current material at:<ul><li><a href=\"$URL\">$URL</a></li><li><a href=\"$URL$FILE\">$URL$FILE</a> (likely URL)</li></ul></div>" >> $TGT_FILE
        ./edit.py < $FILE >> $TGT_FILE
        ./increase-link-depth.py < $FOOT_FILE >> $TGT_FILE
    done

    for SUBDIR in data img
    do
        # copy only if directory exists
        if [ -d "$DIR/$SUBDIR" ]; then
            cp -r $DIR/$SUBDIR $OUTDIR/$DIR
        fi
    done
done

FILES="`./extract-links.py "grass/.+html" assignments.html`"
TITLE="List of GRASS GIS assignments"
HEAD_TEXT=""
# if this gets longer, it must go to a file
FOOT_TEXT="<img src='../img/grass_index.png' style='max-width: 90%;'>
<p>
If you are a non-NCSU visitor, you may find these additional pages useful:
<ul>
    <li><a href='../lectures.html'>Lectures</a>
    <li><a href='../logistics.html#software'>Software download instructions</a>
    <li><a href='../assignments.html#data'>Dataset download instructions</a>\
</ul>
"
DIR="grass"

TGT_FILE=$OUTDIR/$DIR/index.html
./increase-link-depth.py < $HEAD_FILE > $TGT_FILE
echo "<!-- This is a generated file. Do not edit. -->" >> $TGT_FILE
FILE=$DIR/index.html
echo "<div style=\"background-color: #FA8; border: 4px solid #F00; padding: 10px;\"><p>This is an unmaintained course material, please see current material at:<ul><li><a href=\"$URL\">$URL</a></li><li><a href=\"$URL$FILE\">$URL$FILE</a> (likely URL)</li></ul></div>" >> $TGT_FILE
./generate-index.py "$TITLE" "$HEAD_TEXT" "$FOOT_TEXT" $DIR/ $FILES >> $TGT_FILE
./increase-link-depth.py < $FOOT_FILE >> $TGT_FILE

for FILE in *.css
do
    cp $FILE $OUTDIR
done

for DIR in img
do
    cp -r $DIR $OUTDIR
done

for DIR in resources
do
    mkdir -p $OUTDIR/$DIR

    for FILE in `ls $DIR/*.pdf $DIR/*.docx $DIR/*.tex`
    do
        cp $FILE $OUTDIR/$DIR
    done

    for SUBDIR in `ls $DIR/*`
    do
        if [ -d "$DIR/$SUBDIR" ]; then
            cp -r $DIR/$SUBDIR $OUTDIR/$DIR
        fi
    done
done
