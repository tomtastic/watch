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

my $progname = $0
my $usage = "Usage: %s [-dhntv] [--differences[=cumulative]] [--help] [--interval=<n>] [--no-title] [--version] <command>\n";

sub usage() {
    printf STDERR $usage, $progname;
    exit 1;
}

sub help() {
    printf STDERR $usage, $progname;
    print STDERR " -d, --differences[=cumulative]\thighlight changes between updates\n";
    print STDERR "\t\t(cumulative means highlighting is cumulative)\n";
    print STDERR " -h, --help\t\t\t\tprint a summary of the options\n";
    print STDERR " -n, --interval=<seconds>\t\tseconds to wait between updates\n";
    print STDERR " -v, --version\t\t\t\tprint the version number\n";
    print STDERR " -t, --no-title\t\t\tturns off showing the header\n";
    exit 0;
}

