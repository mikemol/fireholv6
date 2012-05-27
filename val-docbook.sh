#!/bin/sh

which xmllint > /dev/null 2>&1
if [ $? -ne 0 ]
then
  echo "Missing xmllint: skipping validation"
  exit 0
fi

for i in "$@"
do
  xmllint --noout --postvalid --xinclude "$i" 2>&1 || exit 1
  echo "$i validated"
done
