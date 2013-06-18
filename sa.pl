#!/usr/bin/perl
# Author: Pengfei Cui
# Date: 10/13/2012
# Purpose:  Parse spectrum analyzer data for v-v experiments
# Usage: For parsing data 
# Output style: 450MHz, 900MHz, 2.4GHz, 5.2Ghz
use Switch;

###########################################################################################
#--------------------------Define output file name----------------------------------------#
###########################################################################################
my $output=">spectrum_analyzer.csv";
my $inputfile="multiband.csv";
use Cwd;

my $dir = cwd or die("error message");

my $count = 0;


opendir(DIR,$dir);

print "Parsing files...\n";

open(OUTFILEIPERF,$output);
#  print OUTFILECSV "System Time",",","Microsecond",",","System time in us",",","Central Frequency",",","TX Rate",",";
###################################################################################
open(INFILE,$inputfile);
open(DEBUG,">debug_sa.txt");
####################################################
# --------- Read to the end of the file ---------- #
####################################################
while (<INFILE>)
{
	$line = $_;

	if ($line =~ /.*-(\d+).(\d*),-(\d+).(\d*),-(\d+).(\d*),-(\d+).(\d*),(\d+)-(\d+)-(\d+)\s+(\d+):(\d+):(\d+).(\d*).*/)
	#  1      2      3     4      5     6      7     8     9     10    11      12    13    14    15
	{
		if($15 eq ""){
			$usecond="0";
		}
		else
		{
			$usecond=$15;
		}
print OUTFILEIPERF "-$1.$2,-$3.$4,-$5.$6,-$7.$8,$9$10$11,$12$13$14,$usecond\n";
		$count=$count+1;
	}

	else 
	{print DEBUG $line};

}


print $count,"\n";
close(OUTFILEIPERF);
close(INFILE);
print "Parsing complete!\n";
closedir(DIR);






