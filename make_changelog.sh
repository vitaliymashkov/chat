#!/usr/bin/env bash
DIRECTORY=$(cd `dirname "$0"` && pwd)
REF=`git show-ref --tags | grep v$2 | awk '{print $1}'`
echo $REF
echo $DIRECTORY
cp $DIRECTORY/CHANGELOG.md $DIRECTORY/CHANGELOG.old.md
echo "# $1" > $DIRECTORY/CHANGELOG.md
$DIRECTORY/node_modules/.bin/changelog-maker --group --start-ref=$REF>> $DIRECTORY/CHANGELOG.md
cat $DIRECTORY/CHANGELOG.old.md >> $DIRECTORY/CHANGELOG.md
rm $DIRECTORY/CHANGELOG.old.md