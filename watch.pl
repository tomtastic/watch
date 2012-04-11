#!/usr/bin/env perl
# watch -- execute a program repeatedly, displaying output fullscreen
#
# Based on the original 1991 'watch' by Tony Rems <rembo@unisoft.com>
# (with mods and corrections by Francois Pinard).
#
# Substantially reworked, new features (differences option, SIGWINCH
# handling, unlimited command length, long line handling) added Apr 1999 by
# Mike Coleman <mkc@acm.org>.
#
# Changes by Albert Cahalan, 2002-2003.
#
# PERL implementation by Tom Matthews, 2012.
#

my @lines = `ls -l`;

while defined(my $line = <>) {
    my $start = $-[0];
    my $stop  = $+[0];
    my $underline = ( ' ' x $-[0] ) . ( '^' x ($stop - $start) );

    print $line;
    print $underline, "\n\n";
}

sub usage() {
    print STDERR "Usage: $0 [-dhntv] [--differences[=cumulative]] [--help] [--interval=<n>] [--no-title] [--version] <command>\n";


