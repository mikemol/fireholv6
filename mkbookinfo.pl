#!/usr/bin/perl -w

if (@ARGV != 3) {
  print STDERR "Usage: mkbookinfo.pl output.xml version input.txt\n";
  exit 1;
}

my $out = shift;
my $ver = shift;
my $in = shift;

open OUT, ">$out" or die "Unable to write $out\n";
open IN, "<$in" or die "Unable to read $in\n";

my $d = `date "+%d %b %Y"`;
chomp $d;

while (<IN>) {
  s/VERSION/$ver/;
  s/DATE/$d/;
  print OUT $_;
}
