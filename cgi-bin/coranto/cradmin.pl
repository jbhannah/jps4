# Administrative functions of Coranto
# This file has not been commented much, and isn't 
# really made to be modified.

#####
# PAGE HANDLING
######

if (defined $crcgiBuild and $crcgiBuild != 39) {
	CRdie('Your cradmin.pl and crcore.pl files are mismatched -- that is, they come from different versions or builds of Coranto. Visit <a href="http://coranto.gweilo.org">the Coranto homepage</a>, download a new copy of Coranto, and upload new versions of crcore.pl and cradmin.pl.',1);
}

sub LoadAdminFunctionList {
	@AdminFunctions = (
	['Change Settings', 'Change a wide variety of program settings, including file paths.', 'settings'],
	['Manage Profiles', 'Create, edit, or remove news profiles, which control how news is selected from the database and published or displayed.', 'profilelist'],
	['Edit Users', 'Add new user accounts or remove/edit existing ones.', 'editusers'],
	['Edit News Styles', 'Create, edit, or remove news styles, which control what news looks like (that is, what HTML is used to display news items) on your site.', 'nstyle'],
	['Edit User Fields', 'Create, edit, or remove user information fields (the fields users see in User Info).', 'edituserdb'],
	['Edit News Fields', 'Create, edit, or remove news fields (the fields on Submit and Modify News forms).', 'editfielddb'],
	['Date &amp; Time Settings', 'Change settings involving times, like time zones and date formats.', 'datesettings'],
	['Addon Manager', 'Enable, disable, or view information on installed addons, and download new addons.', 'addonmanager'],
	['Full Rebuild', 'Rebuild all news items. (Build News tries to build only changed items.) Necessary if you edit files manually.', 'fullbuild']);
	push(@AdminFunctions, GetAddonAdminFunctions()) if $Addons;
	@AdminFunctions = reverse(@AdminFunctions);
}

sub AdminHandler {
	unless ($up == 3) {
		CRcough('You are not authorized to access administrative functions.');
	}
	my %AdminSubs = (
		'profiles_moveupdown' => 'Profiles_MoveUpDown',
		'settings' => 'ChangeSettings',
		'settingssave' => 'ChangeSettingsSave',
		'advset' => 'AdvancedSettings',
		'advsetsave' => 'AdvancedSettingsSave',
		'editusers' => 'EditUsers',
		'adduser' => 'AddUser',
		'removeuser' => 'RemoveUser',
		'toggleuserlevel' => 'ToggleUserLevel',
		'toggleuserenable' => 'ToggleUserEnable',
		'profilelist' => 'MainProfileList',
		'profileenabletoggle' => 'ProfileEnableToggle',
		'removeprofile' => 'RemoveProfile',
		'addprofile' => 'AddProfile',
		'editprofilearc' => 'EditProfileArchiving',
		'editprofilearcsave' => 'EditProfileArchivingSave',
		'editprofilegeneral' => 'EditProfileGeneral',
		'editprofilegeneralsave' => 'EditProfileGeneralSave',
		'datesettings' => 'DateSettings',
		'datesettingssave' => 'DateSettingsSave',
		'adduserdb' => 'AddUserDB',
		'edituserdb' => 'EditUserDB',
		'modifyuserdb' => 'ModifyUserDB',
		'removeuserdb' => 'RemoveUserDB',
		'editfielddb' => 'EditFieldDB',
		'addnewsfield' => 'AddNewsField',
		'removenewsfield' => 'RemoveNewsField',
		'newsfieldupdown' => 'NewsFieldUpDown',
		'changefieldtype' => 'ChangeFieldType',
		'newsfieldedit' => 'NewsFieldEdit',
		'newsfieldeditsave' => 'NewsFieldEditSave',
		'addonmanager' => 'AddonManager',
		'addondisable' => 'AddonDisable',
		'addonenable' => 'AddonEnable',
		'addondoc' => 'AddonDoc',
		'nstyle' => 'EditNewsStyles_Main',
		'nstyle-new' => 'EditNewsStyles_New',
		'nstyle-edit' => 'EditNewsStyles_Edit',
		'nstyle-editsave' => 'EditNewsStyles_EditSave',
		'nstyle-del' => 'EditNewsStyles_Delete',
		'dieplease' => 'DiePlease',
		'fullbuild' => 'FullRebuild');

	if ($AdminSubs{$in{'adminarea'}}) {
		&{$AdminSubs{$in{'adminarea'}}}();
	}
	else {
		my %AddonAdminSubs = GetAddonAdminSubs() if $Addons;
		if ($AddonAdminSubs{$in{'adminarea'}}) {
			my $aa = $AddonAdminSubs{$in{'adminarea'}};
			eval {
				&{$aa->[0]}($aa->[1]);
			};
			AErr($aa->[1], $@) if $@;
		}
		else {
			ShowAdminPage();
		}
	}
}

# Displays the list of administrative functions.
sub ShowAdminPage {
	LoadAdminFunctionList();
	CRHTMLHead('Administration');
	PrintFunctionList(\@AdminFunctions, 'adminarea', 'action', 'admin');
	CRHTMLFoot();
}
sub FullRebuild {
	GenHTML(1);
}


#####
# SETTINGS ENGINE
#####
# These are the definitions for settings pages that use the settings engine.

$Subs{'EditProfDefinition'} = <<'END_SUB';
sub EditProfDefinition {
	my $prof = shift;
	my %DisplayLinkOptions = (
		'0' => 'No link',
		'1' => 'Link pointing to Official Site',
		'2' => 'Link pointing to Unofficial Site',
		'3' => 'Text without link'
	);
	my @EditProfileSettings = (
	['heading: Main Profile Settings'],
	['DisplayName', 'Display Name', "The display name you want to use for this profile. Default is the profile name."],
	['textfile', 'File Name', "The name of the text file which this profile will generate (example: $prof.txt)."],
	['filepath', 'File Path', "The absolute path to the directory in which files will be created, with no trailing slash. <b>Leave blank</b> to use the default HTML Files path (currently $CConfig{'htmlfile_path'})."],
	['agefilter', 'Filter By Time', "The number of days after which news will be considered old. News posted more than the specified number of days ago will not be included in this profile (though it will be archived, if that is enabled). <b>Leave blank</b> if you do not want to filter by time."],
	['numfilter', 'Filter By Number', "The maximum number of news items that will be included in this profile. For instance, if you set this to 10, then the 11th-newest item will not be included (though it will be archived, if that is enabled). <b>Leave blank</b> if you do not want to filter by number."],
	['skipdays', 'Skip Days', "If you want to skip news items rather than start with the most recent item, set this to the number of days to be skipped. For instance, if you set this to 3, the first item in this profile will be over 3 days old. <b>Leave blank</b> if you do not want to skip items by days."],
	['skipfilter', 'Skip Items', "If you want to skip news items rather than start with the most recent item, set this to the number of items to be skipped. For instance, if you set this to 3, the first item in this profile will be the 4th available item. <b>Leave blank</b> if you do not want to skip items. This is applied after <b>Skip Days</b>"]);
	# Addons: don't assume that you're on the Edit Profile screen for a Standard profile here!
	# New profile types should also incorporate this hook; this is the place to add news-selecting options,
	# like a category selection box. DO NOT add HTML-specific things here; the file being generated may not
	# be HTML!
	# HOOK: EditProfDefinition_1
	if($Addons{'EditProfDefinition_1'}){my $w;foreach $w (@{$Addons{'EditProfDefinition_1'}}){my $addon=$w->[2];eval ${$w->[0]};AErr($addon,$@)if $@;};}
	push(@EditProfileSettings, 
	['style', 'News Style', "The news style to use when generating HTML.", GetStyleSelect()],
	['DisplayLink', 'Display Coranto Link', "Adds a link to the Coranto home page to the end of the generated text file. With this version of Coranto, you must include a link on every page of your site that contains news items. If a page contains only headlines that link to full news items, it is exempt from the linking requirement. The default will link to the AmphibianWeb website, which has currently been taken offline. As options, you can choose to link to the unofficial site, or to display the 'Powered by' text with no link, should you not wish to link to a site which is offline.", '<select name="DisplayLink">' . join('', map { qq~<option value="$_"~ . ( $newsprofiles{$prof}->{'DisplayLink'} == $_ ? ' selected' : '' ) . qq~>$DisplayLinkOptions{$_}</option>~ } keys % DisplayLinkOptions) . '</select>'],
	['heading: Headlines'],
	['headlines', 'Enable Headlines', "Creates a file called " . ($prof eq 'news' ? 'headlines.txt' : "$prof-headlines.txt") . " that contains the same news items as this profile does, but uses a different style. (Headline styles are generally more concise than normal styles and don't include the full news text.)", 'yn'],
	['headline-style', 'Headlines Style', "The news style used when creating headlines. Only necessary if headlines are enabled.", GetStyleSelect()],
	['headline-number', 'Number of Headlines', "The maximum number of news items headlines will be generated for. Useful for including headlines of only the few most recent items. <b>Leave blank</b> to create headlines for all items included in this profile."],
	['draw_line'],
	['heading: Advanced Profile Settings'],
	['tmplfile', 'HTML Template', "To generate an HTML file containing the news from the profile, enter the name of a standard .tmpl file below. If creation of an HTML file isn't needed, as is usually the case, <b>leave this blank</b>.", GetTMPLSelect(1)],
	['tmpltitle', 'HTML File Title', "The title of the generated HTML file. Only necessary if an HTML template has been specified in the previous setting."],
	['filtsub', 'Sort Order', "Allows news to be sorted in an order other than the default. Note that no matter what the sort order, filtering by number will restrict the profile to the <i>n</i> newest items. As well, archives always use the default sort order.",
		GetSortOrders() ],
	['anchors', 'Anchor Tags', "Creates &lt;a name&gt; tags with news, allowing links directly to news items. Unless you're going to be including more than one profile (that is, two or more text files) on a single HTML page, you should leave this on.", 'yn']
		);

	# HOOK: EditProfDefinition_2
	if($Addons{'EditProfDefinition_2'}){my $w;foreach $w (@{$Addons{'EditProfDefinition_2'}}){my $addon=$w->[2];eval ${$w->[0]};AErr($addon,$@)if $@;};}
	return \@EditProfileSettings;
}
END_SUB

$Subs{'LoadArchivingSettings'} = <<'END_SUB';
sub LoadArchivingSettings {
	my $prof = shift;
	my %ArchiveSetCheck;
	$ArchiveSetCheck{$newsprofiles{$prof}->{'archive'}} = 'selected';
	
	my @ProfileArchiveSettings = (
	['heading: General Archiving Settings'],
	['archive', 'Archive Type', "Controls if and how archiving is performed. When archiving is enabled, news items which are too old to be included in $newsprofiles{$prof}->{'textfile'} are placed in archives.<br><br>
			Set to Disabled to disable all archiving for this profile. Set to Single File to place all old items in one text file, called $prof-archive.txt.
			Set to Monthly, Weekly, or Daily to create multiple archives, each holding a month's, week's, or day's news, respectively.", 
		[ ['0', 'Disabled (News will not be archived)'], ['1', 'Single File'], ['2', 'Monthly Archives'], ['3', 'Weekly Archives'], ['4', 'Daily Archives'] ] ],
	['archivefilepath', 'Archive File Path', "The absolute path to the directory in which archive files will be created, with no trailing slash. <b>Leave blank</b> to use the default Archive Files path (currently $CConfig{'archive_path'})."],
	['arc-style', 'News Style', "The news style to use for the archives.", GetStyleSelect()],
	['heading: Settings for Monthly, Weekly, and Daily Archiving Only'],
	['arclinkfilename', 'Archive Links File', "The name of the file which will contain links to the various archives. For example, <b>$prof-archive.html</b>."],
	['arclinktmpl', 'Archive Links Template', "The name of the template (.tmpl) file used to configure the style of the archive links page. Most users should use the default, <b>arclink.tmpl</b>.", GetTMPLSelect()],
	['archivetmpl', 'Archive Template', "The name of the template (.tmpl) file used to configure the style of the archives. Most users should use the default, <b>archive.tmpl</b>.", GetTMPLSelect()]
	);
	# HOOK: LoadArchivingSettings
	if($Addons{'LoadArchivingSettings'}){my $w;foreach $w (@{$Addons{'LoadArchivingSettings'}}){my $addon=$w->[2];eval ${$w->[0]};AErr($addon,$@)if $@;};}
	return \@ProfileArchiveSettings;
}
END_SUB

$Subs{'AdvancedSettingsLoad'} = <<'END_SUB';
sub AdvancedSettingsLoad {
	# HOOK: AdvSettings
	if($Addons{'AdvSettings'}){my $w;foreach $w (@{$Addons{'AdvSettings'}}){my $addon=$w->[2];eval ${$w->[0]};AErr($addon,$@)if $@;};}
	my @AdvancedSettings = (
	['AutoBuild_Submit', 'Build News Automatically (Submit)', 'If set to Yes, Coranto will automatically build news when you submit news. This results in changes being visible to users immediately after making them.', 'yn'],
	['AutoBuild_Modify', 'Build News Automatically (Modify)', 'If set to Yes, Coranto will automatically build news when you modify a news item. This means that changes will be visible as soon as you make them, but it also means that things may be slow if you modify several news items', 'yn'],
	['AutoLinkURL', 'Automatically Link URLs', 'Causes URLs in submitted news items to be linked to their destinations.', 'yn'],
	['ArcHtmlExt', 'Archive HTML file extension', "The extension that will be given to to archive HTML files. (No period, just the extension.) For instance, <b>html</b> or <b>shtml</b>. You will need to perform a full rebuild for changes to this setting to take effect."],
	['Modify_ItemsPerPage', 'Items Per Modify News Page', 'The number of news items that are displayed on each Modify News page.'],
	#['MaxSearchResults', 'Maximum Number of Search Results', 'The maximum number of news items returned as results when searching using viewnews.cgi.']
	);
	
	push(@AdvancedSettings, GetAddonAdvancedSettings()) if $Addons;

	return \@AdvancedSettings;

}
END_SUB

$Subs{'ChangeSettingsLoad'} = <<'END_SUB';
sub ChangeSettingsLoad {
	my @ChangeSettings = (
		['heading: File Paths'],
		['admin_path', 'Program Files Path', "Absolute path (<b>not</b> URL) to the directory where this script and its program files are located. Use forward slashes (/), even on Windows systems. Do not include a trailing slash."],
		['htmlfile_path', 'News Files Path', "Absolute path (<b>not</b> URL) to the directory where you'd like the news files (the ones included in your pages) to be generated by default. The news database (newsdat.txt) will also be kept here. Often the same as the Program Files path, though this will not work if your Program Files directory is located within a cgi-bin directory. The directory must be world-writable. On UNIX servers, this means you must CHMOD the directory 777. Use forward slashes (/), even on Windows systems. Do not include a trailing slash."],
		['archive_path', 'Archive Files Path', "Absolute path (<b>not</b> URL) to the directory where you'd like your news archives to be generated. Often the same as the News Files path. The directory must be world-writable. On UNIX servers, this means you must CHMOD the directory 777. Use forward slashes (/), even on Windows systems. Do not include a trailing slash."],
		['heading: General Settings'],
		['SiteTitle', 'Site Name', "The name of your site. This will be displayed on Coranto script pages."],
		['SiteLink', 'Site Link', "If you'd like a &quot;Back to Your Site&quot; link on Coranto script pages, enter a URL here. Otherwise, leave blank."]
	);
	if ($CConfig{'SuperAdmin'} eq $CurrentUser or (not $CConfig{'SuperAdmin'} and $up == 3)) {
		push(@ChangeSettings,
			['SuperAdmin', 'Super Administrator', "Choose who the Super Administrator should be. Since you can see this box you are either the current Super Admin or there isn't a Super Admin set.", , '<select name="SuperAdmin">' . join('', map { qq~<option~ . ( $CConfig{'SuperAdmin'} eq $_ ? ' selected' : '' ) . qq~>$_</option>~ if $userdata{$_}->{'UserLevel'} == 3 } keys % userdata) . '</select>'],
			['heading: Privacy'],
			['PublicOrPrivate', 'Public or Private', "Set this to 'Public' if you would like to have a version check image on the main page, be notified of new releases of Coranto, enable links to the Coranto website and documentation, or allow all addons to work regardless of their privacy status. Set this to 'Private' if you are running Coranto on a private network with no connection to the Internet, or if you would like the highest level of privacy available. Note that on the 'Private' setting, you will find links to our server and documentation hosted there are disabled, and you will not be able to use addons which haven't been certified as compliant with your privacy setting by their authors", '<select name="PublicOrPrivate" onchange="pvtoggle(document.cs)"><option value="1"' . ( $CConfig{'PublicOrPrivate'} == 1 ? ' selected' : '' ) . '>Public</option><option value="0"' . ( $CConfig{'PublicOrPrivate'} == 0 ? ' selected' : '' ) . '>Private</option></select>'],
			['VersionChecking', 'Version Check Image', "Set this to 'Yes' if you would like an image to be displayed on the main page indicating the current version number.", 'yn'],
			['UrgentNotification', 'Urgent Notification', "If the above option is set to 'Yes': set this to 'Yes' if you would like us to keep track of your e-mail so we can notify you of  important news (bug fixes, new releases, etc.). Your email will not be sold or disclosed to a third party, nor will it be publicly viewable or used for any other purposes than those previously mentioned.", 'yn']
		);
	}
	
	push(@ChangeSettings, ['heading: Misc'],
	['XHTMLbr', 'Enable XHTML BR', "If set to <b>Yes</b>, newlines in news posts will be replaced with &lt;br /&gt;, instead of the usual &lt;br&gt;.", 'yn'],
	['ModifyEditLink','Modify News Link','Do you want the Modify News Edit link to open in the current window, instead of a new one?', yn],
	['sql_enabled', 'Enable SQL', 'Do you want to allow Coranto to work with SQL-based addons such as CorantoSQL', yn],
	['heading: Debug Options'],
	['showconfig', 'Show Config', 'Do you want to allow you to display the configuration when debugging? This can be a security risk, so be careful. If not sure, set it to <b>No</b>', yn],
	['shownewsdat', 'Show Newsdat.txt', 'Do you want to allow you to display the contents of newsdat.txt when debugging? This can be a security risk, so be careful. If not sure, set it to <b>No</b>', yn]);
	
	return \@ChangeSettings;
}
END_SUB

$Subs{'NewsFieldEditDef'} = <<'END_SUB';
sub NewsFieldEditDef {
	my $fieldtype = shift;
	my @NFEDef = (
		['DisplayName', 'Display Name', 'The name that will label this field in Submit News and Modify News. This is that name that users will see.'],
		['SubmitPerm', 'Submit Permissions', 'Controls which users will be shown this field when submitting news. (Administrators are always shown all fields.)',
			[ ['0', 'All Users'], ['1', '&quot;High&quot; level users'], ['2', 'Administrators only'] ] ],
		['ModifyPerm', 'Modify Permissions', 'Controls which users will be shown this field when modifying news. (Administrators are always shown all fields.)',
			[ ['0', 'All Users'], ['1', '&quot;High&quot; level users'], ['2', 'Administrators only'] ] ]);
	unless ($fieldtype > 2) {
		push(@NFEDef, ['DisableHTML', 'Disable HTML', 'When enabled, prevents HTML from being used in this field by causing HTML tags to be displayed as part of the news item rather than be interpreted by the browser.', 'yn']);
	}
	# HOOK: NewsFieldEditDef
	if($Addons{'NewsFieldEditDef'}){my $w;foreach $w (@{$Addons{'NewsFieldEditDef'}}){my $addon=$w->[2];eval ${$w->[0]};AErr($addon,$@)if $@;};}
	if ($fieldtype == 1) {
		push(@NFEDef, ['FieldSize', 'Field Size', 'The size, in characters, of the text box.'],
			['MaxLength', 'Maximum Length', 'The number of characters users will be able to enter into this field. Leave blank to not provide a maximum length.'],
			['ParseLinks', 'Parse Links', 'Automatically parse links in this field during Submit/Modify. Most users should leave this on.', 'yn'],
			['DefaultValue', 'Default Value', 'What will initially be in the text box when a user goes to the Submit News page. Leave blank for a normal, empty text box.']);
	}
	elsif ($fieldtype == 2) {
		push(@NFEDef, ['FieldRows', 'Rows', 'The height, in lines, of the text box'], ['FieldCols', 'Columns', 'The width, in characters, of the text box.'], 
			['Newlines', 'Convert Newlines', 'Convert newlines (what you type when you hit Enter) into &lt;br&gt; tags? This is necessary for HTML. Most users should leave this on.', 'yn'],
			['ParseLinks', 'Parse Links', 'Automatically parse links in this field during Submit/Modify. Most users should leave this on.', 'yn'],
			['DefaultValue', 'Default Value', 'What will initially be in the text box when a user goes to the Submit News page. Leave blank for a normal, empty text box.']);
	}
	elsif ($fieldtype == 4) {
		push(@NFEDef, ['OnValue', 'On Value', 'What will be saved in the field if the checkbox is checked.']);
		push(@NFEDef, ['Checked', 'Checked By Default', 'Do you want the checkbox to be automatically checked by default?', yn]);
	}
	elsif ($fieldtype == 3 or $fieldtype == 5) {
		push(@NFEDef, ['Options', 'Options', 'Enter the options you want this field to contain. Seperate each option with a | (pipe) and put the option you want to be default in brackets. In the following example the option "is" would be default: coranto|[is]|cool']);
		push(@NFEDef, ['SplitOptions', 'Split Options', 'What do you want radio button options to be split by? A good choice would be something like &lt;br&gt; (line break).']) if $fieldtype == 5;
		push(@NFEDef, ['FieldSize', 'Field Size', 'The size of the drop-down box (number of options you want to be displayed). Leave blank if you do not want to use this feature.']) if $fieldtype == 3;
	}
	
	unless ($fieldtype > 2){
	push(@NFEDef, ['StripSSI', 'Strip Code', 'Do you want to strip SSI, PHP, and other codes from the field input?', yn]);
	}
	
	# HOOK: NewsFieldEditDef_2
	if($Addons{'NewsFieldEditDef_2'}){my $w;foreach $w (@{$Addons{'NewsFieldEditDef_2'}}){my $addon=$w->[2];eval ${$w->[0]};AErr($addon,$@)if $@;};}
	return \@NFEDef;
}
END_SUB

$Subs{'LoadDateTimeSettings'} = <<'END_SUB';
sub LoadDateTimeSettings {
	my $saving = shift;
	InitGTD('<Field: Hour>:<Field: Minute>:<Field: Second> <Field: AMPM>, <Field: Month_Name> <Field: Day>', 'GetFullDisplayTime');
	@DateTimeSettings = (
	['heading: Time Options'],
	['Standard_Time_Zone', 'Time Zone', "Your time zone. Any name or abbreviation is acceptable -- this is for display purposes only."],
	['Daylight_Time_Zone', 'Daylight Savings Time Zone', "As above, but during Daylight Savings Time."],
	['TimeOffset', 'Server Time Offset', "Often, your server will be in a different time zone than you are. You can enter the difference, in hours, between the server's time and the time you would like displayed on news items. For instance, if your server is in London and you are in Boston, set this to -5. 
		Changing this setting will not affect existing news items; only new items will have an adjusted time. (The server's current time is: " . GetFullDisplayTime($CurrentTime) . ")"],
	['12HourClock', '12/24 Hour Clock?', "Choose between a 12 hour (AM/PM) and 24 hour clock.", 
		[ ['1', '12 Hour (AM/PM)'], ['0', '24 Hour'] ] ]);
	# HOOK: LoadDateTime
	if($Addons{'LoadDateTime'}){my $w;foreach $w (@{$Addons{'LoadDateTime'}}){my $addon=$w->[2];eval ${$w->[0]};AErr($addon,$@)if $@;};}
	push(@DateTimeSettings, ['heading: Date Formats']);
	push(@DateTimeSettings, ['DateFormat'], ['InternalDateFormat'], ['ArchiveDateFormat_Weekly'], ['ArchiveDateFormat_Monthly'], ['ArchiveDateFormat_Daily']) if $saving;
	return \@DateTimeSettings;
}
END_SUB

# Displays a list of available settings; used by most of the settings pages.
$Subs{'SettingsEngine_Display'} = <<'END_SUB';
sub SettingsEngine_Display {
	my $sconfig = shift;
	my $settingshash = shift;
	my $i;
	foreach $i (@$sconfig) {
		if ($i->[0] eq 'draw_line') {
			print '<hr width="80%"><br>';
		}
		elsif ($i->[0] =~ /^heading\: (.+)/) {
			print MidHeading($1);
		}
		elsif ($i->[0] =~ /^descrip\: (.+)/) {
			print MidParagraph($1, 1);
		}
		else {
			my ($name, $setting, $desc);
			if ($i->[1]) {
				$name = $i->[1];
			}
			else {
				$name = $i->[0];
			}
			if ($i->[3] eq 'yn') {
				$name .= '?';
			}
			else {
				$name .= ':';
			}
			if ($i->[3]) {
				if ($i->[3] eq 'yn') {
					$setting = qq~<select name="$i->[0]"><option value="1"~;
					unless ($$settingshash{$i->[0]} == 0) {
						$setting .= ' selected';
					}
					$setting .= q~>Yes (On)</option><option value="0"~;
					if ($$settingshash{$i->[0]} == 0) {
						$setting .= ' selected';
					}
					$setting .= q~>No (Off)</option></select>~;
				}
				elsif (ref($i->[3])) {
					$setting = qq~<select name="$i->[0]">~;
					my $qcnt;
					foreach $qcnt (@{$i->[3]}) {
						$setting .= qq~<option value="$qcnt->[0]"~;
						if ($$settingshash{$i->[0]} eq $qcnt->[0]) {
							$setting .= 'selected';
						}
						$setting .= qq~>$qcnt->[1]</option>~;
					}
					$setting .= '</select>';
				}
				else {
					$setting = $i->[3];
				}
			}
			else {
				$setting = qq~<input type="text" size="30" name="$i->[0]" value="~;
				$setting .= HTMLescape($$settingshash{$i->[0]});
				$setting .= '">';
			}
			$desc = $i->[2];
			print SettingsTable($name, $setting, $desc);
		}
	}
}
END_SUB

# Saves submitted settings. Used by most of the settings pages.
$Subs{'SettingsEngine_Save'} = <<'END_SUB';
sub SettingsEngine_Save {
	my $sconfig = shift;
	my $settingshash = shift;
	my $changeFlag;
	foreach $i (@$sconfig) {
		unless ($i->[0] eq 'draw_line' || $i->[0] =~ /^heading\: / || $i->[0] =~ /^descrip\: /) {
			if (exists $in{$i->[0]}) {
				$in{$i->[0]} =~ s/[\n\r\0]//g;
				$in{$i->[0]} =~ s/(\`\`x|\|x\||\!x\!)/(delim)/g;
				$changeFlag++ unless $$settingshash{$i->[0]} eq $in{$i->[0]};
				$$settingshash{$i->[0]} = $in{$i->[0]};
			}
		}
	}
	return $changeFlag;
}
END_SUB

$Subs{'GetTMPLSelect'} = <<'END_SUB';
sub GetTMPLSelect {
	my $none = shift;
	my (@sl, $file);
	push(@sl, ['', '(none)']) if $none;
	opendir(TMPLDIR, $CConfig{'admin_path'});
	while ($file = readdir(TMPLDIR)) {
		if ($file =~ /^[^\.]+\.tmpl$/) {
			push(@sl, [$file, $file]);
		}
	}
	closedir(TMPLDIR);
	return \@sl;
}
END_SUB

$Subs{'GetSortOrders'} = <<'END_SUB';
sub GetSortOrders {
	my @sortOrders = (['', 'Default (Reverse Chronological)'], ['FilterReverse', 'Chronological (Oldest First)'], ['FilterAlpha', 'Alphabetical (By Subject)'], ['FilterTrueAlpha', 'True Alphabetical (aAbBcC) (By Subject)']);
	push (@sortOrders, GetAddonSortOrders()) if $Addons;
	return \@sortOrders;
}
END_SUB


#####
# DISPLAY SUBROUTINES
#####

# A general confirmation page for settings changes.
$Subs{'SettingsConfirm'} = <<'END_SUB';
sub SettingsConfirm {
	my $extramessage = shift;
	my $suppressbuild = shift;
	SimpleConfirmationPage('Changes Saved', "Any changes that you made have been saved." . ($suppressbuild ? '' : ' You may have to build news for the results of your changes to become visible.') . " $extramessage", 1);
}
END_SUB

# Asks someone to confirm what they're doing. Preserves form data, but adds $in{'really'} when the user confirms.
$Subs{'AreYouSure'} = <<'END_SUB';
sub AreYouSure {
	my $message = shift;
	CRHTMLHead('Confirm Action');
	print qq~<table width="80%" border="0" align="center" class="confirm"><tr><td><div align="center">$message</div></td></tr></table><br>~;
	my %in2;
	my ($key, $value);
	while (($key, $value) = each %in) {
		$in2{$key} = $value unless $key eq 'session' || $key eq 'x';
	}
	print StartForm(\%in2);
	print q~<div align="center"><input type="submit" name="really" value="Yes, I'm sure"></div></form>~;
	CRHTMLFoot();
	exit;
}
END_SUB

#####
# CHANGE SETTINGS
######

# Displays the main Change Settings screen.
$Subs{'ChangeSettings'} = <<'END_SUB';
sub ChangeSettings {
	CRHTMLHead('Change Settings', 1);
	print StartForm( {'action' => 'admin', 'adminarea' => 'settingssave'}, 'name="cs"');

	SettingsEngine_Display(&ChangeSettingsLoad, \%CConfig);
	print
		qq~<table align="center" width="80%" border="0"><tr><td class="description"><div align="center"><input type="submit" onclick="pvtoggle(document.cs)" value="Save Settings"><input type="reset" value="$Messages{'Reset'}"></div></td></tr></table><br>~,
		MidHeading('Advanced Settings');
	SettingsEngine_Display(&AdvancedSettingsLoad, \%CConfig);
	print qq~<table align="center" width="80%" border="0"><tr><td class="description"><div align="center"><input type="submit" onclick="pvtoggle(document.cs)" value="Save Settings"><input type="reset" value="$Messages{'Reset'}"></div></td></tr></table></form>
		<script language="javascript">
		function pvtoggle (form) {
			if (form.PublicOrPrivate[form.PublicOrPrivate.selectedIndex].value == 0){
				form.VersionChecking.disabled = 1;
				form.VersionChecking.value = 0;
				form.UrgentNotification.disabled = 1;
				form.UrgentNotification.value = 0;
			}
			
			else if (form.PublicOrPrivate[form.PublicOrPrivate.selectedIndex].value == 1) {
				form.VersionChecking.disabled = 0;
				form.UrgentNotification.disabled = 0;
			}
			
			else {
			
			}
		}</script>~;
	CRHTMLFoot();
}
END_SUB

# Saves changes made in Change Settings.
$Subs{'ChangeSettingsSave'} = <<'END_SUB';
sub ChangeSettingsSave {
	my $msg;
	if ($in{'htmlfile_path'} ne $CConfig{'htmlfile_path'}) {
		$in{'htmlfile_path'} =~ s/[\n\r\0]//g;
		# We're changing News Files directories - check for newsdat presence
		if (-s "$in{'htmlfile_path'}/newsdat.txt") {
			$msg = qq~
			The News Files path was changed (from $CConfig{'htmlfile_path'} to $in{'htmlfile_path'}), and a
			news database (newsdat.txt) was found in the new directory. This means that Coranto will now use the
			database located at $in{'htmlfile_path'}/newsdat.txt.~;
		}
		else {
			if (-e "$CConfig{'htmlfile_path'}/newsdat.txt") {
				# OK, let's copy it.
				my $fh = CRopen("$CConfig{'htmlfile_path'}/newsdat.txt");
				my $fh2 = CRopen(">>$in{'htmlfile_path'}/newsdat.txt");
				while (<$fh>) {
					print $fh2 $_;
				}
				close($fh);
				close($fh2);
				$msg = qq~
				The News Files path was changed, and the new directory did not contain a news database.
				As a result, the database (newsdat.txt) was copied from $CConfig{'htmlfile_path'}/newsdat.txt
				to $in{'htmlfile_path'}/newsdat.txt.
				~;
			}
			else {
				# No newsdats to be found.
				my $fh = CRopen(">>$in{'htmlfile_path'}/newsdat.txt");
				close($fh);
				$msg = qq~
				<b>WARNING:</b> The News Files path was changed, from $CConfig{'htmlfile_path'} to
				$in{'htmlfile_path'}, but a news database (newsdat.txt) was found in neither directory.
				An empty database has been automatically created.~;
			}
		}
	}
	
	# isPublicSite is no longer used in the Coranto core
	# But some addons may rely on it, so we set it, just in case
	
	if ($in{'PublicOrPrivate'}){
		$CConfig{'isPublicSite'} = $CConfig{'PublicOrPrivate'};
	}
	
	$CConfig{'UrgentNotification'} = $in{'UrgentNotification'};
	$CConfig{'VersionChecking'} = $in{'VersionChecking'};

	my $isChanged = SettingsEngine_Save(ChangeSettingsLoad(), \%CConfig);
	SettingsEngine_Save(AdvancedSettingsLoad(), \%CConfig);
	
	$CConfig{'ForceFullBuild'} = 1 if $isChanged;
	
	# HOOK: ChangeSettingsSave
	if($Addons{'ChangeSettingsSave'}){my $w;foreach $w (@{$Addons{'ChangeSettingsSave'}}){my $addon=$w->[2];eval ${$w->[0]};AErr($addon,$@)if $@;};}
	SettingsConfirm($msg);
}
END_SUB

#####
# DATE & TIME SETTINGS
#####

# Displays the main Date & Time Settings screen.
$Subs{'DateSettings'} = <<'END_SUB';
sub DateSettings {
	NeedCFG();
	InitGTD($CConfig{'ArchiveDateFormat_Weekly'}, 'GetTheDate_WeeklyArchive');
	InitGTD($CConfig{'ArchiveDateFormat_Daily'}, 'GetTheDate_DailyArchive');
	InitGTD($CConfig{'ArchiveDateFormat_Monthly'}, 'GetTheDate_MonthlyArchive');
	CRHTMLHead("Date &amp; Time Settings", 1);
	print StartForm ( {'action' => 'admin', 'adminarea' => 'datesettingssave'});
	SettingsEngine_Display(LoadDateTimeSettings(), \%CConfig);
	print qq~<table width="80%" border="0" align="center" class="confirm" cellpadding="3">
	<tr><td><div align="center">The following settings allow you to configure how dates &amp;
	times appear. The general date format controls the date used in news items.
	The internal date format controls the date used on Coranto administrative pages.
	The three archive date formats control the date used to label monthly, weekly, and daily archives
	respectively. To insert a component of the date or time, use &lt;Field: Name&gt; where Name is one of:
	<b>Year</b>, <b>TwoDigitYear</b>, <b>Month_Name</b>, <b>Month_Number</b>, <b>TwoDigitMonth</b>, <b>Weekday</b>, <b>Day</b>, <b>TwoDigitDay</b>, <b>Hour</b>, 
	<b>TwoDigitHour</b>, <b>Minute</b>, <b>Second</b>, <b>AMPM</b>, or <b>Time_Zone</b>. Remember that spacing and capitalization
	matter: &lt;Field: Day&gt; is valid, but &lt;field:day&gt is not (it contains three errors, actually).</div></td></tr></table><br>~
	. DateSettingsTable('General Date Format', 'DateFormat', GetTheDate()) . DateSettingsTable('Internal Date Format', 'InternalDateFormat', GetTheDate_Internal())
	. DateSettingsTable('Monthly Archive Date Format', 'ArchiveDateFormat_Monthly', GetTheDate_MonthlyArchive())
	. DateSettingsTable('Weekly Archive Date Format', 'ArchiveDateFormat_Weekly', GetTheDate_WeeklyArchive())
	. DateSettingsTable('Daily Archive Date Format', 'ArchiveDateFormat_Daily', GetTheDate_DailyArchive())
	. q~<table width="80%" border="0" align="center" class="confirm">
	<tr><td><div align="center"><input type="submit" name="submit" value="Submit Settings">
	</div></td></tr></table></form>~;
	CRHTMLFoot();
}

# Returns HTML for a table used for date formats
sub DateSettingsTable {
	return qq~<table width="80%" border="0" align="center" class="lightgbg" cellpadding="4" cellspacing="0"><tr><td class="fieldtitle">
	<div align="center">$_[0]</div></td></tr><tr><td><div align="center">
	<textarea name="$_[1]" rows="3" cols="60" wrap="VIRTUAL">~ . HTMLescape($CConfig{$_[1]}) . qq~</textarea></div></td></tr>
	<tr><td class="footnote"><div align="center">Example of current format: ~ . $_[2] . q~</div></td></tr></table><br>~;
}
END_SUB

# Saves any changes to Date & Time Settings.
$Subs{'DateSettingsSave'} = <<'END_SUB';
sub DateSettingsSave {
	SettingsEngine_Save(LoadDateTimeSettings(1), \%CConfig);
	$CConfig{'ForceFullBuild'} = 1;
	SettingsConfirm();
}
END_SUB

#####
# EDIT USERS
#####

# Displays the main Edit Users screen.
$Subs{'EditUsers'} = <<'END_SUB';
sub EditUsers {
	InitGTD($CConfig{'InternalDateFormat'}, 'GetTheDate_Internal');
	CRHTMLHead('Edit Users', 1);
	print MidHeading('Current Users');
	my ($status, $actions);
	foreach $i (sort keys %userdata) {
		$status = qq~User &quot;$i&quot; last logged in on ~ . 
			($userdata{$i}->{'LastLogin'} ? GetTheDate_Internal($userdata{$i}->{'LastLogin'} + (3600 * $CConfig{'TimeOffset'})) : '(never)') . 
			'. User level: <b>';
		if ($userdata{$i}->{'UserLevel'} == 3) {
			$status .= 'Administrator';
		}
		elsif ($userdata{$i}->{'UserLevel'} == 2) {
			$status .= 'High';
		}
		else {
			$status .= 'Standard';
		}
		if ($userdata{$i}->{'UserLevel'} == 3 and $CConfig{'SuperAdmin'} ne $CurrentUser) {
			$actions =  'Administrator users can only be edited or deleted by the Super Administrator.';
		}
		else {
			my @levels = qw(Standard High Administrator);
			$actions = '[' . PageLink( {'action' => 'edituserinfo', 'username' => $i}) . 'Edit User Info</a>] [' . PageLink({'action' => 'admin', 'adminarea' => 'removeuser', 'username' => $i}) . 'Delete User</a>] ' .
			( $i eq $CConfig{'SuperAdmin'} ? '' : '[' . PageLink({'action' => 'admin', 'adminarea' => 'toggleuserlevel', 'username' => $i}) . "Convert to $levels[$userdata{$i}->{'UserLevel'} == 3 ? 0 : $userdata{$i}->{'UserLevel'}] Level User</a>] " ) .
			'[' . PageLink({'action' => 'admin', 'adminarea' => 'toggleuserenable', 'username' => $i}) . ( ($userdata{$i}->{'DisableUser'}) ? 'Enable User' : 'Disable User' ) . '</a>]';
		}
		print Tricolore(( ($userdata{$i}->{'DisableUser'}) ? "$i (disabled)" : $i), $status, $actions);
	}
	print MidHeading('Create New User');
	print MidParagraph('Usernames may contain only letters, numbers, and underscores (_).');
	print StartForm({'action' => 'admin', 'adminarea' => 'adduser'});
	print StartFieldsTable();
	my $rw = RandomWord(8);
	print FieldsRow('Username', q~<input type="text" name="username" size="30" maxlength="30">~);
	print FieldsRow('Password', qq~<input type="text" name="password" size="30" maxlength="30" value="$rw">~);
	print FieldsRow('User Level', q~<select name="UserLevel"><option value="1">Standard (can post news and modify own posts)</option>
	<option value="2">High (can post news and modify all posts)</option>
	<option value="3">Administrator (complete access to all functions)</option></select>~);
	print '</td></tr></table>';
	print MidParagraph('<input type="submit" name="submit" value="Create User">');
	print '</form>';
	CRHTMLFoot();
}
END_SUB

# Moves a user between Standard and High levels.
$Subs{'ToggleUserLevel'} = <<'END_SUB';
sub ToggleUserLevel {
	my $user = $in{'username'};
	CRcough("User $user does not exist.") unless ($user && $userdata{$user});
	$userdata{$user}->{'UserLevel'}++;
	$userdata{$user}->{'UserLevel'} = 1 if $userdata{$user}->{'UserLevel'} > 3;
	WriteUserInfo();
	EditUsers();
}
END_SUB

# Enables/disables a user.
$Subs{'ToggleUserEnable'} = <<'END_SUB';
sub ToggleUserEnable {
	my $user = $in{'username'};
	CRcough("User $user does not exist.") unless ($user && $userdata{$user});
	CRcough("That is an administrative user.") if ($userdata{$user}->{'UserLevel'} == 3 and $CConfig{'SuperAdmin'} ne $CurrentUser);
	$userdata{$user}->{'DisableUser'} = ($userdata{$user}->{'DisableUser'}) ? 0 : 1;
	WriteUserInfo();
	EditUsers();
}
END_SUB

# Adds a new user.
$Subs{'AddUser'} = <<'END_SUB';
sub AddUser {
	my $newuser = $in{'username'};
	my $pass = $in{'password'};
	my $level = $in{'UserLevel'};
	CRcough("The username must be at least 3 characters long.") unless length($newuser) > 2;
	CRcough("Username &quot;$newuser&quot; contains illegal characters. Only letters, numbers, and underscores are permitted in usernames.") if ($newuser =~ /[^a-zA-Z0-9_]/);
	CRcough("That user already exists.") if $userdata{$newuser};
	CRcough("Passwords must be at least 5 characters long.") unless length($pass) > 4;
	CRcough("Invalid user level.") unless $level <= 3 && $level >= 1;
	AreYouSure("Are you sure that you want to create an Administrator user? Administrator users have complete access to all functions, and, once created, <b>can only be deleted by the Super Administrator</b>. 
		Administrator users can delete or modify your files. Administrator users can do almost anything. As a general rule, only give Administrator accounts to those who already have full 
		access to your server.") unless ($level != 3 || $in{'really'});
	if ($newuser =~ /^guest/ && $level == 1) {
		AreYouSure("Are you sure that you want to create a guest user? Users which start with the word guest are special: they can't access User Info or Modify News.") unless $in{'really'};
	}
	NeedFile('crcrypt.pl');
	my $crcrypt = new CRcrypt;
	$userdata{$newuser}->{'CPassword'} = $crcrypt->GetHash($pass . $newuser);
	$userdata{$newuser}->{'UserLevel'} = $in{'UserLevel'};
	# HOOK: AddUser
	if($Addons{'AddUser'}){my $w;foreach $w (@{$Addons{'AddUser'}}){my $addon=$w->[2];eval ${$w->[0]};AErr($addon,$@)if $@;};}
	WriteUserInfo();
	EditUsers();
}
END_SUB

# Deletes a user.
$Subs{'RemoveUser'} = <<'END_SUB';
sub RemoveUser {
	my $user = $in{'username'};
	CRcough("User $user does not exist.") unless ($user && $userdata{$user});
	CRcough("Cannot remove administrative users.") if $CConfig{'SuperAdmin'} ne $CurrentUser and $userdata{$user}->{'UserLevel'} == 3;
	AreYouSure("Are you sure you want to remove user &quot;$user&quot? When a user is removed, everything in the user database associated
	with that user is removed as well. For instance, the user's e-mail address will be deleted, and will no longer be displayed in news items
	posted by that user. Disabling rather than removing the user is usually a better choice.") unless $in{'really'};
	delete $userdata{$user};
	delete $CConfig{"user-$user"};
	WriteUserInfo();
	EditUsers();
}
END_SUB

#####
# USER FIELDS EDITING
#####


# The main Edit User Fields screen.
$Subs{'EditUserDB'} = <<'END_SUB';
sub EditUserDB {
	CRHTMLHead('Edit User Fields', 1);
	ReadUserDBInfo();
	print MidParagraph("The User Fields allow you to associate information with a particular user and display that information in 
	news items posted by that user. For example, you could store the email addresses of users and display a user's address on the items that he or she posts.");
	print MidHeading('Current User Fields');
	my ($options, $remove);
	foreach $i (sort keys %userDB) {
		my (%CheckType, %CheckPerm, %CheckHTML);
		$CheckType{$userDB{$i}->{'FieldType'}} = 'selected';
		$CheckPerm{$userDB{$i}->{'Permissions'}} = 'selected';
		$CheckHTML{$userDB{$i}->{'EnableHTML'}} = 'selected';
		$options = qq~<select name="FieldType"><option value="0" $CheckType{'0'}>Single-line text box</option>
		<option value="1" $CheckType{'1'}>Multi-line text box</option></select> &nbsp; <select name="Permissions">
		<option value="0" $CheckPerm{'0'}>Editable by user</option><option value="1" $CheckPerm{'1'}>Editable only by administrator</option></select>
		&nbsp; <select name="EnableHTML"><option value="0" $CheckHTML{'0'}>HTML forbidden</option><option value="1" $CheckHTML{'1'}>HTML allowed</option></select>
		&nbsp;<input type="submit" name="submit" value="Change Settings">~;
		$remove = '[' . PageLink({'action' => 'admin', 'adminarea' => 'removeuserdb', 'fieldname' => $i}) . 'Delete</a>]' unless $i eq 'Email';
		print StartForm({'action' => 'admin', 'adminarea' => 'modifyuserdb', 'fieldname' => $i});
		print Tricolore($i, $options, $remove);
		print '</form>';
	}
	print MidHeading('Create New User Field');
	print StartForm({'action' => 'admin', 'adminarea' => 'adduserdb'}) . q~
	<table width="80%" border="0" cellspacing="2" cellpadding="2" align="center"><tr><td class="fieldtitle" width="50%"><div align="right">User Field Name:</div></td><td width="50%"><input type="text" size="30" name="fieldname"></td></tr><tr><td colspan="2" class="description">
	<div align="center">User field names may only contain letters, numbers, and underscores (_). </div></td></tr></table><br><div align="center"><input type="submit" name="submit" value="Create Field"></div></form>~;
	CRHTMLFoot();
}
END_SUB

# Removes a user field.
$Subs{'RemoveUserDB'} = <<'END_SUB';
sub RemoveUserDB {
	my $field = $in{'fieldname'};
	ReadUserDBInfo();
	CRcough("Field &quote;$field&quot; does not exist.") unless $userDB{$field};
	CRcough('Sorry, but you cannot remove the Email field.') if $field eq 'Email';
	AreYouSure("Are you sure that you want to delete field &quot;$field&quot;? If you delete the field, all information that has previously been stored in it will be deleted as well.") unless $in{'really'};
	delete $userDB{$field};
	delete $CConfig{"userDB-$field"};
	foreach $i (keys %userdata) {
		delete $userdata{$i}->{$field};
	}
	WriteUserDBInfo();
	WriteUserInfo();
	EditUserDB();
}
END_SUB

# Changes settings for a user field. (type and permissions)
$Subs{'ModifyUserDB'} = <<'END_SUB';
sub ModifyUserDB {
	my $field = $in{'fieldname'};
	ReadUserDBInfo();
	CRcough("Field \"$field\" does not exist.") unless $userDB{$field};
	$userDB{$field}->{'FieldType'} = $in{'FieldType'} if exists $in{'FieldType'};
	$userDB{$field}->{'Permissions'} = $in{'Permissions'} if exists $in{'Permissions'};
	$userDB{$field}->{'EnableHTML'} = $in{'EnableHTML'} if exists $in{'EnableHTML'};

	WriteUserDBInfo();
	EditUserDB();
}
END_SUB

# Adds a new user field
$Subs{'AddUserDB'} = <<'END_SUB';
sub AddUserDB {
	my $field = $in{'fieldname'};
	ReadUserDBInfo();
	CRcough("Field name &quot;$field&quot; contains illegal characters. Only letters, numbers, and underscores are permitted in field names.") if ($field =~ /[^a-zA-Z0-9_]/);
	CRcough("Field &quot;$field&quot; already exists.") if $userDB{$field} || $field eq 'CPassword' || $field eq 'UserLevel' || $field eq 'LastLogin' || $field eq 'DisableUser';
	CRcough("Please enter a field name.") unless $field;
	$userDB{$field} = {
		'FieldType' => 0,
		'Permissions' => 0,
		'EnableHTML' => 0};
	WriteUserDBInfo();
	EditUserDB();
}
END_SUB

#####
# EDIT PROFILES
#####

# The main Edit Profiles screen.
$Subs{'MainProfileList'} = <<'END_SUB';
sub MainProfileList {
	CRHTMLHead('Edit News Profiles',1);

	# HOOK: ProfileList_1
	if($Addons{'ProfileList_1'}){my $w;foreach $w (@{$Addons{'ProfileList_1'}}){my $addon=$w->[2];eval ${$w->[0]};AErr($addon,$@)if $@;};}

	print q~
	<table width="80%" cellpadding="2" border="0" align="center"><tr><td class="midheader"><div align="center">Current Profiles
	</div></td></tr></table><br>~;

	# HOOK: ProfileList_2
	if($Addons{'ProfileList_2'}){my $w;foreach $w (@{$Addons{'ProfileList_2'}}){my $addon=$w->[2];eval ${$w->[0]};AErr($addon,$@)if $@;};}

	my ($status, $actions, @ProfileTypes);
	if ($Addons) {
		@ProfileTypes = GetAddonProfileTypes();
	}
	PROFLOOP: foreach $i (sort keys %newsprofiles) {
		next PROFLOOP if $i =~ /[^\w\d_]/;

		# HOOK: ProfileList_3
		if($Addons{'ProfileList_3'}){my $w;foreach $w (@{$Addons{'ProfileList_3'}}){my $addon=$w->[2];eval ${$w->[0]};AErr($addon,$@)if $@;};}

			my $DisplayName;

			###############
			# New profile display name feature!
			###############

			if (exists $newsprofiles{$i}->{'DisplayName'}){
			$DisplayName = $newsprofiles{$i}->{'DisplayName'};
			}
			else {
			$DisplayName = $i;
			}

			#############
			# END
			#############
	
		if ($newsprofiles{$i}->{'enabled'}) {
			$status = '';
			if ($newsprofiles{$i}->{'type'} eq 'Standard') {
				$status .= 'Archiving is currently <b>';
				if ($newsprofiles{$i}->{'archive'}) {
					$status .= 'on';
				} else {
					$status .= 'off';
				}
				$status .= '</b>. ';
				if (!$newsprofiles{$i}->{'agefilter'} && !$newsprofiles{$i}->{'numfilter'}) {
					$status .= 'This profile is not filtered by time or number. ';
				}
				else {
					$status .= 'A maximum of ';
					if ($newsprofiles{$i}->{'agefilter'}) {
						$status .= "<b>$newsprofiles{$i}->{'agefilter'} days</b> ";
						if ($newsprofiles{$i}->{'numfilter'}) {
							$status .= ' or ';
						}
					}
					if ($newsprofiles{$i}->{'numfilter'}) {
						$status .= "<b>$newsprofiles{$i}->{'numfilter'} item" . ($newsprofiles{$i}->{'numfilter'} == 1 ? '' : 's') . '</b> ';
					}

					$status .= 'will be included in this profile. ';

				}

				if ($newsprofiles{$i}->{'skipdays'}){
				$status .= qq~ Items must be older than <b>$newsprofiles{$i}->{'skipdays'}</b> days.<br>~;
				}
				if ($newsprofiles{$i}->{'skipfilter'}){
				$status .= qq~This profile is set to skip the first <b>$newsprofiles{$i}->{'skipfilter'}</b> items.<br>~;
				}

				$status .= 'Profile type: <b>Standard</b>. ' if @ProfileTypes;
				# HOOK: ProfileList_Standard_Status
				if($Addons{'ProfileList_Standard_Status'}){my $w;foreach $w (@{$Addons{'ProfileList_Standard_Status'}}){my $addon=$w->[2];eval ${$w->[0]};AErr($addon,$@)if $@;};}
			}
			else {
				# HOOK: ProfileList_NewType_Status
				if($Addons{'ProfileList_NewType_Status'}){my $w;foreach $w (@{$Addons{'ProfileList_NewType_Status'}}){my $addon=$w->[2];eval ${$w->[0]};AErr($addon,$@)if $@;};}
			}
		} else {
			$status = "Profile &quot;$i&quot; is currently <b>disabled</b>.";
			$status .= " Profile type: <b>$newsprofiles{$i}->{'type'}</b>." if @ProfileTypes;
		}
		$actions = '[' . PageLink({'action' => 'admin', 'adminarea' => 'profileenabletoggle', 'profname' => $i} ) .
			( ($newsprofiles{$i}->{'enabled'}) ? 'Disable' : 'Enable' ) . '</a>] ';
		if ($newsprofiles{$i}->{'type'} eq 'Standard') {
			$actions .= '[' .
		 	PageLink( {'action' => 'admin', 'adminarea' => 'editprofilegeneral', 'profname' => $i} ) . 'Edit General Settings</a>] [' .
			PageLink( {'action' => 'admin', 'adminarea' => 'editprofilearc', 'profname' => $i} ) . 'Edit Archiving Settings</a>] ';
			# HOOK: ProfileList_Standard_Functions
			if($Addons{'ProfileList_Standard_Functions'}){my $w;foreach $w (@{$Addons{'ProfileList_Standard_Functions'}}){my $addon=$w->[2];eval ${$w->[0]};AErr($addon,$@)if $@;};}
		}
		else {
			# HOOK: ProfileList_NewType_Functions
			if($Addons{'ProfileList_NewType_Functions'}){my $w;foreach $w (@{$Addons{'ProfileList_NewType_Functions'}}){my $addon=$w->[2];eval ${$w->[0]};AErr($addon,$@)if $@;};}
		}
		$actions .= '[' . PageLink( {'action' => 'admin', 'adminarea' => 'removeprofile', 'profname' => $i} ) . 
			'Delete</a>]' unless ($i eq 'news');
			
		#$actions .= ' [' .
		 	PageLink( {'action' => 'admin', 'adminarea' => 'profiles_moveupdown', 'profname' => $i, 'direction' => 1} ) . 'Move Up</a>] [' .
			PageLink( {'action' => 'admin', 'adminarea' => 'profiles_moveupdown', 'profname' => $i, 'direction' => 2} ) . 'Move Down</a>] ';

		if (exists $newsprofiles{$i}->{'DisplayName'}){
			$status .= qq~<br><b>Internal Name:</b> $i~;
		}
		print Tricolore( ($newsprofiles{$i}->{'enabled'} ? $DisplayName : "$DisplayName (disabled)"), $status, $actions);
	}
	print MidHeading('Create New Profile'), StartForm({'action' => 'admin', 'adminarea' => 'addprofile'}), q~
	<table width="80%" border="0" cellspacing="2" cellpadding="2" align="center"><tr><td class="fieldtitle" width="50%" valign="top"><div align="right">Profile Name:</div></td>
	<td width="50%"><input type="text" size="30" name="profname"></td></tr>
	~;
	if (@ProfileTypes) {
		print q~ <tr><td class="fieldtitle" width="50%" valign="top"><div align="right">Profile Type:</div></td>
		<td width="50%"><select name="proftype"><option value="Standard" selected>Standard</option>~;
		foreach $i (@ProfileTypes) {
			print qq~<option value="$i">$i</option>~;
		}
		print '</select></td></tr>';
	}
	print q~
	<tr><td colspan="2" class="description">
	<div align="center">Profile names may only contain letters, numbers, and underscores (_). As well, while uppercase letters are allowed,
	use of lowercase letters only is recommended to avoid confusion. (<b>After creating a profile, you must edit & enable it.</b>)</div></td></tr></table><br>~,
	SubmitButton('Create Profile'), '</form>';
	CRHTMLFoot();
}
END_SUB

# Enables/disables a profile.
$Subs{'ProfileEnableToggle'} = <<'END_SUB';
sub ProfileEnableToggle {
	my $prof = $in{'profname'};
	CRcough('Invalid profile information.') unless ($prof && $newsprofiles{$prof});
	# HOOK: ProfileEnableToggle
	if($Addons{'ProfileEnableToggle'}){my $w;foreach $w (@{$Addons{'ProfileEnableToggle'}}){my $addon=$w->[2];eval ${$w->[0]};AErr($addon,$@)if $@;};}
	$newsprofiles{$prof}->{'enabled'} = $newsprofiles{$prof}->{'enabled'} ? 0 : 1;
	$newsprofiles{"$prof-headlines"}->{'enabled'} = $newsprofiles{"$prof-headlines"}->{'enabled'} ? 0 : 1;
	WriteProfileInfo();
	MainProfileList();
}
END_SUB

# Displays archiving settings for a Standard profile.
$Subs{'EditProfileArchiving'} = <<'END_SUB';
sub EditProfileArchiving {
	my $prof = $in{'profname'};
	CRHTMLHead("Archiving Settings for &quot;$prof&quot;",1);
	print StartForm( {'profname' => $prof, 'action' => 'admin', 'adminarea' => 'editprofilearcsave'} );
	SettingsEngine_Display(LoadArchivingSettings($prof), $newsprofiles{$prof});
	print q~<table align="center" width="80%" border="0">
		<tr><td class="confirm"><div align="center"><input type="submit" value="Save Settings">
		</div></td></tr></table></form>~;
	CRHTMLFoot();
}
END_SUB

# Saves archiving settings for a Standard profile.
$Subs{'EditProfileArchivingSave'} = <<'END_SUB';
sub EditProfileArchivingSave {
	my $prof = $in{'profname'};
	CRdie("Invalid profile information") unless ($prof && $newsprofiles{$prof});
	$newsprofiles{$prof}->{'ForceFullBuild'} = 1;
	SettingsEngine_Save(LoadArchivingSettings($prof), $newsprofiles{$prof});
	WriteProfileInfo();
	SettingsConfirm(PageLink({'action' => 'admin', 'adminarea' => 'profilelist'}) . 'Back to Edit Profiles</a>.');
}
END_SUB

# Displays settings for a (Standard) profile.
$Subs{'EditProfileGeneral'} = <<'END_SUB';
sub EditProfileGeneral {
	my $prof = $in{'profname'};
	&CRHTMLHead(qq~General Settings for "$prof"~,1);
	print StartForm( {'profname' => $prof, 'action' => 'admin', 'adminarea' => 'editprofilegeneralsave'} );

	unless (exists $newsprofiles{$prof}->{'DisplayName'}){
	$newsprofiles{$prof}->{'DisplayName'} = $prof;
	}

	SettingsEngine_Display(EditProfDefinition($prof), $newsprofiles{$prof});
	print SubmitButton('Save Settings'), '</form>';
	&CRHTMLFoot;
}
END_SUB

# Saves changes to settings for a (Standard) profile.
$Subs{'EditProfileGeneralSave'} = <<'END_SUB';
sub EditProfileGeneralSave {
	my $prof = $in{'profname'};
	CRdie("Invalid profile information") unless ($prof && $newsprofiles{$prof});
	# Addons: don't assume you're editing a Standard profile here. Other addons may include
	# this hook themselves when editing non-Standard profiles.
	# HOOK: EditProfileSave
	if($Addons{'EditProfileSave'}){my $w;foreach $w (@{$Addons{'EditProfileSave'}}){my $addon=$w->[2];eval ${$w->[0]};AErr($addon,$@)if $@;};}
	$newsprofiles{$prof}->{'ForceFullBuild'} = 1;
	SettingsEngine_Save(EditProfDefinition($prof), $newsprofiles{$prof});
	if ($newsprofiles{$prof}->{'headlines'} && !$newsprofiles{"$prof-headlines"}) {
		$newsprofiles{"$prof-headlines"} = {'enabled' => 0};
	}
	WriteProfileInfo();
	SettingsConfirm(PageLink({'action' => 'admin', 'adminarea' => 'profilelist'}) . 'Back to Edit Profiles</a>.');
}
END_SUB

# Deletes a profile.
$Subs{'RemoveProfile'} = <<'END_SUB';
sub RemoveProfile {
	#NeedCFG();
	my $prof = $in{'profname'};
	CRcough(q~Invalid profile "$prof".~) unless ($prof && $newsprofiles{$prof} && $prof ne 'news');
	if ($newsprofiles{"$prof-headlines"}) {
		delete $newsprofiles{"$prof-headlines"};
		delete $CConfig{"Profile-$prof-$headlines"};
	}
	delete $newsprofiles{$prof};
	delete $CConfig{"Profile-$prof"};
	WriteProfileInfo();

	#SaveCRCFG();
	MainProfileList();
}
END_SUB

# Adds a new (Standard) profile.
$Subs{'AddProfile'} = <<'END_SUB';
sub AddProfile {
	#NeedCFG();

	my $prof = $in{'profname'};
	my $proftype = $in{'proftype'};
	CRcough("Profile name &quot;$prof&quot; contains illegal characters. Only letters, numbers, and underscores are permitted in profile names.") if ($prof =~ /[^a-zA-Z0-9_]/);
	CRcough("Profile $prof already exists.") if $newsprofiles{$prof};
	CRcough("Please enter a profile name.") unless $prof;
	if ($proftype && $proftype ne 'Standard') {
		# HOOK: AddProfile_NewType
		if($Addons{'AddProfile_NewType'}){my $w;foreach $w (@{$Addons{'AddProfile_NewType'}}){my $addon=$w->[2];eval ${$w->[0]};AErr($addon,$@)if $@;};}
	}
	else {
		$newsprofiles{$prof} = { 'enabled' => 0,
			'textfile' => "$prof.txt",
			'cats' => ['AllCategories'],
			'agefilter' => '30',
			'numfilter' => '',
			'skipdays'=> '',
			'style' => 'NewsStyle_Default',
			'filepath' => '',
			'anchors' => 1,
			'DisplayLink' => 1,
			'archive' => 0,
			'archivefilepath' => '',
			'arc-style', 'NewsStyle_Default',
			'arclinkfilename' => "$prof-archive.$CConfig{'ArcHtmlExt'}",
			'arclinktmpl' => 'arclink.tmpl',
			'archivetmpl' => 'archive.tmpl',
			'type' => 'Standard',
			'headlines' => 0,
			'headline-style' => 'NewsStyle_DefaultHeadline',
			'ForceFullBuild' => 1,
			'DisplayName' => $prof};

		# HOOK: AddProfile_Standard
		if($Addons{'AddProfile_Standard'}){my $w;foreach $w (@{$Addons{'AddProfile_Standard'}}){my $addon=$w->[2];eval ${$w->[0]};AErr($addon,$@)if $@;};}
	}

	#SaveCRCFG();

	WriteProfileInfo();
	MainProfileList();
}
END_SUB

#sub Profiles_MoveUpDown {
#NeedCFG();
#SortedArray_MoveUpDown(\@newsprofiles, $in{'profname'}, $in{'direction'});
#SaveCRCFG();
#NeedCFG();
#MainProfileList();
#}

#####
# CRCFG.DAT MANAGEMENT (INTERNAL SUBS)
######

# Regenerates crcfg.dat from data in memory. crcfg.dat should have been loaded before running this!
$Subs{'SaveCRCFG'} = <<'END_SUB';
sub SaveCRCFG {
	
	unless ($validcrcfg) {
		CRdie('Attempt to save crcfg.dat without previously loading it.');
	}
	
	my $crcfg = q~# WARNING: This is a generated (and frequently re-generated)
# file. DO NOT EDIT.

~;
	#$crcfg .= ArraytoPerl('newsprofiles')
	$crcfg .= ArraytoPerl('fieldDB')
		. ArraytoPerl('fieldDB_internalorder')
		. HashtoPerl('fieldDB')
		. HashtoPerl('LoginMessages')
		. ArraytoPerl('Week_Days')
		. ArraytoPerl('Months')
		. HashtoPerl('NewsStyles');
	my $i;
	foreach $i (sort keys %NewsStyles) {
		$crcfg .= StyletoPerl("NewsStyle_$i", $NewsStyles{$i}->{'RawStyle'});
	}
	$crcfg .= CreateSplitDF('SplitDataFile');
	$crcfg .= CreateJoinDF('JoinDataFile');

	##############
	# NEW IN 1.03
	##############

	# HOOK: SaveCRCFG_1
	if($Addons{'SaveCRCFG_1'}){my $w;foreach $w (@{$Addons{'SaveCRCFG_1'}}){my $addon=$w->[2];eval ${$w->[0]};AErr($addon,$@)if $@;};}

	##############
	# END NEW IN 1.03
	##############	


	$crcfg .= "\$validcrcfg = 1;\n1;";
	my $fh;
	if ($cfgpath) {
		$fh = CRopen(">$cfgpath");
	}
	else {
		$fh = CRopen(">$CConfig{'admin_path'}/crcfg.dat");
	}
	print {$fh} $crcfg;
	close($fh);
}
END_SUB

# Converts a hash to Perl code (that'll load the hash). Supports 1 level of hash (and only hash) references.
$Subs{'HashtoPerl'} = <<'END_SUB';
sub HashtoPerl {
	my $hashname = shift;
	my $output;
	my ($key, $value, $key2, $value2, $comma1, $comma2);
	$output = "\%$hashname = (\n";
	while (($key, $value) = each %$hashname) {
		if ($comma1) {
			$output .= ",\n";
		}
		else {
			$comma1 = 1;
		}
		$output .= "'$key' => ";
		if (ref($value)) {
			$output .= '{ ';
			while (($key2, $value2) = each %$value) {
				if ($comma2) {
					$output .= ",\n";
				}
				else {
					$comma2 = 1;
				}
				$value2 = qEscape($value2);
				$output .= "'$key2' => q~$value2~";
			}
			$comma2 = 0;
			$output .= ' }';
		}
		else {
			$output .= 'q~' . qEscape($value) . '~';
		}
	}
	$output .= ");\n";
	return $output;
}
END_SUB

# Converts an array to Perl.
$Subs{'ArraytoPerl'} = <<'END_SUB';
sub ArraytoPerl {
	my $arrname = shift;
	my $item;
	my $output = "\@$arrname = (";
	$output .= join(', ', map { $item = qEscape($_); "q~$item~" } @$arrname);
	$output .= ");\n";
	return $output;
}
END_SUB

# Creates the Perl code for a SplitDataFile subroutine.
$Subs{'CreateSplitDF'} = <<'END_SUB';
sub CreateSplitDF {
	my $subname = shift;
	my $splitdf = qq~sub $subname {
	(~;
	$splitdf .= join(', ', map { "\$$_" } @fieldDB_internalorder);
	$splitdf .= ') = split(/\\`\\`x/, $_[0]);' . "\n}\n";
	return $splitdf;
}
END_SUB

# Creates the Perl code for a JoinDataFile subroutine.
$Subs{'CreateJoinDF'} = <<'END_SUB';
sub CreateJoinDF {
	my $subname = shift;
	my $joindf = qq~sub $subname {
	return join('``x', ~;
	$joindf .= join(', ', map { "\$$_" } @fieldDB_internalorder);
	$joindf .= ");\n}\n";
	return $joindf;
}
END_SUB

# Escapes a string, suitable for inclusion in a q~
$Subs{'qEscape'} = <<'END_SUB';
sub qEscape {
	my $text = shift;
	$text =~ s/(\~|\\)/\\$1/g;
	return $text;
}
END_SUB

# Escapes a string, suitable for inclusion in a qq~	
$Subs{'qqEscape'} = <<'END_SUB';
sub qqEscape {
	my $text = shift;
	$text =~ s/(\~|\\|\$|\@)/\\$1/g;
	return $text;
}
END_SUB

#####
# NEWS FIELDS EDITING
#####

# The main Edit News Fields screen.
$Subs{'EditFieldDB'} = <<'END_SUB';
sub EditFieldDB {
	CRHTMLHead('Edit News Fields', 1);
	NeedCFG();
	print MidParagraph("News fields are the fields available for users to enter information when
	submitting or modifying news.");
	print MidHeading('Current News Fields');
	my ($info, $actions);
	foreach $i (@fieldDB) {
		$info = "Display Name: <b>$fieldDB{$i}->{'DisplayName'}</b> Field Type: <b>";
		if ($fieldDB{$i}->{'FieldType'} == 1) {
			$info .= 'Single-Line Text Field';
		}
		elsif ($fieldDB{$i}->{'FieldType'} == 2) {
			$info .= 'Multi-Line Text Field';
		}
		elsif ($fieldDB{$i}->{'FieldType'} == 3) {
			$info .= 'Drop-Down Box';
		}
		elsif ($fieldDB{$i}->{'FieldType'} == 4) {
			$info .= 'Checkbox';
		}
		elsif ($fieldDB{$i}->{'FieldType'} == 5) {
			$info .= 'Radio Button';
		}

		# HOOK: EditFieldDB_1
		if($Addons{'EditFieldDB_1'}){my $w;foreach $w (@{$Addons{'EditFieldDB_1'}}){my $addon=$w->[2];eval ${$w->[0]};AErr($addon,$@)if $@;};}

		$info .= '</b>';
		$actions = '';
		if ($i =~ /^CustomField_/) {
			$actions .= ' [' . PageLink({'action' => 'admin', 'adminarea' => 'removenewsfield', 'fieldname' => $i}) . 
				'Delete</a>]';
		}
		$actions .= ' [' . PageLink({'action' => 'admin', 'adminarea' => 'newsfieldupdown', 'fieldname' => $i, 'updown' => '1'}) . 
			'Move Up</a>] [' . PageLink({'action' => 'admin', 'adminarea' => 'newsfieldupdown', 'fieldname' => $i, 'updown' => '2'}) . 
			'Move Down</a>] [' . PageLink({'action' => 'admin', 'adminarea' => 'newsfieldedit', 'fieldname' => $i}) . 'Edit</a>]';
		print StartForm({'action' => 'admin', 'adminarea' => 'changefieldtype', 'fieldname' => $i});
		print Tricolore($i, $info, $actions);
		print '</form>';
	}
	print MidHeading('Create New News Field');
	print StartForm({'action' => 'admin', 'adminarea' => 'addnewsfield'});
	print MidParagraph('Enter both the internal and display name of the field that you wish to create. The internal name is the name which will be used
		to refer to this field in your news style settings; it may contain only letters, numbers, and underscores, and will always begin with &quot;CustomField_&quot;. The display name is the name shown to users when submitting or modifying news.');
	print StartFieldsTable();
	print FieldsRow('Internal Name', q~CustomField_<input type="text" name="internalname" size="30">~);
	print FieldsRow('Display Name', q~<input type="text" name="displayname" size="45">~);


	my $fieldtypes = qq~<option value="1" selected>Single-Line Text Field</option>
			<option value="2">Multi-Line Text Field</option>
			<option value="3">Drop-Down Box</option>
			<option value="4">Checkbox</option>
			<option value="5">Radio Button</option>~;

	# HOOK: EditFieldDB_2
	if($Addons{'EditFieldDB_2'}){my $w;foreach $w (@{$Addons{'EditFieldDB_2'}}){my $addon=$w->[2];eval ${$w->[0]};AErr($addon,$@)if $@;};}

	print FieldsRow('Field Type', qq~<select name="FieldType">$fieldtypes</select>~);
	print '</td></tr></table>';
	print MidParagraph('<input type="submit" name="submit" value="Create Field">');
	print '</form>';
	CRHTMLFoot();
}
END_SUB

# The settings page for editing a news field.
$Subs{'NewsFieldEdit'} = <<'END_SUB';
sub NewsFieldEdit {
	my $field = $in{'fieldname'};
	NeedCFG();
	&CRHTMLHead("Edit Field &quot;$field&quot;",1);
	print StartForm( {'fieldname' => $field, 'action' => 'admin', 'adminarea' => 'newsfieldeditsave'} );
	SettingsEngine_Display(NewsFieldEditDef($fieldDB{$field}->{'FieldType'}), $fieldDB{$field});
	print q~<table align="center" width="80%" border="0">
		<tr><td class="confirm"><div align="center"><input type="submit" value="Save Settings">
		</div></td></tr></table></form>~;
	&CRHTMLFoot;
}
END_SUB

# Sabes changes to news field settings.
$Subs{'NewsFieldEditSave'} = <<'END_SUB';
sub NewsFieldEditSave {
	my $field = $in{'fieldname'};
	NeedCFG();

	# HOOK: NewsFieldEditSave_1
	if($Addons{'NewsFieldEditSave_1'}){my $w;foreach $w (@{$Addons{'NewsFieldEditSave_1'}}){my $addon=$w->[2];eval ${$w->[0]};AErr($addon,$@)if $@;};}

	CRdie("No such field $field.") unless $fieldDB{$field};
	SettingsEngine_Save(NewsFieldEditDef($fieldDB{$field}->{'FieldType'}), $fieldDB{$field});
	SaveCRCFG();
	SettingsConfirm(PageLink({'action' => 'admin', 'adminarea' => 'editfielddb'}) . 'Back to Edit News Fields</a>.');
}
END_SUB

# Moves a news field either up or down in the display order. (Internal order isn't changed.)
$Subs{'NewsFieldUpDown'} = <<'END_SUB';
sub NewsFieldUpDown {
	NeedCFG();
	my $fieldname = $in{'fieldname'};
	my $updown = $in{'updown'};
	CRcough('That field does not exist.') unless $fieldDB{$fieldname};
	CRdie('Invalid input.') if $updown < 1 || $updown > 2;
	my (%fieldDBkeys, $swap);
	for ($i = 0; $i < @fieldDB; $i++) {
		$fieldDBkeys{$fieldDB[$i]} = $i;
	}	
	CRcough('Could not find field.') unless exists $fieldDBkeys{$fieldname};
	CRcough('This is already the first item.') if $updown == 1 && $fieldDBkeys{$fieldname} == 0;
	CRcough('This is already the last item.') if $updown == 2 && $fieldDBkeys{$fieldname} == (@fieldDB - 1);
	if ($updown == 1) {
		$swap = ($fieldDBkeys{$fieldname} - 1);
	} else {
		$swap = ($fieldDBkeys{$fieldname} + 1);
	}
	@fieldDB[$fieldDBkeys{$fieldname}, $swap] = @fieldDB[$swap, $fieldDBkeys{$fieldname}];
	SaveCRCFG();
	EditFieldDB();
}
END_SUB

# Adds a new news field
$Subs{'AddNewsField'} = <<'END_SUB';
sub AddNewsField {
	NeedCFG();
	my $fieldname = $in{'internalname'};
	my $dispname = $in{'displayname'};
	my $fieldtype = $in{'FieldType'};
	CRcough("Please enter an internal name.") unless $fieldname;
	$fieldname = "CustomField_$fieldname";
	CRcough("Field name $fieldname contains illegal characters. Only letters, numbers, and underscores are permitted in field names.") if ($fieldname =~ /[^a-zA-Z0-9_]/);
	CRcough("Field $fieldname already exists.") if $fieldDB{$fieldname};
	AddNewsField_Internal($fieldname, $fieldtype, $dispname);
	EditFieldDB();
}
END_SUB

# Does the legwork of actually adding the field.
$Subs{'AddNewsField_Internal'} = <<'END_SUB';
sub AddNewsField_Internal {
	NeedCFG();
	my ($fieldname, $fieldtype, $dispname) = @_;
	$dispname = $fieldname unless $dispname;
	push(@fieldDB, $fieldname);
	push(@fieldDB_internalorder, $fieldname);
	$fieldDB{$fieldname} = {
		'DisplayName' => $dispname,
		'FieldType' => $fieldtype,
		'SubmitPerm' => 0,
		'ModifyPerm' => 0};
	
	if ($fieldtype == 1) {
		$fieldDB{$fieldname}->{'FieldSize'} = 45;
		$fieldDB{$fieldname}->{'ParseLinks'} = 1;
	}
	elsif ($fieldtype == 2) {
		$fieldDB{$fieldname}->{'FieldRows'} = 6;
		$fieldDB{$fieldname}->{'FieldCols'} = 80;
		$fieldDB{$fieldname}->{'Newlines'} = 1;
		$fieldDB{$fieldname}->{'ParseLinks'} = 1;
	}
	elsif ($fieldtype == 4) {
		$fieldDB{$fieldname}->{'OnValue'} = 1;
	}
	
	# HOOK: AddNewsField_Internal
	if($Addons{'AddNewsField_Internal'}){my $w;foreach $w (@{$Addons{'AddNewsField_Internal'}}){my $addon=$w->[2];eval ${$w->[0]};AErr($addon,$@)if $@;};}
	SaveCRCFG();
}
END_SUB

# Deletes a news field. (This involves rebuilding newsdat.txt.)
$Subs{'RemoveNewsField'} = <<'END_SUB';
sub RemoveNewsField {
	NeedCFG();
	my $fieldname = $in{'fieldname'};
	CRcough("That field cannot be deleted.") unless $fieldname =~ /^CustomField_/;
	CRcough('That field does not exist.') unless $fieldDB{$fieldname};
	AreYouSure("Are you sure that you want to delete field &quot;$fieldname&quot;? Any data that has been stored in this field will be deleted!") unless $in{'really'};
	RemoveNewsField_Internal($fieldname);
	EditFieldDB();
}
END_SUB

# Does the legwork of actually removing the field.
$Subs{'RemoveNewsField_Internal'} = <<'END_SUB';
sub RemoveNewsField_Internal {
	my $fieldname = shift;
	NeedCFG();
	my %fieldDBkeys;
	for ($i = 0; $i < @fieldDB; $i++) {
		$fieldDBkeys{$fieldDB[$i]} = $i;
	}
	CRcough('Could not find field.') unless exists $fieldDBkeys{$fieldname};
	splice(@fieldDB, $fieldDBkeys{$fieldname},1);
	eval CreateSplitDF('SDFTemp');
	%fieldDBkeys = ();
	for ($i = 0; $i < @fieldDB_internalorder; $i++) {
		$fieldDBkeys{$fieldDB_internalorder[$i]} = $i;
	}
	CRcough('Could not find field.') unless exists $fieldDBkeys{$fieldname};	
	splice(@fieldDB_internalorder, $fieldDBkeys{$fieldname},1);
	delete $fieldDB{$fieldname};
	eval CreateJoinDF('JDFTemp');
	# HOOK: RemoveNewsField_Internal
	if($Addons{'RemoveNewsField_Internal'}){my $w;foreach $w (@{$Addons{'RemoveNewsField_Internal'}}){my $addon=$w->[2];eval ${$w->[0]};AErr($addon,$@)if $@;};}
	SaveCRCFG();	
	my ($fh, $fh2) = EditNewsdat_Start();
	while (<$fh>) {
		chomp($_);
		SDFTemp($_);
		print {$fh2} JDFTemp(), "\n";
	}
	
	close($fh);
	close($fh2);
	EditNewsdat_Finish();
}
END_SUB


#####
# ADDON MANAGER
#####

# Searches for addons in our directory and gets information on them.
$Subs{'OpenAddons'} = <<'END_SUB';
sub OpenAddons {
	my (%AddonFileInfo, $af);
	opendir(ADMINDIR, $CConfig{'admin_path'});
	my @addonfiles = readdir(ADMINDIR);
	closedir(ADMINDIR);
	@addonfiles = grep(/cra_\S+\.pl/, @addonfiles);
	@addonfiles = map {/cra_(\S+)\.pl/; $1} @addonfiles;
	foreach $af (@addonfiles) {
		my %afi;
		my $fh = CRopen("$CConfig{'admin_path'}/cra_$af.pl");
		AFLOOP: while (<$fh>) {
			if (/^#! ([A-Z]+) (.+)/) {
				$afi{$1} = $2;
			}
			else {
				last AFLOOP;
			}
		}
		if ($afi{'CRADDON'} == 1 && $afi{'NAME'}) {
			$AddonFileInfo{$af} = \%afi;
		}
	}
	return \%AddonFileInfo;
}
END_SUB

# The main Addon Manager screen.
$Subs{'AddonManager'} = <<'END_SUB';
sub AddonManager {
	my $afi = OpenAddons();
	my ($i, %AddonsLoaded, $list, @summ);
	CRHTMLHead('Addon Manager', 1);

	unless($CConfig{'AddonsLoaded'}){
	ReadConfigInfo();
	}
	
	my @AddonsLoaded = split(/~/, $CConfig{'AddonsLoaded'});
	
	foreach $i (@AddonsLoaded) {
		$AddonsLoaded{$i} = 1;
	}
	
	my @alist = keys %$afi;
	if (@alist) {
		@alist = sort {uc($$afi{$a}->{'NAME'}) cmp uc($$afi{$b}->{'NAME'})} @alist;
		foreach $i (@alist) {
			my $en = 1 if $AddonsLoaded{"cra_$i.pl"};
			my $name = $$afi{$i}->{'NAME'};
			$name .= ' (disabled)' unless $en;
			my $description = $$afi{$i}->{'DESCRIPTION'};
			$description .= '<br>' if $description;
			$description .= "<b>Filename</b>: cra_$i.pl ";
			$description .= "&nbsp;<b>Version</b>: $$afi{$i}->{'VERSION'} " if $$afi{$i}->{'VERSION'};
			$description .= "&nbsp;<b>Documentation Available</b> " if $$afi{$i}->{'DOC'};
			my $action = '[';
			if ($en) {
				$action .= PageLink({'action' => 'admin', 'adminarea' => 'addondisable', 'addon' => $i}) . 'Disable</a>]';
				push(@summ, qq~<a href="#add_$i"><b>$$afi{$i}->{'NAME'}</b></a>~);
			}
			else {
				$action .= PageLink({'action' => 'admin', 'adminarea' => 'addonenable', 'addon' => $i}) . 'Enable</a>]';
				push(@summ, qq~<a href="#add_$i">$$afi{$i}->{'NAME'}</a>~);
			}
			if ($$afi{$i}->{'DOC'}) {
				$action .= ' [' . PageLink({'action' => 'admin', 'adminarea' => 'addondoc', 'addon' => $i}, q~target="_blank"~) . 'View Documentation</a>]';
			}
			if ($$afi{$i}->{'HOMEPAGE'}) {
				$action .= qq~ [<a href="$$afi{$i}->{'HOMEPAGE'}" target="_blank">Visit Site</a>]~;
			}
			$list .= qq~<a name="add_$i"></a>~ . Tricolore($name, $description, $action);
		}
		
	}
	else {
		print '<div align="center"><h3>No addons found.</h3></div>';
	}
	print q~<table width="70%" cellpadding="4" align="center" border="0"><tr><td class="footnote"><div align="center">Addons Found: ~
		. join(', ', @summ) . q~</div></td></tr></table>~ . $list;

	CRHTMLFoot();
	exit;
}
END_SUB

# Disables an addon (after the user clicks Disable; forced disables of addons are done
# by ForceDisableAddon, elsewhere).
$Subs{'AddonDisable'} = <<'END_SUB';
sub AddonDisable {
	my $addonname = $in{'addon'};
	$addonname =~ s/[^\w\d_\-]//g;
	$addonfile = "cra_$addonname.pl";
	CRdie('You must provide an addon name.') unless $addonfile;
	my @AddonsLoaded = split(/~/, $CConfig{'AddonsLoaded'});
	@AddonsLoaded = grep(!/\Q$addonfile\E/, @AddonsLoaded);
	$CConfig{'AddonsLoaded'} = join('~', @AddonsLoaded);
	AddonManager();
}
END_SUB

# Enables an addon.
$Subs{'AddonEnable'} = <<'END_SUB';
sub AddonEnable {
	my $addonname = $in{'addon'};
	$addonname =~ s/[^\w\d_\-]//g;
	$addonfile = "cra_$addonname.pl";
	unless (-e "$CConfig{'admin_path'}/$addonfile") {
		CRdie("Couldn't find addon $addonfile.");
	}
	my @AddonsLoaded = split(/~/, $CConfig{'AddonsLoaded'});
	push(@AddonsLoaded, $addonfile);
	$CConfig{'AddonsLoaded'} = join('~', @AddonsLoaded);
	AddonManager();
}
END_SUB

# Displays addon documentation
$Subs{'AddonDoc'} = <<'END_SUB';
sub AddonDoc {
	my $addonname = $in{'addon'};
	$addonname =~ s/[^\w\d_\-]//g;
	$addonfile = "$CConfig{'admin_path'}/cra_$addonname.pl";
	unless (-e $addonfile) {
		CRdie("Was asked to display documentation for addon $addonname, but could not find $addonfile.");
	}
	print MiniPod($addonfile);
	exit;
}
END_SUB

# Hand-rolled pod to HTML converter. Does not support all POD features.
$Subs{'MiniPod'} = <<'END_SUB';
sub MiniPod {
	my $path = shift;
	my ($pod, $readFlag);
	my $fh = CRopen($path);
	while (<$fh>) {
		if ($readFlag) {
			if (/^=cut/) {
				$readFlag = 0;
			}
			else {
				$pod .= $_;
			}
		}
		else {
			if (/^=pod/) {
				$readFlag = 1;
			}
			if (/^=head\d/) {
				$readFlag = 1;
				$pod .= $_;
			}
		}
	}
	close($fh);
	$pod =~ s~\G(.*?)(\A|=end html)(.*?)(\Z|=begin html)~$1 . HTMLescape($3)~ges; # escape <>&" for HTML
	$pod =~ s/B&lt;(.+?)&gt;/<b>$1<\/b>/g; # bold B<> codes
	$pod =~ s/I&lt;(.+?)&gt;/<i>$1<\/i>/g; # italicise I<> codes
	$pod =~ s/L&lt;(.+?)&gt;/<a href="$1">$1<\/a>/g; # link L<> codes (I don't think this is valid POD, by the way)
	$pod =~ s/^=head1 (.+)/<h1>$1<\/h1>/mg; # header level 1
	$pod =~ s/^=head2 (.+)/<h2>$1<\/h2>/mg; # header level 2
	$pod =~ s/^=head3 (.+)/<h3>$1<\/h3>/mg; # header level 3 (not valid POD)
	$pod =~ s/^=over.*/<ul>/gm; # begin bulleted list
	$pod =~ s/^=back/<\/ul>/gm; # end bulleted list
	$pod =~ s/^=item \*\n\n(.+)\n/<li>$1<\/li>/gm; # single bullet
	$pod =~ s/(\n\n|\G)([\w\d][\s\S]+?)(\n\n|\Z)/$1<p>$2<\/p>\n\n/g; # paragraph
	$pod =~ s/(\n\n|\G)([ \t][\s\S]+?)(\n\n|\Z)/$1<pre>$2<\/pre>\n\n/g; # verbatim paragraph
	return qq~
	<html><head><title>Coranto Addon Documentation</title></head>
	<style TYPE="text/css">
	body {  font-family: Arial, Helvetica, sans-serif }
	pre { font-family: "Courier New", Courier, mono; background-color: #CCCCCC }
	h1 {  font-family: Arial, Helvetica, sans-serif; text-align: center; text-decoration: underline}
	h2 {  font-family: Arial, Helvetica, sans-serif; color: #FF0000; background-color: #FFCC66}
	h3 {  font-family: Arial, Helvetica, sans-serif; color: #990000; background-color: #CCCCCC}
	</style>
	<body><h3>Addon Documentation -- close window to return to Coranto</h3>
	$pod
	<h3>Addon Documentation -- close window to return to Coranto</h3>
	</body></html>~;
}
END_SUB

######
# NEWS STYLES
######

$Subs{'EditNewsStyles_Main'} = <<'END_SUB';
sub EditNewsStyles_Main {
	NeedCFG();
	CRHTMLHead('Edit News Styles');
	print MidHeading('Current News Styles');
	my %profs = GetStyleProfiles();
	my @StyleTypes = GetAddonStyleTypes() if $Addons;
	my $i;
	foreach $i (sort keys %NewsStyles) {
		my ($descript, $act, @profs);
		my @profs = sort keys %{$profs{"NewsStyle_$i"}};
		$descript = '<b>This style is empty.</b> ' unless $NewsStyles{$i}->{'RawStyle'};
		if ($NewsStyles{$i}->{'Type'} eq 'Archive Link') {
			$descript .= 'This style is used by all archives.';
		}
		else {
			if (@profs == 0) {
				$descript .= 'This style is currently used by <b>no</b> profiles.';
			}
			elsif (@profs == 1) {
				$descript .= "This style is currently used by profile <b>$profs[0]</b>.";
			}
			else {
				$descript .= "This style is currently used by profiles: " .
					join(', ', map {"<b>$_</b>"} @profs) . '.';
			}
		}
		# Addons: this is where you override $descript if necessary.
		# HOOK: StylesMain_NewStyle
		if($Addons{'StylesMain_NewStyle'}){my $w;foreach $w (@{$Addons{'StylesMain_NewStyle'}}){my $addon=$w->[2];eval ${$w->[0]};AErr($addon,$@)if $@;};}
		$descript .= qq~ Style type: <b>$NewsStyles{$i}->{'Type'}</b>.~ if @StyleTypes;
		$act = '[' . PageLink({'action' => 'admin', 'adminarea' => 'nstyle-edit', 'stylename' => $i}) . 'Edit</a>]';
		unless ($i =~ /[^a-z0-9_]/) {
			$act .= ' [' . PageLink({'action' => 'admin', 'adminarea' => 'nstyle-del', 'stylename' => $i}) . 'Delete</a>]';
		}
		print Tricolore($NewsStyles{$i}->{'FullName'}, $descript, $act);
	}
	print MidHeading('Create New News Style'),
		StartForm({'action' => 'admin', 'adminarea' => 'nstyle-new'}),
		StartFieldsTable(),
		FieldsRow('Style Name', '<input name="stylename" type="text" size="45">');
	if (@StyleTypes) {
		my $sel = '<select name="styletype"><option value="Standard" selected>Standard</option>';
		foreach $i (@StyleTypes) {
			$sel .= qq~<option value="$i">$i</option>~;
		}
		$sel .= '</select>';
		print FieldsRow('Style Type', $sel);
	}
	print '</table><div align="center"><input type="submit" value="Create Style"></div></form>';
	CRHTMLFoot();
}
END_SUB

$Subs{'EditNewsStyles_New'} = <<'END_SUB';
sub EditNewsStyles_New {
	NeedCFG();
	my $nsext = $in{'stylename'};
	my $ntype = $in{'styletype'};
	$ntype = 'Standard' unless $ntype;
	$nsext =~ s/<[^>]*>//g;
	my $nsint = $nsext;
	$nsint =~ s/ /_/g;
	$nsint = lc($nsint);
	$nsint =~ s/[^a-z0-9_]//g;
	CRcough('Style name must contain at least 3 alphanumeric characters.') if length($nsint) < 3;
	CRcough('A style with that name (or a similar name) already exists.') if ($NewsStyles{$nsint} || $nsext =~ /Default News Style/i || $nsint eq 'default' || $nsint eq 'defaultheadline' || $nsext =~ /Default Headline Style/i || $nsext =~ /Archive Link Style/i);
	$NewsStyles{$nsint} = {
		'FullName' => $nsext,
		'RawStyle' => '' };
	if ($ntype eq 'Standard') {
		$NewsStyles{$nsint}->{'Type'} = 'Standard';
	}
	else {
		$NewsStyles{$nsint}->{'Type'} = $ntype;
		# HOOK: StylesNew_NewStyle
		if($Addons{'StylesNew_NewStyle'}){my $w;foreach $w (@{$Addons{'StylesNew_NewStyle'}}){my $addon=$w->[2];eval ${$w->[0]};AErr($addon,$@)if $@;};}
	}
	SaveCRCFG();
	EditNewsStyles_Main();
}
END_SUB

$Subs{'EditNewsStyles_Edit'} = <<'END_SUB';
sub EditNewsStyles_Edit {
	NeedCFG();
	ReadUserDBInfo();
	my $style = $in{'stylename'};
	CRcough("That style doesn't exist.") unless $NewsStyles{$style};
	my $styleraw = HTMLescape($NewsStyles{$style}->{'RawStyle'});
	CRHTMLHead("Edit Style $NewsStyles{$style}->{'FullName'}");
	my $msg = q~Below, enter the HTML code you'd like this style to use. Where you'd like to include one of the various components of a news item, enter &lt;Field: FieldName&gt; where FieldName is the name of the appropriate field. For example, use &lt;Field: Text&gt; to insert the text of the news item. ~;
	my @fields = @fieldDB;
	push(@fields, 'User', 'Date');
	push(@fields, 'Category') if $EnableCategories;
	push(@fields, map {"UserField_$_"} keys %userDB);
	@fields = map {"<b>$_</b>"} @fields;
	$msg .= q~The following basic fields are available: ~ . join(', ', @fields) . 
		q~. <br><br><a href="http://coranto.gweilo.org/guides/tagsdoc.html" target="_new">Fuller documentation</a> of style-editing options is available.~;
	#my $msg = "Instructions and a link to documentation forthcoming. Basics: use &lt;Field: Text&gt;, &lt;Field: UserField_Email&gt;, etc.";
	# HOOK: EditNewsStyles_Edit
	if($Addons{'EditNewsStyles_Edit'}){my $w;foreach $w (@{$Addons{'EditNewsStyles_Edit'}}){my $addon=$w->[2];eval ${$w->[0]};AErr($addon,$@)if $@;};}
	print MidParagraph($msg),
		StartForm({'action' => 'admin', 'adminarea' => 'nstyle-editsave', 'stylename' => $style}),
		qq~<div align="center"><textarea name="styleraw" rows="20" cols="60" style="width: 100%" wrap="VIRTUAL">$styleraw</textarea><br><br>
		<input type="submit" value="Save Changes"></div></form>~;
	CRHTMLFoot();
}
END_SUB

$Subs{'EditNewsStyles_EditSave'} = <<'END_SUB';
sub EditNewsStyles_EditSave {
	NeedCFG();
	my $style = $in{'stylename'};
	CRcough("That style doesn't exist.") unless $NewsStyles{$style};
	CRcough("Style cannot be empty. (You can delete a style instead.)") unless $in{'styleraw'};
	$in{'styleraw'} =~ s/\r//g; # Remove the Evil Carriage Return
	eval StyletoPerl('TempStyle', $in{'styleraw'});
	if ($@) {
		CRcough("That style is invalid and has a syntax error. Check, in particular, that all ifs are properly matched and ended. Perl reported the following error, which may or may not be helpful: <i>$@</i>", 1);
	}
	$NewsStyles{$style}->{'RawStyle'} = $in{'styleraw'};
	SaveCRCFG();
	my %profs = GetStyleProfiles();
	foreach (keys %{$profs{"NewsStyle_$style"}}) {
		$newsprofiles{$_}->{'ForceFullBuild'} = 1;
	}
	WriteProfileInfo();
	SimpleConfirmationPage('Style Changes Saved', "Your changes to style &quot;$NewsStyles{$style}->{'FullName'}&quot; have been saved. " .
		PageLink({'action' => 'admin', 'adminarea' => 'nstyle'}) . 'Back to Edit News Styles</a>.', 1);
}
END_SUB

$Subs{'EditNewsStyles_Delete'} = <<'END_SUB';
sub EditNewsStyles_Delete {
	NeedCFG();
	my $style = $in{'stylename'};
	CRcough("That style doesn't exist.") unless $NewsStyles{$style};
	CRcough("That style can't be deleted.") if $style =~ /[^a-z0-9_]/;
	my %profs = GetStyleProfiles();
	my @profs = keys %{$profs{"NewsStyle_$style"}};
	CRcough("That style is still being used by profile(s) " . join(', ', @profs) . ". While profiles are still using this style, it cannot be deleted.") if @profs;
	delete $NewsStyles{$style};
	SaveCRCFG();
	EditNewsStyles_Main();
}
END_SUB

$Subs{'StyletoPerl'} = <<'END_SUB';
sub StyletoPerl {
	my $stylename = shift;
	my $style = shift;

	# Welcome to the forest of regular expressions.

	# Accomodate some basic mistakes
	$style =~ s/<field: ([^>]+)>/<Field: $1>/gi;
	$style =~ s/<Field: text>/<Field: Text>/gi;
	$style =~ s/<Field: subject>/<Field: Subject>/gi;
	$style =~ s/<Field: user>/<Field: User>/gi;
	$style =~ s/<Field: userfield_email>/<Field: UserField_Email>/gi;
	$style =~ s/<If: isnewdate>/<If: Sub: isNewDate>/gi;
	$style =~ s/<\/if>/<\/If>/gi;

	# Get rid of PerlCode if not allowed
	unless ($EnableRawPerl) {
		$style =~ s/<\/?PerlCode>//gi;
	}
	
	# Escape everything other than perl code
	$style =~ s~\G(.*?)(\A|</PerlCode>)(.*?)(\Z|<PerlCode>)~$1 . $2 . qqEscape($3) . $4~ges; # thanks plush!
	# Now allow this code to execute
	$style =~ s/<PerlCode>/~;\n/g;
	$style =~ s!</PerlCode>!\n\$newshtml .= qq~!g;

	$style = "sub $stylename {\nmy \$newshtml = qq~$style";

	# Replace <Field: Name> with $Name
	$style =~ s/<Field: ([a-zA-Z0-9_]+)>/\$$1/g;
	# Replace <Field: Hash{"Key"}> with $Hash{"Key"}
	$style =~ s/<Field: ([a-zA-Z0-9_]+)\{"([a-zA-Z0-9_]+)"\}>/'$' . $1 . '{"' . $2 . '"}'/ge;

	# <TextField: Name>
	$style =~ s/<TextField: ([a-zA-Z0-9_]+)>/~;\n\$newshtml .= HTMLtoText(\$$1);\n\$newshtml .= qq~/g;
	# <TextField: Hash{"Key"}>
	$style =~ s/<TextField: ([a-zA-Z0-9_]+)\{"(a-zA-Z0-9_]+)"\}>/"~;\n\$newshtml .= HTMLToText(".'$'.$1.'{"'.$2.'"}' . ");\n\$newshtml .= qq~"/ge;
	
	# Replace <Sub: Name> with a call to &Name()
	$style =~ s/<Sub: ([a-zA-Z0-9_]+)>/~;\n\$newshtml .= &$1();\n\$newshtml .= qq~/g;

	# Replace <NP3Style: Name> with a call to &Name(), and then compensate for old style system.
	$style =~ s/<NP3Style: ([a-zA-Z0-9_]+)>/~;\n&$1();\n\$newshtml .= \$main::newshtml;\n\$newshtml .= qq~/g;

	# Replace <If: End> with a closing bracket
	$style =~ s/<If: End>/~;\n}\n\$newshtml .= qq~/g;
	# Replace </If> with a closing bracket
	$style =~ s/<\/If>/~;\n}\n\$newshtml .= qq~/g;
	# Replace <If: Else> with } else {
	$style =~ s/<If: Else>/~;\n} else {\n\$newshtml .= qq~/g;

	# Replace <If: Field: Name> with if ($Name)
	$style =~ s/<If: Field: ([a-zA-Z0-9_]+)>/~;\nif (\$$1) {\n\$newshtml .= qq~/g;
	# Replace <If: Field: Name eq 'something'> with if ($Name eq 'something') -- also supports ne
	$style =~ s/<If:\ Field:\ 
		([a-zA-Z0-9_]+)\ # Name of the field
		(eq|ne)\ # The operator
		(['"]) # Quotes, if any
		([^'"\n\$\@]+) # What it's being compared with
		\3 # Quotes, if any
		>/~;\nif (\$$1 $2 $3$4$3) {\n\$newshtml .= qq~/gx;
	# <If: Field: Name{"key"} eq 'something'>
	$style =~ s/<If:\ Field:\ 
		([a-zA-Z0-9_]+)\{"([a-zA-Z0-9_]+)"\}\ # Name of the field
		(eq|ne)\ # The operator
		(['"]) # Quotes
		([^'"\n\$\@]+) # What it's being compared with
		\4 # Quotes
		>/"~;\nif (\$$1" . qq~{"$2"}~ . " $3 $4$5$4) {\n\$newshtml .= qq~"/gex;
	# <If: Sub: Name eq 'something'>
	$style =~ s/<If:\ Sub:\ 
		([a-zA-Z0-9_]+)\ # Name of the sub
		(eq|ne)\ # The operator
		(['"]) # Quotes, if any
		([^'"\n\$\@]+) # What it's being compared with
		\3 # Quotes, if any
		>/~;\nif (&$1() $2 $3$4$3) {\n\$newshtml .= qq~/gx;
	# Replace <If: Field: Name == something> with if ($Name == something) -- also supports !=
	$style =~ s/<If:\ Field:\ 
		([a-zA-Z0-9_]+)\ # Name of the field
		(==|!=)\ # The operator
		(['"]?) # Quotes, if any
		(\d+) # What it's being compared with
		\3 # Quotes, if any
		>/~;\nif (\$$1 $2 $3$4$3) {\n\$newshtml .= qq~/gx;
	# <If: Field: Name{"key"} == something>
	$style =~ s/<If:\ Field:\ 
		([a-zA-Z0-9_]+)\{"([a-zA-Z0-9_]+)"\}\ # Name of the field
		(==|!=)\ # The operator
		(['"]?) # Quotes
		(\d+) # What it's being compared with
		\4 # Quotes
		>/"~;\nif (\$$1" . qq~{"$2"}~ . " $3 $4$5$4) {\n\$newshtml .= qq~"/gex;
	# <If: Sub: Name == something>
	$style =~ s/<If:\ Sub:\ 
		([a-zA-Z0-9_]+)\ # Name of the sub
		(!=|==)\ # The operator
		(['"]|) # Quotes, if any
		(\d+) # What it's being compared with
		\3 # Quotes, if any
		>/~;\nif (&$1() $2 $3$4$3) {\n\$newshtml .= qq~/gx;

	# Replace <If: Sub: Name> with if (&Name())
	$style =~ s/<If: Sub: ([a-zA-Z0-9_]+)>/~;\nif (&$1()) {\n\$newshtml .= qq~/g;

	# Replace <Snip 20: Field: Name> with SnipText($Name, 20);
	$style =~ s/<Snip (\d+): Field: ([a-zA-Z0-9_]+)>/~;\n\$newshtml .= SnipText(\$$2, $1);\n\$newshtml .= qq~/g;
	# <Snip 20: Field: Name{"key"}>
	$style =~ s/<Snip (\d+): Field: ([a-zA-Z0-9_]+)\{"([a-zA-Z0-9_]+)"\}>/"~;\n\$newshtml .= SnipText(\$$2" .
		'{"' . $3 . '"}' . ", $1);\n\$newshtml .= qq~"/ge;
	# <Snip 20: Sub: Name>
	$style =~ s/<Snip (\d+): Sub: ([a-zA-Z0-9_]+)>/~;\n\$newshtml .= SnipText(&$2(), $1);\n\$newshtml .= qq~/g;

	# <ItemAnchor>
	$style =~ s/<ItemAnchor>/#newsitem\$newsid/g;

	# Replace <If: Else: Field: Name> with elsif ($Name)
	$style =~ s/<If: Else: Field: ([a-zA-Z0-9_]+)>/~;\n} elsif (\$$1) {\n\$newshtml .= qq~/g;
	# Replace <If: Else: Field: Name eq 'something'> with elsif ($Name eq 'something') -- also supports ne
	$style =~ s/<If:\ Else:\ Field:\ 
		([a-zA-Z0-9_]+)\ # Name of the field
		(eq|ne)\ # The operator
		(['"]) # Quotes, if any
		([^'"\n\$\@]+) # What it's being compared with
		\3 # Quotes, if any
		>/~;\n} elsif (\$$1 $2 $3$4$3) {\n\$newshtml .= qq~/gx;
	# <If: Else: Field: Name{"key"} eq 'something'>
	$style =~ s/<If:\ Else:\ Field:\ 
		([a-zA-Z0-9_]+)\{"([a-zA-Z0-9_]+)"\}\ # Name of the field
		(eq|ne)\ # The operator
		(['"]) # Quotes
		([^'"\n\$\@]+) # What it's being compared with
		\4 # Quotes
		>/"~;\n} elsif (\$$1" . qq~{"$2"}~ . " $3 $4$5$4) {\n\$newshtml .= qq~"/gex;
	# <If: Else: Sub: Name eq 'something'>
	$style =~ s/<If:\ Else:\ Sub:\ 
		([a-zA-Z0-9_]+)\ # Name of the sub
		(eq|ne)\ # The operator
		(['"]) # Quotes, if any
		([^'"\n\$\@]+) # What it's being compared with
		\3 # Quotes, if any
		>/~;\n} elsif (&$1() $2 $3$4$3) {\n\$newshtml .= qq~/gx;
	# Replace <If: Else: Field: Name == something> with elsif ($Name == something) -- also supports !=
	$style =~ s/<If:\ Else:\ Field:\ 
		([a-zA-Z0-9_]+)\ # Name of the field
		(==|!=)\ # The operator
		(['"]?) # Quotes, if any
		(\d+) # What it's being compared with
		\3 # Quotes, if any
		>/~;\n} elsif (\$$1 $2 $3$4$3) {\n\$newshtml .= qq~/gx;
	# <If: Else: Field: Name{"key"} == something>
	$style =~ s/<If:\ Else:\ Field:\ 
		([a-zA-Z0-9_]+)\{"([a-zA-Z0-9_]+)"\}\ # Name of the field
		(==|!=)\ # The operator
		(['"]?) # Quotes
		(\d+) # What it's being compared with
		\4 # Quotes
		>/"~;\n} elsif (\$$1" . qq~{"$2"}~ . " $3 $4$5$4) {\n\$newshtml .= qq~"/gex;
	# <If: Else: Sub: Name == something>
	$style =~ s/<If:\ Else:\ Sub:\ 
		([a-zA-Z0-9_]+)\ # Name of the sub
		(!=|==)\ # The operator
		(['"]|) # Quotes, if any
		(\d+) # What it's being compared with
		\3 # Quotes, if any
		>/~;\n} elsif (&$1() $2 $3$4$3) {\n\$newshtml .= qq~/gx;

	# Replace <If: Else: Sub: Name> with elsif (&Name())
	$style =~ s/<If: Else: Sub: ([a-zA-Z0-9_]+)>/~;\n} elsif (&$1()) {\n\$newshtml .= qq~/g;

	# HOOK: StyletoPerl
	if($Addons{'StyletoPerl'}){my $w;foreach $w (@{$Addons{'StyletoPerl'}}){my $addon=$w->[2];eval ${$w->[0]};AErr($addon,$@)if $@;};}

	$style .= "~;\nreturn \$newshtml;\n}\n";
	return $style;
}
END_SUB

$Subs{'GetStyleSelect'} = <<'END_SUB';
sub GetStyleSelect {
	my $type = shift;
	$type = 'Standard' unless $type;
	NeedCFG();
	my @sl;
	my $i;
	foreach $i (sort keys %NewsStyles) {
		push(@sl, ["NewsStyle_$i", $NewsStyles{$i}->{'FullName'}]) if $NewsStyles{$i}->{'Type'} eq $type;
	}
	return \@sl;
}
END_SUB

$Subs{'GetStyleProfiles'} = <<'END_SUB';
sub GetStyleProfiles {
	# This handles Standard profiles. Addons which add new profile types should hook themselves in below.
	my (%profstyles, $key, $value);

	while (($key, $value) = each %newsprofiles) {
		unless ($key =~ /[^\w\d_]/) {
			$profstyles{$value->{'style'}}->{$key} = 1 if $value->{'style'};
			$profstyles{$value->{'arc-style'}}->{$key} = 1 if $value->{'arc-style'} && ($value->{'archive'} || $value->{'arc-style'} ne 'NewsStyle_Default');
			$profstyles{$value->{'headline-style'}}->{$key} = 1 if $value->{'headline-style'} && ($value->{'headlines'} || $value->{'headline-style'} ne 'NewsStyle_DefaultHeadline');
		}
	}
	
	# HOOK: GetStyleProfiles
	if($Addons{'GetStyleProfiles'}){my $w;foreach $w (@{$Addons{'GetStyleProfiles'}}){my $addon=$w->[2];eval ${$w->[0]};AErr($addon,$@)if $@;};}
	
	return %profstyles;
}
END_SUB

1;
