#!/usr/bin/perl
# Author: Pengfei Cui
# Date: 16/08/2012
# Modified 20/09/2012
# Purpose:  Parse tcpdump data for v-v experiments
# Usage: tests 
# History, Oct.11 change the GPS output model as standard 
use Switch;

###########################################################################################
#--------------------------Define output file name----------------------------------------#
###########################################################################################
my $iperf_24="gps_24";
my $iperf_52="gps_52";
my $iperf_70="gps_45";
my $iperf_90="gps_90";


my @filearray_24;
my @filearray_52;
my @filearray_70;
my @filearray_70;




#System information
my $year = 0;
my $month = 0;
my $day = 0;
my $date = 0;
my $hour = 0;
my $minute = 0;
my $second = 0;
$time = 0;

my $microsec = 0;

my $system_uss=0 ;
our $tx_rates=0 ;
my $pkt_freqs=0 ;
my $pkt_rssis=0 ;
my $pkt_noises=0 ;

my $pkt_snrs=0 ;

my $pkt_src_IPs=0 ;
my $pkt_src_ports=0 ;
my $pkt_dst_IPs=0 ;
my $pkt_dst_ports=0 ;
my $pkt_types=0 ;
my $pkt_lengths=0;
my $pkt_amount=0;
my $snr_sum=0;
my $snr_avr=0;

my $delay=0;
my $delay_avr=0;
my $system_us_previous=0;


#GPS information

our $latitude = 0;
our $longitude = 0;
our $velocity = 0;
our $gpstime =0;


#Activity Level
our $activity = 0;

#Debug flag
our $f_line=0;

my $inter_cnt=0;


use Cwd;

my $dir = cwd or die("error message");




opendir(DIR,$dir);

print "Parsing files...\n";

#Put different bands data file to different file arrays
################################################################################
while ($filename = readdir(DIR)) 

{
  if ($filename =~ /^veh_info/)
  {
    push(@filearray_24,"$filename");
  }
  elsif ($filename =~ /^vehinfo5/)
  {
    push(@filearray_52,"$filename");
  }
  elsif ($filename =~ /^vehinfo4/)
  {
    push(@filearray_70,"$filename");
  }
  elsif ($filename =~ /^vehinfo9/)
  {
    push(@filearray_90,"$filename");
  }

}
##################################################################################

#Count the amount of data files and put the number to array_size
##################################################################################
my $array_size_24 = $#filearray_24 + 1;
push(@array_size,$array_size_24);
my $array_size_52 = $#filearray_52 + 1;
push(@array_size,$array_size_52);
my $array_size_70 = $#filearray_70 + 1;
push(@array_size,$array_size_70);
my $array_size_90 = $#filearray_90 + 1;
push(@array_size,$array_size_90);
###################################################################################

my $array_num=$#array_size+1;
#############Debug output information #############################################

$logfile2 = ">debug_log2.txt";
open(OUTFILELOG2,$logfile2);

$logfile = ">debug_log.txt";
open(OUTFILELOG,$logfile);
print "Create logfile\n";

for ($i=0;$i <$array_num; $i++ )
{
########Choose band################################################################	
  switch ($i)
  {
    case (0)
    {@filearray=@filearray_24;
      print "Parsing 24GHz...\n";
      $iperfdata = ">".$iperf_24.".csv"};
      case (1) 
      {@filearray=@filearray_52;
	print "Parsing 52GHz...\n";
	$iperfdata = ">".$iperf_52.".csv"};
	case (2)
	{@filearray=@filearray_70;
	  print "Parsing 700MHz...\n";
	  $iperfdata = ">".$iperf_70.".csv"};
	  case (3)
	  {@filearray=@filearray_90;
	    print "Parsing 900MHz...\n";
	    $iperfdata = ">".$iperf_90.".csv"};
  }	
  $count=0;
  $gpstime=0;
  open(OUTFILEIPERF,$iperfdata);
#  print OUTFILECSV "System Time",",","Microsecond",",","System time in us",",","Central Frequency",",","TX Rate",",";
#  print OUTFILECSV "RX_RSSI",",","PKT_Noise";
#  print OUTFILECSV ",","PKT_SNR","\n"; # Print snr information
###################################################################################

##############Parse one band data files############################################
    for ($j = 0; $j < $array_size[$i]; $j++)

    {
########Open data files and output file
      open(INFILE,$filearray[$j]);

      $pkt_amount = 0;
      $snr_sum=0;
      $delay=0;

####################################################
# --------- Read to the end of the file ---------- #
####################################################
      while (<INFILE>)
      {
	$line = $_;
	$count++;
	$f_line=0;



#[  3] 200.0-200.5 sec  17.2 KBytes   282 Kbits/sec  22.802 ms  184/  196 (94%)
#Parse the throughput
	if ($line =~ /.*[ \d+]\s*(\d+).(\d+)-\s*(\d+).(\d+)\ssec\s*(.+)\s.+Bytes\s*(.+)\s(.*)bits.sec\s*(\d+).(\d+)\sms.*/)
	{
	  $f_line=1;
	  $throughput = "$6";

#print $1,".",$2,"\n";
# check if in Kbitsa
	  if ($7 eq "K") { $throughput = $throughput/1000; }
#	  if ($7 eq "\s") { $throughput = 0; }

#Calculate average SNR
	  if ($pkt_amount>0)
	  {
	    $snr_avr=$snr_sum/$pkt_amount;
	    $delay_avr=$delay/$pkt_amount;
	  }
#Output here	

#	  if ($delay_avr>1960) {
	    #print OUTFILECSV $snr_avr,",",$throughput,",",$delay_avr,"\n";
#print OUTFILECSV $snr_avr,",",$throughput,",",$pkt_amount,",",$delay_avr,"\n";
	    print OUTFILEIPERF $gpstime,",",$velocity,",",$latitude,",",$longitude,",",$throughput,"\n";
#print OUTFILELOG $inter_cnt,",",$activity,"\n";
	    $pkt_amount = 0;
	    $snr_sum=0;
	    $throughput=0;
	    $delay=0;
	    $delay_avr=0;
	    $activity = 0;
	    $inter_cnt = 0;

#print $pkt_amount,"\n";

#	  }
	  print OUTFILELOG2 "$line";

	}


#Parse the tcpdump information

#00:15:01.546755 908189762us tsft short preamble 6.0 Mb/s 5200 MHz 11a -64dB signal -95dB noise antenna 1 31dB signal 60us DA:06:15:6d:67:ef:9b (oui Unknown) SA:00:15:6d:68:0c:84 (oui Unknown) BSSID:00:00:00:00:00:00 (oui Ethernet) LLC, dsap SNAP (0xaa) Individual, ssap SNAP (0xaa) Command, ctrl 0x03: oui Ethernet (0x000000), ethertype IPv4 (0x0800): (tos 0x0, ttl 64, id 32337, offset 0, flags [DF], proto UDP (17), length 1498)
	if ($line =~ /\s*(\d+):(\d+):(\d+).(\d+)\s(\d+)us\stsft\sshort\spreamble\s+(\d+.\d+)\sMb\/s\s(\d+)\sMHz\s+11.\s+(\D*)(\d+)dB\ssignal\s(\D*)(\d+)dB\snoise\santenna\S*/)#
#         10  11                              12                                     
	{

	  $f_line=1;
	  my $hour = $1;
	  my $minute = $2;
	  my $second = $3;
	  $time = $hour.$minute.$second;

	  my $microsec = $4;
	  my $system_us = $5;
	     $tx_rate = $6;
	  my $pkt_freq = $7;
	  my $pkt_rssi = $8.$9;
	  my $pkt_noise = $10.$11;



	  if ($line =~ /\s*(\d+):(\d+):(\d+).(\d+)\s(\d+)us\stsft\sshort\spreamble\s+(\d+).\d+\sMb\/s\s(\d+)\sMHz\s+11.\s+(\D*)(\d+)dB\ssignal\s(\D*)(\d+)dB\snoise\santenna\s\d+\s\D*(\d+)dB\ssignal\s.*,\s+length\s1498\S*/)#
	  {
	    my $delay_pkt=$system_us-$system_us_previous;

	    $snr_sum=$snr_sum+$pkt_rssi;
	    $pkt_amount++;

	    if($pkt_amount> 1)
	    {
	      $delay=$delay+$delay_pkt;
	      $system_us_previous=$system_us;
	    }
	    else
	    {
	      $system_us_previous=$system_us;
	    }
	  }
#Calculate activity level
#00:09:47.213304 590680576us tsft short preamble 1.0 Mb/s 2412 MHz 11g -87dB signal -96dB noise antenna 1 9dB signal 120us RA:e0:46:9a:3c:f9:bd (oui Unknown) Clear-To-Send
#	  elsif ($line =~ /.*signal\s+(\d*)us.*Clear-To\S*/)#
#	  {
#	    $activity=$activity+$1/1000000;
#	    #print OUTFILELOG $activity,"\n";
#	    print OUTFILELOG $1,"\n";
#
#	  }
	  else
	  {
	    $inter_cnt++;
	    if($tx_rate ne "0.0" )
	    {
	      $activity=$activity+(160/$tx_rate/1000000);
	    }

	  }
#print $delay_pkt,"\n";
#	  print OUTFILECSV $time,",",$microsec,",",$system_us,",",$pkt_freq,",",$tx_rate,",",$pkt_rssi,",",$pkt_noise;
#	  print OUTFILECSV ",",$pkt_snr;# Print snr information
#	    print OUTFILECSV ",",$pkt_dst_IP,",",$pkt_dst_port; # Print dst information
#	    print OUTFILECSV ",",$pkt_type,",",$pkt_length,",",$pkt_amount,"\n";
	}

#41719564us tsft short preamble 1.0 Mb/s 2412 MHz 11g -96dB signal -96dB noise antenna 1 0dB signal 0us RA:00:16:b6:9e:29:a9 (oui Unknown) Acknowledgment
#41719564us tsft short preamble 1.0 Mb/s 2412 MHz 11g -96dB signal -96dB noise antenna 1 0dB signal 0us RA:00:16:b6:9e:29:a9 (oui Unknown) Acknowledgment
	elsif ($line =~ /\.*(\d+)us\stsft\sshort\spreamble\s+(\d+.\d+)\sMb\/s\s(\d+)\sMHz\s+11.\s+(\D*)(\d+)dB\ssignal\s(\D*)(\d+)dB\snoise\santenna\S*/)
	{
	  $f_line=1;
	  my $tx_rate = $2;
	  if($tx_rate ne "0.0")
	  {
	    $activity=$activity+(160/$tx_rate/1000000);
	  }
	}


#6.0 Mb/s 2412 MHz 11g -65dB signal -96dB noise antenna 1 31dB signal 60us DA:06:15:6d:68:4e:30 (oui Unknown) SA:00:15:6d:68:4e:3f (oui Unknown) BSSID:00:00:00:00:00:00 (oui Ethernet) LLC, dsap SNAP (0xaa) Individual, ssap SNAP (0xaa) Command, ctrl 0x03: oui Ethernet (0x000000), ethertype IPv4 (0x0800): (tos 0x0, ttl 64, id 12481, offset 0, flags [DF], proto UDP (17), length 1498)
	elsif ($line =~ /\s*(\d+.\d+)\sMb\/s\s(\d+)\sMHz\s+11.\s+(\D*)(\d+)dB\ssignal\s(\D*)(\d+)dB\snoise\santenna.*length\s1498\S*/)#
	{
	  $f_line=1;
	  $pkt_rssi=$3.$4;
	  $snr_sum=$snr_sum+$pkt_rssi;
	  $pkt_amount++;

	}


#SA:f4:ea:67:0a:e1:24 (oui Unknown) Beacon () [1.0* 2.0* 5.5* 6.0 9.0 11.0* 12.0 18.0 Mbit] ESS CH: 1[|802.11]
#DA:Broadcast SA:20:37:06:a4:8e:60 (oui Unknown) Beacon (concrete) [5.5* 11.0 Mbit] ESS CH: 1, PRIVACY[|802.11]

	elsif ($line =~ /\s*Beacon\S*/)#
	{
	  $f_line=1;
	  $activity=$activity+(160/1000000);
	}

#BSSID:00:00:00:00:00:00 (oui Ethernet) LLC, dsap SNAP (0xaa) Individual, ssap SNAP (0xaa) Command, ctrl 0x03: oui Ethernet (0x000000), ethertype IPv4 (0x0800): (tos 0x0, ttl 64, id 12656, offset 0, flags [DF], proto UDP (17), length 1498)

	elsif ($line =~ /\s*length\s1498\S*/)#
	{
	  $f_line=1;
	}
#fixme	find interference
#192.168.10.81.64644 > 255.255.255.255.10007: [bad udp cksum a4ce!] UDP, length 128
    #10.161.15.234.mdns > 224.0.0.251.mdns: [bad udp cksum cecc!] 0 [2q] [2n] Type0 (Class 32512) (QU)? Blessons-iPod.local. Type3072 (Class 32512) (QU)? Blessons-iPod.local. ns: Blessons-iPod.local. (Class 7168) Type3072[|domain]
	elsif ($line =~ /\s*(\d+).(\d+).\d+.(\d+).*>.*\s+length\s+(\d+)\S*/)#
	{
	  $f_line=1;
	  my $ip_s=$1.$2.$3;
	    if($ip_s ne "19216855")
	    {
	    if($tx_rate ne 0 && $tx_rate ne "0.0")
	
	{ 
	 $activity=$activity+($4*8/$tx_rate/1000000);
	  }
	    #   print $line;
	
	#print $tx_rate,"\n";
	    }
	}





#Server listening on UDP port 5001
	if ($line =~ /\s*Server\s+listening\son\sUDP\sport.*/)
	{
	  $f_line=1;
#print OUTFILELOG2 $line,",",$pkt_amount,"\n";

	  $pkt_amount = 0;
	  $snr_sum=0;
	  $delay=0;
	}
#[  5]  0.5- 1.0 sec    301 KBytes  4.94 Mbits/sec  3.604 ms 3835/ 4045 (95%)
#[  7] 10.0-10.5 sec    312 KBytes  5.10 Mbits/sec  3.170 ms  573/  790 (73%)

#Parse GPS information
	if ($line =~ /\.*GPGGA,(\d+).(\d+),(\d+).(\d+),N,(\d+).(\d+),W,(\d+),(\d+),(\d+).(\d+),(\d+),M.*/)
	{
	  $f_line=1;
	  our $gpstime = $1.".".$2;
	  our $latitude = $3.".".$4;
	  our $longitude = $5.".".$6;

	}

	elsif ($line =~ /\.*GPVTG,\d+.\d+,T,\d+.\d+,M,(\d+).(\d+),N,(\d+).(\d+),K.*/)
	{
	  $f_line=1;
#velocity in KM
	  our $velocity = $3.".".$4;
#	printf "$gpstime,$velocity\n";

		$latitude_degree=int($latitude/100);
		$latitude_cent=($latitude-$latitude_degree*100)/60;
		$latitude=$latitude_degree+$latitude_cent;
		
		$longitude_degree=int($longitude/100);
		$longitude_cent=($longitude-$longitude_degree*100)/60;
		$longitude=0-($longitude_degree+$longitude_cent);

	    print OUTFILEIPERF $gpstime,",",$velocity,",",$latitude,",",$longitude,"\n";


	}





#Filter some lines for debugging
#    192.168.12.55.48435 > 192.168.12.65.5003: [bad udp cksum a189!] UDP, length 1470

#------------------------------------------------------------
	if ($line =~ /\.*-------------------------------------.*/)
	{
	  $f_line = 1;
	}

#Receiving 1470 byte datagrams
	if ($line =~ /\.*Receiving\s1470\sbyte.*/)
	{
	  $f_line = 1;
	}
#UDP buffer size:  108 KByte (default)
	if ($line =~ /\.*UDP\sbuffer\ssize:.*/)
	{
	  $f_line = 1;
	}
#message-age 21.00s, max-age 0.08s, hello-time 0.01s, forwarding-delay 0.06s
	if ($line =~ /\.*message-age\s\d+..*/)
	{
	  $f_line = 1;
	}
#root-id 807c.00:12:7f:f5:be:80, root-pathcost 3196059893
	if ($line =~ /\.*root-id.*/)
	{
	  $f_line = 1;
	}
#TrnID=0xAC94
	if ($line =~ /\S*TrnID.*/)
	{
	  $f_line = 1;
	}
	elsif($line=~/\s*OpCode.*/)
	{
	  $f_line = 1;
	}
	elsif($line=~/\s*NmFlags.*/)
	{
	  $f_line = 1;
	}
	elsif($line=~/\s*AnswerCount.*/)
	{
	  $f_line = 1;
	}
	elsif($line=~/\s*AuthorityCount.*/)
	{
	  $f_line = 1;
	}
	elsif($line=~/\s*Name=.*/)
	{
	  $f_line = 1;
	}
	elsif($line=~/\s*Question.*/)
	{
	  $f_line = 1;
	}
	elsif($line=~/\s*Query.*/)
	{
	  $f_line = 1;
	}
	elsif($line=~/\s*Rcode.*/)
	{
	  $f_line = 1;
	}
	elsif($line=~/\s*AddressRec.*/ || $line=~/\s*Tot.*/ ||	$line=~/\s*Max.*/)
	{
	  $f_line = 1;
	}

	elsif($line=~/\s*UID.*/ || $line=~/\s*Error.*/)
	{
	  $f_line = 1;
	}
	elsif($line=~/\s*Error.*/ || $line=~/\.*length\s1470/)
	{
	  $f_line = 1;
	if ($line !~ /\.*192.168.\d+.55.*/)
	{
	  #print $line,"\n";
	}
	}

	elsif($line=~/\s*Vendor.*/ || $line=~/\s*DHCP.*/ || $line=~/\s*Magic.*/)
	{
	  $f_line = 1;
	}
	elsif($line=~/\s*Requested.*/ || $line=~/\s*MSZ.*/ ||
	$line=~/\s*Subnet.*/)
	{
	  $f_line = 1;
	}
	elsif($line=~/\s*Parameter-Request.*/ ||
	$line=~/\s*Domain-.*/ ||
	$line=~/\s*RN,.*/)
	{
	  $f_line = 1;
	}
	elsif($line=~/\s*BROWSE.*/ ||
	$line=~/\s*Param.*/ ||
	$line=~/\s*Browser.*/ ||
	$line=~/\s*Type\sunknown.*/ ||
	$line=~/\s*Tree.*/)
	{
	  $f_line = 1;
	}

	elsif($line=~/\s*DataCnt.*/ ||
	$line=~/\s*SUCnt.*/ ||
	$line=~/\s*Browser.*/ ||
	$line=~/\s*Flags1.*/ ||
	$line=~/\s*Flags2.*/ ||
	$line=~/\s*SMB.*/)
	{
	  $f_line = 1;
	#  print $line,"\n";
	}



	if($f_line eq "0" && $line ne "\n") 
	{
	  print OUTFILELOG $line;
	}

      }#while
      close (INFILE);

    }#j loop
  print $count,"\n";
  close(OUTFILEIPERF);
}#i loop


close(OUTFILELOG);
close(OUTFILELOG2);
print "Parsing complete!\n";
closedir(DIR);






