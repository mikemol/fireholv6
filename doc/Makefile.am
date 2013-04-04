# Process this file with automake to produce Makefile.in

DIST_SUBDIRS = xsl latex tools reference man

dochtmldir = $(htmldir)/html

SANEWALLMANUALXML_CSS = \
	sanewall-manual.css

SANEWALLMANUALXML_MASTER = \
	sanewall-manual.xml

SANEWALLMANUALXML_CHAPTERS= \
	chapter-intro.xml \
	chapter-language.xml \
	chapter-security.xml \
	chapter-troubleshooting.xml

SANEWALLMANUALXML_REFERENCES = \
	reference/sanewall.xml \
	reference/sanewall-conf.xml \
	reference/sanewall-variables.xml \
	reference/def-interface.xml \
	reference/def-router.xml \
	reference/cmd-policy.xml \
	reference/cmd-protection.xml \
	reference/cmd-server.xml \
	reference/cmd-client.xml \
	reference/cmd-group.xml \
	reference/helpconf-version.xml \
	reference/helpconf-action.xml \
	reference/helpconf-blacklist.xml \
	reference/helpconf-classify.xml \
	reference/helpconf-connmark.xml \
	reference/helpconf-dscp.xml \
	reference/helpconf-mac.xml \
	reference/helpconf-mark.xml \
	reference/helpconf-nat.xml \
	reference/helpconf-proxy.xml \
	reference/helpconf-tos.xml \
	reference/helpconf-tosfix.xml \
	reference/helpcmd-iptables.xml \
	reference/helpcmd-masquerade.xml \
	reference/helpcmd-tcpmss.xml \
	reference/rule-params.xml \
	reference/actions.xml \
	reference/services.xml

SANEWALLMANUALXML_GENERATED = \
	services-list.xml

SANEWALLMANUALMAN_GENERATED = \
	man/man1/sanewall.1 \
	man/man5/sanewall-accept.5 \
	man/man5/sanewall-action.5 \
	man/man5/sanewall-actions.5 \
	man/man5/sanewall-blacklist.5 \
	man/man5/sanewall-classify.5 \
	man/man5/sanewall-client.5 \
	man/man5/sanewall.conf.5 \
	man/man5/sanewall-connmark.5 \
	man/man5/sanewall-custom.5 \
	man/man5/sanewall-deny.5 \
	man/man5/sanewall-dnat.5 \
	man/man5/sanewall-drop.5 \
	man/man5/sanewall-dscp.5 \
	man/man5/sanewall-dscp-param.5 \
	man/man5/sanewall-dst.5 \
	man/man5/sanewall-dsttype.5 \
	man/man5/sanewall-gid.5 \
	man/man5/sanewall-group.5 \
	man/man5/sanewall-inface.5 \
	man/man5/sanewall-interface.5 \
	man/man5/sanewall-iptables.5 \
	man/man5/sanewall-log.5 \
	man/man5/sanewall-loglimit.5 \
	man/man5/sanewall-mac.5 \
	man/man5/sanewall-mac-param.5 \
	man/man5/sanewall-mark.5 \
	man/man5/sanewall-mark-param.5 \
	man/man5/sanewall-masquerade.5 \
	man/man5/sanewall-nat.5 \
	man/man5/sanewall-outface.5 \
	man/man5/sanewall-physin.5 \
	man/man5/sanewall-physout.5 \
	man/man5/sanewall-policy.5 \
	man/man5/sanewall-protection.5 \
	man/man5/sanewall-proto.5 \
	man/man5/sanewall-redirect.5 \
	man/man5/sanewall-reject.5 \
	man/man5/sanewall-return.5 \
	man/man5/sanewall-route.5 \
	man/man5/sanewall-router.5 \
	man/man5/sanewall-rule-params.5 \
	man/man5/sanewall-server.5 \
	man/man5/sanewall-services.5 \
	man/man5/sanewall-snat.5 \
	man/man5/sanewall-src.5 \
	man/man5/sanewall-srctype.5 \
	man/man5/sanewall-tarpit.5 \
	man/man5/sanewall-tcpmss.5 \
	man/man5/sanewall-tos.5 \
	man/man5/sanewall-tosfix.5 \
	man/man5/sanewall-tos-param.5 \
	man/man5/sanewall-transparent_proxy.5 \
	man/man5/sanewall-transparent_squid.5 \
	man/man5/sanewall-uid.5 \
	man/man5/sanewall-variables.5 \
	man/man5/sanewall-version.5

SANEWALLMANUALHTML_GENERATED = \
	sanewall-services.html \
	sanewall-manual.html

SANEWALLMANUALPDF_GENERATED = \
	sanewall-manual.pdf

export SANEWALLMANUALXML_MASTER

man_MANS = \
	$(SANEWALLMANUALMAN_GENERATED)

dochtml_DATA = \
	$(SANEWALLMANUALXML_CSS) \
	$(SANEWALLMANUALHTML_GENERATED)

pdf_DATA = \
	$(SANEWALLMANUALPDF_GENERATED)

if MAINTAINER_MODE

PAPERTYPE = a4paper

MKSERVICELIST = ${top_srcdir}/doc/tools/mkservicelist
MKHTMLINDEX = ${top_srcdir}/doc/tools/mkhtmlindex

SANEWALLIN = $(top_srcdir)/sbin/sanewall.in

XMLLINT_FLAGS += \
	--path ${abs_top_builddir}/doc:${abs_top_srcdir}/doc \
	--xinclude

XSLTPROC_FLAGS += \
	--path ${abs_top_builddir}/doc:${abs_top_srcdir}/doc:${abs_top_srcdir}/doc/xsl \
	--xinclude

##DBLATEX_FLAGS += \
##	--xslt=xsltproc \
##	--xslt-opts "--path ${abs_top_builddir}/doc:${abs_top_srcdir}/doc:${abs_top_srcdir}/doc/xsl"

export manpages_XSLTPROC_FLAGS = \
	$(XSLTPROC_FLAGS) \
	--param man.output.base.dir man

services-list.xml: $(SANEWALLIN) services-db.data
	$(MKSERVICELIST) $@ $+

sanewall-services.html:
	$(MKHTMLINDEX) $@ $(SANEWALLIN)

db-valid: \
		$(SANEWALLMANUALXML_MASTER) \
		$(SANEWALLMANUALXML_CHAPTERS) \
		$(SANEWALLMANUALXML_REFERENCES) \
		$(SANEWALLMANUALXML_GENERATED) \
		sanewall-manual-info.xml
	$(XMLLINT) $(XMLLINT_FLAGS) --noout --postvalid $<
	touch db-valid

$(SANEWALLMANUALMAN_GENERATED): db-valid xsl/manpages.xsl
	$(MAKE) -C man manpages

sanewall-manual.html: db-valid xsl/html.xsl $(SANEWALLMANUALXML_CSS)
	$(XSLTPROC) $(XSLTPROC_FLAGS) -o $@ html.xsl $(SANEWALLMANUALXML_MASTER)

sanewall-manual.pdf: db-valid xsl/dblatex.xsl latex/dbsanewall.sty
	$(DBLATEX) $(DBLATEX_FLAGS) \
			-t pdf \
			-P paper.type=$(PAPERTYPE) \
			-p xsl/dblatex.xsl \
			-s latex/dbsanewall.sty \
			-o $@ \
		$(SANEWALLMANUALXML_MASTER)

endif

EXTRA_DIST = \
	services-db.data \
	sanewall-manual-info.xml \
	$(SANEWALLMANUALXML_GENERATED) \
	db-valid \
	$(SANEWALLMANUALXML_CSS) \
	$(SANEWALLMANUALXML_CHAPTERS) \
	$(SANEWALLMANUALXML_MASTER) \
	$(SANEWALLMANUALMAN_GENERATED) \
	$(SANEWALLMANUALHTML_GENERATED) \
	$(SANEWALLMANUALPDF_GENERATED)

CLEANFILES =

DISTCLEANFILES =

MAINTAINERCLEANFILES = \
	sanewall-manual-info.xml \
	$(SANEWALLMANUALXML_GENERATED) \
	db-valid \
	$(SANEWALLMANUALMAN_GENERATED) \
	$(SANEWALLMANUALHTML_GENERATED) \
	$(SANEWALLMANUALPDF_GENERATED)

uninstall-local:
	@-rmdir --ignore-fail-on-non-empty $(DESTDIR)$(dochtmldir)
	@-rmdir --ignore-fail-on-non-empty $(DESTDIR)$(pdfdir)
#	@-rmdir --ignore-fail-on-non-empty $(DESTDIR)$(docdir)

.NOTPARALLEL: $(SANEWALLMANUALMAN_GENERATED)
