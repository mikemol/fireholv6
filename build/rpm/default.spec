Summary:	A powerful yet easy to use iptables frontend
Name:		sanewall
Version:	MYVERSION
Release:	MYRELEASE
License:	GPLv2+
Group:		Applications/Internet
Source:		http://www.sanewall.org/downloads/%{name}/%{name}-%{version}.tar.bz2

URL:		http://www.sanewall.org
BuildArch:	noarch
BuildRoot:	%(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)

Requires:	bash >= 2.04
Requires:	fileutils >= 4.0.36
Requires:	gawk >= 3.0
Requires:	grep >= 2.4.2
Requires:	iproute >= 2.2.4
Requires:	iptables >= 1.2.4
Requires:	kernel >= 2.4
Requires:	less
Requires:	kmod
Requires:	net-tools >= 1.57
Requires:	sed >= 3.02
Requires:	sh-utils >= 2.0
Requires:	textutils >= 2.0.11
Requires:	util-linux >= 2.11

Requires(post):		chkconfig
Requires(preun):	chkconfig
Requires(preun):	initscripts
Requires(postun):	initscripts


%description
Sanewall is an easy to use but powerful iptables stateful firewall generator.
It generates firewalls using an extremely simple but powerful configuration
language, enabling you to design any kind of local or routing stateful packet
filtering firewall with ease.

The default configuration file will allow only client traffic on all
interfaces and examples are provided for common routing and DMZ setups.

You can run sanewall with the 'helpme' argument, to get a configuration file
appropriate for the system running, which you can modify according to your
needs.

Sanewall is a based on the FireHOL project and understands FireHOL
configuration syntax.

%prep
%setup -q

%build

%install
rm -rf %{buildroot}
install -D -p -m 755 sanewall %{buildroot}%{_initrddir}/sanewall
install -D -p -m 640 examples/client-all.conf %{buildroot}/etc/sanewall/sanewall.conf

# Install man files
mkdir -p %{buildroot}%{_mandir}/man1
mkdir -p %{buildroot}%{_mandir}/man5
install -p -m 644 man/man1/*.1 %{buildroot}/%{_mandir}/man1
install -p -m 644 man/man5/*.5 %{buildroot}/%{_mandir}/man5

# Executables
mkdir -p %{buildroot}%{_libexecdir}/sanewall
install -p -m 755 *.sh %{buildroot}%{_libexecdir}/sanewall

# Install runtime directories
mkdir -p %{buildroot}%{_sysconfdir}/sanewall/services
mkdir -p %{buildroot}%{_localstatedir}/spool/sanewall


%post
/sbin/chkconfig --add sanewall

%preun
if [ $1 = 0 ] ; then
	/sbin/service sanewall stop >/dev/null 2>&1
	/sbin/chkconfig --del sanewall
fi

%postun
if [ "$1" -ge "1" ] ; then
	/sbin/service sanewall condrestart >/dev/null 2>&1 || :
fi


%clean
rm -rf %{buildroot}


%files
%defattr(-,root,root,-)
%doc README INSTALL COPYING ChangeLog.gz examples doc
%dir %{_sysconfdir}/sanewall
%config(noreplace) %{_sysconfdir}/sanewall/sanewall.conf
%{_initrddir}/sanewall
%{_libexecdir}/sanewall
%{_mandir}/man1/*.1.gz
%{_mandir}/man5/*.5.gz
%{_sysconfdir}/sanewall/services
%{_localstatedir}/spool/sanewall


%changelog
* Sun Mar 25 2012 Phil Whineray <phil.whineray@gmail.com> - 0.9.0
- import spec from fedora 1.273-8
