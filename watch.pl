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
use Time::HiRes qw(sleep);

my $VERSION = "0.2.0";
my $progname = $0;
my $usage = "Usage: %s [-dhntv] [--differences[=cumulative]] [--help] [--interval=<n>] [--no-title] [--version] <command>\n";

sub do_usage() {
    printf STDERR $usage, $progname;
    exit 1;
}

sub ioctl_TIOCGWINSZ(%) {
# Sets $rows and $cols to values representing the terminals view (cf. environment variables LINES,COLUMNS)
# We use this workaround to avoid needing to query TIOCGWINSZ using C ioctls
# As long as the system has the stty command, this should be fairly portable
    chomp (local $stty_cmd=`which stty`);
    local @line;

    open (STTY, "$stty_cmd -a |") || die "$progname requires $stty_cmd, which we can't open\n";
    while (<STTY>) {
        next unless (/columns/);
        @line=split /;/,$_,4;
        foreach my $segment (@line) {
            if ($segment =~ /rows/) {
            $winsize{ws_row} = $segment;
            $winsize{ws_row} =~ s/^\D*//;
            $winsize{ws_row} =~ s/\D*$//;
            }
        elsif ($segment =~ /columns/) {
            $winsize{ws_col} = $segment;
            $winsize{ws_col} =~ s/^\D*//;
            $winsize{ws_col} =~ s/\D*$//;
            }
        }
    }
    return %winsize;
}

my $height = 24, $width = 80;
my $incoming_cols;
my $incoming_rows;

sub get_terminal_size() {
    local %winsize = (
        ws_row => undef,
	ws_col => undef
	);
    if (!$incoming_cols) {
        local $s = $ENV{'COLUMNS'};				# Get cols from env if set
	$incoming_cols = -1;
	if (defined $s) {
	    local $t = $s;
	    $t =~ s/^\s+//;					# strip leading whitespace
	    if (($t =~ /^[1-9][0-9]*$/) && ($t < 666)) {	# test cols are gt 0 and lt 666
		$incoming_cols = $t;
            }
	    $width = $incoming_cols;
	    $ENV{'COLUMNS'} = $width;
	}
    }
    if (!$incoming_rows) {
        local $s = $ENV{'LINES'};				# Get rows from env if set
        $incoming_rows = -1;
	if (defined $s) {
	    local $t = $s;
	    $t =~ s/^\s+//;					# strip leading whitespace
	    if (($t =~ /^[1-9][0-9]*$/) && ($t < 666)) {	# test rows are gt 0 and lt 666
		$incoming_rows = $t;
            }
	    $height = $incoming_rows;
	    $ENV{'LINES'} = $height;
        }
    }
    if ($incoming_cols<0 || $incoming_rows<0) {			# If valid size still not found yet
        %winsize=ioctl_TIOCGWINSZ();
        if ($incoming_rows < 0 && $winsize{ws_row} > 0) {
            $height = $winsize{ws_row};
            $ENV{'LINES'} = $height;	
        }
        if ($incoming_cols < 1 && $winsize{ws_col} > 0) {
            $width = $winsize{ws_col};
            $ENV{'COLUMNS'} = $width;
        }
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
             'n|interval=i' => sub { if (\$interval !~ /^[0-9]*$/) { do_usage; }
	                             if (\$interval <= 0.1) { $interval=0.1 }
				     if (\$interval >= 4096) { $interval=4096 } },
             't|no-title' => sub { $show_title=0 },
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

chomp (my $command="@ARGV");
print "DEBUG command is : $command\n";

get_terminal_size;

while (true) {
    local $time = localtime();
    local $x, $y;
    open (P, "$command |") || die "cannot open $command\n";

    if ($show_title >= 1) {
	# left justify interval and command,
	# right justify time, clipping all to fit window width
	#asprintf(&header, "Every %.1fs: %.*s",
	#interval, min(width - 1, command_length), command);
	#mvaddstr(0, 0, header);
	#if (strlen(header) > (size_t) (width - tsl - 1))
	#    mvaddstr(0, width - tsl - 4, "... ");
	#    mvaddstr(0, width - tsl + 1, ts);
	#    free(header);
	print "TIME\n";
    }

    print "$time\n";
    sleep($interval);
};



