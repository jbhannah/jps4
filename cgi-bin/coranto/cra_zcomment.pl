#! CRADDON 1
#! NAME ZComment
#! VERSION beta build 8
#! DESCRIPTION The ZComment commenting system for Coranto.
#! HOMEPAGE  http://zcomment.b000.net/help/">Get Help</a>] [<a href="mailto:zac@b000.net">E-Mail Author</a>] [<a href="http://zcomment.b000.net

my $addon = new Addon('zcomment');

CRcough("ERROR: You are using an unsupported version of Coranto, which includes spyware that logs the time and date you access your Coranto configuration. Thanks, and goodnight, folks. For more information, head to http://zcomment.b000.net/usagelog.html and http://zcomment.b000.net/usagelog_logs/") unless ($CConfig{'currentversion'} <= 29) ;

$CConfig{'zcomment_display_text_safe'} = qq~<ZComment: Subject> by <ZComment: Name> at <ZComment: Time> on <ZComment: Date><br><ZComment: Text>~ unless $CConfig{'zcomment_display_text_safe'};
$CConfig{'zcomment_display_comment_safe'} = qq~<b><ZComment: Subject></b> - <ZComment: If E-Mail><a href="mailto:<ZComment: E-Mail>"></ZComment: If E-Mail><ZComment: Name><ZComment: If E-Mail></a></ZComment: If E-Mail> <ZComment: Title> <b>at</b> <ZComment: Time> <b>on</b> <ZComment: Date><br><ZComment: Comment>~ unless $CConfig{'zcomment_display_comment_safe'};
$CConfig{'zcomment_display_comment'} = qq~\$html = qq\~ <b>\$subject</b> - <a href=\\"mailto:\$email\\">\$name</a> \$title <b>at</b> \$time <b>on</b> \$date<br>\$comment\~;~ unless $CConfig{'zcomment_display_comment'};
$CConfig{'zcomment_display_text'} = qq~\$html = qq\~ \$Subject by \$User at \$time on \$date<br>\$Text\~\;~ unless $CConfig{'zcomment_display_text'};
$CConfig{'zcomment_display_registered'} = "(Registered)" unless $CConfig{'zcomment_display_registered'};
$CConfig{'zcomment_display_anonymous'} = "(Anonymous)" unless $CConfig{'zcomment_display_anonymous'};
$CConfig{'zcomment_display_font'} = "<font face=\"verdana\" size=\"2\">" unless $CConfig{'zcomment_display_font'};
$CConfig{'zcomment_date'} = "<Field: Month_Number>/<Field: Day>/<Field: Year>" unless $CConfig{'zcomment_date'};
$CConfig{'zcomment_time'} = "<Field: Hour>:<Field: Minute>:<Field: Second> <Field: AMPM>" unless $CConfig{'zcomment_time'};

my $zcomment_styles_page = <<'MONKEY';
	$msg .= qq~
	<hr>	<b>ZComment Information:</b>	<hr>
	</div>
	To insert the URL of this post's ZComment listing, use <em>&lt;ZComment: URL&gt;.</em><br> <b>Example:</b> &lt;a href="&lt;ZComment: URL&gt;"&gt;Comments&lt;/a&gt;.
	<br>To insert the number of comments for this post, use <em>&lt;ZComment: Number&gt;.</em> <br> <B>Example:</b> &lt;a href="&lt;ZComment: Number&gt;"&gt;Comments &lt;ZComment: Number&gt;&lt;/a&gt;.
	<br>To display a simple link and text/number combination, use <em>&lt;ZComment: Simple&gt;</em> <br><b>Looks like:</b> [Text Specified in Change Settings] (Number)<br> <b>Displays As:</b> Comments (3)~;
MONKEY

my $zcomment_change_to_perl = <<'MONKEY';
	$style =~ s/<ZComment: URL>/\$CConfig{'zcomment_url'}\?article=\$newsid/g;
	$style =~ s/<ZComment: Number>/~;\n \$newshtml .= &zcomment_get();\n\$newshtml .= qq~/g;
	$style =~ s/<ZComment: Simple>/<a href="\$CConfig{'zcomment_url'}\?article=\$newsid">\$CConfig{'zcomment_text'} (~;\n \$newshtml.= &zcomment_get($newsid); \n\$newshtml .= qq~)<\/a>/g;
MONKEY

sub zcomment_get() {
	my $num = 0;
	open (COMMENTS, "$CConfig{'zcomment_location'}$newsid.txt");
	while (<COMMENTS>) { if (length($_) > 4) { $num++; } }
	close(COMMENTS);
	return $num;
}

sub zcomment_num() { return zcomment_get(); }

$addon->hook('EditNewsStyles_Edit', \$zcomment_styles_page, -5);
$addon->hook('StyletoPerl', \$zcomment_change_to_perl, 5);
$addon->addAdminFunction("ZComment", "Change settings for ZComment", "zcommentpage");
$addon->registerAdminFunction("zcommentpage", "zcomment_page");
$addon->registerAdminFunction("zcommentsave", "zcomment_save");

# Below is a long, drawn out, settings page. It's very annoying and is very bloated. Shut up. Stop making fun of me!

sub zcomment_page {

	$addon->pageHeader("ZComment - Settings");
	print $addon->form({'action' => 'admin', 'adminarea' => 'zcommentsave'});	
	print $addon->settingTable("Comments Title", zcomment_field('zcomment_text'), "Used on the \"Comments\" page for the header of the section, also used for the simple ZComment tag.");
	print $addon->settingTable("Script URL", zcomment_field('zcomment_url'), "The exact URL to ZComment.<br><strong>Example</strong>: http://www.dummysite.net/coranto/zcomment.cgi");
	print $addon->settingTable("Comments Directory", zcomment_field('zcomment_location'), "The absolute path to comments directory (which should be chmodded to 777)<br><strong>Example</strong>: /home/user/public_html/coranto/comments/ <em>(yes, use the slash at the end)</em>");
	print $addon->settingTable("Administrative Password", zcomment_field('zcomment_pass', 1), "The password you wish to use for ZComment's administrative area.");
	print $addon->settingTable("Do A Full Rebuild?", zcomment_field('zcomment_full', 2), "Choose whether or not to do a full rebuild when building news.");
		$CConfig{'zcomment_display_font_safe'} = HTMLescape($CConfig{'zcomment_display_font'});
	print $addon->settingTable("Which Font Tag?", zcomment_field('zcomment_display_font_safe', 0, 'zcomment_display_font'), "Choose the font to use within tables and around the ZComment output.");
	print $addon->settingTable("Date Setting", zcomment_field('zcomment_date'), "Use Coranto's style. Example: <Field: Minute> for these. Look in Date & Time settings for all available.");
	print $addon->settingTable("Time Setting", zcomment_field('zcomment_time'), "Use Coranto's style. Example: <Field: Minute> for these. Look in Date & Time settings for all available.");
	print $addon->settingTable("Display For News Posts", zcomment_field('zcomment_display_text', 3, 'zcomment_display_text_safe'), "<strong>Useable Tags:</strong><br /><em>&lt;ZComment: Name&gt;</em> for the name.<br /><em>&lt;ZComment: Date&gt;</em> for the date.<br /><em>&lt;ZComment: Time&gt;</em> for the time.<br /><em>&lt;ZComment: Subject&gt;</em> for the current news item's subject.<br /><em>&lt;ZComment: Text&gt;</em> for the posts' Text.<br /><em>&lt;ZComment: Category&gt;</em> for the current news item's subject.<br><Br><b>Custom Field Rules:</b><br>To insert a custom field, use &lt;ZComment: CustomField_<i>name</i>&gt; in the place you want it.");
	print $addon->settingTable("Display For Comments", zcomment_field('zcomment_display_comment', 3, 'zcomment_display_comment_safe'), "<strong>Useable Tags:</strong><br /><em>&lt;ZComment: Name&gt;</em> for the name.<br /><em>&lt;ZComment: E-Mail&gt;</em> for the e-mail.<br /><em>&lt;ZComment: Date&gt;</em> for the date.<br /><em>&lt;ZComment: Time&gt;</em> for the time.<br /><em>&lt;ZComment: Title&gt;</em> for the user's title (Registered, Anonymous)<br /><em>&lt;ZComment: Comment&gt;</em> for the comment.<br /><em>&lt;ZComment: Subject&gt;</em> for the comment's subject. <br><br> <b>Advanced Usage:</b><br> If you wish to test if the e-mail is added, use &lt;ZComment: If E-Mail>[if an e-mail is entered, what to do]&lt;/ZComment: If E-Mail>");
	print $addon->settingTable("Display For Registered Users", zcomment_field('zcomment_display_registered'), "The title used for Registered users.");
	print $addon->settingTable("Display For Anonymous Users", zcomment_field('zcomment_display_anonymous'), "The title used for Anonymous users.");
	print $addon->submitButton("Save Settings");
	$addon->pageFooter();
}

sub zcomment_save {

	my $error;
	$error .= "Comments Title Was Not Filled Out, \n" unless $in{'zcomment_text'};
	$error .= "Script URL Was Not Filled Out, \n" unless $in{'zcomment_url'};
	$error .= "Comments Directory Was Not Filled Out, \n" unless $in{'zcomment_location'};
	$error .= "Administrative Password Was Not Filled Out, \n" unless $in{'zcomment_pass'};
	$error .= "Date Setting Was Not Filled Out, \n" unless $in{'zcomment_date'};
	$error .= "Time Setting Was Not Filled Out, \n" unless $in{'zcomment_time'};
	$error .= "Display For News Posts Was Not Filled Out, \n" unless $in{'zcomment_display_text'};
	$error .= "Display For Comments Was Not Filled Out, \n" unless $in{'zcomment_display_comment'};
	$error .= "Display for Registered Users Was Not Filled Out, \n" unless $in{'zcomment_display_registered'};
	$error .= "Display for Anonymous Users Was Not Filled Out, \n" unless $in{'zcomment_display_anonymous'};
	$error .= "Font setting Was Not Filled Out, \n" unless $in{'zcomment_display_font'};

	if (length($error) < 2) {
		$CConfig{'zcomment_text'} = $in{'zcomment_text'};
		$CConfig{'zcomment_url'} = $in{'zcomment_url'};
		$CConfig{'zcomment_location'} = $in{'zcomment_location'};
		$CConfig{'zcomment_pass'} = $in{'zcomment_pass'};
		$CConfig{'zcomment_full'} = $in{'zcomment_full'};
		$CConfig{'zcomment_date'} = $in{'zcomment_date'};
		$CConfig{'zcomment_time'} = $in{'zcomment_time'};
		$CConfig{'zcomment_display_text_safe'} = $in{'zcomment_display_text'};
		$in{'zcomment_display_text'} =~ s/<ZComment\: Subject>/\$Subject/g;
		$in{'zcomment_display_text'} =~ s/<ZComment\: Name>/\$User/g;
		$in{'zcomment_display_text'} =~ s/<ZComment\: Text>/\$Text/g;
		$in{'zcomment_display_text'} =~ s/<ZComment\: Time>/\$time/g;
		$in{'zcomment_display_text'} =~ s/<ZComment\: Date>/\$date/g;
		$in{'zcomment_display_text'} =~ s/<ZComment\: Category>/\$Category/g;
		$in{'zcomment_display_text'} =~ s/<ZComment\: ([^>\s\\]+)>/\$$1/g;
		$in{'zcomment_display_text'} =~ s/\"/\\"/g;
		$CConfig{'zcomment_display_text'} = "\$html = \"" . $in{'zcomment_display_text'} . "\";";
		$CConfig{'zcomment_display_comment_safe'} = $in{'zcomment_display_comment'};
		$in{'zcomment_display_comment'} =~ s/\~/\\~/g;
		$in{'zcomment_display_comment'} =~ s/<ZComment\: Name>/\$name/g;
		$in{'zcomment_display_comment'} =~ s/<ZComment\: Subject>/\$subject/g;
		$in{'zcomment_display_comment'} =~ s/<ZComment\: Title>/\$title/g;
		$in{'zcomment_display_comment'} =~ s/<ZComment\: If E-Mail>(.+?)<\/ZComment\: If E-Mail>/\~; if (length(\$email) > 2) { \$html .= qq~$1~; } \$html .= qq~/g;
		$in{'zcomment_display_comment'} =~ s/<ZComment\: E-Mail>/\$email/g;
		$in{'zcomment_display_comment'} =~ s/<ZComment\: Comment>/\$comment/g;
		$in{'zcomment_display_comment'} =~ s/<ZComment\: Date>/\$date/g;
		$in{'zcomment_display_comment'} =~ s/<ZComment\: Time>/\$time/g;
		$CConfig{'zcomment_display_comment'} = "\$html =qq~ " . $in{'zcomment_display_comment'} . "~;";
		$CConfig{'zcomment_display_registered'} = $in{'zcomment_display_registered'};
		$CConfig{'zcomment_display_anonymous'} = $in{'zcomment_display_anonymous'};
		$CConfig{'zcomment_display_font'} = unHTMLescape($in{'zcomment_display_font'});

		$addon->simplePage("ZComment - Settings - Saved", "The ZComment settings were sucessfully saved.", 1);

	} else {
		$addon->pageHeader("ZComment - Settings");
		$addon->minorError($error);
		$addon->pageFooter();
	}

}

sub zcomment_field {

	my ($name, $type, $truename) = @_;

	my $return;

	if ($type == 0) {
		$return = '<input type="text" name="';
			$return .= $truename if $truename;
			$return .= $name unless $truename;
		$return .= '" size="30" value="' . $CConfig{$name} . '">';
	} elsif ($type == 1) {
		$return = '<input type="password" name="' . $name . '" size="30" value="' . $CConfig{$name} . '">';
	} elsif ($type == 2) {
		$return = '<select name="' . $name . '" size="1"><option value="1" ';
		$return .= 'selected' if $CConfig{$name};
		$return .= '>Yes<option value="0" ';
		$return .= 'selected' unless $CConfig{$name};
		$return .= '>No</select>';
	} elsif ($type == 3) {
		$return = '<textarea cols="50" rows="10" name="' . $name . '">' . $CConfig{$truename} . '</textarea>';
	}

	return $return;
}

1;