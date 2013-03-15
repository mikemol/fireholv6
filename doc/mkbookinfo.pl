#!/usr/bin/perl -w

if (@ARGV != 3) {
  print STDERR "Usage: mkbookinfo.pl output.xml ChangeLog input.txt\n";
  exit 1;
}

my $out = shift;
my $ver = shift;
my $in = shift;

open VER, "<$ver" or die "Unable to read $ver\n";
open IN, "<$in" or die "Unable to read $in\n";

my $verno;
my $verline = <VER>;
if ($verline =~ /\(([0-9][0-9a-zA-Z_.-]+)\)/) {
  $verno = $1;
} else {
 die "Unable to extract version from $ver\n";
}

my $d = `date "+%d %b %Y"`;
chomp $d;

open OUT, ">$out" or die "Unable to write $out\n";
while (<IN>) {
  s/VERSION/$verno/;
  s/DATE/$d/;
  print OUT $_;
}
