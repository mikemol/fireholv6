MANPAGES=man/man1/get-iana.1 \
         man/man1/sanewall.1 \
         man/man5/sanewall.conf.5

all: doc

doc: $(MANPAGES)

man/man1/get-iana.1: man/get-iana.1.txt
	test -d man/man1 || mkdir man/man1
	a2x -f manpage man/get-iana.1.txt -D man/man1

man/man1/sanewall.1: man/sanewall.1.txt
	test -d man/man1 || mkdir man/man1
	a2x -f manpage man/sanewall.1.txt -D man/man1

man/man5/sanewall.conf.5: man/sanewall.conf.5
	test -d man/man5 || mkdir man/man5
	cp man/sanewall.conf.5 man/man5/sanewall.conf.5

clean:
	rm -rf man/man1 man/man5
