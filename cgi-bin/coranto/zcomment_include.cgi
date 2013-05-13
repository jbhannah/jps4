# ZCOMMENT INCLUDED SUBROUTINES #

###############################################
# Read ZCOMMENT.CGI for licencing information #
###############################################

$includebuild = 8;

%zlang = (
	"error" => q~An error has occured~,
	"unknown_article" => q~The article you specified is unknown.~,
	"currently_none" => q~Currently none.~,
	"change_your_password_link" => q~Change Your Password (If Registered)~,
	"clear_remember_me_link" => q~Clear Your "Remember Me" Information~,
	"register_link" => q~Register Your User Name~,
	"name" => q~Name~,
	"password" => q~Password~,
	"logged_in" => q~You Are Logged In~,
	"register_link_form" => q~Only required if you~,
	"toolbox" => q~Toolbox~,
	"email" => q~E-Mail~,
	"subject" => q~Subject~,
	"comment" => q~Comment~,
	"remember_me" => q~Remember Me~,
	"submit" => q~Submit~,
	"taken_username" => q~The User Name is taken or you produced an invalid password.~,
	"missing_fields" => q~One or more required fields have not been filled out.~,
	"info_cleared" => q~Information Cleared~,
	"info_cleared_mess" => q~All "Remember Me" information has been cleared.~,
	"go_back" => q~Go Back~,
	"register_your_username_mess" => q~Use the form below to register your username~,
	"confirm_password" => q~Confirm Password~,
	"password_mismatch" => q~The passwords you entered do not match. Please try again.~,
	"name_created" => q~User Name Created~,
	"name_created_mess" => q~The user name, $name, has sucessfully been created. For security reasons the password will not be displayed here.~,
	"change_your_password" => q~Change Your Password~,
	"change_your_password_mess" => q~Use the form below to change your password, be sure to fill out all the fields, as they are all required.~,
	"old_password" => q~Old Password~,
	"confirm_new_password" => q~Confirm New Password~,
	"password_changed" => q~Password Changed~,
	"password_changed_mess" => q~Your password was sucessfully changed.~,
	"invalid_password" => q~The password you have entered is invalid.~,
	"register" => q~register~,
	"powered_by" => q~Powered By <a href="http://zcomment.b000.net">ZComment</a>~
);

## IIS? ##
 ## 1 = yes, 0 = no
$IIS = 0;

if (($IIS) && ($0 =~ m!(.*)(\\|\/)!)) {
	chdir($1);
}

open (SETTINGS, "nsettings.cgi");
while (<SETTINGS>) {
	chomp($_);
	my ($name, $value) = split (/``x/, $_);
	$settings{$name} = $value;
}
close (SETTINGS);

$newsdatpath = $settings{'htmlfile_path'} . "/newsdat.txt";

if ($ENV{'QUERY_STRING'}) {
	@sets = split(/&/, $ENV{'QUERY_STRING'});
	foreach $set (@sets) {
		my ($name, $value) = split(/=/, $set);
		$value =~ tr/+/ /;
		$value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
		$page{$name} = $value;
	}
}

if ($ENV{'CONTENT_LENGTH'}) {
	read(STDIN, $buffer, $ENV{'CONTENT_LENGTH'});
	@sets = split(/&/, $buffer);
	foreach $set (@sets) {
		my ($name, $value) = split(/=/, $set);
		$value =~ tr/+/ /;
		$value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
		$form{$name} = $value;
	} 
}

if ($ENV{'HTTP_COOKIE'}) {
	foreach (split(/; /, $ENV{'HTTP_COOKIE'})) {
		my ($name, $value) = split (/=/);
		$cookies{$name} = $value;
	}
}

sub zdie {
	my $message = shift;
	print "Content-type: text/html\n\n";
	print "<b>ZComment Errored With The Following Error:</b> $message";
}

sub simplepage {
	my ($title, $message) = @_;
	&top($title);
	&message($title, $message);
	&bottom();
}

sub get_unique {
	$unique = time;
}

sub message {
	my ($doname, $domessage) = @_;
	print "\n$domessage";

}

sub date {

	$newstime = $postid if ($postid);

	($sec, $min, $hour, $day, $mon, $year, $wday, $yday, $isdst) = localtime($newstime);

	$year += 1900;
	$mon  += 1;
	$ampm  = "PM"        if ($hour < 12);
	$ampm  = "AM"        if ($hour > 12);
	$hour += -12         if ($hour > 12);
	$hour += $settings{'TimeOffset'};
	$hour += 12          if ($hour < 0);
	$hour  = 12          if ($hour == 0);
	$hour  = "0" . $hour if ($hour < 10);
	$min   = "0" . $min  if ($min < 10);

	$datedisp = $settings{'zcomment_date'};
	$timedisp = $settings{'zcomment_time'};

	@months = ("MONKEY", "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December");
	@days = ("Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday");

	$datedisp =~ s/<Field: Year>/$year/g;
	$datedisp =~ s/<Field: TwoDigitYear>/substr($year, 3, 2)/g;
	$datedisp =~ s/<Field: Month_Name>/$months[$mon]/g;
	$datedisp =~ s/<Field: Month_Number>/$mon/g;
	$datedisp =~ s/<Field: TwoDigitMonth>/$mon/g;
	$datedisp =~ s/<Field: Weekday>/$days[$wday]/g;
	$datedisp =~ s/<Field: Day>/$day/g;
	$datedisp =~ s/<Field: TwoDigitDay>/$day/g;
	$datedisp =~ s/<Field: Hour>/$hour/g;
	$datedisp =~ s/<Field: TwoDigitHour>/$hour/g;
	$datedisp =~ s/<Field: Minute>/$min/g;
	$datedisp =~ s/<Field: Second>/$sec/g;
	$datedisp =~ s/<Field: AMPM>/$ampm/g;

	$timedisp =~ s/<Field: Year>/$year/g;
	$timedisp =~ s/<Field: TwoDigitYear>/substr($year, 3, 2)/g;
	$timedisp =~ s/<Field: Month_Name>/$months[$mon]/g;
	$timedisp =~ s/<Field: Month_Number>/$mon/g;
	$timedisp =~ s/<Field: TwoDigitMonth>/$mon/g;
	$timedisp =~ s/<Field: Weekday>/$days[$wday]/g;
	$timedisp =~ s/<Field: Day>/$day/g;
	$timedisp =~ s/<Field: TwoDigitDay>/$day/g;
	$timedisp =~ s/<Field: Hour>/$hour/g;
	$timedisp =~ s/<Field: TwoDigitHour>/$hour/g;
	$timedisp =~ s/<Field: Minute>/$min/g;
	$timedisp =~ s/<Field: Second>/$sec/g;
	$timedisp =~ s/<Field: AMPM>/$ampm/g;

	$date = $datedisp;
	$time = $timedisp;
}

sub tmpl {
	$template = "";
	open (TMPL, "zcomment.tmpl");
	while (<TMPL>) {
		$template .= $_;
	}
	close (TMPL);

	$template =~ s/<!-- INSTRUCTIONS[\s\w\W\S]+-->//g; # From El Coranto
	$template =~ s/<Field: Title>/<ZComent: Title>/gi;
	$template =~ s/<Field: Content>/<ZComment: Content/gi;
	$template =~ s/<InsertTitle>/<ZComment: Title>/gi;
	$template =~ s/<InsertContent>/<ZComment: Content>/gi;
	$template =~ s/<ZComment: Title>/<ZComment: Title>/gi;
	$template =~ s/<ZComment: Content>/<ZComment: Content>/gi;
	$template =~ s/<!--#include file\s*=\s*"(\S+?)"\s*-->/FakeSSI($1)/gie; # From Da Coranto

	($top, $bottom) = split (/<ZComment: Content>/, $template);
}

sub FakeSSI {
	my $file;
	my ($name) = @_;
	open(FILE, "$name");
	while (<FILE>) {
		$file .= $_;
	}
	close(FILE);

	return $file;
}

sub top {
	($pagetitle) = @_;
	tmpl;
	if ($IIS) { print "HTTP/1.0 200 OK\n"; }
	unless ($IIS) { print "Content-type: text/html\n\n"; }
	if ($pagetitle) { $top =~ s/<ZComment: Title>/$pagetitle/g; }
	print $top;
}

sub bottom {
	tmpl;
	if ($title) { $bottom =~ s/<ZComment: Title>/$pagetitle/g; }
	print $bottom;
}

sub build {
	$JustLoadSubs++;
	$EnableCategories = 1;
	require 'coranto.cgi';
	NeedFile('crcore.pl');
	StartUp();
	ReadUserInfo();
	NeedFile('crlang.pl');
	if ($CConfig{'AddonsLoaded'}) {
		NeedFile('craddon.pl');
		LoadAddons();
	}
	my $full = $settings{'zcomment_full'};
	BuildNews($full); 
}

1;