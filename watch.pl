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

use Getopt::Long;

my $VERSION = "0.2.0";
my $progname = $0;
my $usage = "Usage: %s [-dhntv] [--differences[=cumulative]] [--help] [--interval=<n>] [--no-title] [--version] <command>\n";

sub do_usage() {
    printf STDERR $usage, $progname;
    exit 1;
}

my $height = 24, $width = 80;
my $incoming_cols;
my $incoming_rows;

sub get_terminal_size() {
    if (!$incoming_cols) {
        local $s = $ENV{'COLUMNS'};	# Get cols from env if set
	$incoming_cols = -1;
	if (defined $s) {
	    local $t = $s;
	    $t =~ s/^\s+//;		# strip leading whitespace
	    if (($t =~ /^[1-9][0-9]*$/) && ($t < 666)) {	# test cols are gt 0 and lt 666
		$incoming_cols = $t;
            }
	    $width = $incoming_cols;
	    $ENV{'COLUMNS'} = $width;
	}
    }
    if (!$incoming_rows) {
        local $s = $ENV{'LINES'};
        $incoming_rows = -1;
	if (defined $s) {
	    local $t = $s;
	    $t =~ s/^\s+//;		# strip leading whitespace
	    if (($t =~ /^[1-9][0-9]*$/) && ($t < 666)) {	# test rows are gt 0 and lt 666
		$incoming_rows = $t;
            }
	    $height = $incoming_rows;
	    $ENV{'LINES'} = $height;
        }
    }
    if ($incoming_cols<0 || $incoming_rows<0) {
        # blah
    }
}

my $show_title=2;			# number of lines used, 2 or 0
my $option_differences=0;
my $option_differences_cumulative=0;
my $option_help=0;
my $option_version=0;
my $interval=2;
my $command;
my $command_length=0;

&do_usage unless (@ARGV);

GetOptions  ('d|differences:i' => \$option_differences,
             'h|help' => \$option_help,
             'n|interval=i' => \$interval,
             't|no-title' => \$show_title,
             'v|version' => \$option_version,
);

if ($option_version >= 1) {
    printf STDERR "%s\n", $VERSION;
    if (! $option_help) {
	exit 0;
    }
}

if ($option_help >= 1) {
    printf STDERR $usage, $progname;
    print STDERR " -d, --differences[=cumulative]\t\thighlight changes between updates\n";
    print STDERR "\t\t(cumulative means highlighting is cumulative)\n";
    print STDERR " -h, --help\t\t\t\tprint a summary of the options\n";
    print STDERR " -n, --interval=<seconds>\t\tseconds to wait between updates\n";
    print STDERR " -v, --version\t\t\t\tprint the version number\n";
    print STDERR " -t, --no-title\t\t\t\tturns off showing the header\n";
    exit 0;
}

&get_terminal_size;

