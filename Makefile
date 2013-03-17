DB_XSL_BASE=/usr/share/xml/docbook/stylesheet/docbook-xsl
DB_DTD_BASE=/usr/share/xml/docbook/schema/dtd/4.5
PAPERTYPE=A4

VERSION=$(shell ./get-version.sh ChangeLog)

DB_SCHEMA_DTD=$(DB_DTD_BASE)/docbookx.dtd
DB_TITLE_XSL=$(DB_XSL_BASE)/template/titlepage.xsl
DB_MAN_XSL=$(DB_XSL_BASE)/manpages/docbook.xsl
DB_FO_XSL=$(DB_XSL_BASE)/fo/docbook.xsl
DB_HTML_XSL=$(DB_XSL_BASE)/html/docbook.xsl

DBSRC=doc/chapter-intro.xml doc/chapter-language.xml doc/chapter-security.xml \
      doc/chapter-troubleshooting.xml doc/sanewall-manual.xml

DBGEN=doc/services-list.xml doc/manual-info.xml

OUT=build/sanewall-$(VERSION)

TAR=dist/sanewall-$(VERSION).tar.gz

HTMLDOC=$(OUT)/doc/sanewall-manual.html $(OUT)/doc/sanewall-services.html \
        $(OUT)/doc/sanewall-manual.css
PDFDOC=$(OUT)/doc/sanewall-manual.pdf
MANDOC=$(OUT)/man/man1/sanewall.1

BASEFILES=sanewall INSTALL README COPYING ChangeLog
ADMINFILES=admin/adblock.sh admin/prettyconf.sh
EXAMPLES=examples/bittorrent.conf examples/lan-gateway.conf \
         examples/server-dmz.conf examples/client-all.conf \
         examples/office.conf

$(TAR): $(OUT)/sanewall $(HTMLDOC) $(PDFDOC) $(MANDOC)
	mkdir -p dist
	tar cpCfz build $(TAR) sanewall-$(VERSION) --owner=root --group=root

$(OUT)/sanewall: $(BASEFILES)
	mkdir -p build/tmp
	install -m 755 -d $(OUT)
	install -m 755 -d $(OUT)/admin
	install -m 755 -d $(OUT)/doc
	install -m 755 -d $(OUT)/examples
	install -m 755 -d $(OUT)/init.d
	install -m 755 -d $(OUT)/man
	install -m 755 -d $(OUT)/man/man1
	install -m 755 -d $(OUT)/man/man5
	install -m 644 admin/* $(OUT)/admin
	install -m 644 examples/* $(OUT)/examples
	install -m 644 init.d/* $(OUT)/init.d
	install -m 644 INSTALL $(OUT)
	install -m 644 README $(OUT)
	install -m 644 COPYING $(OUT)
	gzip -c9 ChangeLog > build/tmp/ChangeLog.gz
	install -m 644 build/tmp/ChangeLog.gz $(OUT)
	sed -e 's/VERSION=DEVELOPMENT/VERSION=$(VERSION)/' sanewall > build/tmp/sanewall
	install -m 755 build/tmp/sanewall $(OUT)/sanewall

build/tmp/titlepage-fo.xsl: $(OUT)/sanewall doc/titlepage-fo.xml
	xsltproc --stringparam ns http://www.w3.org/1999/XSL/Format --output build/tmp/titlepage-fo.xsl $(DB_TITLE_XSL) doc/titlepage-fo.xml

doc/services-list.xml: doc/services-db.txt $(OUT)/sanewall
	doc/mkservicelist.pl doc/services-list.xml $(OUT)/sanewall doc/services-db.txt

doc/manual-info.xml: doc/manual-info.txt ChangeLog
	doc/mkbookinfo.pl doc/manual-info.xml ChangeLog doc/manual-info.txt

build/tmp/db-valid: $(DBSRC) $(DBGEN)
	xmllint --noout --postvalid --xinclude doc/sanewall-manual.xml --dtdvalid $(DB_SCHEMA_DTD)
	touch build/tmp/db-valid

$(OUT)/man/man1/sanewall.1: build/tmp/db-valid $(OUT)/sanewall
	xsltproc --nonet --output build/tmp --xinclude --param man.output.in.separate.dir 1 --param man.output.subdirs.enabled 1 $(DB_MAN_XSL) doc/sanewall-manual.xml
	sed -i -e "s;.so man/man;.so man;" build/man/man*/*
	install -m 644 build/man/man1/* $(OUT)/man/man1
	install -m 644 build/man/man5/* $(OUT)/man/man5

$(OUT)/doc/sanewall-manual.css: $(OUT)/doc/sanewall-manual.html doc/sanewall-manual.css
	cp doc/sanewall-manual.css $(OUT)/doc/
	chmod 644 $(OUT)/doc/sanewall-manual.css

$(OUT)/doc/sanewall-services.html: $(OUT)/sanewall
	doc/mkhtmlindex.pl $(OUT)/doc/sanewall-services.html $(OUT)/sanewall
	chmod 644 $(OUT)/doc/sanewall-services.html

$(OUT)/doc/sanewall-manual.html: build/tmp/db-valid $(OUT)/sanewall
	xsltproc --nonet --xinclude --stringparam html.stylesheet.type text/css --stringparam html.stylesheet sanewall-manual.css --param generate.index 0 -o $(OUT)/doc/sanewall-manual.html $(DB_HTML_XSL) doc/sanewall-manual.xml
	chmod 644 $(OUT)/doc/sanewall-manual.html

build/tmp/sanewall-manual.fo: build/tmp/db-valid $(OUT)/sanewall build/tmp/titlepage-fo.xsl doc/pdf.xsl
	sed -e "s:IMPORTXSL:$(DB_FO_XSL):" doc/pdf.xsl > build/tmp/pdf.xsl
	xsltproc --nonet --xinclude --stringparam paper.type $(PAPERTYPE) -o build/tmp/sanewall-manual.fo build/tmp/pdf.xsl doc/sanewall-manual.xml

$(OUT)/doc/sanewall-manual.pdf: build/tmp/sanewall-manual.fo
	fop build/tmp/sanewall-manual.fo -pdf $(OUT)/doc/sanewall-manual.pdf
	chmod 644 $(OUT)/doc/sanewall-manual.pdf

clean:
	rm -f doc/services-list.xml doc/manual-info.xml
	rm -rf build
