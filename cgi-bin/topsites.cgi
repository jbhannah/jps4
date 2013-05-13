#!/usr/bin/perl
#!C:/Perl/bin/perl.exe

$topsites_php_url = "http://www.you.com/topsites";

use CGI qw/:standard/;
$q = new CGI;
%form = map { $_ => $q->param($_) } $q->param;

if ($form{action} eq "button" && $form{id} >= 1) {
  print "Location: $topsites_php_url/button.php?id=$form{id}\n\n";
}
elsif ($form{action} eq "in" && $form{id} >= 1) {
  print "Location: $topsites_php_url/in.php?id=$form{id}\n\n";
}
else {
  print "Location: $topsites_php_url/index.php\n\n";
}