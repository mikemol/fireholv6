#!/bin/sh

#
# Download all the pre-requisites for building the docbook documentation
# using "ant".
#

cd doc || exit 1

if [ -f docbook/complete ]
then
  echo "Already have the dependencies"
  exit 0
fi

mkdir -p docbook || exit 1
cd docbook || exit 1

db_xsl_ver=1.77.0
db_xsl_base=docbook-xsl-${db_xsl_ver}
db_xsl_ext=.zip
db_xsl_file=${db_xsl_base}${db_xsl_ext}
db_xsl_uribase=http://sourceforge.net/projects/docbook/files/docbook-xsl/${db_xsl_ver}
db_xsl_uri=${db_xsl_uribase}/${db_xsl_file}/download

db_xml_file=docbook-xml-4.5.zip
db_xml_uri=http://www.docbook.org/xml/4.5/${db_xml_file}

fop_base=fop-1.0
fop_file=${fop_base}-bin.zip
fop_uri=http://linux-files.com/xmlgraphics/fop/binaries/${fop_file}

hyph_ver=2.0
hyph_base=offo-hyphenation-binary_v${hyph_ver}
hyph_ext=.zip
hyph_file=${hyph_base}${hyph_ext}
hyph_uribase=http://sourceforge.net/projects/offo/files/offo-hyphenation/${hyph_ver}
hyph_uri=${hyph_uribase}/${hyph_file}/download

mkdir -p deps || exit 1

which_cmd() {
  unalias $2 >/dev/null 2>&1
  tmpcmd=`which $2 2>/dev/null | head -n 1`
  if [ $? -gt 0 -o ! -x "${tmpcmd}" ]
  then
    return 1
  fi
  eval $1=${tmpcmd}
  return 0
}

which_cmd WGET wget
which_cmd CURL curl

if [ -z "$WGET" -a -z "$CURL" ]
then
  echo You need either wget or curl to get the dependencies
  exit 1
fi

download() {
  if [ -f "$2" ]
  then
    return
  fi

  if [ ! -z "$CURL" ]
  then
    $CURL -o"$2" -L "$1" || exit 1
  else
    $WGET -O"$2" "$1" || exit 1
  fi
}

if [ -d docbook-xsl ]
then
  echo "You already have directory docbook-xsl, skipping"
else
  echo "Getting docbook-xsl"
  download ${db_xsl_uri} deps/${db_xsl_file}
  unzip -q deps/${db_xsl_file} || exit 1
  mv ${db_xsl_base} docbook-xsl
fi

if [ -d docbook-xml ]
then
  echo "You already have directory docbook-xml, skipping"
else
  echo "Getting docbook-xml"
  download ${db_xml_uri} deps/${db_xml_file}
  mkdir docbook-xml
  cd docbook-xml || exit 1
  unzip -q ../deps/${db_xml_file}
  if [ $? -eq 0 ]
  then
    cd ..
  else
    cd ..
    rm -rf docbook-xml
  fi
fi

mkdir -p lib
if [ -f lib/fop.jar ]
then
  echo "You already have file lib/fop.jar, skipping"
else
  echo "Getting lib/fop.jar"
  download ${fop_uri} deps/${fop_file}
  cd deps || exit 1
  unzip -q ${fop_file} || exit 1
  cd .. || exit 1
  mv deps/${fop_base}/lib/*.jar lib/.
  mv deps/${fop_base}/build/*.jar lib/.
  rm -rf deps/${fop_base}
fi

if [ -f lib/fop-hyph.jar ]
then
  echo "You already have file lib/fop-hyph.jar, skipping"
else
  echo "Getting lib/fop-hyph.jar"
  download ${hyph_uri} deps/${hyph_file}
  cd deps || exit 1
  unzip -q ${hyph_file} || exit 1
  cd .. || exit 1
  mv deps/offo-hyphenation-binary/*.jar lib/.
  rm -rf deps/offo-hyphenation-binary
fi

date > complete
