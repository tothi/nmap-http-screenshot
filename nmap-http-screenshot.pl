#!/usr/bin/env perl

use strict;
use Getopt::Std;
use Nmap::Parser;

sub HELP_MESSAGE { usage(); }
sub usage() {
    print <<"HERE";
Grab screenshots of http services found in an nmap scan.

Usage: nmap-http-screenshot.pl [switches]
   -x [file]     specify nmap scan XML output file (MANDATORY)
   -o [dir]      target folder of screenshot images (MANDATORY; created if not exists)
   -w [path]     wkhtmltoimage binary path (default: /usr/bin/wkhtmltoimage)
   -t [fileext]  output file extension defining image type (default: png)
   -q [quality]  quality of image in precentage (default: 60)
   -h            show this help

Pro-Tip for using without an X display: xvfb-run nmap-http-screenshot.pl [switches]

Please note that the capturing ability is limited to the ability of wkhtmltoimage.

HERE
    exit;
}

my $timeoutcmd = '/usr/bin/timeout';
my $timeoutdelay = '10';

our($opt_x, $opt_o, $opt_w, $opt_t, $opt_q, $opt_h);
getopts('hx:o:');

# mandatory options
if ($opt_x eq "" or $opt_o eq "" or $opt_h) {
    usage();
}

# defaults
my $w = ($opt_w eq "") ? "/usr/bin/wkhtmltoimage" : $opt_w;
my $t = ($opt_t eq "") ? "png" : $opt_t;
my $q = ($opt_q eq "") ? "60" : $opt_q;

$opt_o =~ s/\/$//;
mkdir $opt_o;
if (! -d $opt_o) {
    print "[!] Creating folder '".$opt_o."' failed.\n";
    exit;
}

my $np = new Nmap::Parser;

eval {
    $np->parsefile($opt_x);
    1;
} or die "[!] Parsing nmap XML file '".$opt_x."' failed.\n";

my $index = "<html><body>\n";
$index .= "<h2><pre>" . $np->get_session()->scan_args() . "</pre></h2><br>\n";

for my $addr ($np->addr_sort($np->get_ips('up'))) {
    my $host = $np->get_host($addr);
    for my $port ($host->tcp_open_ports()) {
	my $svc = $host->tcp_service($port);
	if ($svc->name() =~ /http[s]*/) {
	    my $prefix = ($svc->tunnel() eq "ssl") ? "https" : "http";
	    my $url = $prefix . "://" . $host->addr() . ":" . $port . "/";
	    my $outfile = "screenshot-nmap-" . $host->addr() . ":" . $port . "." . $t;
	    if (system($timeoutcmd, $timeoutdelay, $w,
		       '-q', '--quality', $q, '--enable-plugins',
		       $url, $opt_o . "/" . $outfile) == 0) {
		print "[+] " . $outfile . " saved.\n";
	    } else {
		print "[!] grabbing " . $outfile . " failed.\n";
	    }
	    $index .= $host->addr() . ":" . $port;
	    $index .= " [" . $host->hostname() . "] (";
	    $index .= $svc->product() . ")<br>\n";
	    $index .= '<img src="./'. $outfile;
	    $index .= '" width="800" onerror="this.width=20" border="1"><br><br>' . "\n";
	}
    }
}

open(my $fh, '>', $opt_o . "/index.html");
print $fh $index;
close $fh;
print "[+] index file '" . $opt_o . "/index.html' written.\n";
