NAME=sanewall
VERSION=`cat VERSION`
RELEASE=`cat RELEASE`

all: VERSION RELEASE build-stamp build-stamp-tgz build-stamp-rpm

VERSION: ../ChangeLog ../sanewall
	sed -e '2,$$d' -e 's|.*[a-z][a-z]* (\([^-)]*\)-*[^-)]*).*|\1|' ../ChangeLog > VERSION.tmp
	test -s VERSION.tmp
	sed -ne 's/^VERSION=\([0-9].*\)/\1/p' ../sanewall > VERSION.script
	cmp -s VERSION.tmp VERSION.script || echo "ChangeLog and sanewall script have different versions"
	cmp -s VERSION.tmp VERSION.script
	rm -f VERSION.script
	mv VERSION.tmp VERSION

RELEASE: ../ChangeLog
	sed -n -e '2,$$d' -e 's|.*[a-z][a-z]* ([^)]*-\([^-)]*\)).*|\1|p' ../ChangeLog > RELEASE

build-stamp:
	sudo ./debian/rules binary NAME="$(NAME)" VERSION="$(VERSION)" RELEASE="$(RELEASE)"

build-stamp-rpm: build-stamp-tgz
	sudo rm -rf rpm/tmp
	sudo mkdir rpm/tmp
	sudo tar xfzC $(NAME)-$(VERSION).tar.gz rpm/tmp
	sudo cp rpm/default.spec rpm/tmp/$(NAME)-$(VERSION)/.spec
	test -s RELEASE || sudo sed -e "s/MYRELEASE/orig/" -i rpm/tmp/$(NAME)-$(VERSION)/.spec
	sudo sed -e "s|MYVERSION|$(VERSION)|" -e "s|MYRELEASE|$(RELEASE)|" -i rpm/tmp/$(NAME)-$(VERSION)/.spec
	sudo tar Ccfj rpm/tmp rpm/tmp/$(NAME)-$(VERSION).tar.bz2 $(NAME)-$(VERSION)
	rpmbuild -tb rpm/tmp/$(NAME)-$(VERSION).tar.bz2
	sudo rm -rf rpm/tmp
	touch build-stamp-rpm

build-stamp-tgz:
	sudo ./tgz/rules binary NAME="$(NAME)" VERSION="$(VERSION)" RELEASE="$(RELEASE)"

clean:
	rm -f build-stamp* *.tar.gz *.rpm *.deb RELEASE VERSION *.tmp
	rm -f VERSION.script
	sudo ./debian/rules clean
	sudo ./tgz/rules clean
