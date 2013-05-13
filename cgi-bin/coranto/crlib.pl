# CRLIB.pl
# Common routines for Coranto scripts and addons.
# See coranto.cgi for license information.

if (defined $crcgiBuild and $crcgiBuild != 39) {
	CRdie('Your crlib.pl and crcore.pl files are mismatched -- that is, they come from different versions or builds of Coranto. Visit <a href="http://coranto.gweilo.org/">the unofficial Coranto homepage</a>, download a new copy of Coranto, and upload new versions of crcore.pl and crlib.pl.',1);
}

@Abbrev_Week_Days = ('Sun','Mon','Tue','Wed','Thu','Fri','Sat');
@Abbrev_Months = ('Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec');

# Auto-detect flock support, if necessary
unless ($UseFlock == 0){
	if ($^O eq 'MSWin32' || $ENV{'OS'} =~ /window/i){
		# We appear to be on a Windows box, so flock() isn't supported
		$UseFlock = 0;
	}
	else {
		# Assume we have file locking available
		$UseFlock = 1;
	}
}

######
# CORE SUBROUTINES
######

sub SortedArray_MoveUpDown {
# This is a general purpose sub that moves items in an array up/down by one each time
# Works ONLY with arrays passed by reference

my($arrayref, $object, $direction) = @_;

my @array = @{$arrayref};

my (%sorted, $swap);

	for(my $i=0;$i<@array;$i++){
	$sorted{$array[$i]} = $i;
	}

	CRcough('Invalid input error 1.') unless $sorted{$object} >= 0 && $sorted{$object} <= @array;
	CRcough('Invalid input error 2.') if $direction < 1 || $direction > 2;
	CRcough('This is already the first item.') if $direction == 1 && $sorted{$object} == 0;
	CRcough('This is already the last item.') if $direction == 2 && $sorted{$object} == @array - 1;

	$swap = ($sorted{$object} + 1) if $direction == 2;
	$swap = ($sorted{$object} - 1) if $direction == 1;
	@array[$sorted{$object}, $swap] = @array[$swap, $sorted{$object}];
	
	@{$arrayref} = @array;
}

######
# LOAD/SAVE SETTINGS
######

# Reads in user information. No arguments.
sub ReadUserInfo {
	%userdata = ();
	ReadInnerHash('userdata', 'user', \%userdata);
}

# Writes user information to %CConfig. No arguments.
sub WriteUserInfo {
	WriteInnerHash('userdata', 'user', \%userdata);
}

# Reads in information about the fields of the user database. No arguments.
sub ReadUserDBInfo {
	%userDB = ();
	ReadInnerHash('userDB', 'userDB', \%userDB);
}

# As above; writes the information.
sub WriteUserDBInfo {
	WriteInnerHash('userDB', 'userDB', \%userDB);
}

# Reads information from nsettings.cgi into a hash where each key is a hash reference.
# ReadInnerHash($list, $prefix, $hash) -- see WriteInnerHash.
sub ReadInnerHash {
	my ($list, $nprefix, $hash) = @_;
	my ($key, $value, $i, $j);
	my @list = split(/\|x\|/, $CConfig{$list});
	my @list2;
	foreach $i (@list) {
		if ($i) {
			@list2 = split(/\|x\|/, $CConfig{"$nprefix-$i"});
			foreach $j (@list2) {
				($key, $value) = split(/\!x\!/, $j);
				$$hash{$i}->{$key} = $value if $key;
			}
		}
	}
}

# Writes information from a hash where each key is a hash reference to nsettings.cgi.
# WriteInnerHash($list, $prefix, $hash);
# $list: A key in %CConfig where a list of the hash elements can be stored.
# $prefix: For storage purposes, each hash element will have its own element in %CConfig.
#	These elements will be called $prefix-something.
# $hash: A reference to the hash you want to save.
sub WriteInnerHash {
	my ($list, $nprefix, $hash) = @_;
	my ($i, $j, $key, $value);
	foreach $i (keys %$hash) {
		my @list;
		while (($key, $value) = each %{$$hash{$i}}) {
			$value =~ s/^\s+//;
			$value =~ s/\s+$//;
			$value =~ s/[\n\r]//g;
			$value =~ s/\|x\|//g;			
			$value =~ s/\!x\!//g;			
			push(@list, join('!x!', $key, $value)) if $key && $value ne '';
		}
		$CConfig{"$nprefix-$i"} = join('|x|', @list);
	}
	$CConfig{$list} = join('|x|', keys %$hash);
}

# Reads profile settings into %newsprofiles. No arguments.
sub ReadProfileInfo {
	my @nprof = split(/\|x\|/, $CConfig{'NewsProfiles'});
	my ($i, $j, $key, $value);
	foreach $i (@nprof) {
		if ($i ne '') {
			my @nprof2 = split(/\|x\|/, $CConfig{"Profile-$i"});
			foreach $j (@nprof2) {
				($key, $value) = split(/\!x\!/, $j);
				if ($key && $key ne 'cats') {
					$newsprofiles{$i}->{$key} = $value;
				}
				elsif ($key eq 'cats') {
					@{$newsprofiles{$i}->{$key}} = split(/\~x\~/, $value);
				}
				# HOOK: ReadProfileInfo
				if($Addons{'ReadProfileInfo'}){my $w;foreach $w (@{$Addons{'ReadProfileInfo'}}){my $addon=$w->[2];eval ${$w->[0]};AErr($addon,$@)if $@;};}
			}
		}
		
	}
}

# Reads settings information from nsettings.cgi into a tied hash it creates called %CConfig.
# This hash will automatically save to nsettings.cgi when necessary.
sub ReadConfigInfo {
	my $nsetpath = $nsettingspath;
	my $bakpath = $nsbkpath;
	if ($abspath && !$nsetpath) {
		$nsetpath = "$abspath/nsettings.cgi";
	}
	$nsetpath = 'nsettings.cgi' unless $nsetpath;
	if ($abspath && !$bakpath) {
		$bakpath = "$abspath/nsbk.cgi";
	}
	$bakpath = 'nsbk.cgi' unless $bakpath;
	tie(%CConfig, 'Tie::CConfig', $nsetpath, $bakpath);
}	

use subs 'exit';

sub exit {
	untie(%CConfig) if %CConfig;
	CORE::exit();
}

package Tie::CConfig;

sub TIEHASH  { 
	my $self = {};
	my ($class, $nsetpath, $bakpath) = @_;
	$self->{'nsetpath'} = $nsetpath;
	$self->{'bakpath'} = $bakpath;
	my $fh = main::CRopen($nsetpath);
	while (<$fh>) {
		($key, $value) = split(/``x/, $_);
		chomp $value;
		$value =~ s/\(ns!x!nl\)/\n/g;
		$self->{$key} = $value;
	}
	close($fh);
	bless $self, $class;
}

sub STORE { 
	my ($self, $key, $value) = @_;
	$self->{'saveFlag'} = 1;
	if ($key eq 'saveNow') {
		SaveCConfig($self);
	}
	else {
		$key =~ s/[\n\r]//g;
		$value =~ s/\(ns!x!nl\)//g;
		$value =~ s/\r//g;
		$key =~ s/\`\`x//g;
		$value =~ s/\`\`x//g;
		$self->{$key} = $value;
	}
}
sub FETCH { 
	$_[0]->{$_[1]};
}
sub FIRSTKEY { 
	my $a = scalar keys %{$_[0]}; 
	each %{$_[0]};
}
sub NEXTKEY { 
	each %{$_[0]};
}
sub EXISTS { 
	exists $_[0]->{$_[1]};
}
sub DELETE { 
	$_[0]->{'saveFlag'} = 1;
	delete $_[0]->{$_[1]};
}
sub CLEAR {
	die 'cannot clear %CConfig';
}
sub DESTROY {
	my $self = shift;
	unless ($self->{'manualSave'}) {
		SaveCConfig($self);
	}
}

sub SaveCConfig {
	my $self = shift;
	if ($self->{'saveFlag'} && !$self->{'neverSave'}) {
		my ($key, $value, $bak);
		my ($nsetpath, $bakpath) = ($self->{'nsetpath'}, $self->{'bakpath'});
		delete $self->{'nsetpath'};
		delete $self->{'saveFlag'};
		delete $self->{'bakpath'};
		delete $self->{'manualSave'};
		delete $self->{'saveNow'};
		unless (scalar(keys %$self) > 10) {
			die '%CConfig has 10 or fewer entries, and so is not being saved.';
		}
		my $fh = &main::CRopen('>' . $nsetpath);
		$self->{'currentbuild'} = $main::coreBuild if $main::coreBuild;
		# is a backup necessary?
		if ($self->{'nset_baktime'} && ($main::CurrentTime - $self->{'nset_baktime'}) > 604800) {
			$bak = 1;
			$self->{'nset_baktime'} = $main::CurrentTime;
		}
		elsif (!$self->{'nset_baktime'}) {
			$self->{'nset_baktime'} = $main::CurrentTime;
		}
		while (($key, $value) = each %$self) {
			$value =~ s/\n/(ns!x!nl)/g;
			print $fh "$key``x$value\n" if $key && $value ne '';
		}
		close($fh);
		if ($bak) {
			# Back up
			$fh = &main::CRopen($nsetpath);
			my @bak = <$fh>;
			close($fh);
			if (scalar(@bak) > 14) {
				# Only create a backup if nsettings.cgi looks OK.
				$fh = &main::CRopen('>' . $bakpath);
				print $fh join('', @bak);
				close($fh);
			}
		}
			
	}
}

package main;

######
# FORM & HTTP PROCESSING
######

# ReadForm: Reads in form values to %in. No arguments.
$Subs{'ReadForm'} = <<'END_SUB';
sub ReadForm {
	my (@pairs, $buffer, $pair, $name, $value); 
	if ($ENV{'REQUEST_METHOD'} eq 'GET') {
		@pairs = split(/&/, $ENV{'QUERY_STRING'});
	}
	elsif ($ENV{'REQUEST_METHOD'} eq 'POST') {
		read(STDIN, $buffer, $ENV{'CONTENT_LENGTH'});
		@pairs = split(/&/, $buffer);
	}
	foreach $pair (@pairs) {
		($name, $value) = split(/=/, $pair);
	
		$name =~ tr/+/ /;
		$name =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
	
		$value =~ tr/+/ /;
		$value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;

		# Translate OS-specific newline chars into Perl's logical one
		$name =~ s/\015?\012/\n/gi;
		$value =~ s/\015?\012/\n/gi;
	
		exists $in{$name} ? ($in{$name} .= "|x|$value") : ($in{$name}  = $value);
	}
}
END_SUB

# Reads cookies into %Cookies. No arguments.
sub GetCookies {
	my(@pairs) = split("; ",$ENV{'HTTP_COOKIE'});
	foreach (@pairs) {
		my($key,$value) = split("=");
		$value =~ tr/+/ /;
		$value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
		
		$key =~ tr/+/ /;
		$key =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;		
		
		$Cookies{$key} = $value;		
	}
}

# URLescape($url) returns an escaped version of $url suitable for using in a link.
{
	my %escapes;
	for (0..255) { $escapes{chr($_)} = sprintf("%%%02X", $_); }	
	$escapes{' '} = '+'; # only valid for GET parameters!
	sub URLescape {
		my $url = shift;
		$url =~ s/([^;\/?:@+\$,A-Za-z0-9\-_.!~*'()])/$escapes{$1}/g;
		return $url;
	}
}


######
# DATE & TIME
######

# Get necessary localtime information into variables. 
# BasicDateVars($time);
# $time: A UNIX-format timestamp. (Seconds since 1970.)
sub BasicDateVars {
	my $thetime = shift;
	($Second,$Minute,$Hour,$Month_Day, $Month,$Year,$Week_Day,$IsDST) = (localtime($thetime))[0,1,2,3,4,5,6,8]; 
	$Month_Number = $ActualMonth = $Month + 1;
	$Year += 1900;
	$TwoDigitYear = substr($Year,2,2);
	$TwoDigitDay = sprintf('%.2d', $Month_Day);
	$TwoDigitMonth = sprintf('%.2d', $Month_Number);
	$Minute = sprintf('%.2d', $Minute);
	$Second = sprintf('%.2d', $Second);
	$TwoDigitHour = sprintf('%.2d', $Hour);
	$Month_Name = $Months[$Month];
	$Abbrev_Month_Name = $Abbrev_Months[$Month];
	$Day = $Month_Day;
	$Weekday = $Week_Days[$Week_Day];
	if ($Hour == 0) {
		$TwelveHour = 12;
		$AMPM = 'AM';
	}
	elsif ($Hour < 12) {
		$AMPM = 'AM';
		$TwelveHour = $Hour;
	}
	elsif ($Hour == 12) {
		$AMPM = 'PM';
		$TwelveHour = $Hour;
	}
	else {
		$TwelveHour = $Hour - 12;
		$AMPM = 'PM';
	}
}

# Prepares a subroutine that turns UNIX dates into date strings.
# InitGTD($format, $name);
# $format: The format of the date. Uses <Field: FieldName> tags.
# $name: The name of the subroutine that will be created.
sub InitGTD {
	my $convdateformat = shift;
	my $subName = shift;
	my $GTDcode = qq~
	sub $subName {
	~;
	$GTDcode .= q~
	my $thetime = shift;
	unless ($thetime) {
		$thetime = time;
		if ($CConfig{'TimeOffset'}) {
			$thetime += (3600 * $CConfig{'TimeOffset'});
		}
	}
	BasicDateVars($thetime);
	if ($IsDST == 1) {
		$Time_Zone = $CConfig{'Daylight_Time_Zone'};
	}
	else {
   		$Time_Zone = $CConfig{'Standard_Time_Zone'};
	}
	~;
	if ($CConfig{'12HourClock'}) {
		$GTDcode .= q~$Hour = $TwelveHour;
~;
	}
	$GTDcode .= 'return qq~';
	$convdateformat =~ s/(\$|\@|\%|\~|\\)/\\$1/g;
	$convdateformat =~ s/<Field\: Abbrev_Weekday>/\$Abbrev_Week_Days[\$Week_Day]/g;
	$convdateformat =~ s/<Field\: Abbrev_Month_Name>/\$Abbrev_Months[\$Month]/g;
	$convdateformat =~ s/<Field\: Month>/\$Month_Number/g;
	$convdateformat =~ s/<Field\: UNIXMonth>/\$Month/g;
	$convdateformat =~ s/<Field\: ([^>\s\\]+)>/\$$1/g;
	$GTDcode .= $convdateformat . "~;
	}";
	eval $GTDcode;
}
	

	
# Returns date in GMT text format. Used for cookie expiry dates
# DoGMTTime($time, $dashflag);
# $time: The UNIX time that will converted into GMT text format.
# $hyphenflag: When set to 1, uses a hyphen between the day, the month, and the year.
sub DoGMTTime {
	my $thetime = shift;
	my $nodash = shift;
	my $dash;
	if ($nodash) {
		$dash = ' ';
	}
	else {
		$dash = '-';
	}
	my $thedate;
	my ($Second,$Minute,$Hour,$Month_Day, $Month,$Year,$Week_Day,$IsDST) = (gmtime($thetime))[0,1,2,3,4,5,6,8];
	if ($Month_Day < 10) {
		$Month_Day = "0$Month_Day";
	}
	$Year = $Year + 1900;
	$Second = "0$Second" if $Second < 10;
	$Minute = "0$Minute" if $Minute < 10;
	$Hour = "0$Hour" if $Hour < 10;
		
	$thedate = "$Abbrev_Week_Days[$Week_Day], $Month_Day$dash$Abbrev_Months[$Month]$dash$Year $Hour:$Minute:$Second GMT";
	return $thedate;
}

#####
# MISC.
#####

sub NeedCFG {
	if ($cfgpath) {
		NeedFile($cfgpath);
	}
	else {
		NeedFile('crcfg.dat');
	}
}

sub SecurePath {
	my $filename = shift;
	# Translate windows-style \ slashes to unix-style /
	$filename =~ s!\\!/!g;
	# Remove all characters other than: letters, numbers, spaces, and -_:/.
	$filename =~ s~[^\w\d \-_:/\.]~~g; 
	return $filename;
}



# header: A convenience that returns the full Content-type header.
sub header {
	unless ($HeaderPrinted) {
		$HeaderPrinted = 1;
		return "Content-type: text/html\nExpires: "
			.  DoGMTTime(time, 1) . "\n\n";
	}
	else {
		return '';
	}
}

sub HTMLescape {
	my $text = shift;
	$text =~ s/&/&amp;/g;
	$text =~ s/</&lt;/g;
	$text =~ s/>/&gt;/g;
	$text =~ s/"/&quot;/g;
	return $text;
}

{
	my (%NewDateInfo, $lastAnswer, $lastID, $lastProf, $lastFile);     
	sub isNewDate {
		my $isNewDate;
		if ($newsid eq $lastID && $ProfileName eq $lastProf && $FileName eq $lastFile) {
			return $lastAnswer;
		}
		my $mdy = "$Month_Day-$Month-$Year";
		if (!$NewDateInfo{"$ProfileName--$FileName"} || $NewDateInfo{"$ProfileName--$FileName"} ne $mdy) { # First new date
			$lastID = $newsid;
			$lastAnswer = 1;
			$NewDateInfo{"$ProfileName--$FileName"} = $mdy;
			return 1;
		}
		else { # Next same date
			return 0;
		}
	}
	
	my(%NewYearInfo, $lastAnswerYear, $lastIDYear);
	sub isNewYear {
		my $isNewYear;
		if ($newsid eq $lastIDYear && $ProfileName eq $lastProf && $FileName eq $lastFile) {
			return $lastAnswerYear;
		}
		my $year = $Year;
		if (!$NewYearInfo{"$ProfileName--$FileName"} || $NewYearInfo{"$ProfileName--$FileName"} ne $year) { # First new Year
		$lastIDYear = $newsid;
		$lastAnswerYear = 1;
		$NewYearInfo{"$ProfileName--$FileName"} = $year;
		return 1;
		}
		else { # Next same date
		return 0;
		}
	}
	
	my(%NewMonthInfo, $lastAnswerMonth, $lastIDMonth);
	sub isNewMonth {
		my $isNewMonth;
		if ($newsid eq $lastIDMonth && $ProfileName eq $lastProf && $FileName eq $lastFile) {
			return $lastAnswerMonth;
		}
		my $Month = $Month;
		if (!$NewMonthInfo{"$ProfileName--$FileName"} || $NewMonthInfo{"$ProfileName--$FileName"} ne $Month) { # First new Month
		$lastIDMonth = $newsid;
		$lastAnswerMonth = 1;
		$NewMonthInfo{"$ProfileName--$FileName"} = $Month;
		return 1;
		}
		else { # Next same date
		return 0;
		}
	}
	
	my(%NewWeekInfo, $lastAnswerWeek, $lastIDWeek);
	sub isNewWeek {
		my ($isNewWeek, $CorrectedWeeklyTime, $NewWeek);
		
		if ($newsid eq $lastIDWeek && $ProfileName eq $lastProf && $FileName eq $lastFile) {
			return $lastAnswerWeek;
		}
		
		if ($Week_Day) {
			# We're not on Sunday. Find the previous Sunday.
			$CorrectedWeeklyTime = ($newstime - ($Week_Day * 86400));
			# Make sure that we don't run into Daylight Savings problems.
				if ($AMPM eq 'AM') {
				$CorrectedWeeklyTime += 14400;
				}
				elsif ($AMPM eq 'PM') {
				$CorrectedWeeklyTime -= 14400;
				}
							
			my @cweeklytime = localtime($CorrectedWeeklyTime);
			$NewWeek = "$i-week-$cweeklytime[3]-" . ($cweeklytime[4] + 1) . '-' . ($cweeklytime[5] + 1900);
		}
		else {
			# It's a Sunday. Just use the current day as the archive title.
			$NewWeek = "$i-week-$Month_Day-$ActualMonth-$Year";	
		}
		
		if (!$NewWeekInfo{"$ProfileName--$FileName"} || $NewWeekInfo{"$ProfileName--$FileName"} ne $NewWeek) { # First new Week
		$lastIDWeek = $newsid;
		$lastAnswerWeek = 1;
		$NewWeekInfo{"$ProfileName--$FileName"} = $NewWeek;
		return 1;
		}
		else { # Next same date
		return 0;
		}
	} 

	
	my(%NewUserInfo, $lastAnswerUser, $lastIDUser);
	sub isNewUser {
		my $isNewUser;
		if ($newsid eq $lastIDUser && $ProfileName eq $lastProf && $FileName eq $lastFile) {
			return $lastAnswerUser;
		}
		my $NewUser = $User;
		if (!$NewUserInfo{"$ProfileName--$FileName"} || $NewUserInfo{"$ProfileName--$FileName"} ne $NewUser) { # First new User
		$lastIDUser = $newsid;
		$lastAnswerUser = 1;
		$NewUserInfo{"$ProfileName--$FileName"} = $NewUser;
		return 1;
		}
		else { # Next same date
		return 0;
		}
	}
	
	my(%NewCategoryInfo, $lastAnswerCategory, $lastIDCategory);
	sub isNewCategory {
		my $isNewCategory;
		if ($newsid eq $lastIDCategory && $ProfileName eq $lastProf && $FileName eq $lastFile) {
			return $lastAnswerUser;
		}
		my $NewCategory = $Category;
		if (!$NewCategoryInfo{"$ProfileName--$FileName"} || $NewCategoryInfo{"$ProfileName--$FileName"} ne $Category) { # First new User
		$lastIDCategory = $newsid;
		$lastAnswerCategory = 1;
		$NewCategoryInfo{"$ProfileName--$FileName"} = $Category;
		return 1;
		}
		else { # Next same date
		return 0;
		}
	}
	
	# WARNING: isNewFile must be called BEFORE isNewDate!
	sub isNewFile {
		if ($NewDateInfo{"$ProfileName--$FileName"}) {
			return 0;
		}
		else {
			return 1;
		}
	}
		
}		


######
# AUTOLOADED SUBS
######

# These aren't quite as commonly used, so we don't compile them until used.


$Subs{'SnipText'} = <<'END_SUB';
sub SnipText {
	my ($text, $len) = @_;
	$text = HTMLstrip($text);
	if ($text =~ /([\s\S]{$len}\S*)/) {
		return "$1...";
	}
	else {
		return $text;
	}
}
END_SUB

$Subs{'unHTMLescape'} = <<'END_SUB';
sub unHTMLescape {
	my $text = shift;
	$text =~ s/&quot;/"/g;
	$text =~ s/&gt;/>/g;
	$text =~ s/&lt;/</g;
	$text =~ s/&amp;/&/g;
	return $text;
}
END_SUB

$Subs{'HTMLstrip'} = <<'END_SUB';
sub HTMLstrip {
	my $text = shift;
	#$text =~ s/<(?:[^>'"]*|(['"]).*?\1)*>//gs; ** this works well, but earlier Perls don't like it
	$text =~ s/(<br[^<>]*>|<p[^<>]*>)/ /gi;
	$text =~ s/<[^>]+>//g;
	return $text;
}
END_SUB

# loadND, saveND, and getNDvar were previously the main method of
# processing news items. While they're very flexible and allow
# many otherwise-difficult things (like sorting), they're also
# very slow and are no longer used. They're provided for compatibility
# with addons.

# Loads newsdat.txt, and reads news data into a variety of places.
$Subs{'loadND'} = <<'END_SUB';
sub loadND {
	undef @NewsData;
	
	# HOOK: loadND_1
	if($Addons{'loadND_1'}){my $w;foreach $w (@{$Addons{'loadND_1'}}){my $addon=$w->[2];eval ${$w->[0]};AErr($addon,$@)if $@;};}
	
	# Declare variables
	my $newsnum = 0;
	my $newsline;
	my $formfield;
	
	# Open newsdat.txt
	my $fh = CRopen("$CConfig{'htmlfile_path'}/newsdat.txt");
	$nd_age = (stat($fh))[9];

	# Begin line-by-line processing of newsdat.txt
	while (<$fh>) {
		# Remove ending newline character
		chomp($_);
		# Split news item into component variables, using crcfg.dat definition
		SplitDataFile($_);

		# HOOK: loadND_2
		if($Addons{'loadND_2'}){my $w;foreach $w (@{$Addons{'loadND_2'}}){my $addon=$w->[2];eval ${$w->[0]};AErr($addon,$@)if $@;};}
		
		# Go through each defined form field.
		foreach $formfield (@fieldDB_internalorder) {
			# Load that particular news variable into the appropriate place in @NewsData
			$NewsData[$newsnum]->{$formfield} = ${$formfield};
		}
		# Establish a hash of news IDs
		$NewsID{$newsid} = $newsnum;
		# Increment $newsnum to continue the processing.
		$newsnum++;
	}
	# HOOK: loadND_3
	if($Addons{'loadND_3'}){my $w;foreach $w (@{$Addons{'loadND_3'}}){my $addon=$w->[2];eval ${$w->[0]};AErr($addon,$@)if $@;};}
	close($fh);
}

# Saves newsdat.txt from @NewsData, which is set by &loadND
sub saveND {
	my ($ndentry, $joinline, $key, $value);
	# HOOK: saveND_Pre
	if($Addons{'saveND_Pre'}){my $w;foreach $w (@{$Addons{'saveND_Pre'}}){my $addon=$w->[2];eval ${$w->[0]};AErr($addon,$@)if $@;};}
	my $fh = CRopen(">$CConfig{'htmlfile_path'}/newsdat.txt");
	SAVELOOP: foreach $ndentry (@NewsData) {
		unless ($ndentry eq "del") {
			while (($key, $value) = each %{$ndentry}) {
				${$key} = $value;
			}
			# HOOK: saveND_Loop
			if($Addons{'saveND_Loop'}){my $w;foreach $w (@{$Addons{'saveND_Loop'}}){my $addon=$w->[2];eval ${$w->[0]};AErr($addon,$@)if $@;};}
			$joinline = &JoinDataFile;
			$joinline =~ s/\n//g;
			print $fh "$joinline\n";
		}
	}
	close($fh);
}	#~ add saveND_Post

# Gets the news variables for a particular item.
sub getNDvar {
	my $nn = shift;
	my $ff;
	foreach $ff (keys %{$NewsData[$nn]}) {
		${$ff} = $NewsData[$nn]->{$ff};
	}
	$newsdate = GetTheDate($newstime);
	# HOOK: getNDvar
	if($Addons{'getNDvar'}){my $w;foreach $w (@{$Addons{'getNDvar'}}){my $addon=$w->[2];eval ${$w->[0]};AErr($addon,$@)if $@;};}
}	

# Gets the news variables for a particular item.
# Does not generate date information.
sub getNDvar_nodate {
	my $nn = shift;
	my $ff;
	foreach $ff (keys %{$NewsData[$nn]}) {
		${$ff} = $NewsData[$nn]->{$ff};
	}
	# HOOK: getNDvar_nodate
	if($Addons{'getNDvar_nodate'}){my $w;foreach $w (@{$Addons{'getNDvar_nodate'}}){my $addon=$w->[2];eval ${$w->[0]};AErr($addon,$@)if $@;};}
}	
END_SUB


$Subs{'PrintSelectValues'} = <<'END_SUB';
sub PrintSelectValues {
	my @values = @_;
	my $selected = shift @values;
	if ($values[0] eq 'same') {
		shift @values;
		foreach $i (@values) {
			print qq~
			<option value="$i"~, ($i eq $selected ? ' selected' : ''), 
			qq~>$i</option>~;
		}
	} else {
		my $count = 1;
		foreach $i (@values) {
			print qq~
			<option value="$count"~ . ($count == $selected ? ' selected' : '') 
			. qq~>$i</option>~;
			$count++
		}
	}
}
END_SUB

# YMDtoUNIX
# Turns a date of form 1999-7-13 (July 13, 1999) into UNIX time.
# Uses time of midnight.
$Subs{'YMDtoUNIX'} = <<'END_SUB';
sub YMDtoUNIX {
	my ($textyear, $textmonth, $textday) = @_;
	my $unixtime;
	$textyear = $textyear - 1900;
	$textmonth = $textmonth - 1;
	$unixtime = timelocal(0,0,0, $textday, $textmonth, $textyear);
	return $unixtime;
}
END_SUB


$Subs{'PastDaysTime'} = <<'END_SUB';
sub PastDaysTime {
	my ($pastdays, $timetouse) = @_;
	unless ($timetouse) {
		$timetouse = time;
		if ($CConfig{'TimeOffset'}) {
			$timetouse += (3600 * $CConfig{'TimeOffset'});
		}
	}
	my @ltime = localtime($timetouse);
	my $enddate = YMDtoUNIX(($ltime[5] + 1900), ($ltime[4] + 1), $ltime[3]);
	$enddate += 86399;
	my $startdate = $enddate - ($pastdays * 86400);
	$startdate++;
	return ($startdate, $enddate);
}
END_SUB

# Used to process .tmpl files (HTML template files)
$Subs{'ProcessTMPL'} = <<'END_SUB';
{
	my %TemplateCache;

	sub ProcessTMPL {
		my ($tmplpath, $tmplcontent, $tmpltitle, $compat, $fakessi) = @_;
		return 0 unless $tmplpath;
		unless ($TemplateCache{$tmplpath}) {
			my $fh = CRopen($tmplpath);
			{
				local $/;
				$TemplateCache{$tmplpath} = <$fh>;
			}
			close($fh);
		}
		my $theresult = $TemplateCache{$tmplpath};

		
		$theresult =~ s/<InsertDate>/<InsertTitle>/g;
		$theresult =~ s/<Field: Title>/<InsertTitle>/gi; # While it's simpler for the user to use the new <Field:>
								# syntax, it's simpler for us to use the old <InsertTitle>.
		$theresult =~ s/<Field: Date>/<InsertTitle>/gi if $compat;
		$theresult =~ s/<Field: Content>/<InsertContent>/gi;

		$theresult =~ s/<!--INSTRUCTIONS[\s\S]+?END INSTRUCTIONS-->//g;
		$theresult =~ s/<TextField\: ([^\s\>\{\[]+)>/HTMLtoText(${$1})/ge;
		$theresult =~ s/<TextField\: ([^\s\>\{]+)\{[\'\"]([^\s\>\}\'\"]+)[\'\"]\}>/HTMLtoText(${$1}{$2})/ge;
		$theresult =~ s/<TextField\: ([^\s\>\[]+)\[(\d+)\]>/HTMLtoText(${$1}[$2])/ge;
		$theresult =~ s/<Field\: ([^\s\>\{\[]+)>/${$1}/gi;
		$theresult =~ s/<Field\: ([^\s\>\{]+)\{[\'\"]([^\s\>\}\'\"]+)[\'\"]\}>/${$1}{$2}/g;
		$theresult =~ s/<Field\: ([^\s\>\[]+)\[(\d+)\]>/${$1}[$2]/g;

		$theresult =~ s/<\!--#include file\s*=\s*"(\S+?)"\s*-->/FakeSSI($1)/gie if $fakessi;

		# Parse fake SSI tags
		$theresult =~ s/<include file\s*=\s*"(\S+?)">/FakeSSI($1)/gie;
		$theresult =~ s/<exec cgi\s*=\s*"(\S+?)">/Execute_CGI($1)/gie;

		# HOOK: ProcessTMPL
		if($Addons{'ProcessTMPL'}){my $w;foreach $w (@{$Addons{'ProcessTMPL'}}){my $addon=$w->[2];eval ${$w->[0]};AErr($addon,$@)if $@;};}
		if (ref($tmplcontent)) {
			$theresult =~ s/<InsertContent>/$$tmplcontent/gi;
			$theresult =~ s/<InsertTextContent>/HTMLtoText($$tmplcontent)/ge;
		}
		else {
			$theresult =~ s/<InsertContent>/$tmplcontent/gi;
			$theresult =~ s/<InsertTextContent>/HTMLtoText($tmplcontent)/ge;
		}
		$theresult =~ s/<InsertTitle>/$tmpltitle/gi;

		return $theresult;
	}
}

sub FakeSSI {
	my $fpath = shift;
	$fpath = SecurePath($fpath);
	my $fh = CRopen($fpath);
	my $file;
	{
		local $/;
		$file = <$fh>;
	}
	close($fh);
	return $file;
}

sub Execute_CGI {
	my $perlpath = $^X;
	my $script = $1;
	$script = SecurePath($script);
	my $output;

	if (-e $perlpath){
		if (-e $script){
		$output = eval { `$perlpath $script` };
		$output = "ERROR: $@" if $@;
		}
		else {
		$output = "ERROR: could not find $script";
		}
	}
	else {
	$output = "ERROR: could not find $perlpath";
	}

	$output =~ s/Content-(.*?)html//i;
	return $output;
}

END_SUB

$Subs{'HTMLtoText'} = <<'END_SUB';
sub HTMLtoText {
	my $html = shift;
	$html =~ s/\n//g;
	$html =~ s/<br[^<>]*>/\n/gi;
	$html =~ s/<\/*(blockquote|ul|p)[^<>]*>/\n\n/gi;
	$html =~ s/<li[^<>]*>/	-- /gi;
	$html =~ s/<hr[^<>]*>/---------------------------------/gi;
	$html =~ s/<a href=\"*([^\s<>\"]+)\"*[^>]*>([\s\S]+?)<\/a>/$2 ($1 )/gi;
	$html =~ s/<[^>]+>//g;
	return $html;
}
END_SUB

$Subs{'FilterReverse'} = <<'END_SUB';
sub FilterReverse {
	return reverse(@_);
}
END_SUB

$Subs{'FilterAlpha'} = <<'END_SUB';
sub FilterAlpha {
	return	map  { $_->[0] }
		sort { $a->[1] cmp $b->[1] }
		map  { [ $_, ($_->{'Subject'})[0] ] } @_;
}
END_SUB

$Subs{'FilterTrueAlpha'} = <<'END_SUB';
sub FilterTrueAlpha {
my($da,$db);

	return	map  { $_->[0] }
            sort { ($da = lc $a->[1]) =~ s/[\W_]+//g;
                   ($db = lc $b->[1]) =~ s/[\W_]+//g;
                    $da cmp $db }
            map { [ $_, ($_->{'Subject'})[0] ] } @_;
}
END_SUB

$Subs{'InitUserFieldVars'} = <<'END_SUB';
sub InitUserFieldVars {
	my ($i, $varname);
	ReadUserDBInfo();
	foreach $i (keys %userDB) {
		$varname = "UserField_$i";
		tie($$varname, 'UserField', $i);
	}
}

package UserField;

sub TIESCALAR {
	my $class = shift;
	my $field = shift;
	bless \$field, $class;
}

sub FETCH {
	my $self = shift;
	return $main::userdata{$main::User}->{$$self};
}

sub STORE { }

package main;
END_SUB

$Subs{'SpaceSplit'} = <<'END_SUB';
sub SpaceSplit {
	return Text::ParseWords::quotewords('\s+', 0, @_);
}

# From the Text::ParseWords module
package Text::ParseWords;

sub quotewords {
	my($delim, $keep, @lines) = @_;
	my($line, @words, @allwords);
	foreach $line (@lines) {
		@words = parse_line($delim, $keep, $line);
		return() unless (@words || !length($line));
		push(@allwords, @words);
	}
	return(@allwords);
}



sub nested_quotewords {
	my($delim, $keep, @lines) = @_;
	my($i, @allwords);
	
	for ($i = 0; $i < @lines; $i++) {
		@{$allwords[$i]} = parse_line($delim, $keep, $lines[$i]);
		return() unless (@{$allwords[$i]} || !length($lines[$i]));
	}
	return(@allwords);
}



sub parse_line {
	my($delimiter, $keep, $line) = @_;
	my($quote, $quoted, $unquoted, $delim, $word, @pieces);
	while (length($line)) {
		
		($quote, $quoted, undef, $unquoted, $delim, undef) =
		$line =~ m/^(["'])		# a $quote
		((?:\\.|(?!\1)[^\\])*)		# and $quoted text
		\1 				# followed by the same quote
		([\000-\377]*)			# and the rest
		|				# --OR--
		^((?:\\.|[^\\"'])*?)		# an $unquoted text
		(\Z(?!\n)|(?-x:$delimiter)|(?!^)(?=["']))
						# plus EOL, delimiter, or quote
		([\000-\377]*)			# the rest
		/x;				# extended layout
		return() unless( $quote || length($unquoted) || length($delim));
		
		$line = $+;
		
		if ($keep) {
			$quoted = "$quote$quoted$quote";
		}
		else {
			$unquoted =~ s/\\(.)/$1/g;
			if (defined $quote) {
				$quoted =~ s/\\(.)/$1/g if ($quote eq '"');
				$quoted =~ s/\\([\\'])/$1/g if ( $PERL_SINGLE_QUOTE && $quote eq "'");
			}
		}
		$word .= defined $quote ? $quoted : $unquoted;
		
		if (length($delim)) {
			push(@pieces, $word);
			push(@pieces, $delim) if ($keep eq 'delimiters');
			undef $word;
		}
		if (!length($line)) {
			push(@pieces, $word);
		}
	}
	return(@pieces);
}

package main;
END_SUB

$Subs{'timelocal'} = <<'END_SUB';
sub timelocal {
	Time::Local::timelocal(@_);
}

package Time::Local;

# Load values for computing times
$SEC  = 1;
$MIN  = 60 * $SEC;
$HR   = 60 * $MIN;
$DAY  = 24 * $HR;
$epoch = (localtime(2*$DAY))[5];	# Allow for bugs near localtime == 0.
$YearFix = ((gmtime(946684800))[5] == 100) ? 100 : 0;


# The following three subroutines are from the Perl Time::Local module.
sub timegm {
	$ym = pack(C2, @_[5,4]);
	$cheat = $cheat{$ym} || &cheat;
	return -1 if $cheat<0 and $^O ne 'VMS';
	$cheat + $_[0] * $SEC + $_[1] * $MIN + $_[2] * $HR + ($_[3]-1) * $DAY;
}

sub timelocal {
	my $t = &timegm;
	my $tt = $t;
	
	my (@lt) = localtime($t);
	my (@gt) = gmtime($t);
	if ($t < $DAY and ($lt[5] >= 70 or $gt[5] >= 70 )) {
		# Wrap error, too early a date
		# Try a safer date
		$tt = $DAY;
		@lt = localtime($tt);
		@gt = gmtime($tt);
	}
	
	my $tzsec = ($gt[1] - $lt[1]) * $MIN + ($gt[2] - $lt[2]) * $HR;
	
	my($lday,$gday) = ($lt[7],$gt[7]);
	if($lt[5] > $gt[5]) {
		$tzsec -= $DAY;
	}
	elsif($gt[5] > $lt[5]) {
		$tzsec += $DAY;
	}
	else {
		$tzsec += ($gt[7] - $lt[7]) * $DAY;
	}
	
	$tzsec += $HR if($lt[8]);
	
	$time = $t + $tzsec;
	return -1 if $cheat<0 and $^O ne 'VMS';
	@test = localtime($time + ($tt - $t));
	$time -= $HR if $test[2] != $_[2];
	$time;
}

sub cheat {
	$year = $_[5];
	$year -= 1900
	if $year > 1900;
		$month = $_[4];
	die("Month '$month' out of range 0..11")	if $month > 11 || $month < 0;
	die ("Day '$_[3]' out of range 1..31")	if $_[3] > 31 || $_[3] < 1;
	die("Hour '$_[2]' out of range 0..23")	if $_[2] > 23 || $_[2] < 0;
	die("Minute '$_[1]' out of range 0..59")	if $_[1] > 59 || $_[1] < 0;
	die("Second '$_[0]' out of range 0..59")	if $_[0] > 59 || $_[0] < 0;
	$guess = $^T;
	@g = gmtime($guess);
	$year += $YearFix if $year < $epoch;
	$lastguess = "";
	$counter = 0;
	while ($diff = $year - $g[5]) {
		die("Can't handle date (".join(", ",@_).")") if ++$counter > 255;
		$guess += $diff * (363 * $DAY);
		@g = gmtime($guess);
		if (($thisguess = "@g") eq $lastguess){
			return -1; #date beyond this machine's integer limit
		}
		$lastguess = $thisguess;
	}
	while ($diff = $month - $g[4]) {
		die("Can't handle date (".join(", ",@_).")") if ++$counter > 255;
		$guess += $diff * (27 * $DAY);
		@g = gmtime($guess);
		if (($thisguess = "@g") eq $lastguess){
			return -1; #date beyond this machine's integer limit
		}
		$lastguess = $thisguess;
	}
	@gfake = gmtime($guess-1); #still being skeptic
	if ("@gfake" eq $lastguess){
		return -1; #date beyond this machine's integer limit
	}
	$g[3]--;
	$guess -= $g[0] * $SEC + $g[1] * $MIN + $g[2] * $HR + $g[3] * $DAY;
	$cheat{$ym} = $guess;
}

package main;
END_SUB

$Subs{'SimpleWrap'} = <<'END_SUB';
sub SimpleWrap {
	my @lines = split(/\n/, $_[0]);
	@lines = map {Text::Wrap::TextWrap($_)} @lines;
	return join("\n", @lines);
}

package Text::Wrap;

$tabstop = 8;
$debug = 0;
$columns = 76;  
$debug = 0;
$break = '\s';
$huge = 'wrap'; 

sub TextWrap {
	return wrap('', '', $_[0]);
}

sub wrap {
	my ($ip, $xp, @t) = @_;

	my $r = "";
	my $t = expand(join(" ",@t));
	my $lead = $ip;
	my $ll = $columns - length(expand($ip)) - 1;
	my $nll = $columns - length(expand($xp)) - 1;
	my $nl = "";
	my $remainder = "";

	while ($t !~ /^\s*$/) {
		if ($t =~ s/^([^\n]{0,$ll})($break|\Z(?!\n))//xm) {
			$r .= unexpand($nl . $lead . $1);
			$remainder = $2;
		} elsif ($huge eq 'wrap' && $t =~ s/^([^\n]{$ll})//) {
			$r .= unexpand($nl . $lead . $1);
			$remainder = "\n";
		} elsif ($huge eq 'die') {
			die "couldn't wrap '$t'";
		} else {
			die "This shouldn't happen";
		}
			
		$lead = $xp;
		$ll = $nll;
		$nl = "\n";
	}
	$r .= $remainder;

	$r .= $lead . $t if $t ne "";

	return $r;
}	

sub expand
{
	my (@l) = @_;
	for $_ (@l) {
		1 while s/(^|\n)([^\t\n]*)(\t+)/
			$1. $2 . (" " x 
				($tabstop * length($3)
				- (length($2) % $tabstop)))
			/sex;
	}
	return @l if wantarray;
	return $l[0];
}

sub unexpand
{
	my (@l) = @_;
	my @e;
	my $x;
	my $line;
	my @lines;
	my $lastbit;
	for $x (@l) {
		@lines = split("\n", $x, -1);
		for $line (@lines) {
			$line = expand($line);
			@e = split(/(.{$tabstop})/,$line,-1);
			$lastbit = pop(@e);
			$lastbit = '' unless defined $lastbit;
			$lastbit = "\t"
				if $lastbit eq " "x$tabstop;
			for $_ (@e) {
				if ($debug) {
					my $x = $_;
					$x =~ s/\t/^I\t/gs;
					print "sub on '$x'\n";
				}
				s/  +$/\t/;
			}
			$line = join('',@e, $lastbit);
		}
		$x = join("\n", @lines);
	}
	return @l if wantarray;
	return $l[0];
}
package main;
END_SUB

1;
