# CRCORE.PL
# Where it all happens.

#####
# STARTUP
#####

require 5.005;

sub StartUp {
	
	$CurrentTime = time;

	use Fcntl qw(:DEFAULT :flock);
	
	# Require crlib.pl
	NeedFile('cruser.pl');
	NeedFile('crlib.pl');
	
	if (defined $crcgiBuild and $crcgiBuild != 39) {
		CRdie('Your coranto.cgi and crcore.pl files are mismatched -- that is, they come from different versions or builds of Coranto. Visit <a href="http://coranto.gweilo.org/">the unofficial Coranto homepage</a>, download a new copy of Coranto, and upload new versions of crcore.pl and coranto.cgi.',1);
	}

	# Get form input
	ReadForm();
	
	# Read in settings
	
	ReadConfigInfo();

	# Future proof Coranto, so that SQL-based addons can work properly
	if (exists $CConfig{'sql_enabled'} && $CConfig{'sql_enabled'} == 1){
		eval {
		require DBI;
		DBI->import();
		};
		if ($@){
		$CConfig{'sql_enabled'} = 0;
		&CRcough("You have tried to enable Coranto's SQL support, but DBI could not be loaded. It has been automatically disabled.");
		exit;
		}
	}

	ReadProfileInfo();

	# Initialize the date-retrieval subroutines.
	InitGTD($CConfig{'DateFormat'}, 'GetTheDate');
	InitGTD($CConfig{'InternalDateFormat'}, 'GetTheDate_Internal');
}

sub RunCoranto {
	StartUp();
	
	# Debugging feature: show configuration (no passwords are displayed).
	if ($ENV{'QUERY_STRING'} eq 'showconfig') {
		Debug_ShowConfig();
		exit;
	}

	# Debugging feature: show newsdat.txt
	if ($ENV{'QUERY_STRING'} eq 'shownewsdat') {
		Debug_Newsdat();
		exit;
	}

	if ($in{'action'} eq 'setup') {
		NeedFile('crsetup.pl');
		SetupHandler();
	}
	
	# Check if the user is logged in. If not, display login screen.
	CheckLogin();
	
	# Load any add-ons
	if ($CConfig{'AddonsLoaded'}) {
		NeedFile('craddon.pl');
		LoadAddons();
	}
	
	# Make sure that the "firsttime" variable is set to no, otherwise people can set up
	# the script via the web.
	#if ($CConfig{'firsttime'} eq 'yes') {
	#	$CConfig{'firsttime'} = 'no';
	#}

	# Check to see if the user has just upgraded to a newer version.
	if ($CConfig{'currentversion'} ne $crcgiVer || $CConfig{'currentbuild'} ne $coreBuild || $CConfig{'currentrc'} ne $crcgiRC) {
		&UpgradeHandler;
	}

	# HOOK: PreHeader
	if($Addons{'PreHeader'}){my $w;foreach $w (@{$Addons{'PreHeader'}}){my $addon=$w->[2];eval ${$w->[0]};AErr($addon,$@)if $@;};}
	# Print the content-type header.
	print header();
	
	# Addons: if you need to do something every time your addon is run,
	# hook it in here. (Think twice about whether you really need to
	# do it every time, though.)
	# HOOK: EarlyHook
	if($Addons{'EarlyHook'}){my $w;foreach $w (@{$Addons{'EarlyHook'}}){my $addon=$w->[2];eval ${$w->[0]};AErr($addon,$@)if $@;};}
	
	LoadFunctionList();	
	
	my $action = $in{'action'};

	if ($action eq 'admin') {
		if ($up != 3) {
			CRcough("You are not authorized to access administrative functions.");
		}
		else {
			NeedFile('cradmin.pl');
			AdminHandler();
		}
	}
	else {
		PageHandler();
	}
	untie(%CConfig);
	
}

sub PageHandler {
	my %FunctionSubs = (
		'' => 'MainPage',
		'mainpage' => 'MainPage',
		'submit' => 'DisplaySubForm',
		'submitsave' => 'SaveNews',
		'generate' => 'GenHTML',
		'modify' => 'ModifyNews',
		'modify-edit' => 'ModifyNews_Edit',
		'modify-editsave' => 'ModifyNews_EditSave',
		'edituserinfo' => 'EditUserInfo',
		'edituserinfosave' => 'EditUserInfoSave');
	if ($FunctionSubs{$in{'action'}}) {
		&{$FunctionSubs{$in{'action'}}}();
	}
	else {
		my %AddonFunctionSubs = GetAddonFunctionSubs() if $Addons;
		if ($AddonFunctionSubs{$in{'action'}}) {
			my $aa = $AddonFunctionSubs{$in{'action'}};
			eval {
				&{$aa->[0]}($aa->[1]);
			};
			AErr($aa->[1],$@) if $@;
		}
		else {
			MainPage();
		}
	}		
}

#######
# CORE SUBROUTINES
#######

# Loads the list of functions for the main page and the bar at the bottom of all pages.
sub LoadFunctionList {
	my $buildDesc = "$Messages{'Desc_Build'} ";
	@AvailableFunctions = (
		[$Messages{'Section_Submit'}, $Messages{'Desc_Submit'}, 'submit'],
		[$Messages{'Section_Build'}, $buildDesc, 'generate']);
	unless ($CurrentUser =~ /^guest/ && $up == 1) {
 		push(@AvailableFunctions,
 		[$Messages{'Section_Modify'}, $Messages{'Desc_Modify'} . ' ' . ( $up == 1 ? $Messages{'Desc_Modify_Std'} : $Messages{'Desc_Modify_High'} ), 'modify']);
		push(@AvailableFunctions,
		[$Messages{'Section_UserInfo'}, $Messages{'Desc_UserInfo'}, 'edituserinfo']);
	}
	push(@AvailableFunctions, GetAddonAvailableFunctions()) if $Addons;
	if ($up == 3) {
		push(@AvailableFunctions, 
			['Administration', 'Configure Coranto and change all available settings.', 'admin']
		);
	}
	push(@AvailableFunctions,
		[$Messages{'Section_LogOut'}, $Messages{'Desc_LogOut'}, 'logout']);
	@AvailableFunctions = reverse(@AvailableFunctions);
}	

# Generates an <a> tag to link to a page, with specified parameters. Includes session information.
my $sURL;
sub PageLink {
	my ($url, $key, $val);
	my ($params, $tagoptions) = @_;
	while (($key, $val) = each %$params) {
		$url .= '&amp;' . URLescape($key) . '=' . URLescape($val) if $key;
	}
	$sURL ||= '<a href="' . "$scripturl?session=$CurrentSession&amp;x=$AntiCache";
	return qq~$sURL$url" $tagoptions>~;
}

# Generates a <form> tag, with specified parameters. Includes session information.
sub StartForm {
	my $params = shift;
	my $tagoptions = shift;
	my ($frm, $key, $value);
	foreach $key (keys %$params) {
		if ($key) {
			$value = HTMLescape($params->{$key});
			$frm .= qq~<input type="hidden" name="$key" value="$value">~;
		}
	}
	return qq~<form action="$scripturl" method="POST" $tagoptions><input type="hidden" name="session" value="$CurrentSession">$frm~;
}

# RandomWord(x) returns a random string of x characters. (Letters only.)
{
	my @alpha = split(//, 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ');
	sub RandomWord {
		my $letters = shift;
		my ($word, $i);
		for ($i = 0; $i < $letters; $i++) {
			$word .= $alpha[int(rand(52))];
		}
		return $word;
	}
}

# CRopen: opens a file. Allows for file locking and better error-handling.
sub CRopen ($;$$) {
my $filename = shift;
my ($addfile, $addname) = @_ if @_;

$filename =~ s~\A([\+\<\>]{0,3})[\+\<\>]*~~;
$filename = SecurePath($filename);
my $openchars = $1;
my $flockflag = LOCK_EX;
my $flags = 0;
my $pos_at_end_after_flock = 0;
my $trunc_after_flock = 0;

	# Read, write, append
	if ($openchars eq '+>>'){
	$flags = O_CREAT | O_RDWR | O_APPEND;
	$pos_at_end_after_flock = 2;
	}

	# Read, write... truncate
	elsif ($openchars eq '+>'){
	$flags =  O_CREAT | O_RDWR;
	$trunc_after_flock = 1;
	}

	elsif ($openchars eq '+<'){
	$flags =  O_RDWR;
	}

	# Append	
	elsif ($openchars eq '>>'){
	$flags = O_CREAT | O_WRONLY | O_APPEND;
	$pos_at_end_after_flock = 2;
	}

	# Write only... truncate
	elsif ($openchars eq '>'){
	$flags =  O_CREAT | O_WRONLY;
	$trunc_after_flock = 1;
	}
	
	# Create, read, write... no truncate
	elsif ($openchars eq '+<>'){
	$flags = O_CREAT | O_RDWR;
	}

	# read-only, create
	elsif ($openchars eq '+<<'){
	$flags =  O_CREAT | O_RDONLY;
	$flockflag = LOCK_SH;
	}

	# Nothing specified, assume read-only
	else {
	$flags =  O_RDONLY;
	$flockflag = LOCK_SH;
	}

	my $fh = do { local *FH; };

	eval {

		if ($UseFlock == 1){
			sysopen($fh, $filename, $flags) || die "Unable to open $filename. $!";
			flock($fh, $flockflag) || die "Unable to flock $filename. $!";

			if ($trunc_after_flock){
			truncate($fh, 0) || die "Unable to truncate $filename. $!";
			}
		}
		else {
			if ($trunc_after_flock){
			open($fh, "$openchars$filename") || die "Unable to open $filename. $!";
			}
			else {
			sysopen($fh, $filename, $flags) || die "Unable to open $filename. $!";
			}
		}

		seek($fh, 0, $pos_at_end_after_flock);

	};

	if ($@){
		if ($addname) {
			AErr({'file' => $addfile, 'name' => $addname}, $@);
			exit;
		}
		else {
			CRdie($@);
			exit;
		}
	}

return $fh;
}

# Checks that a user is logged in, or allows a user to log in.		
sub CheckLogin {
	
	srand;
	
	$AntiCache = int(rand(500));
		
	# Read cookies into %Cookies
	GetCookies();
	
	# Get user's IP.
	$IP = $ENV{'REMOTE_ADDR'};
	
	# Read user info into %userdata
	ReadUserInfo();
	
	# Load session info.
	my @sesstemp = split (/\|x\|/, $CConfig{'Sessions'});
	my @st2;
	foreach $i (@sesstemp) {
		@st2 = split(/\!x\!/, $i);
		unless ($st2[5] < $CurrentTime) {
			# The session is current
			$Sessions{$st2[0]} = [$st2[1], $st2[2], $st2[3], $st2[4], $st2[5]];
		}
	}
	
	# Remember password function: simulate a login
	if ($Cookies{'cruser'} && $Cookies{'crpermkey'} && (!$in{'session'} || !$Sessions{$in{'session'}}) && $in{'action'} ne 'login') {
		my $uname = $Cookies{'cruser'};
		my $key = $Cookies{'crpermkey'};
		my $vkey = $userdata{$uname}->{'CPermkey'};
		unless (length($vkey) == 40 && length($uname) > 2 && length($key) > 4) {
			LoginPage();
		}
		NeedFile('crcrypt.pl');
		$crcrypt = new CRcrypt;
		my $ckey = $crcrypt->GetHash($key . $uname);
		if ($ckey eq $vkey) {
			# Valid user. Create a session.
			CreateSession($uname);
		}
		else {
			# Invalid key.
			LoginPage();
		}		
	}	
	# User is logging in.
	elsif ($in{'action'} eq 'login') {
		my $uname = $in{'uname'};
		my $pword = $in{'pword'};
		my $cpass;
		my $rpass = $userdata{$uname}->{'CPassword'};
		# Get the proper encrypted password.
		NeedFile('crcrypt.pl');
		$crcrypt = new CRcrypt;
		$cpass = $crcrypt->GetHash($pword . $uname);
		
		if ($cpass eq $rpass && length($rpass) == 40) {
			# The user is valid. Create a session.
			CreateSession($uname);
		}
		elsif ($uname eq 'setup' && $CConfig{'firsttime'} eq 'yes') {
			# It's the initial setup login.
			NeedFile('crsetup.pl');
			print header();
			FirstTimePage();
			exit;
		}
		elsif ($CConfig{'CryptCompat'} && length($rpass) != 40 && (crypt($pword, $rpass) eq $rpass) && length($rpass) > 2) {
			# Valid login, with an old crypt-style password.
			# First, replace the user's password with a new non-crypt one.
			$userdata{$uname}->{'CPassword'} = $cpass;
			# Now create a session
			CreateSession($uname);
		}
		elsif ($CConfig{'resetpass'} eq $uname && length($pword) > 4 && $CConfig{'resetpass'}) {
			# Forgotten password; set it to whatever was used
			$userdata{$uname}->{'CPassword'} = $cpass;
			# Stop people from resetting the password again
			delete $CConfig{'resetpass'};
			# Create a session
			CreateSession($uname);
		}
		else {
			# The information is incorrect; show a failure page.
			print header();
			NeedCFG();
			SimpleConfirmationPage($LoginMessages{'Fail_Title'}, $LoginMessages{'Fail_Message'}, 0,1);
			exit;
		}
	}
	else {
		# The user isn't logging in; set the current session to the provided session.
		$CurrentSession = $in{'session'};
	}
	# If no session is provided, show login page.
	LoginPage() unless $CurrentSession;
	my $sessinfo = $Sessions{$CurrentSession};
	unless ($sessinfo # Check that the session exists.
		&& ($sessinfo->[1] eq $userdata{$sessinfo->[0]}->{'CPassword'}) # Check that the encrypted password stored in this session is the same as that in the user database
		&& (
			($sessinfo->[2] eq $IP) # Check that the session for this IP is the same as the provided session
			|| ($sessinfo->[3] eq $Cookies{'crsesskey'}) # Or that the proper secondary session key cookie is provided.
		)
		) {
		# Login is invalid; show login page.
		print header();
		LoginPage();
	}
	if ($userdata{$sessinfo->[0]}->{'DisableUser'}) {
		NeedCFG();
		SimpleConfirmationPage($LoginMessages{'Fail_Title'}, $LoginMessages{'Disable'},0,1);
		exit;
	}
	if ($userdata{$sessinfo->[0]}->{'Language'}) {
		eval {
			require("crl_$userdata{$sessinfo->[0]}->{'Language'}.pl");
		};
		if ($@) {
			NeedFile('crlang.pl');
		}
		unless ($crlangVersion == 1) {
			NeedFile('crlang.pl');
		}
	}
	else {
		NeedFile('crlang.pl');
	}
	
	unless ($crlangVersion == 1) {
		CRdie('Your crcore.pl and crlang.pl files are mismatched -- that is, they come from different versions or builds of Coranto. Visit <a href="http://coranto.gweilo.org/">the Coranto homepage</a>, download a new copy of Coranto, and upload new versions of crcore.pl and crlang.pl.',1);
	}	
		
	if ($in{'action'} eq 'logout') {
		# We're logging out; clear any cookies, delete the session.
		ClearCookies();
		if ($userdata{$Sessions{$CurrentSession}->[0]}) {
			$userdata{$Sessions{$CurrentSession}->[0]}->{'CPermkey'} = undef;
		}
		WriteUserInfo();
		delete $Sessions{$CurrentSession};
		SaveSessions();
		NeedCFG();
		
		SimpleConfirmationPage($Messages{'Section_LogOut'}, $Messages{'LogOut_Message'} . qq~<p><a href="$scripturl">$LoginMessages{'Login'}</a>~, 0, 1);
		exit;
	}
	if (($sessinfo->[4] - $CurrentTime) <= 900) {
		# If the session is over in less than 15 minutes, extend it.
		$Sessions{$CurrentSession}->[4] += $SessionLength;
		SaveSessions();
	}
	# The user is legitimately logged in.
	$CurrentUser = $Sessions{$CurrentSession}->[0];
	$up = $userdata{$CurrentUser}->{'UserLevel'};
}

# Saves session information to %CConfig.
sub SaveSessions {
	my $i;
	my @sesstemp = ();
	foreach $i (keys %Sessions) {
		push(@sesstemp, join('!x!', $i, @{$Sessions{$i}}));
	}
	$CConfig{'Sessions'} = join('|x|', @sesstemp);
}

# Creates a new session for a user
sub CreateSession {
	my $uname = shift;
	return 0 unless $uname;
	$CurrentSession = $CurrentTime;
	$CurrentSession =~ tr/0123456789/actuwjkdio/; # Just cause I prefer letters to numbers, OK?
	$CurrentSession .= RandomWord(8);
	my $sesskey = RandomWord(6);
	# your hair smells nice
	$Sessions{$CurrentSession} = [$uname, $userdata{$uname}->{'CPassword'}, $IP, $sesskey, ($CurrentTime + $SessionLength)];
	SaveSessions();
	$userdata{$uname}->{'LastLogin'} = $CurrentTime;
	if ($in{'rememberpass'}) {
		# The user wants his/her password to be remembered.
		# Rather than saving a cookie with the password, generate
		# a slightly more secure key.
		my $key = $CurrentTime;
		$key =~ tr/0123456789/lhjtruscfv/; # why not?
		$key = RandomWord(10) . $key;
		SetCookies('cruser', $uname, $cookieExpLength); # Set a cookie with the username.
		SetCookies('crpermkey', $key, $cookieExpLength); # And another with the new key.
		unless ($crcrypt) {
			NeedFile('crcrypt.pl');
			$crcrypt = new CRcrypt;
		}
		# Get a hash of the key.
		my $ckey = $crcrypt->GetHash($key . $uname);
		# Save this hash rather than the key (that way, read access to the config file will not be enough to get in).
		$userdata{$uname}->{'CPermkey'} = $ckey;
	}
	WriteUserInfo();
	# Set the secondary session key cookie.
	SetCookies('crsesskey', $sesskey);
	$in{'uname'} = '';
	$in{'pword'} = '';
	$in{'action'} = $in{'pausedaction'} if $in{'pausedaction'};
}

sub StartFieldsTable {
	return q~<table width="98%" align="center" border="0" cellpadding="3" cellspacing="2">~;
}
sub FieldsRow {
	return qq~<tr><td width="30%" class="fieldtitle" valign="top"><div align="right">$_[0]:</div></td>
	<td width="70%">$_[1]</td></tr>~;
}

sub MidHeading {
	return qq~<table width="80%" cellpadding="2" border="0" align="center"><tr><td class="midheader"><div align="center">$_[0]
	</div></td></tr></table><br>~;
}

sub MidParagraph {
	return qq~<table width="80%" cellpadding="2" border="0" align="center" class="confirm"><tr><td><div align="~ . ($_[1] ? 'left' : 'center') . qq~">$_[0]
	</div></td></tr></table><br>~;
}

sub SubmitButton {
	my ($submit, $noreset) = @_;
	$submit ||= $Messages{'Submit'};
	return qq~<table align="center" width="80%" border="0">
		<tr><td class="description"><div align="center"><input type="submit" value="$submit">
		~ . ( $noreset ? '' : qq~<input type="reset" value="$Messages{'Reset'}">~ ) . '</div></td></tr></table>';
}

#####
# AUTOLOADED SUBS
#####

# That's it for core, important subroutines that are used virtually
# every time the script is run. To speed up loading, remaining subroutines
# are stored in memory and only compiled when necessary. They're stored
# in a hash called %Subs. This subroutine will automatically compile
# and then transparently run subroutines in %Subs the first time they're
# called.
sub AUTOLOAD {
	my $sub = $AUTOLOAD;
	CRdie("Error: AUTOLOAD called without providing subroutine. ($sub)") unless $sub;
	# Get rid of package information.
	$sub =~ s/.+\:\://;
	if ($Subs{$sub}) {
		# Compile it.
		eval $Subs{$sub};
		if ($@) { die ("Subroutine $AUTOLOAD encountered a compile error during autoload: $@"); }
	}
	else {
		die("Subroutine $AUTOLOAD was called, but does not exist. (It isn't already loaded, and it isn't in the cache.)");
	}
	# Delete the source from memory, to save memory.
	delete $Subs{$sub};
	# Now switch to the just-compiled sub.
	goto &$AUTOLOAD;
}

%Subs = (

#######
# PAGE DISPLAY
#######

'PrintFunctionList' => <<'END_SUB',
sub PrintFunctionList {
	my $list = shift;
	my $actionparam = shift;
	my $extrakey = shift;
	my $extravalue = shift;
	$i = (@$list - 1);
	while ($i >= 0) {
		if ($i) {
			print q~<table width="90%" border="0" cellspacing="2" cellpadding="2" align="center"><tr>
			<td width="45%" class="fieldtitle"><div align="center">~ . PageLink({$actionparam => $$list[$i]->[2], $extrakey => $extravalue}) .
			qq~$$list[$i]->[0]</a></div>
			</td><td width="10%">&nbsp;</td><td width="45%" class="fieldtitle"><div align="center">~
			. PageLink({$actionparam => $$list[($i - 1)]->[2], $extrakey => $extravalue}) . qq~$$list[($i - 1)]->[0]</a></div>
			</td></tr><tr><td width="45%" class="description"><div align="center">$$list[$i]->[1]</div>
			</td><td width="10%">&nbsp;</td><td width="45%" class="description"><div align="center">
			$$list[($i - 1)]->[1]</div></td></tr></table><br>~;
		}
		else {
			print q~<table width="40%" border="0" cellspacing="2" cellpadding="2" align="center"><tr>
			<td class="fieldtitle"><div align="center">~ . PageLink({$actionparam => $$list[$i]->[2], $extrakey => $extravalue}) . 
			qq~$$list[$i]->[0]</a><div></td></tr><tr><td class="description"><div align="center">
			$$list[$i]->[1]</div></td></tr></table><br>~;
		}
		$i -= 2;
	}
}
END_SUB

# MainPage: Displays the main Coranto page.
'MainPage' => <<'END_SUB',
sub MainPage {
	CRHTMLHead($Messages{'Section_MainPage'});

	PrintFunctionList(\@AvailableFunctions, 'action');
	print qq~
	<table width="80%" cellpadding="4" align="center" border="0"><tr><td class="footnote"><div align="center">
	<b>$Messages{'MainPage_YourVersion'}</b> $crcgiVer~ . ( $crcgiRC ? " RC-$crcgiRC" : '' ) . ( $CConfig{'VersionChecking'} ? qq~ / <b>$Messages{'MainPage_CurrentVersion'}</b> <img src="http://coranto.gweilo.org/scripts/upgrade.php?do=img&b=$crcgiBuild&rc=$crcgiRC&v=~ .
		URLescape($crcgiVer) . ( $CConfig{'UrgentNotification'} ? '&sau=' . URLescape($CConfig{'SuperAdmin'}) . '&sae=' . URLescape($userdata{$CConfig{'SuperAdmin'}}->{'Email'}) : '' ) . '&url=' . URLescape($scripturl) . '" align="top">' : '' ) . '<br>';
	# HOOK: MainPage
	if($Addons{'MainPage'}){my $w;foreach $w (@{$Addons{'MainPage'}}){my $addon=$w->[2];eval ${$w->[0]};AErr($addon,$@)if $@;};}
	if ($CConfig{'PublicOrPrivate'}) {
		print qq~<a href="http://coranto.gweilo.org/scripts/upgrade.php?b=$crcgiBuild&rc=$crcgiRC&ver=$crcgiVer"><b>Download Upgrade</b> (if available)</a> / ~ if $up == 3;
		print '<a href="http://coranto.gweilo.org/" target="_blank">Unofficial Coranto Web Site</a>';
	}
	print '</div></td></tr></table>';
	CRHTMLFoot();
}
END_SUB


# Prints a simple message.
'SimpleConfirmationPage' => <<'END_SUB',
sub SimpleConfirmationPage {
	my ($pagetitle, $pagecontent, $adminnav, $halffoot) = @_;
	CRHTMLHead($pagetitle, $adminnav);
	print qq~
	<table width="80%" border="0" cellpadding="4" class="confirm" align="center"><tr><td><div align="center">$pagecontent</div></td></tr></table>
	<br>
	~;
	if ($halffoot) {
		CRHTMLFoot_NoNav();
	}
	else {
		CRHTMLFoot();
	}
}
END_SUB

# Tricolore: prints a nice table with three areas (name, description, actions) suitable for lists of things.
'Tricolore' => <<'END_SUB',
sub Tricolore {
	return qq~
	<table width="80%" cellpadding="1" border="0" cellspacing="0" align="center" class="darkgbg"><tr><td>
	<table width="100%" cellpadding="4" cellspacing="0" align="center" border="0" class="whitebg">
	<tr><td class="fieldtitle"><div align="center">$_[0]</div></td></tr>
	<tr><td class="footnote"><div align="center">$_[1]</div></td></tr>
	<tr><td class="description"><div align="center">$_[2]</div></td></tr></table>
	</td></tr></table><br>~;
}
END_SUB

'SettingsTable' => <<'END_SUB',
sub SettingsTable {
	return qq~
	<table width="80%" border="0" cellspacing="2" cellpadding="2" align="center"><tr><td class="fieldtitle" width="50%"><div align="right">
	$_[0]</div></td><td width="50%"><div align="center">$_[1]</div></td></tr><tr><td colspan="2" class="description">
	<div align="center">$_[2]</div></td></tr></table><br>~;
}
END_SUB

#######
# SUBMIT NEWS
#######

# DisplaySubForm: displays the Submit News page.
'DisplaySubForm' => <<'END_SUB',
sub DisplaySubForm {
	NeedCFG();
	CRHTMLHead($Messages{'Section_Submit'});
	my $formCode = StartForm( {'action' => 'submitsave'}, 'name="submitnews"');
	# HOOK: DisplaySubForm_FormStart
	if($Addons{'DisplaySubForm_FormStart'}){my $w;foreach $w (@{$Addons{'DisplaySubForm_FormStart'}}){my $addon=$w->[2];eval ${$w->[0]};AErr($addon,$@)if $@;};}
	print $formCode;
	print StartFieldsTable();
	print FieldsRow('Date', GetTheDate_Internal());
	# HOOK: DisplaySubForm_TopRow
	if($Addons{'DisplaySubForm_TopRow'}){my $w;foreach $w (@{$Addons{'DisplaySubForm_TopRow'}}){my $addon=$w->[2];eval ${$w->[0]};AErr($addon,$@)if $@;};}
	my ($fn, $fcode);
	foreach $fn (@fieldDB) {
		# Go through the list of fields.
		if ($up > $fieldDB{$fn}->{'SubmitPerm'}) {
			# Current user is allowed to submit things into this field.
			if ($fieldDB{$fn}->{'FieldType'} == 1){
				$fcode = qq~<input type="text" name="$fn" size="$fieldDB{$fn}->{'FieldSize'}" value="~ . HTMLescape($fieldDB{$fn}->{'DefaultValue'}) . '"' . ($fieldDB{$fn}->{'MaxLength'} ? qq~ maxlength="$fieldDB{$fn}->{'MaxLength'}">~ : '>');
			}

			if ($fieldDB{$fn}->{'FieldType'} == 2) {
				$fcode = qq~<textarea name="$fn" rows="$fieldDB{$fn}->{'FieldRows'}" cols="$fieldDB{$fn}->{'FieldCols'}" wrap="VIRTUAL">~ . HTMLescape($fieldDB{$fn}->{'DefaultValue'}) . '</textarea>';
			}
			
			if ($fieldDB{$fn}->{'FieldType'} == 3) {
				$fcode = qq~<select name="$fn" size="$fieldDB{$fn}->{'FieldSize'}">~ . join('', map { '<option ' . ($_ =~ /^\[(.+)\]/ ? 'selected>' . HTMLescape($1) : '>' . HTMLescape($_)) . '</option>' } split(/\|/, $fieldDB{$fn}->{'Options'})) . '</select>';
			}

			if ($fieldDB{$fn}->{'FieldType'} == 4) {
				$fcode = qq~<input type="checkbox" name="$fn" value="~ . HTMLescape($fieldDB{$fn}->{'OnValue'}) . '"';
				if ($fieldDB{$fn}->{'Checked'}){
				$fcode .= qq~ checked~;
				}
				$fcode .= '>';
			}

			if ($fieldDB{$fn}->{'FieldType'} == 5) {
				$fcode = join('', map { qq~<input name="$fn" type="radio" ~ . ($_ =~ /^\[(.+)\]/ ? 'checked value="' . HTMLescape($1) . '">' . HTMLescape($1) : 'value="' . HTMLescape($_) . '">' . HTMLescape($_)) . $fieldDB{$fn}->{'SplitOptions'} } split(/\|/, $fieldDB{$fn}->{'Options'}));
			}

			# HOOK: DisplaySubForm_Fields
			if($Addons{'DisplaySubForm_Fields'}){my $w;foreach $w (@{$Addons{'DisplaySubForm_Fields'}}){my $addon=$w->[2];eval ${$w->[0]};AErr($addon,$@)if $@;};}
			print FieldsRow($fieldDB{$fn}->{'DisplayName'}, $fcode);
		}
	}
	# HOOK: DisplaySubForm_BottomRow
	if($Addons{'DisplaySubForm_BottomRow'}){my $w;foreach $w (@{$Addons{'DisplaySubForm_BottomRow'}}){my $addon=$w->[2];eval ${$w->[0]};AErr($addon,$@)if $@;};}
	print '</table><div align="center">';
	# HOOK: DisplaySubForm_AfterTable
	if($Addons{'DisplaySubForm_AfterTable'}){my $w;foreach $w (@{$Addons{'DisplaySubForm_AfterTable'}}){my $addon=$w->[2];eval ${$w->[0]};AErr($addon,$@)if $@;};}
	print qq~<br><table align="center" width="80%" border="0">
		<tr><td class="description"><div align="center">~;
	# HOOK: DisplaySubForm_Submit
	if($Addons{'DisplaySubForm_Submit'}){my $w;foreach $w (@{$Addons{'DisplaySubForm_Submit'}}){my $addon=$w->[2];eval ${$w->[0]};AErr($addon,$@)if $@;};}
	print qq~<input type="submit" value="$Messages{'Submit'}" onClick="document.forms.submitnews.target = '_top'">
		<input type="reset" value="$Messages{'Reset'}"></div></td></tr></table></div></form>~;
	# HOOK: DisplaySubForm_AfterForm
	if($Addons{'DisplaySubForm_AfterForm'}){my $w;foreach $w (@{$Addons{'DisplaySubForm_AfterForm'}}){my $addon=$w->[2];eval ${$w->[0]};AErr($addon,$@)if $@;};}
	CRHTMLFoot();
}
END_SUB

# SaveNews: Saves submitted news to newsdat.txt.
'SaveNews' => <<'END_SUB',
sub SaveNews {
	NeedCFG();
	my $i;
	
	# HOOK: SaveNews_Pre
	if($Addons{'SaveNews_Pre'}){my $w;foreach $w (@{$Addons{'SaveNews_Pre'}}){my $addon=$w->[2];eval ${$w->[0]};AErr($addon,$@)if $@;};}
	foreach $i (@fieldDB) {
		# Go through the list of fields.

		# Translate OS-specific newline chars into Perl's logical one
		#$in{$i} =~ s/\015?\012/\n/gi;

		if ($up > $fieldDB{$i}->{'SubmitPerm'}) {
			# The user is authorized to submit things into this field.
			if ($fieldDB{$i}->{'DisableHTML'}) {
				$in{$i} = HTMLescape($in{$i});
			}

			unless ($fieldDB{$i}->{'StripSSI'}){
			$fieldDB{$i}->{'StripSSI'} = 1;
			}

			if ($fieldDB{$i}->{'StripSSI'} == 1) {
				StripSSI(\$in{$i});
			}
			if ($fieldDB{$i}->{'ParseLinks'}){
			$in{$i} =~ s/([\s\(]|\A|<br>)(http:\/\/|ftp:\/\/|https:\/\/)([^\s\)"<>,]+)/$1<a href="$2$3">$2$3<\/a>/gi;
			}
			if ($fieldDB{$i}->{'Newlines'} == 1) {
				if ($CConfig{'XHTMLbr'}) {
				$in{$i} =~ s/\n/<br \/>/g;
				}
				else {
				$in{$i} =~ s/\n/<br>/g;
				}
			}

			else {
			$in{$i} =~ s/\n//g;
			}

			# Field processed. Now set the equivalent global variable to the contents of the field.
			$$i = $in{$i};
		}
	}
	if ($CConfig{'AutoLinkURL'}) {
		# This monster replaces URLs with links to the URL.
		$Text =~ s/([\s\(]|\A|<br>)(http:\/\/|ftp:\/\/|https:\/\/)([^\s\)"<>,]+)/$1<a href="$2$3">$2$3<\/a>/gi;
	}
	$User = $CurrentUser;
	$newstime = $CurrentTime;
	$newsid = $CurrentTime;
	$newsid =~ tr/0123456789/pEkFuVyZlA/;
	$newsid .= RandomWord(8);
	if ($CConfig{'TimeOffset'}) {
		$newstime += (3600 * $CConfig{'TimeOffset'});
	}
	# HOOK: SaveNews_1
	if($Addons{'SaveNews_1'}){my $w;foreach $w (@{$Addons{'SaveNews_1'}}){my $addon=$w->[2];eval ${$w->[0]};AErr($addon,$@)if $@;};}
	$Category = '(default)' unless $Category; # unless the Categories addon is installed, put this in the default cat
	my $newsline = JoinDataFile();
	# Now add this line to the top of newsdat.txt
	
	my ($fh, $fh2) = EditNewsdat_Start();
	
	print $fh2 $newsline . "\n";
	while (<$fh>) {
		print {$fh2} $_;
	}
	close($fh);
	close($fh2);
	
	EditNewsdat_Finish();
	
	# HOOK: SaveNews_2
	if($Addons{'SaveNews_2'}){my $w;foreach $w (@{$Addons{'SaveNews_2'}}){my $addon=$w->[2];eval ${$w->[0]};AErr($addon,$@)if $@;};}
	
	if ($CConfig{'AutoBuild_Submit'}) {
		BuildNews();
	}
	SimpleConfirmationPage($Messages{'SaveNews_Title'}, $Messages{'SaveNews_Message'} . ' ' . 
		($CConfig{'AutoBuild_Submit'} ? $Messages{'SaveNews_Message_Auto'} : $Messages{'SaveNews_Message_NoAuto'}));
}				
END_SUB

'StripSSI' => <<'END_SUB',
sub StripSSI {
	# Get rid of possibly evil things in submitted news: server side includes, ASP, and PHP
	my $text = shift;
	$$text =~ s/<[\!\?\%][\s\S]*?>[\!\?\%]*//g; # SSI, ASP, and most PHP
	$$text =~ s/<\s*script[^>]*language\s*=\s*["']?PHP\d*["']?[^>]*>//gi; # PHP's alternate format
}
END_SUB

'StripNewlines' => <<'END_SUB',
sub StripNewlines {
	# Get rid of possibly evil things in submitted news: server side includes, ASP, and PHP
	my $text = shift;
	$$text =~ s/\n//g;
}
END_SUB

#######
# BUILD NEWS
#######

# GenHTML: Called when Build News is selected. (The core of Build News is elsewhere.)
'GenHTML' => <<'END_SUB',
sub GenHTML {
	my $fullbuild = shift;
		
	# Start the actual process, which for cleanliness is in another subroutine.
	BuildNews($fullbuild);
	
	# Done! Print confirmation page.
	SimpleConfirmationPage($Messages{'Build_Title'}, $Messages{'Build_Message'});
}
END_SUB

# BuildNews: This handles building news.
# It is, you may notice, very, very large.
'BuildNews' => <<'END_SUB',
sub BuildNews {
	my $buildtype = shift; # if this == 1, then we'll do a full rebuild
	
	
	# Load some other files
	NeedCFG();

	# Get initial data and initialize variables.
	
	my (%ActiveProfiles, %ProfCats, %ProfTimeFilter, %ProfNumFilter, %ProfSkipDays);
	my (%ProfFiltSub, %ProfArchive, %ProfStopArcTime, %ProfSAFNum, %ProfExtra);
	my (%ProfArchiveFilePath, %ProfFilePath, %ProfType, $i, %ProfSkip, %ProfExtra2);
	
	# Allows addons some easier variable access.
	sub GetBuildVar {
		my $name = shift;
		$name =~ s/(\S+)/'$' . $1/ee;
		return $name;
	}
	sub GetBuildRef {
		return eval "return \\$_[0]"; 
	}
	
	# If $buildtype == 1, then do a full rebuild.
	# HOOK: InitActiveProfiles
	if($Addons{'InitActiveProfiles'}){my $w;foreach $w (@{$Addons{'InitActiveProfiles'}}){my $addon=$w->[2];eval ${$w->[0]};AErr($addon,$@)if $@;};}
	
	# Get some information ready and variables set up for each profile.
	INITLOOP: foreach $i (sort keys %newsprofiles) {
		# HOOK: InitActiveProfiles_UseProfile
		if($Addons{'InitActiveProfiles_UseProfile'}){my $w;foreach $w (@{$Addons{'InitActiveProfiles_UseProfile'}}){my $addon=$w->[2];eval ${$w->[0]};AErr($addon,$@)if $@;};}

		if ($newsprofiles{$i}->{'enabled'}) {
			$ActiveProfiles{$i} = 1;

			if ($EnableCategories) {
				$ProfCats{$i} = {};
				my $j;
				foreach $j (@{$newsprofiles{$i}->{'cats'}}) {
					$ProfCats{$i}->{$j} = 1;
				}
			}

			# New speedup code for Submit News
			# Only build profiles containing the item

			if ($newsprofiles{$i}->{'type'} eq 'Standard' && $in{'action'} eq 'submitsave' && $EnableCategories && $ProfCats{$i} && $in{'Category'}){
				unless ($ProfCats{$i}->{$in{'Category'}} || $ProfCats{$i}->{'AllCategories'}){
						delete $ActiveProfiles{$i};
						next INITLOOP;
				}
			}

			# HOOK: BuildNews_Speedup_Code
			if($Addons{'BuildNews_Speedup_Code'}){my $w;foreach $w (@{$Addons{'BuildNews_Speedup_Code'}}){my $addon=$w->[2];eval ${$w->[0]};AErr($addon,$@)if $@;};}

			# End speedup code

			if ($newsprofiles{$i}->{'agefilter'}) {
				$ProfTimeFilter{$i} = (PastDaysTime($newsprofiles{$i}->{'agefilter'}))[0];
			}
			else {
				$ProfTimeFilter{$i} = 0;
			}

			## PROFILE FILTER DAYS
			$ProfSkipDays{$i} = $newsprofiles{$i}->{'skipdays'} * (60*60*24);
			## PROFILE FILTER DAYS

			$ProfNumFilter{$i} = $newsprofiles{$i}->{'numfilter'};
			$ProfNumFilter{$i}-- if $ProfNumFilter{$i};
			$ProfSkip{$i} = $newsprofiles{$i}->{'skipfilter'};
			$ProfFiltSub{$i} = $newsprofiles{$i}->{'filtsub'} if $newsprofiles{$i}->{'filtsub'};
			$ProfType{$i} = $newsprofiles{$i}->{'type'};
			if ($newsprofiles{$i}->{'archive'} && $ProfType{$i} eq 'Standard') {
				$ProfArchive{$i} = $newsprofiles{$i}->{'archive'};
				if ($newsprofiles{$i}->{'archive'} >= 2 && !$buildtype && !$newsprofiles{$i}->{'ForceFullBuild'} && !$CConfig{'ForceFullBuild'}) {
					$ProfStopArcTime{$i} = $newsprofiles{$i}->{'LastBuildTime'};
					if ($CConfig{'LastBuildOverride'} && $CConfig{'LastBuildOverride'} < $ProfStopArcTime{$i}) {
						$ProfStopArcTime{$i} = $CConfig{'LastBuildOverride'};
					}
					$ProfSAFNum{$i} = $ProfNumFilter{$i};
					if ($ProfSkip{$i}) {
						$ProfSAFNum{$i} += $ProfSkip{$i}; # Compensate for the skip feature
					}
				}
				else {
					$ProfStopArcTime{$i} = 0;
					$newsprofiles{$i}->{'ForceFullBuild'} = 0;
				}
				if ($newsprofiles{$i}->{'archivefilepath'}) {
					$ProfArchiveFilePath{$i} = $newsprofiles{$i}->{'archivefilepath'};
				}
				else {
					$ProfArchiveFilePath{$i} = $CConfig{'archive_path'};
				}
			}
			if ($newsprofiles{$i}->{'filepath'}) {
				$ProfFilePath{$i} = $newsprofiles{$i}->{'filepath'};
			}
			else {
				$ProfFilePath{$i} = $CConfig{'htmlfile_path'};
			}
			if ($newsprofiles{$i}->{'headlines'}) {
				# If headlines are enabled, create a fake profile called (name)-headlines
				$newsprofiles{"$i-headlines"} = {
					'enabled' => 1,
					'textfile' => ($i eq 'news' ? 'headlines.txt' : "$i-headlines.txt"),
					'cats' => $newsprofiles{$i}->{'cats'},
					'agefilter' => $newsprofiles{$i}->{'agefilter'},
					'numfilter' => ($newsprofiles{$i}->{'headline-number'} && ($newsprofiles{$i}->{'headline-number'} < $newsprofiles{$i}->{'numfilter'} || !$newsprofiles{$i}->{'numfilter'}) ? $newsprofiles{$i}->{'headline-number'} : $newsprofiles{$i}->{'numfilter'}),
					'style' => $newsprofiles{$i}->{'headline-style'},
					'filepath' => $newsprofiles{$i}->{'filepath'},
					'anchors' => 0,
					'archive' => 0,
					'type' => 'Standard',
					'ForceFullBuild' => $newsprofiles{$i}->{'ForceFullBuild'},
					'LastBuildTime' => $newsprofiles{$i}->{'LastBuildTime'}};

			}
			else {
			# No headlines are to be built, so delete fake profile
			delete $newsprofiles{"$i-headlines"};
			delete $ActiveProfiles{"$i-headlines"};
			}

			$newsprofiles{$i}->{'LastBuildTime'} = $CurrentTime;
			# HOOK: InitActiveProfiles_2
			if($Addons{'InitActiveProfiles_2'}){my $w;foreach $w (@{$Addons{'InitActiveProfiles_2'}}){my $addon=$w->[2];eval ${$w->[0]};AErr($addon,$@)if $@;};}
		}
	}
	delete $CConfig{'ForceFullBuild'};
	delete $CConfig{'LastBuildOverride'};
	InitGTD($CConfig{'ArchiveDateFormat_Weekly'}, 'GetTheDate_WeeklyArchive');
	InitGTD($CConfig{'ArchiveDateFormat_Daily'}, 'GetTheDate_DailyArchive');
	InitGTD($CConfig{'ArchiveDateFormat_Monthly'}, 'GetTheDate_MonthlyArchive');
		
	InitUserFieldVars();
	if (keys %ActiveProfiles) {
	my (%FilesOpened, %HTMLContent, %FilteredContent, %ArchiveData);
	my (%ArcLastFile, %ArcLinkData, %ArcTitle, %StopArchiving1, %StopArchiving2);
	my ($line, $key, $value, @finprof);
	
	# Open files for each profile.
	while ($i = each %ActiveProfiles) {
		if ($ProfType{$i} eq 'Standard') {
			$FilesOpened{$i} = CRopen(">$ProfFilePath{$i}/$newsprofiles{$i}->{'textfile'}");
		}
		else {
			# HOOK: BuildNews_NewType_Open
			if($Addons{'BuildNews_NewType_Open'}){my $w;foreach $w (@{$Addons{'BuildNews_NewType_Open'}}){my $addon=$w->[2];eval ${$w->[0]};AErr($addon,$@)if $@;};}
		}
	}
	
	# Open newsdat.txt
	my $ndfh = CRopen("$CConfig{'htmlfile_path'}/newsdat.txt");
	$newsnum = 1;
	# HOOK: BuildNews_PreLoop
	if($Addons{'BuildNews_PreLoop'}){my $w;foreach $w (@{$Addons{'BuildNews_PreLoop'}}){my $addon=$w->[2];eval ${$w->[0]};AErr($addon,$@)if $@;};}
	# Begin looping through newsdat.txt
	NCLOOP: while (<$ndfh>) {
		chomp($_);
		# Split the item into the news fields
		SplitDataFile($_);
		
		# Addons: don't necessarily assume you're in Build News here; this hook may be duplicated
		# in other places where news is being built, after SplitDataFile has been run.
		# It's intended to be the place where you set the values of synthetic fields.
		# HOOK: Build_GetData
		if($Addons{'Build_GetData'}){my $w;foreach $w (@{$Addons{'Build_GetData'}}){my $addon=$w->[2];eval ${$w->[0]};AErr($addon,$@)if $@;};}
		
		# Go through each profile, one at a time.
		PROFLOOP: while ($i = each %ActiveProfiles) {		
			# Filter by category.
			if (!$EnableCategories || $ProfCats{$i}->{'AllCategories'} || $ProfCats{$i}->{$Category}) {

				# HOOK: BuildNews_Filtering2
				# This is for addons that need to do filtering before anything else does
				if($Addons{'BuildNews_Filtering2'}){my $w;foreach $w (@{$Addons{'BuildNews_Filtering2'}}){my $addon=$w->[2];eval ${$w->[0]};AErr($addon,$@)if $@;};}

				{

					if ($newsprofiles{$i}->{'skipdays'}){
					# PROFILE FILTER DAYS

					# Subtract x days from current time
					my $first_item_time = time() - ($newsprofiles{$i}->{'skipdays'} * (60*60*24));

					# Get date vars
					BasicDateVars($first_item_time);

					# Get timestamp for x days ago, at 12:00AM
					my $time = YMDtoUNIX($Year, $Month_Number, $Month_Day);

						if ($newstime > $time){
						# skip items less than x days old
						next PROFLOOP;
						}

					# END PROFILE FILTER DAYS
					}

				}

				if ($ProfSkip{$i}) {
					$ProfSkip{$i}--;
					next PROFLOOP;
				}
				if ($newstime < $ProfStopArcTime{$i}) {
					$StopArchiving1{$i} = 1;
					$ProfSAFTime{$i} = PastDaysTime($newsprofiles{$i}->{'agefilter'}, $newstime) if $ProfTimeFilter{$i};
				}
				$ProfSAFNum{$i}-- if ($StopArchiving1{$i} && $ProfSAFNum{$i} ne '');

				# Filter by age/number
				if ($ProfNumFilter{$i} > -1 && $newstime >= $ProfTimeFilter{$i}) {
					if ($ProfNumFilter{$i} ne '') {
						# Take one off the count of allowable remaining items.
						$ProfNumFilter{$i}--;
					}
					
					# HOOK: BuildNews_Filtering
					if($Addons{'BuildNews_Filtering'}){my $w;foreach $w (@{$Addons{'BuildNews_Filtering'}}){my $addon=$w->[2];eval ${$w->[0]};AErr($addon,$@)if $@;};}
					
					if ($ProfType{$i} eq 'Standard') {
						# If we're using a different sort order, save the item to be sorted later.
						if ($ProfFiltSub{$i}) {
							my $tmpnhash = {};
							foreach $k (@fieldDB_internalorder) {
								$tmpnhash->{$k} = ${$k};
							}
							push(@{$FilteredContent{$i}}, $tmpnhash);
						}
						else {
							# Get the date, get the HTML, and save it.
							$Date = GetTheDate($newstime);
							$FileName = $i;
							$ProfileName = $i;
							# HOOK: BuildNews_StandardProfile
							if($Addons{'BuildNews_StandardProfile'}){my $w;foreach $w (@{$Addons{'BuildNews_StandardProfile'}}){my $addon=$w->[2];eval ${$w->[0]};AErr($addon,$@)if $@;};}
							$newshtml = &{$newsprofiles{$i}->{'style'}};
							if ($newsprofiles{$i}->{'anchors'}) {
								$newshtml = qq~<a name="newsitem$newsid"></a>$newshtml~;
							}

							print {$FilesOpened{$i}} $newshtml;

							# If creating an HTML file, save the info for later.
							if ($newsprofiles{$i}->{'tmplfile'}) {
								$HTMLContent{$i} .= $newshtml;
							}
						}
					}
					else {					
						# This is where to hook yourself in if your addon provides a new profile type.
						# HOOK: BuildNews_ProfileType
						if($Addons{'BuildNews_ProfileType'}){my $w;foreach $w (@{$Addons{'BuildNews_ProfileType'}}){my $addon=$w->[2];eval ${$w->[0]};AErr($addon,$@)if $@;};}
					}
				}	
				elsif ($ProfArchive{$i}) {
					# The age/number limits have been reached, but we're archiving.
					$Date = GetTheDate($newstime);
					if ($ProfArchive{$i} == 1) {
						# One big archive -- just get the info and save it.
						$FileName = "$i-archive";
						$ProfileName = $i;
						# HOOK: BuildNews_SingleArchive
						if($Addons{'BuildNews_SingleArchive'}){my $w;foreach $w (@{$Addons{'BuildNews_SingleArchive'}}){my $addon=$w->[2];eval ${$w->[0]};AErr($addon,$@)if $@;};}
						$newshtml = &{$newsprofiles{$i}->{'arc-style'}};
						if ($newsprofiles{$i}->{'anchors'}) {
							$newshtml = qq~<a name="newsitem$newsid"></a>$newshtml~;
						}
						unless ($FilesOpened{$FileName}) {
							$FilesOpened{$FileName} = CRopen(">$ProfArchiveFilePath{$i}/$FileName.txt");
						}
						print {$FilesOpened{$FileName}} $newshtml;
					}
					elsif ($ProfArchive{$i} >= 2) {
						# We're doing multiple archives.
						# First, check if we should stop quick-building after this archive
						$StopArchiving2{$i} = 1 if ($StopArchiving1{$i} && ($ProfSAFTime{$i} > $newstime || $ProfSAFNum{$i} < -1));
						$ProfileName = $i;
						if ($ProfArchive{$i} == 4) {
							# Daily archiving
							$CorrectedWeeklyTime = $newstime;
							$FileName = "$i-archive-$Month_Day-$ActualMonth-$Year";
						}
						elsif ($ProfArchive{$i} == 3) {
							# Weekly archiving. This takes calculations.
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
								$FileName = "$i-archive-$cweeklytime[3]-" . ($cweeklytime[4] + 1) . '-' . ($cweeklytime[5] + 1900);
							}
							else {
								# It's a Sunday. Just use the current day as the archive title.
								$FileName = "$i-archive-$Month_Day-$ActualMonth-$Year";	
							}
						}
						else {
							# Monthly archiving.
							$FileName = "$i-archive-$ActualMonth-$Year";
						}
						$FileName = "$FileName.$CConfig{'ArcHtmlExt'}";
						# Get the HTML built.
						# HOOK: BuildNews_MultiArchive
						if($Addons{'BuildNews_MultiArchive'}){my $w;foreach $w (@{$Addons{'BuildNews_MultiArchive'}}){my $addon=$w->[2];eval ${$w->[0]};AErr($addon,$@)if $@;};}
						$newshtml = &{$newsprofiles{$i}->{'arc-style'}};
						if ($newsprofiles{$i}->{'anchors'}) {
							$newshtml = qq~<a name="newsitem$newsid"></a>$newshtml~;
						}
						if ($ArcLastFile{$i} ne $FileName) {
							# This is the first time in this archive.
							if ($ArcLastFile{$i}) {
								# Process the previous archive.
								my $fh = CRopen(">$ProfArchiveFilePath{$i}/$ArcLastFile{$i}");
								print $fh &ProcessTMPL("$CConfig{'admin_path'}/$newsprofiles{$i}->{'archivetmpl'}", \$ArchiveData{$i}, $ArcTitle{$i}, 1);
								close($fh);						
							}
							
							# Do we still want to be archiving?
							if ($StopArchiving2{$i}) {
								push(@finprof, $i);
							}
							else {
								# Yes, we want to be archiving.
								# Get the date of the archive.
								if ($ProfArchive{$i} == 4) {
									$ArchiveDate = GetTheDate_DailyArchive($newstime);
								}
								elsif ($ProfArchive{$i} == 3) {
									if ($Week_Day) {
										$ArchiveDate = GetTheDate_WeeklyArchive($CorrectedWeeklyTime);
									}
									else {
										$ArchiveDate = GetTheDate_WeeklyArchive($newstime);
									}
								}
								else {
									$ArchiveDate = GetTheDate_MonthlyArchive($newstime);
								}

								# Initialise variables and add the link to the links page.
								$ArchiveData{$i} = $newshtml;
								$newshtml = &NewsStyle_ArchiveLink();
								$ArcLinkData{$i} .=  $newshtml . "<!--LINK: $FileName-->";
								$ArcTitle{$i} = $ArchiveDate;
								$ArcLastFile{$i} = $FileName;
							}
							
						}
						else {
							# We're in the middle of an archive. Save the data for later.
							$ArchiveData{$i} .= $newshtml;
						}
					}	

				}
				else {
					# No news matches this profile. Delete it from the active list so that it will
					# be ignored in the future.
					push(@finprof, $i);
					# HOOK: BuildNews_ProfileFinished
					if($Addons{'BuildNews_ProfileFinished'}){my $w;foreach $w (@{$Addons{'BuildNews_ProfileFinished'}}){my $addon=$w->[2];eval ${$w->[0]};AErr($addon,$@)if $@;};}
				}
			}
		}
		if (@finprof) {
			my $fpr;
			foreach $fpr (@finprof) {
				delete $ActiveProfiles{$fpr};
			}
			unless (keys %ActiveProfiles) {
				last NCLOOP;
			}
		}
		# HOOK: BuildNews_Loop
		if($Addons{'BuildNews_Loop'}){my $w;foreach $w (@{$Addons{'BuildNews_Loop'}}){my $addon=$w->[2];eval ${$w->[0]};AErr($addon,$@)if $@;};}
		$newsnum++;
	}
	close($ndfh);
	# The main loop is done. Now, do things that were kept for later.
	
	# HOOK: BuildNews_PostLoop
	if($Addons{'BuildNews_PostLoop'}){my $w;foreach $w (@{$Addons{'BuildNews_PostLoop'}}){my $addon=$w->[2];eval ${$w->[0]};AErr($addon,$@)if $@;};}
	
	
	# Process the last archive where applicable.
	foreach $i (keys %ArchiveData) {
		my $fh = CRopen(">$ProfArchiveFilePath{$i}/$ArcLastFile{$i}");
		print $fh &ProcessTMPL("$CConfig{'admin_path'}/$newsprofiles{$i}->{'archivetmpl'}", \$ArchiveData{$i}, $ArcTitle{$i}, 1);
		close($fh);						
	}	
	
	# Take care of profiles with other sort orders.
	foreach $i (keys %FilteredContent) {
		if ($ProfFiltSub{$i}) {
		
			# HOOK: BuildNews_DifferentSortOrder
          		if($Addons{'BuildNews_DifferentSortOrder'}){my $w;foreach $w (@{$Addons{'BuildNews_DifferentSortOrder'}}){my $addon=$w->[2];eval ${$w->[0]};AErr($addon,$@)if $@;};}
	  
			# Run the saved data through the specified sorting subroutine.
			my @FilteredND = &{$ProfFiltSub{$i}}(@{$FilteredContent{$i}});
			foreach $j (@FilteredND) {
				# The data has been sorted; go through the sorted data.
				# Get the global field variables.
				foreach $k (keys %{$j}) {
					${$k} = $j->{$k};
				}
				
				# Build HTML, save. As usual.
				$Date = GetTheDate($newstime);
				$ProfileName = $i;
				$FileName = $i;
				# HOOK: BuildNews_Filtered
				if($Addons{'BuildNews_Filtered'}){my $w;foreach $w (@{$Addons{'BuildNews_Filtered'}}){my $addon=$w->[2];eval ${$w->[0]};AErr($addon,$@)if $@;};}
				$newshtml = &{$newsprofiles{$i}->{'style'}};
				if ($newsprofiles{$i}->{'anchors'}) {
					$newshtml = qq~<a name="newsitem$newsid"></a>$newshtml~;
				}
				unless ($FilesOpened{$i}) {
					$FilesOpened{$i} = CRopen(">$ProfFilePath{$i}/$newsprofiles{$i}->{'textfile'}");
				}
				print {$FilesOpened{$i}} $newshtml;
				if ($newsprofiles{$i}->{'tmplfile'}) {
					$HTMLContent{$i} .= $newshtml;
				}
			}
		}
	}
	

	# Go through all open files (open files will be text files)
	# Print news controls or links, and then close them.	
	while (($key, $value) = each %FilesOpened) {
		# HOOK: BuildNews_CloseFile
		if($Addons{'BuildNews_CloseFile'}){my $w;foreach $w (@{$Addons{'BuildNews_CloseFile'}}){my $addon=$w->[2];eval ${$w->[0]};AErr($addon,$@)if $@;};}
		my $br = ($CConfig{'XHTMLbr'} ? '<br />' : '<br>');
		if ($newsprofiles{$key}->{'DisplayLink'} == 1) {
			print $value qq~$br<i><small>$Messages{'DisplayLink'} <a href="http://www.amphibianweb.com" target="_blank">Coranto</a></small></i>$br~;
		}
		elsif ($newsprofiles{$key}->{'DisplayLink'} == 2) {
			print $value qq~$br<i><small>$Messages{'DisplayLink'} <a href="http://coranto.gweilo.org" target="_blank">Coranto</a></small></i>$br~;
		}
		elsif ($newsprofiles{$key}->{'DisplayLink'} == 3) {
			print $value qq~$br<i><small>$Messages{'DisplayLink'} Coranto</small></i>$br~;
		}
		close($value);
	}
	foreach $i (keys %HTMLContent) {
		if ($newsprofiles{$i}->{'tmplfile'}) {
			# Take care of profiles which want an HTML file built.
			# HOOK: BuildNews_HTMLFile
			if($Addons{'BuildNews_HTMLFile'}){my $w;foreach $w (@{$Addons{'BuildNews_HTMLFile'}}){my $addon=$w->[2];eval ${$w->[0]};AErr($addon,$@)if $@;};}

			my $br = ($CConfig{'XHTMLbr'} ? '<br />' : '<br>');
			if ($newsprofiles{$key}->{'DisplayLink'} == 1) {
				print $value qq~$br<i><small>$Messages{'DisplayLink'} <a href="http://www.amphibianweb.com" target="_blank">Coranto</a></small></i>$br~;
			}
			elsif ($newsprofiles{$key}->{'DisplayLink'} == 2) {
				print $value qq~$br<i><small>$Messages{'DisplayLink'} <a href="http://coranto.gweilo.org" target="_blank">Coranto</a></small></i>$br~;
			}
			elsif ($newsprofiles{$key}->{'DisplayLink'} == 3) {
				print $value qq~$br<i><small>$Messages{'DisplayLink'} Coranto</small></i>$br~;
			}
			
			# Put the saved data through a TMPL file and save it.
			my $fh = CRopen(">$ProfFilePath{$i}/$i.$CConfig{'ArcHtmlExt'}");
			print {$fh} ProcessTMPL("$CConfig{'admin_path'}/$newsprofiles{$i}->{'tmplfile'}", \$HTMLContent{$i}, $newsprofiles{$i}->{'tmpltitle'});
			close($fh);
		}
	}
	
	foreach $i (keys %ArcLinkData) {
		# Go through any archive links pages. 
		if ($newsprofiles{$i}->{'arclinkfilename'}) {
			my $fh;
			my $txtfilepath = "$ProfArchiveFilePath{$i}/$i-archive-links.txt";
			if ($ProfStopArcTime{$i}) {
				# We've done a quick build, so we have to load in previous link data.
				if (-e $txtfilepath) {
					my $oldarclink;
					$fh = CRopen($txtfilepath);
					{
						local $/;
						$oldarclink = <$fh>;
					}
					close($fh);
					if ($oldarclink =~ /\Q<!--LINK: $ArcLastFile{$i}-->\E/) {
						$oldarclink =~ s/<\!--QuickBuild[^>]+>//g;
						$oldarclink =~ s/^[\s\S]+\Q<!--LINK: $ArcLastFile{$i}-->\E/<!--QuickBuild: Links removed up to $ArcLastFile{$i}-->/g;
					}
					$ArcLinkData{$i} .= $oldarclink;
				}
			} 
			# The data is there, just save it as a text file...
			$fh = CRopen(">$txtfilepath");
			# HOOK: BuildNews_ArchiveLinks
			if($Addons{'BuildNews_ArchiveLinks'}){my $w;foreach $w (@{$Addons{'BuildNews_ArchiveLinks'}}){my $addon=$w->[2];eval ${$w->[0]};AErr($addon,$@)if $@;};}
			print $fh $ArcLinkData{$i};
			close($fh);
			$fh = CRopen(">$ProfArchiveFilePath{$i}/$newsprofiles{$i}->{'arclinkfilename'}");
			print {$fh} ProcessTMPL("$CConfig{'admin_path'}/$newsprofiles{$i}->{'arclinktmpl'}", \$ArcLinkData{$i});
			close($fh);
		}
	}
	
	$CConfig{'LastBuildTime'} = $CurrentTime;
	# HOOK: BuildNews_Post
	if($Addons{'BuildNews_Post'}){my $w;foreach $w (@{$Addons{'BuildNews_Post'}}){my $addon=$w->[2];eval ${$w->[0]};AErr($addon,$@)if $@;};}
	WriteProfileInfo();
	
	} # End if %ActiveProfiles

} # We're done!
END_SUB
# Yes, it's long.

######
# MODIFY NEWS
######

'ModifyNews' => <<'END_SUB',
sub ModifyNews {
	CRcough("The guest account can't access this function.") if $CurrentUser =~ /^guest/ && $up == 1;
	NeedCFG();

	# localize NDLOOP
	local *NDLOOP;

	# Set up variables
	
	my $ColCount = 1;
	my $MaxItems = $CConfig{'Modify_ItemsPerPage'};
	my $MaxSrchItems = $MaxItems + 20;
	my $StartFileCount = -1;
	my ($ItemCount, $FileCount, $Searching, $Filter, %FilterData, $MoreItems, $i);
	
	# If we're deleting, call the delete sub
	
	if ($in{'delete'}) {
		NeedFile('cradmin.pl');
		AreYouSure("Are you sure you want to delete the item(s) you just selected?") unless $in{'really'};
		ModifyNews_Delete();
	}
	
	# Print start of HTML and the search buttons
	
	CRHTMLHead($Messages{'Section_Modify'});
	print '<div align="center"><br>';
	print StartForm{'action' => 'modify'};
	print qq~$Messages{'Modify_Search'} <input type="text" name="search" size="25"> $Messages{'Modify_SearchIn'} <select name="searchfield">~;
	foreach $i (@fieldDB) {
		print qq~<option value="$i"~,
			($i eq 'Text' ? 'selected>' : '>'),
			$fieldDB{$i}->{'DisplayName'},
			'</option>';
	}
	print qq~<option value="User">$Messages{'User'}</option>~;
	# HOOK: ModifyNews_NewSearchField_1
	if($Addons{'ModifyNews_NewSearchField_1'}){my $w;foreach $w (@{$Addons{'ModifyNews_NewSearchField_1'}}){my $addon=$w->[2];eval ${$w->[0]};AErr($addon,$@)if $@;};}
	print qq~</select>
	<input type="submit" value="$Messages{'Search'}"></form>~;
	{
		my ($selday, $selmonth, $selyear);
		if ($in{'jumpmonth'}) {
			$selday = $in{'jumpday'};
			$selmonth = $in{'jumpmonth'};
			$selyear = $in{'jumpyear'};
		}
		else {
			BasicDateVars($CurrentTime - 2592000); # auto-select 30 days ago
			$selday = $Month_Day;
			$selmonth = $ActualMonth;
			$selyear = $Year;
		}
		print StartForm({'action' => 'modify'});
		print qq~$Messages{'Modify_Jump'} <select name="jumpday">~;
		PrintSelectValues($selday,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31);
		print '</select> <select name="jumpmonth">';
		PrintSelectValues($selmonth, @Months);
		print '</select> <select name="jumpyear">';
		PrintSelectValues($selyear, qw(same 1998 1999 2000 2001 2002 2003 2004 2005 2006 2007 2008)); # What? Make it automatic? Come on, we need a year-based bug here...
		print qq~</select> <input type="submit" name="submit" value="$Messages{'Go'}"></form>~;
	}
	# HOOK: ModifyNews_SearchForms
	if($Addons{'ModifyNews_SearchForms'}){my $w;foreach $w (@{$Addons{'ModifyNews_SearchForms'}}){my $addon=$w->[2];eval ${$w->[0]};AErr($addon,$@)if $@;};}
	
	# Now start the main table 
	
	print StartForm{'action' => 'modify'};

	# HOOK: ModifyNews_StartForm
	if($Addons{'ModifyNews_StartForm'}){my $w;foreach $w (@{$Addons{'ModifyNews_StartForm'}}){my $addon=$w->[2];eval ${$w->[0]};AErr($addon,$@)if $@;};}

	print qq~<table align="center" width="92%" border="0" cellspacing="1" cellpadding="3">
	<tr><td class="lightgbg"><div align="center"><b>$Messages{'Modify_Del'}</b></div></td><td class="yellowbg"><div align="center"><b>$fieldDB{'Subject'}->{'DisplayName'}</b></div></td>
	<td class="lightgbg"><div align="center"><b>$Messages{'Date'}</b></div></td>~;
	
	# Addons here, please increment $ColCount if you're adding a column.
	# HOOK: ModifyNews_NewColumn_1
	if($Addons{'ModifyNews_NewColumn_1'}){my $w;foreach $w (@{$Addons{'ModifyNews_NewColumn_1'}}){my $addon=$w->[2];eval ${$w->[0]};AErr($addon,$@)if $@;};}
	
	if ($ColCount % 2) { # alternating colours
		print q~<td class="yellowbg">&nbsp;</td>~;
	} 
	else {
		print q~<td class="lightgbg">&nbsp;</td>~;
	}
	
	print '</tr>';
	
	# OK, the table's up. Now set some variables...
	
	if ($in{'startitem'}) {
		$StartFileCount = $in{'startitem'};
	}
	if ($in{'delete'}) {
		$StartFileCount = $in{'originalcount'};
	}
	
	if ($in{'search'}) {
		$Searching++;
		$Filter = 'search';
		$in{'search'} =~ s/(\$|\@)/\\$1/g;
		my @searchterms = SpaceSplit($in{'search'});
		if (@searchterms == 1) {
			$FilterData{'regex'} = quotemeta($searchterms[0]);
		}
		else {
			@searchterms = map { quotemeta($_) } @searchterms;
			$FilterData{'regex'} = '(?:' . join('|', @searchterms) . ')';
		}
		if ($in{'searchfield'} && ($fieldDB{$in{'searchfield'}} || $in{'searchfield'} eq 'User')) {
			$FilterData{'field'} = $in{'searchfield'};
		}
		else {
			$FilterData{'field'} = 'Text';
			# HOOK: ModifyNews_NewSearchField_2
			if($Addons{'ModifyNews_NewSearchField_2'}){my $w;foreach $w (@{$Addons{'ModifyNews_NewSearchField_2'}}){my $addon=$w->[2];eval ${$w->[0]};AErr($addon,$@)if $@;};}
		}
	}
	elsif ($in{'jumpmonth'}) {
		$Filter = 'jump';
		$FilterData{'starttime'} = timelocal(59,59,23,$in{'jumpday'},($in{'jumpmonth'} - 1), ($in{'jumpyear'} - 1900));
	}

	# HOOK: ModifyNews_PreLoop
	if($Addons{'ModifyNews_PreLoop'}){my $w;foreach $w (@{$Addons{'ModifyNews_PreLoop'}}){my $addon=$w->[2];eval ${$w->[0]};AErr($addon,$@)if $@;};}
	
	my $fh = CRopen("$CConfig{'htmlfile_path'}/newsdat.txt");

	my $stoppermnow = 0;

	NDLOOP: while (<$fh>) {

		$stoppermnow = 0;

		# Loop through news items
		if ((!$Searching && $ItemCount >= $MaxItems) || $ItemCount >= $MaxSrchItems) {
			# We've reached out item limit
			$MoreItems++;
			last NDLOOP;
		}

		$FileCount++;
		if ($StartFileCount >= $FileCount) {
			# Keep on going to reach our start point.
			next NDLOOP;
		}

		chomp $_;
		SplitDataFile($_);

		if ($up == 1 && $User ne $CurrentUser) {
			# User doesn't have permission for this item
			next NDLOOP;
		}

		# Addons: please only hook in here if you're restricting access to items based
		# on permissions. If you're filtering/searching, your hook is later.
		# HOOK: ModifyNews_Permissions
		if($Addons{'ModifyNews_Permissions'}){my $w;foreach $w (@{$Addons{'ModifyNews_Permissions'}}){my $addon=$w->[2];eval ${$w->[0]};AErr($addon,$@)if $@;};}

		# BUG FIX: NDLOOP label not accessible from outside crcore.pl
		if ($stoppermnow == 1){
		next NDLOOP;
		}

		if ($Filter) {
			# Some kind of filter/search
			if ($Filter eq 'search') {
				unless (${$FilterData{'field'}} =~ /$FilterData{'regex'}/io) {
					next NDLOOP;
				}
			}
			elsif ($Filter eq 'jump') {
				unless ($newstime <= $FilterData{'starttime'}) {
					next NDLOOP;
				}
				else {
					$StartFileCount = $FileCount;
					$Filter = '';
				}
			}
			# HOOK: ModifyNews_Filter
			if($Addons{'ModifyNews_Filter'}){my $w;foreach $w (@{$Addons{'ModifyNews_Filter'}}){my $addon=$w->[2];eval ${$w->[0]};AErr($addon,$@)if $@;};}
		}

		# BUG FIX: NDLOOP label not accessible from outside crcore.pl
		if ($stoppermnow == 1){
		next NDLOOP;
		}

		# OK, we can edit the news item.
		print qq~<tr><td class="lightgbg"><div align="center"><input type="checkbox" value="del" name="del-$newsid"></div></td>
		<td class="navlink"><div align="center">~;

		if (length($Subject) > 50) {
			print SnipText($Subject, 45);
		}
		elsif (length($Subject) == 0) {
			print SnipText($Text, 45);
		}
		else {
			print $Subject;
		}
		print q~</div></td><td class="lightgbg"><div class="footnote" align="center">~ . GetTheDate_Internal($newstime) . '</div></td>';
		$ColCount = 1;

		# Addons here, please increment $ColCount.
		# HOOK: ModifyNews_NewColumn_2
		if($Addons{'ModifyNews_NewColumn_2'}){my $w;foreach $w (@{$Addons{'ModifyNews_NewColumn_2'}}){my $addon=$w->[2];eval ${$w->[0]};AErr($addon,$@)if $@;};}

		if ($ColCount % 2) {
			print q~<td class="navlink"><div align="center">~;
		}
		else {
			print q~<td class="lightgbg"><div align="center" class="footnote">~;
		}
		
		{
			my $WindowTarget = '_blank';
			if ($CConfig{'ModifyEditLink'} == 1){
			$WindowTarget = '_top';			
			}
			print '[', PageLink({'action' => 'modify-edit', 'nid' => $newsid}, "target = $WindowTarget"),"$Messages{'Edit'}</a>]</div></td></tr>";
		}
		
		$ItemCount++;
	}
	close($fh);
	# Done looping. Print finishing HTML.
	
	print qq~</table><br><input type="submit" name="delete" value="$Messages{'Modify_DelButton'}"> &nbsp;
		<input type="hidden" name="startitem" value="$FileCount"><input type="hidden" name="originalcount" value="$StartFileCount">~;
	print qq~<input type="submit" value="$Messages{'Modify_Next'}">~ if $MoreItems;
	print '</form>';
	# HOOK: ModifyNews_PageEnd
	if($Addons{'ModifyNews_PageEnd'}){my $w;foreach $w (@{$Addons{'ModifyNews_PageEnd'}}){my $addon=$w->[2];eval ${$w->[0]};AErr($addon,$@)if $@;};}
	unless ($ItemCount) {
		print "<h3>$Messages{'Modify_None'}</h3>";
	}
	print '</div>';
	CRHTMLFoot();
}
END_SUB

'ModifyNews_Delete' => <<'END_SUB',
sub ModifyNews_Delete {
	CRcough("The guest account can't access this function.") if $CurrentUser =~ /^guest/ && $up == 1;
	my ($fh, $fh2) = EditNewsdat_Start();
	
	# HOOK: ModifyNews_Delete_PreLoop
	if($Addons{'ModifyNews_Delete_PreLoop'}){my $w;foreach $w (@{$Addons{'ModifyNews_Delete_PreLoop'}}){my $addon=$w->[2];eval ${$w->[0]};AErr($addon,$@)if $@;};}
	
	NDLOOP: while (<$fh>) {
		chomp($_);
		SplitDataFile($_);
		if ($in{"del-$newsid"} eq 'del') {
			if ($up > 1 || $User eq $CurrentUser) {
				# HOOK: ModifyNews_Delete_1
				if($Addons{'ModifyNews_Delete_1'}){my $w;foreach $w (@{$Addons{'ModifyNews_Delete_1'}}){my $addon=$w->[2];eval ${$w->[0]};AErr($addon,$@)if $@;};}
				# Delete!
				$CConfig{'LastBuildOverride'} = ($newstime - 1) if ($newstime - 1) < $CConfig{'LastBuildOverride'};
				next NDLOOP;
			}
		}
		print {$fh2} $_ . "\n";
	}
	
	close($fh);
	close($fh2);
	
	
	EditNewsdat_Finish();
	
	if ($CConfig{'AutoBuild_Modify'}) {
		BuildNews();
	}	
	
}
END_SUB

'ModifyNews_Edit' => <<'END_SUB',
sub ModifyNews_Edit {
	CRcough("The guest account can't access this function.") if $CurrentUser =~ /^guest/ && $up == 1;
	NeedCFG();
	CRHTMLHead('Edit News Item');
	
	my $fh = CRopen("$CConfig{'htmlfile_path'}/newsdat.txt");
	
	# HOOK: ModifyNews_Edit_PreLoop
	if($Addons{'ModifyNews_Edit_PreLoop'}){my $w;foreach $w (@{$Addons{'ModifyNews_Edit_PreLoop'}}){my $addon=$w->[2];eval ${$w->[0]};AErr($addon,$@)if $@;};}
	
	NDLOOP: while (<$fh>) {
		chomp($_);
		SplitDataFile($_);
		if ($in{'nid'} eq $newsid) {
			print StartForm({'action' => 'modify-editsave', 'nid' => $newsid}, 'name="submitnews"');
			print StartFieldsTable();
			print FieldsRow($Messages{'Date'},GetTheDate_Internal($newstime));
			print FieldsRow($Messages{'User'}, $User);
			# HOOK: ModifyNews_Edit_TopRow
			if($Addons{'ModifyNews_Edit_TopRow'}){my $w;foreach $w (@{$Addons{'ModifyNews_Edit_TopRow'}}){my $addon=$w->[2];eval ${$w->[0]};AErr($addon,$@)if $@;};}
			my ($fn, $fcode);
			foreach $fn (@fieldDB) {
				# Go through the list of fields.
				if ($up > $fieldDB{$fn}->{'ModifyPerm'}){
					
					# Current user is allowed to submit things into this field.

					if ($fieldDB{$fn}->{'DisableHTML'}) {
						$$fn = unHTMLescape($$fn);
					}

					if ($fieldDB{$fn}->{'ParseLinks'}){
						$$fn =~ s/<a href="(.*?)".*?>(http:\/\/|ftp:\/\/|https:\/\/).*?<\/a>/$1/gi;
					}

					if ($fieldDB{$fn}->{'FieldType'} == 1){
						$fcode = qq~<input type="text" name="$fn" size="$fieldDB{$fn}->{'FieldSize'}" value="~
						. HTMLescape($$fn) . '"' . 
						($fieldDB{$fn}->{'MaxLength'} ? qq~ maxlength="$fieldDB{$fn}->{'MaxLength'}">~ : '>');
						
					}
					
					if ($fieldDB{$fn}->{'FieldType'} == 2) {
						if ($fieldDB{$fn}->{'Newlines'}) {
						$$fn =~ s/<br[\s\/]*>/\n/g;
						}
						$fcode = qq~<textarea name="$fn" rows="$fieldDB{$fn}->{'FieldRows'}" cols="$fieldDB{$fn}->{'FieldCols'}" wrap="VIRTUAL">~ . HTMLescape($$fn) . '</textarea>';
					}

					if ($fieldDB{$fn}->{'FieldType'} == 3) {
						$fcode = qq~<select name="$fn" size="$fieldDB{$fn}->{'FieldSize'}">~ . join('', map { '<option ' . ($_ =~ /^\[(.+)\]/ ? (HTMLescape($$fn) eq HTMLescape($1) ? selected : '') . '>' . HTMLescape($1) : (HTMLescape($$fn) eq HTMLescape($_) ? selected : '') . '>' . HTMLescape($_)) . '</option>' } split(/\|/, $fieldDB{$fn}->{'Options'})) . '</select>';
					}

					if ($fieldDB{$fn}->{'FieldType'} == 4) {
						$fcode = qq~<input type="checkbox" name="$fn" value="~ . HTMLescape($fieldDB{$fn}->{'OnValue'}) . ($$fn eq $fieldDB{$fn}->{'OnValue'} ? '" checked>' : '">');
					}

					if ($fieldDB{$fn}->{'FieldType'} == 5) {
						$fcode = join('', map { qq~<input name="$fn" type="radio" ~ . ($_ =~ /^\[(.+)\]/ ? (HTMLescape($$fn) eq HTMLescape($1) ? checked : '') . ' value="' . HTMLescape($1) . '">' . HTMLescape($1) : (HTMLescape($$fn) eq HTMLescape($_) ? checked : '') . ' value="' . HTMLescape($_) . '">' . HTMLescape($_)) . $fieldDB{$fn}->{'SplitOptions'} } split(/\|/, $fieldDB{$fn}->{'Options'}));
					}
					
					# HOOK: ModifyNews_Edit_Fields
					if($Addons{'ModifyNews_Edit_Fields'}){my $w;foreach $w (@{$Addons{'ModifyNews_Edit_Fields'}}){my $addon=$w->[2];eval ${$w->[0]};AErr($addon,$@)if $@;};}
					print FieldsRow($fieldDB{$fn}->{'DisplayName'}, $fcode);
				}
			}
			# HOOK: ModifyNews_Edit_BottomRow
			if($Addons{'ModifyNews_Edit_BottomRow'}){my $w;foreach $w (@{$Addons{'ModifyNews_Edit_BottomRow'}}){my $addon=$w->[2];eval ${$w->[0]};AErr($addon,$@)if $@;};}
			print '</table>';
			# HOOK: ModifyNews_Edit_AfterTable
			if($Addons{'ModifyNews_Edit_AfterTable'}){my $w;foreach $w (@{$Addons{'ModifyNews_Edit_AfterTable'}}){my $addon=$w->[2];eval ${$w->[0]};AErr($addon,$@)if $@;};}
			print qq~<br><table align="center" width="80%" border="0">
				<tr><td class="description"><div align="center"><input type="submit" value="$Messages{'Submit'}">
				<input type="reset" value="$Messages{'Reset'}">~;
			# HOOK: ModifyNews_Edit_Submit
			if($Addons{'ModifyNews_Edit_Submit'}){my $w;foreach $w (@{$Addons{'ModifyNews_Edit_Submit'}}){my $addon=$w->[2];eval ${$w->[0]};AErr($addon,$@)if $@;};}
			print '</div></td></tr></table></form>';
			# HOOK: ModifyNews_Edit_AfterForm
			if($Addons{'ModifyNews_Edit_AfterForm'}){my $w;foreach $w (@{$Addons{'ModifyNews_Edit_AfterForm'}}){my $addon=$w->[2];eval ${$w->[0]};AErr($addon,$@)if $@;};}
			CRHTMLFoot();			
			last NDLOOP;
		}
	}
	
	close($fh);	
	
}
END_SUB

'ModifyNews_EditSave' => <<'END_SUB',
sub ModifyNews_EditSave {
	CRcough("The guest account can't access this function.") if $CurrentUser =~ /^guest/ && $up == 1;
	NeedCFG();
	my $nid = $in{'nid'};
	CRcough("No news ID specified in Modify News.") unless $nid;
	
	my ($fh, $fh2) = EditNewsdat_Start();
		
	# HOOK: ModifyNews_EditSave_PreLoop
	if($Addons{'ModifyNews_EditSave_PreLoop'}){my $w;foreach $w (@{$Addons{'ModifyNews_EditSave_PreLoop'}}){my $addon=$w->[2];eval ${$w->[0]};AErr($addon,$@)if $@;};}
	
	NDLOOP: while (<$fh>) {
		# Loop through items.
		chomp $_;
		SplitDataFile($_);
		if ($nid eq $newsid) {
			# It's our item.
			if ($User eq $CurrentUser || $up > 1) {
				# HOOK: ModifyNews_EditSave_Permissions
				if($Addons{'ModifyNews_EditSave_Permissions'}){my $w;foreach $w (@{$Addons{'ModifyNews_EditSave_Permissions'}}){my $addon=$w->[2];eval ${$w->[0]};AErr($addon,$@)if $@;};}
				# We're allowed to edit the item.
				my $fn;
				foreach $fn (@fieldDB) {

				# Translate OS-specific newline chars into Perl's logical one
				#$in{$fn} =~ s/\015?\012/\n/gi;

					if ($up > $fieldDB{$fn}->{'ModifyPerm'}) {
						# We're allowed to edit this field.

						if (exists $in{$fn} || $fieldDB{$fn}->{'FieldType'} == 4) {
							if ($fieldDB{$fn}->{'DisableHTML'}) {
								# How many ifs is that?
								$in{$fn} = HTMLescape($in{$fn});
							}
							if ($fieldDB{$fn}->{'ParseLinks'}){
							$in{$fn} =~ s/([\s\(]|\A|<br>)(http:\/\/|ftp:\/\/|https:\/\/)([^\s\)"<>,]+)/$1<a href="$2$3">$2$3<\/a>/gi;
							}

							$$fn = $in{$fn};
							$$fn =~ s/\r//g;
							$$fn =~ s/``x/` ` x/g;

							unless (exists $fieldDB{$fn}->{'StripSSI'}){
							$fieldDB{$fn}->{'StripSSI'} = 1;
							}

							if ($fieldDB{$fn}->{'StripSSI'} == 1){
							StripSSI(\$$fn); # we like hard references
							}
							
							# HOOK: ModifyNews_EditSave_2
							if($Addons{'ModifyNews_EditSave_2'}){my $w;foreach $w (@{$Addons{'ModifyNews_EditSave_2'}}){my $addon=$w->[2];eval ${$w->[0]};AErr($addon,$@)if $@;};}
							if ($fieldDB{$fn}->{'Newlines'}) {
								if ($CConfig{'XHTMLbr'}) {
									$$fn =~ s/\n/<br \/>/g;
								}
								else {
									$$fn =~ s/\n/<br>/g;
								}
							}
							else {
								$$fn =~ s/\n//g;
							}
						}
					}
				}
				# HOOK: ModifyNews_EditSave_3
				if($Addons{'ModifyNews_EditSave_3'}){my $w;foreach $w (@{$Addons{'ModifyNews_EditSave_3'}}){my $addon=$w->[2];eval ${$w->[0]};AErr($addon,$@)if $@;};}
				my $newsline = JoinDataFile();
				print $fh2 $newsline, "\n";
				$CConfig{'LastBuildOverride'} = ($newstime - 1) if ($newstime - 1) < $CConfig{'LastBuildOverride'};
				# Save the changed item, and remember that news item's time so that it will be rebuild without needing a full rebuild.
			}
			else {
				CRcough("You don't have permission to edit this item.");
			}
		}
		else {
			print $fh2 $_, "\n";
		}
	}
	
	close($fh);
	close($fh2);

	EditNewsdat_Finish();
	
	# HOOK: ModifyNews_EditSave_Done
	if($Addons{'ModifyNews_EditSave_Done'}){my $w;foreach $w (@{$Addons{'ModifyNews_EditSave_Done'}}){my $addon=$w->[2];eval ${$w->[0]};AErr($addon,$@)if $@;};}
	
	if ($CConfig{'AutoBuild_Modify'}) {
		BuildNews();
	}
	
	if ($CConfig{'ModifyEditLink'} == 1){
		ModifyNews();
	}
	else {
		SimpleConfirmationPage($Messages{'ModifySave_Title'}, $Messages{'ModifySave_Message'} . ' ' . ($CConfig{'AutoBuild_Modify'} ? $Messages{'ModifySave_Message_Auto'} : $Messages{'ModifySave_Message_NoAuto'}) ,0, ($CConfig{'ModifyEditLink'} == 1 ? 0:1));
	}
}
END_SUB

#######
# USERS & LOGIN
#######


# Prints the login page.
'LoginPage' => <<'END_SUB',
sub LoginPage {
	unless ($HeaderPrinted) {
		print header();
	}
	NeedCFG();

	CRHTMLHead($LoginMessages{'Title'});

	# HOOK: LoginPage_1
	#if($Addons{'LoginPage_1'}){my $w;foreach $w (@{$Addons{'LoginPage_1'}}){my $addon=$w->[2];eval ${$w->[0]};AErr($addon,$@)if $@;};}

	print qq~
	<form action="$scripturl" method="post"><br>
	<input type="hidden" name="action" value="login">~;
	if ($in{'action'} && $in{'action'} ne 'login') {
		my ($key, $value);
		while (($key, $value) = each %in) {
			print qq~<input type="hidden" name="$key" value="$value">
			~ unless $key eq 'session' || $key eq 'x' || $key eq 'action';
		}
		print qq~<input type="hidden" name="pausedaction" value="$in{'action'}">~;
	}
	print qq~
	<table width="80%" align="center" cellpadding="2" cellspacing="2" border="0">
	<tr><td class="fieldtitle"><div align="right">$LoginMessages{'Username'}</div></td><td>
	<input type="text" name="uname"></td></tr>
	<tr><td class="fieldtitle"><div align="right">$LoginMessages{'Password'}</div></td><td>
	<input type="password" name="pword"></td></tr>
	<tr><td class="fieldtitle"><div align="right">$LoginMessages{'Remember'}</div></td><td>
	<input type="checkbox" name="rememberpass" value="1"></td></tr>~;


	# HOOK: LoginPage_2
	#if($Addons{'LoginPage_2'}){my $w;foreach $w (@{$Addons{'LoginPage_2'}}){my $addon=$w->[2];eval ${$w->[0]};AErr($addon,$@)if $@;};}

	print qq~</table>
	<br>
	<table width="80%" align="center" border="0" class="yellowbg"><tr><td><div align="center">
	<input type="submit" name=submit value="$LoginMessages{'Login'}">
	</div></td></tr></table></form>
	~;

	# HOOK: LoginPage_3
	#if($Addons{'LoginPage_3'}){my $w;foreach $w (@{$Addons{'LoginPage_3'}}){my $addon=$w->[2];eval ${$w->[0]};AErr($addon,$@)if $@;};}
	
	if ($CConfig{'firsttime'} eq "yes") {
		print "<br><br>To set up Coranto, enter <b>setup</b> as your username and leave the password blank.";
	}
	CRHTMLFoot_NoNav();
	exit;	
}
END_SUB


# Edit a user's profile.
'EditUserInfo' => <<'END_SUB',
sub EditUserInfo {
	CRcough("The guest account can't access this function.") if $CurrentUser =~ /^guest/ && $up == 1;
	CRHTMLHead($Messages{'Section_UserInfo'});
	ReadUserDBInfo();
	my ($username, $key, $value);
	if ($in{'username'} && $up == 3) {
		$username = $in{'username'};
		CRcough("User $username does not exist.") unless $userdata{$username};
	}
	else {
		$username = $CurrentUser;
		
	}
	print StartForm( {'action' => 'edituserinfosave', 'username' => $username} );
	print MidHeading($Messages{'UserInfo_PassChange'});
	print MidParagraph (($username ne $CurrentUser) ? "Leave the password fields blank if you do not want to change the password." : $Messages{'UserInfo_PassChange_Message'});
	print StartFieldsTable();
	if ($username eq $CurrentUser) {
		print FieldsRow($Messages{'UserInfo_Pass_1'}, '<input type="password" name="currentpass" size="30" maxlength="30">');
	}
	print FieldsRow($Messages{'UserInfo_Pass_2'}, '<input type="password" name="newpass" size="30" maxlength="30">');
	print FieldsRow($Messages{'UserInfo_Pass_3'}, '<input type="password" name="newpassverify" size="30" maxlength="30">');
	print '</table><br>';

	if (keys %userDB || $userdata{$username}->{'UserLevel'} != 3) {
		print MidHeading($Messages{'UserInfo_Profile'});
		print StartFieldsTable();
		print FieldsRow('Language', GetLangSelect($userdata{$username}->{'Language'}));

		foreach $i (sort keys %userDB) {
			unless ($userDB{$i}->{'Permissions'} && $up != 3) {
				my $curval = $userdata{$username}->{$i};
				unless ($userDB{$i}->{'EnableHTML'}) {
					$curval = unHTMLescape($curval);
				}
				$curval = HTMLescape($curval);
				if ($userDB{$i}->{'FieldType'}) {
					$curval =~ s/\Q&lt;br&gt;\E/\n/g;
					print FieldsRow($i, qq~<textarea name="$i" rows="5" cols="60" wrap="VIRTUAL">$curval</textarea>~);
				}
				else {
					print FieldsRow($i, qq~<input type="text" name="$i" value="$curval" size="45">~);
				}
			}
		}
		# HOOK: EditUserInfo
		if($Addons{'EditUserInfo'}){my $w;foreach $w (@{$Addons{'EditUserInfo'}}){my $addon=$w->[2];eval ${$w->[0]};AErr($addon,$@)if $@;};}
		print '</table><br>';
	}

	# HOOK: EditUserInfo_Done
	if($Addons{'EditUserInfo_Done'}){my $w;foreach $w (@{$Addons{'EditUserInfo_Done'}}){my $addon=$w->[2];eval ${$w->[0]};AErr($addon,$@)if $@;};}

	print SubmitButton($Messages{'Save'});
	print '</form>';
	CRHTMLFoot();
}
END_SUB

# Save changes to edited profile.
'EditUserInfoSave' => <<'END_SUB',
sub EditUserInfoSave {
	CRcough("The guest account can't access this function.") if $CurrentUser =~ /^guest/ && $up == 1;
	ReadUserDBInfo();
	my $username = $in{'username'};
	CRcough("Please enter a username.") unless $username;
	CRcough("You can't edit user $username.") unless $username eq $CurrentUser || $up == 3;
	CRcough('You must enter a valid Email address.') unless length $in{'Email'} > 2;
	if ($in{'newpass'}) {
		NeedFile('crcrypt.pl');
		my $crcrypt = new CRcrypt;		
		unless ($up == 3 && $username ne $CurrentUser) {
			my $cpass;
			$cpass = $crcrypt->GetHash($in{'currentpass'} . $username);
			CRcough($Messages{'UserInfo_Error_1'}) unless $cpass eq $userdata{$username}->{'CPassword'};
		}
		CRcough($Messages{'UserInfo_Error_2'}) unless $in{'newpass'} eq $in{'newpassverify'};
		CRcough($Messages{'UserInfo_Error_3'}) unless length($in{'newpass'}) > 4;
		
		$userdata{$username}->{'CPassword'} = $crcrypt->GetHash($in{'newpass'} . $username);
	}
	if ($in{'Language'}) {
		$in{'Language'} =~ s/[^\w\d]//g;
		$userdata{$username}->{'Language'} = $in{'Language'};
	}
	foreach $i (keys %userDB) {
		unless ($userDB{$i}->{'Permissions'} && $up != 3) {
			if (exists $in{$i}) {
				if ($userDB{$i}->{'EnableHTML'}) {
					StripSSI(\$in{$i});
					$in{$i} =~ s/\n/<br>/g;
				}
				else {
					$in{$i} = HTMLescape($in{$i});
				}
				$in{$i} =~ s/[\n\r]//g;
				# HOOK: EditUserInfoSave_1
				if($Addons{'EditUserInfoSave_1'}){my $w;foreach $w (@{$Addons{'EditUserInfoSave_1'}}){my $addon=$w->[2];eval ${$w->[0]};AErr($addon,$@)if $@;};}
				if ($userdata{$username}->{$i} ne $in{$i}) {
					$CConfig{'ForceFullBuild'} = 1;
				}
				$userdata{$username}->{$i} = $in{$i};
			}
		}
	}
	# HOOK: EditUserInfoSave_2
	if($Addons{'EditUserInfoSave_2'}){my $w;foreach $w (@{$Addons{'EditUserInfoSave_2'}}){my $addon=$w->[2];eval ${$w->[0]};AErr($addon,$@)if $@;};}
	WriteUserInfo();
	if ($up == 3 && $username ne $CurrentUser) {
		NeedFile('cradmin.pl');
		EditUsers();
	}
	else {
		SimpleConfirmationPage($Messages{'UserInfoSave_Title'}, $Messages{'UserInfoSave_Message'});
	}
}
END_SUB

# Gets a Select box of installed languages
'GetLangSelect' => <<'END_SUB',
sub GetLangSelect {
	my $lang = shift;
	my @languages = (['English', 'crlang.pl']);
	opendir(ADMINDIR, $CConfig{'admin_path'});
	my @langfiles = readdir(ADMINDIR);
	closedir(ADMINDIR);
	@langfiles = grep(/crl_[\w\d]+\.pl/, @langfiles);
	@langfiles = map {/crl_([\w\d]+)\.pl/; $1;} @langfiles;
	my $lf;
	foreach $lf (@langfiles) {
		my $fh = CRopen("$CConfig{'admin_path'}/crl_$lf.pl");
		my $line1 = <$fh>; my $line2 = <$fh>;
		close($fh);
		if ($line1 =~ /#! CRLANGUAGE 1/) {
			if ($line2 =~ /#! NAME (.+)/) {
				push(@languages, [$1, $lf]);
			}
		}
	}
	my $sbox = '<select name="Language">';
	foreach $lf (@languages) {
		$sbox .= qq~<option value="$lf->[1]"~ . 
		($lang eq $lf->[1] ? ' selected' : '') . 
		qq~>$lf->[0]</option>~;
	}
	return "$sbox</select>";
}
END_SUB
		

#######
# UPGRADING
#######

# UpgradeHandler: Checks if running an upgrade procedure is necessary.
'UpgradeHandler' => => <<'END_SUB',
sub UpgradeHandler {
	if ($CConfig{'currentbuild'} <= 30) {
		$CConfig{'PublicOrPrivate'} = 1;
		$CConfig{'UrgentNotification'} = 1;
		$CConfig{'VersionChecking'} = 1;
	}
	$CConfig{'currentversion'} = $crcgiVer;
	$CConfig{'currentrc'} = $crcgiRC;
	$CConfig{'currentbuild'} = $crcgiBuild;
}
END_SUB


#######
# MISCELLANEOUS
#######


# Handles minor errors which don't require diagnostic information.
'CRcough' => <<'END_SUB',
sub CRcough {
	my $msg = shift;
	my $html = shift;
	unless ($html) {
		$msg =~ s/</&lt;/g;
		$msg =~ s/>/&gt;/g;
		$msg =~ s/"/&quot;/g;
	}
	print header();
	SimpleConfirmationPage('Error', "<b>Error:</b> $msg");
	exit;
}
END_SUB

# Triggers a full error message.
'DiePlease' => <<'END_SUB',
sub DiePlease {
	CRdie("A full error message was requested.");
}
END_SUB

'WriteProfileInfo' => <<'END_SUB',
sub WriteProfileInfo {
	my $i;
	foreach $i (keys %newsprofiles) {
		my ($key, $value, @nprof);
		while (($key, $value) = each %{$newsprofiles{$i}}) {
			unless ($key eq 'cats') {
				push(@nprof, "$key!x!$value");
			}
			else {
				push(@nprof, join('!x!', $key, join('~x~', @$value)));
			}
			# HOOK: WriteProfileInfo
			if($Addons{'WriteProfileInfo'}){my $w;foreach $w (@{$Addons{'WriteProfileInfo'}}){my $addon=$w->[2];eval ${$w->[0]};AErr($addon,$@)if $@;};}
		}
		$CConfig{"Profile-$i"} = join('|x|', @nprof);		
	}
	$CConfig{'NewsProfiles'} = join('|x|', keys %newsprofiles);
}
END_SUB

# SetCookies: Prints a Set-Cookie line for an HTTP header.
'SetCookies' => <<'END_SUB',
sub SetCookies {
	@Cookie_Encode_Chars = ('\%', '\+', '\;', '\,', '\=', '\&', '\:\:', '\s');
	
	%Cookie_Encode_Chars = ('\%',   '%25',
	                        '\+',   '%2B',
	                        '\;',   '%3B',
	                        '\,',   '%2C',
	                        '\=',   '%3D',
	                        '\&',   '%26',
	                        '\:\:', '%3A%3A',
	                        '\s',   '+');	
	my ($cookie, $value, $explength) = @_;
	foreach $char (@Cookie_Encode_Chars) {
		$cookie =~ s/$char/$Cookie_Encode_Chars{$char}/g;
		$value =~ s/$char/$Cookie_Encode_Chars{$char}/g;
	}

	print 'Set-Cookie: ' . $cookie . '=' . $value . ';';
	if ($explength) {
		my $exptime = time + $cookieExpLength;
		$CookieExpires = DoGMTTime($exptime);
		print ' expires=' . $CookieExpires . ';';
	}
	print "\n";
}
END_SUB

'ClearCookies' => <<'END_SUB',
sub ClearCookies {
	print "Content-type: text/html\n";
	print "Set-Cookie: cruser=x; expires=Thu, 03-Feb-2000 00:00:00 GMT;\n";
	print "Set-Cookie: crsesskey=x; expires=Thu, 03-Feb-2000 00:00:00 GMT;\n";
	print "Set-Cookie: crpermkey=x; expires=Thu, 03-Feb-2000 00:00:00 GMT;\n";
	print "Set-Cookie: crpass=x; expires=Thu, 03-Feb-2000 00:00:00 GMT;\n\n";
	$HeaderPrinted = 1;
}
END_SUB

'EditNewsdat_Start' => <<'END_SUB',
sub EditNewsdat_Start {
	if (-e "$CConfig{'htmlfile_path'}/ndtmp2.txt") {
		unlink "$CConfig{'htmlfile_path'}/ndtmp2.txt" || CRdie("Could not delete $CConfig{'htmlfile_path'}/ndtmp2.txt");
	}
	
	my $fh = CRopen("$CConfig{'htmlfile_path'}/newsdat.txt");
	my $fh2 = CRopen(">$CConfig{'htmlfile_path'}/ndtmp1.txt");
	
	# HOOK: EditNewsdat_Start
	if($Addons{'EditNewsdat_Start'}){my $w;foreach $w (@{$Addons{'EditNewsdat_Start'}}){my $addon=$w->[2];eval ${$w->[0]};AErr($addon,$@)if $@;};}
	
	return ($fh, $fh2);
}

sub EditNewsdat_Finish {
	rename("$CConfig{'htmlfile_path'}/newsdat.txt", "$CConfig{'htmlfile_path'}/ndtmp2.txt") || CRdie("Could not rename $CConfig{'htmlfile_path'}/newsdat.txt to $CConfig{'htmlfile_path'}/ndtmp2.txt");
	rename("$CConfig{'htmlfile_path'}/ndtmp1.txt", "$CConfig{'htmlfile_path'}/newsdat.txt") || CRdie("Could not rename $CConfig{'htmlfile_path'}/ndtmp1.txt to $CConfig{'htmlfile_path'}/newsdat.txt");
	# HOOK: EditNewsdat_Finish
	if($Addons{'EditNewsdat_Finish'}){my $w;foreach $w (@{$Addons{'EditNewsdat_Finish'}}){my $addon=$w->[2];eval ${$w->[0]};AErr($addon,$@)if $@;};}
	unlink "$CConfig{'htmlfile_path'}/ndtmp2.txt" || CRdie("Could not delete $CConfig{'htmlfile_path'}/ndtmp2.txt");
}
END_SUB

'Debug_ShowConfig' => <<'END_SUB',
sub Debug_ShowConfig {
	print header();
	
	$CConfig{'showconfig'} = 1 unless $CConfig{'showconfig'};
	
	if ($CConfig{'showconfig'} == 1) {
		ReadUserDBInfo();
		my $thetime = time;
		my $ltime = GetTheDate_Internal($thetime);
		print "<html><body><b>Time</b>: $thetime $ltime<br>\n<b>Version</b>: $crcgiVer<br>\n<b>Build</b>: $crcgiBuild<br>\n";
		my @OKSettings = qw(admin_path htmlfile_path archive_path ArchiveDateFormat_Monthly ArchiveDateFormat_Weekly ArchiveDateFormat_Daily DateFormat InternalDateFormat
			NewsCategories Standard_Time_Zone TimeOffset SiteTitle AutoLinkURL AutoBuild_Submit AutoBuild_Modify Modify_ItemsPerPage LastBuildTime AddonsLoaded
			ArcHtmlExt ForceFullBuild Backup_LastBackup);
		foreach (sort @OKSettings) {
			print "<b>$_</b>: " . HTMLescape($CConfig{$_}) . "<br>\n" if defined $CConfig{$_};
		}
		print "<br>\n";
		PrettyMLHash('Profiles', \%newsprofiles);
		PrettyMLHash('userDB', \%userDB);
		print "</body></html>";
	}
	else {
		print "The debugging features have been disabled.";
	}
}

sub PrettyMLHash {
	my ($name, $hr) = @_;
	print "<b>$name:</b>";
	print '<ul>';
	foreach $i (sort keys %$hr) {
		print "<li>$i</li><ul><li>";
		my @arr = map { 
				unless (/^x_/i) {
					if (ref($hr->{$i}->{$_})) { 
						"<b>$_</b>: " . join(', ', @{$hr->{$i}->{$_}}) . '<br>';
					} 
					else { 
						"<b>$_</b>: " . HTMLescape($hr->{$i}->{$_}) . '<br>'; 					
					}
				}
			} sort keys %{$hr->{$i}};
			
		print join('</li><li>', @arr);
		print '</li></ul>';
	}
	print '</ul>';
}
END_SUB

'Debug_Newsdat' => <<'END_SUB',
sub Debug_Newsdat {
	print header();
	
	$CConfig{'shownewsdat'} = 0 unless $CConfig{'shownewsdat'};
	
	if ($CConfig{'shownewsdat'} == 1) {
		open(ND, "$CConfig{'htmlfile_path'}/newsdat.txt");
		while (<ND>) {
			print "$_<br>";
		}
		close(ND);
	}
	else {
		print "The debugging features have been disabled.";
	}
}
END_SUB

); # That's it for %Subs, at least in this file.

1;

