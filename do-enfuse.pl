#!/usr/bin/perl

use strict;
use warnings;
use File::Copy;
use Data::Printer;
use Archive::Zip qw(:ERROR_CODES :CONSTANTS );

# Move files into a sub-directory based on the date
my $root_dir = '/home/icydee/images/';
opendir(my $dh, $root_dir);
my @files = readdir($dh);

# Now process each directory
opendir($dh, $root_dir);
my @dirs = readdir($dh);
DIR:
foreach my $dir (@dirs) {
    next DIR if not (-d $root_dir.$dir);
    my ($subdir) = $dir =~ m/^(\d\d\d\d\d\d)$/;
    if ($subdir) {
        # Process all groups of files in this dir
        opendir(my $sub, $root_dir.$dir);
        my @sub_files = readdir($sub);

	# Don't process the directory if we have an mp4 file
        if ( grep(/video_${subdir}.mp4/, @sub_files) ) {
            print("Skipping directory $subdir, already processed\n");
        }
        else {
            print("Processing directory $subdir\n");
        }
        
        my $files_hash;
        foreach my $sub_file (@sub_files) {
            my ($time, $postfix) = $sub_file =~ m/img_${subdir}-(\d\d\d\d)_(.)\.jpg/;
            if ($time) {
                $files_hash->{$time}{$postfix} = $sub_file;
            }
        }
        print(p($files_hash));
	
	my $idx = '0001';
	# Now process each file group
        foreach my $key (sort keys %$files_hash) {
            my $file_hash = $files_hash->{$key};

	    my $calc_filename = sub {
                my ($postfix) = @_;

		return $root_dir.$subdir."/img_${subdir}-${key}_${postfix}.jpg";
            };

	    if ($file_hash->{x}) {
                my $outfile = $root_dir.$subdir."/img_${idx}.jpg";

                print("Create file $outfile\n");
                my $cmd = "enfuse -o $outfile ";
		my $zip = Archive::Zip->new();
                foreach my $postfix (sort keys %$file_hash) {
                    $cmd .= &$calc_filename($postfix)." ";
                    $zip->addFile(&$calc_filename($postfix));
                }

		my $stdout = `$cmd`;
                print $stdout;

                if ( ! $zip->writeToFileNamed($root_dir.$subdir."/img_${idx}.zip") == AZ_OK) {
                    die "write error";
                }

                # Remove all files that were zipped
                foreach my $postfix (sort keys %$file_hash) {
                    my $filename = &$calc_filename($postfix);
                    print "DEL: $filename\n";
		    unlink($filename) or warn "Could not unlink file";
                }

                $idx++;
            }
        }
    }
}


