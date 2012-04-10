#!/usr/bin/env perl
# PERL implementation of the Linux watch utility
# 10/04/2012

my @lines = `ls -l`;

while defined(my $line = <>) {
    my $start = $-[0];
    my $stop  = $+[0];
    my $underline = ( ' ' x $-[0] ) . ( '^' x ($stop - $start) );

    print $line;
    print $underline, "\n\n";
}


