
sub FirstTimePage {
	print &header;
	NeedFile('crlang.pl');
	CRHTMLHead('Coranto Setup');
	my $dir = GetDirInfo();
	print
		MidHeading('Welcome to Coranto'),
		StartForm({'action' => 'setup', 'setupstep' => 1}, 'name="setup"'),
	
		MidParagraph(q~Congratulations: one of the most problematic parts of setup, getting Coranto to run as a CGI script, is complete.
			Now, you need to give Coranto some information -- the paths where its files are stored, the name you'd like to log in with,
			and various other important details. On this and the next couple of pages, Coranto will ask you for this information.~, 1),
	
		MidHeading('Licensing'),
		MidParagraph(q~This is the download version of Coranto. Although it is and will continue to be available for free download,
			in order to prevent confusion and make support easier, we ask that you do not distribute copies of it yourself.<p>
			The primary license requirement for this version is that you include a link to the Coranto homepage on your news page(s).
			Specifically, every page which contains full news items must include a link to the Coranto site (http://www.amphibianweb.com/),
			preferably via the phrase Powered by Coranto. Pages which contain only headlines linking to full news items are exempt. Since
			the official site is down at this time, as an option you can choose to remove the link text, or to link to the Unofficial
			site, on a per profile basis.<p>
			The Display Link option, on by default, makes Coranto include the link automatically. If you prefer, you can turn this option
			off and include the link yourself, provided that it remains in a visible location and is not significantly smaller than the main
			text on the page.
			<center><select name="license" onchange="safety(document.setup)"><option value="" selected>Please select an option</option>
			<option value="1">I agree -- I will comply with the Coranto license</option><option value="0">I disagree</option></select></center>~, 1),
	
		MidHeading('Privacy'),
		MidParagraph(q~Coranto is designed to allow for a good degree of privacy for its users, and two privacy levels are available to
			cater for different users' needs.  No personal information about users is logged without your permission, and we do not share
			any information with third-parties or use it for junk mail.<p>
			The standard privacy setting, 'Public', will suit most users. At your option, you can choose to disable the version checking
			image (to speed page loading and/or to prevent the URL to your coranto.cgi appearing as a referrer in our server logs). You
			can also choose whether or not you would like to share the name and email address of your SuperAdmin user with us, solely to allow
			us to notify you of any major bugs or security holes discovered in the version of the script you are running.  You will be passed
			briefly to our server during the setup process to allow you to sign up for our forums and update mailing list if you desire. The
			URL to your coranto.cgi is passed to our server at this stage solely to allow us to provide you with a link back to your completed
			installation, and is not logged. For greater privacy, you can set your web browser or firewall to hide the referrer; this is a
			function of your computer's setup, and is beyond Coranto's control.<p>
			If you are running Coranto on a private network that is not linked to the Internet, or require the absolute maximum privacy
			possible, you may choose the 'Private' setting. You will not be passed to our server during the setup process, and all links
			or image calls to third-party servers in the script will be disabled.  Note that if you choose this option, YOU WILL BE UNABLE TO
			RUN ANY ADDONS WHICH DO NOT ALSO COMPLY WITH THIS PRIVACY SETTING. Be aware that if you choose this option, you are acknowledging
			that Coranto's creators bear no responsibility (and have no means) to contact you should a bug or security hole be found in the
			script, nor to provide you with support for the script's operation. You agree that it is your own responsibility to regularly check
			the News section of our site and the Announcements forum where you may find news on new releases, bugs, etc. 
			<center> Please choose your privacy settings: <select name="PublicOrPrivate" onchange="pvtoggle(document.setup)"><option value="1">Public</option><option value="0">Private</option></select></center>~, 1),
		SettingsTable('Version Checking?', qq~<select name="VersionChecking"><option value="1" selected>Yes (On)</option><option value="0">No (Off)</option></select>~, "Set this to 'Yes' if you would like an image to be displayed on the main page indication the current version number."),
		SettingsTable('Urgent Notification?', qq~<select name="UrgentNotification"><option value="1" selected>Yes (On)</option><option value="0">No (Off)</option></select>~, "If the above option is set to 'Yes': set this to 'Yes' if you'd like us to keep track of your e-mail so we can notify you of important news (bug fixes, new releases, etc.). Your email will not be sold or disclosed to a third party, nor will it be publicly viewable or used for any other purposes than those previously mentioned."),
	
		MidHeading('File Paths'),
		MidParagraph(q~In the boxes below, please enter the absolute paths for the three different Coranto directories: <b>Program Files</b>,
			<b>News Files</b>, and <b>Archive Files</b>. The directory which coranto.cgi is currently in is the Program Files directory; the
			setup documentation provides information on selecting the other two.<p>You must enter <b>absolute paths</b> here, not URLs. (Use
			forward / slashes, even on Windows servers, and do not include a trailing slash.) ~ . ($dir ? qq~It looks like the path to the
			current directory (the Program Files directory) is <b>$dir</b>. This guess is accurate 95% of the time; only disregard it if you
			are absolutely certain that the absolute path to your directory is something different.~ : q~Unfortunately, Coranto could
			notautomatically determine the absolute path to its directory. If you are not sure what the path is, please contact your host.~), 1);
	Setup_PathSettings($dir, $dir, $dir);
	
	print q~<table align="center" width="80%" border="0"><tr><td class="description"><div align="center"><input type="submit" name="sbmt" value="Continue Setup"></div></td></tr></table></form><script language="javascript">
		function pvtoggle (form) {
			if (form.PublicOrPrivate[form.PublicOrPrivate.selectedIndex].value == 0) {
				form.VersionChecking.disabled = true;
				form.VersionChecking.value = 0;
				form.UrgentNotification.disabled = true;
				form.UrgentNotification.value = 0;
			}
			else {
				form.VersionChecking.disabled = false;
				form.VersionChecking.value = 1;
				form.UrgentNotification.disabled = false;
				form.UrgentNotification.value = 1;
			}
		}
		function safety (form) {
			if (form.license[form.license.selectedIndex].value == 1) {
				form.PublicOrPrivate.disabled = false;
				form.VersionChecking.disabled = false;
				form.UrgentNotification.disabled = false;
				form.admin_path.disabled = false;
				form.htmlfile_path.disabled = false;
				form.archive_path.disabled = false;
				form.sbmt.disabled = false;
			}
			else {
				form.PublicOrPrivate.disabled = true;
				form.VersionChecking.disabled = true;
				form.UrgentNotification.disabled = true;
				form.admin_path.disabled = true;
				form.htmlfile_path.disabled = true;
				form.archive_path.disabled = true;
				form.sbmt.disabled = true;
			}
		}
		safety(document.setup);</script>~;
	&CRHTMLFoot_NoNav;
}

sub Setup_PathSettings {
	my ($prog, $news, $arc) = @_;
	print
		SettingsTable('Program Files Path:', qq~<input type="text" name="admin_path" size="50" value="$prog">~, q~Absolute path to the directory where this script and its program files are located.~),
		SettingsTable('News Files Path:', qq~<input type="text" name="htmlfile_path" size="50" value="$news">~, q~Absolute path to the directory where you'd like the news files -- the ones to be used on your web pages -- to be generated by default. You should already have uploaded the news database, <i>newsdat.txt</i>, to this directory.~),
		SettingsTable('Archive Files Path:', qq~<input type="text" name="archive_path" size="50" value="$arc">~, q~Absolute path to the directory where you'd like news archive to be generated by default. Often the same as the News File path.~);
}


sub SetupHandler {
	if ($CConfig{'firsttime'} ne 'yes') {
		CRcough("This script appears to have already been set up. If you'd like to go through set up again, re-upload the original nsettings.cgi file.");
	}
	NeedFile('crlang.pl');
	if ($in{'setupstep'} == 1) {
		print &header;
		unless ($in{'license'}) {
			CRcough('If you do not agree to the license conditions, please delete the Coranto files from your server.');
		}
		unless ($in{'admin_path'} && $in{'htmlfile_path'} && $in{'archive_path'}) {
			CRcough('You must enter paths for all three directories.');
		}
		my ($prog, $news, $arc) = (SecurePath($in{'admin_path'}), SecurePath($in{'htmlfile_path'}), SecurePath($in{'archive_path'}));
		my $err;
		my @paths = ("$prog/nsettings.cgi", "$prog/crcfg.dat", "$prog/nsbk.cgi", "$news/newsdat.txt");
		for $i (@paths) {
			unless (open(TEST, ">>$i")) {
				$err .= "Could not open <b>$i</b> for writing. ";
			}
			close(TEST);
		}
		unless (open(TEST, ">>$news/delete.me")) {
			$err .= "Could not create a new file in your News Files directory ($news). Check permissions on this directory.";
		}
		unlink("$news/delete.me");
		close(TEST);
		if ($err) {
			CRHTMLHead('File Error');
			print
				StartForm({'action' => 'setup', 'setupstep' => 1, 'license' => 1}),
				MidParagraph(qq~Whilst testing that all necessary files could be written to, Coranto encountered some errors. Details on
					the errors are below. Errors are probably caused either by incorrect paths, which you can correct in the boxes below,
					or incorrect file permissions (CHMOD settings).<p>$err~, 1);
			Setup_PathSettings($prog, $news, $arc);
			print SubmitButton('Continue Setup'), '</form>';
			CRHTMLFoot_NoNav();
			exit;
		}
		
		$CConfig{'PublicOrPrivate'} = $in{'PublicOrPrivate'};
		$CConfig{'isPublicSite'} = $in{'PublicOrPrivate'};
		
		$CConfig{'UrgentNotification'} = $in{'UrgentNotification'};
		$CConfig{'VersionChecking'} = $in{'VersionChecking'};
		
		$CConfig{'admin_path'} = $prog;
		$CConfig{'htmlfile_path'} = $news;
		$CConfig{'archive_path'} = $arc;
		CRHTMLHead('Coranto Setup');
		my $rpass = RandomWord(8);
		print
			StartForm({'action' => 'setup', 'setupstep' => 2}),
			MidHeading('File and Path Tests'),
			MidParagraph("Testing paths and file permissions... all tests were successful. The paths you entered seem correct, as do file permissions.", 1),
			MidHeading('Create Account'),
			MidParagraph("Please choose the username and password you'd like to use to log in to Coranto. By default, the username you choose will appear beside your news posts. This user will be your Super-Admin user, and will be the only user with authority to remove standard Admin-level users, as well as the point of contact for urgent emails regarding bugfixes and new features if you should choose to receive them.", 1),
			SettingsTable('Username:', '<input type="text" name="user">', "Your username may only contain letters, numbers, and underscores."),
			SettingsTable('Password:', qq~<input type="text" name="pass" value="$rpass">~, "Your password must be a minimum of five characters. A randomly-generated secure password is suggested in the box above."),
			SettingsTable('Email:', qq~<input type="text" name="email">~, "Your email address. This will, if you choose, be used to send you emails with information relating to urgent bugfixes, new Coranto features, etc. You can choose to disable this 'Urgent Notification' feature on the next screen, should you wish."),
			MidHeading('Language Settings'),
			MidParagraph("This version of Coranto currently only supports translation of the standard user interface. You can choose the language for each user on the Edit User page."),
			SubmitButton('Continue Setup'), '</form>';
		CRHTMLFoot_NoNav();
		exit;
	}
	elsif ($in{'setupstep'} == 2) {
		print header();
		my $user = $in{'user'};
		my $pass = $in{'pass'};
		CRcough("Username &quot;$user&quot; contains illegal characters. Only letters, numbers, and underscores are permitted in usernames.") if ($user =~ /[^a-zA-Z0-9_]/);
		CRcough("Usernames have to be at least 3 characters long.") unless length($user) > 2;
		CRcough("Passwords have to be at least 5 characters long.") unless length($pass) > 4;
		CRcough('You must enter a valid Email address.') unless length $in{'email'} > 2;
		NeedFile('crcrypt.pl');
		my $crcrypt = new CRcrypt;
		$userdata{$user}->{'CPassword'} = $crcrypt->GetHash($pass . $user);
		$userdata{$user}->{'UserLevel'} = 3;
		$userdata{$user}->{'Email'} = $in{'email'};
		WriteUserInfo();
		CRHTMLHead('Coranto Setup');
		print 
			StartForm({'action' => 'setup', 'setupstep' => 3, 'user' => $user, 'email' => $in{'email'}}),
			MidHeading("Account $user Created"),
			MidParagraph("Please remember your password. You will need it to use Coranto in the future, and it is not easily reset if you forget it.", 1),
			MidParagraph("To get Coranto started quickly, some of the more essential settings are organized into a single page below. All these settings will be available in Coranto's Administration section in the future, and you will be able to change anything you enter here.", 1);
		NeedFile('cradmin.pl');
		SettingsEngine_Display(SetupSettingsLoad(), \%CConfig);
		print 
			MidParagraph('After you click the button below, there may be a delay of about thirty seconds as a basic security check is performed and setup continues at the Coranto site.'),
			SubmitButton('Continue Setup (Almost finished!)');
		CRHTMLFoot_NoNav();
		exit;
	}
	elsif ($in{'setupstep'} == 3) {
		NeedFile('cradmin.pl');
		$CConfig{'currentversion'} = $crcgiVer;
		$CConfig{'currentrc'} = $crcgiRC;
		$CConfig{'currentbuild'} = $crcgiBuild;
		$CConfig{'firsttime'} = 'no';
		$CConfig{'SuperAdmin'} = $in{'user'};
		my $afi = OpenAddons();
		if ($afi->{'backup'}) {
			my @AddonsLoaded = split(/~/, $CConfig{'AddonsLoaded'});
			push(@AddonsLoaded, 'cra_backup.pl');
			$CConfig{'AddonsLoaded'} = join('~', @AddonsLoaded);
		}

		SettingsEngine_Save(&SetupSettingsLoad, \%CConfig);

		if ($CConfig{'PublicOrPrivate'}) {
			print "Location: http://coranto.gweilo.org/scripts/done.php?b=$crcgiBuild&rc=$crcgiRC&u=" . URLescape($scripturl) . '&v=' . URLescape($crcgiVer) . "\n\n";
		}
		else {
			print &header;
			CRHTMLHead('Setup Complete');
			print MidParagraph('Setup is complete.<p>Click ' . &PageLink . 'here</a> to continue');
			&CRHTMLFoot_NoNav;
		}
		exit;
	}
}
		
		
sub SetupSettingsLoad {
	NeedFile('crcfg.dat');
	InitGTD('<Field: Hour>:<Field: Minute>:<Field: Second> <Field: AMPM>, <Field: Month_Name> <Field: Day>', 'GetFullDisplayTime');
	my @SetupSettings = (
	['heading: Your Site'],		
	['SiteTitle', 'Site Name', "The name of your site. Will be displayed on Coranto administrative pages."],
	['SiteLink', 'Site Link', "If you'd like a <i>Back to Your Site</i> link on Coranto administrative pages, enter the URL here. Otherwise, leave this blank."],
	['heading: Date and Time'],
	['Standard_Time_Zone', 'Time Zone', "Your time zone. Any name or abbreviation is acceptable -- this is for display purposes only."],
	['Daylight_Time_Zone', 'Daylight Savings Time Zone', "As above, but during Daylight Savings Time."],
	['TimeOffset', 'Server Time Offset', "Often, your server will be in a different time zone than you are. You can enter the difference, in hours, between the server's time and the time you would like displayed on news items. For instance, if your server is in London and you are in Boston, set this to -5. Changing this setting will not affect existing news items; only new items will have an adjusted time. (The server's current time is: " . GetFullDisplayTime($CurrentTime) . ")"],
	['12HourClock', '12/24 Hour Clock', "Choose between a 12 hour (AM/PM) and 24 hour clock.", 
		[ ['1', '12 Hour (AM/PM)'], ['0', '24 Hour'] ] ]);
	return \@SetupSettings;
}
	


1;
