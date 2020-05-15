#!/usr/bin/perl

use strict;
use warnings;
use File::Copy;
use Data::Printer;

# Move files into a sub-directory based on the date
my $root_dir = '/home/icydee/images/';
opendir(my $dh, $root_dir);
my @files = readdir($dh);

FILE:
foreach my $file (@files) {
    my ($date, $time, $postfix) = $file =~ m/img_(\d\d\d\d\d\d)-(\d\d\d\d)_(.)\.jpg/;
    next FILE if not $date;
    #print "FILE [$date][$time][$postfix]\n";
    # check if directory exists, if not, create it
    my $dir = $root_dir.$date.'/';
    print("DIR: [$dir]\n");
    if ( not ( -e $dir ) ) {
        # Create the directory.
        print("Create dir [$dir]\n");
	mkdir($dir);
    }
    # Copy file to directory
    move( $root_dir.$file, $dir.$file );
}

