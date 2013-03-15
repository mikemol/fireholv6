#!/bin/sh

if [ $# -lt 1 ]
then
  echo "Usage: get-version.sh ChangeLog"
  exit 1
fi

head -n1 "$1" | cut -f1 -d')' | cut -f2 -d'('
exit 0
