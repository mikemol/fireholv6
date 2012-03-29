Summary:	A powerful yet easy to use iptables frontend
Name:		firehol
Version:	MYVERSION
Release:	MYRELEASE
License:	GPLv2+
Group:		Applications/Internet
Source:		http://downloads.sourceforge.net/%{name}/%{name}-%{version}.tar.bz2

URL:		http://firehol.sourceforge.net
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
FireHOL is a generic firewall generator, meaning that you can design any kind
of local or routing stateful packet filtering firewalls with ease. Install
FireHOL if you want an easy way to configure stateful packet filtering
firewalls on Linux hosts and routers.

FireHOL uses an extremely simple but powerful way to define firewall rules
which it turns into complete stateful iptables firewalls.

You can run FireHOL with the 'helpme' argument, to get a configuration file for
the system run, which you can modify according to your needs. The default
configuration file will allow only client traffic on all interfaces.

%prep
%setup -q

%build

%install
rm -rf %{buildroot}
install -D -p -m 755 firehol.sh %{buildroot}%{_initrddir}/firehol
install -D -p -m 640 examples/client-all.conf %{buildroot}/etc/firehol/firehol.conf

# Install man files
mkdir -p %{buildroot}%{_mandir}/man1
mkdir -p %{buildroot}%{_mandir}/man5
install -p -m 644 man/*.1 %{buildroot}/%{_mandir}/man1
install -p -m 644 man/*.5 %{buildroot}/%{_mandir}/man5

# Executables
mkdir -p %{buildroot}%{_libexecdir}/firehol
install -p -m 755 *.sh %{buildroot}%{_libexecdir}/firehol

# Install runtime directories
mkdir -p %{buildroot}%{_sysconfdir}/firehol/services
mkdir -p %{buildroot}%{_localstatedir}/spool/firehol


%post
/sbin/chkconfig --add firehol

%preun
if [ $1 = 0 ] ; then
	/sbin/service firehol stop >/dev/null 2>&1
	/sbin/chkconfig --del firehol
fi

%postun
if [ "$1" -ge "1" ] ; then
	/sbin/service firehol condrestart >/dev/null 2>&1 || :
fi


%clean
rm -rf %{buildroot}


%files
%defattr(-,root,root,-)
%doc README COPYING ChangeLog examples doc
%dir %{_sysconfdir}/firehol
%config(noreplace) %{_sysconfdir}/firehol/firehol.conf
%{_initrddir}/firehol
%{_libexecdir}/firehol
%{_mandir}/man1/*.1.gz
%{_mandir}/man5/*.5.gz
%{_sysconfdir}/firehol/services
%{_localstatedir}/spool/firehol


%changelog
* Sun Mar 25 2012 Phil Whineray <phil.whineray@gmail.com> - 0.9.0
- import spec from fedora 1.273-8
