#!C:/Perl/bin/perl.exe

#################################
# ZCOMMENT by AGNST             #
# email AGNST@STONEDMONKEYS.COM #
##########################################################
# LICENCE INFO::   You can modify it, you can change it, #
# but you CANNOT release the modified version as yours   #
# or even as a modified version of mine. You can't post  #
# it on your site without my direct permission. If you   #
# do, may Jebiz save your soul. If you see this on a     #
# site that isn't my own (b000.net/zcomment) please      #
# notify me with the contact information above.          #
##########################################################

$zcommentbuild = 8;

# BELOW IS ABSOLUTLY, POSITIVLY REQUIRED IF YOU USE IIS!
# Specify the absolute path to the directory ZComment is stored in,
# not the file.

$abs = "";
push (@INC, $abs) if ($abs);

eval {
 require "zcomment_include.cgi";
};

if ($@) {
	print "Content-type: text/html\n\n";
	print "<b>Critical Error:</b> Cannot read <b>zcomment_include.cgi</b>, please be sure it is uploaded and set accordingly.";
	print "<br><br>Actually, I'm lying...sorta. This is the REAL error: <br><br>\n\n$@";
	exit;
}

if ($zcommentbuild != $includebuild) {
	print "Content-type: text/html\n\n";
	print "<b>Critical Error:</b> The versions of <b>zcomment_include.cgi</b> and <b>$settings{'zcomment_url'}</b> do not match.";
	exit;
}

if ($page{'article'}) {
	open(N, $newsdatpath) || zdie("Cannot open newsdat.txt. <br><br> $!");
	DISPLAY: while (<N>) {
		require "crcfg.dat";
		SplitDataFile($_);
		if ($newsid eq $page{'article'}) {
			$found = 1;
			top($Subject);

			&date();

			eval $settings{'zcomment_display_text'};

			$html =~ s/\\"/\"/g;
			$html =~ s/\(ns!x!nl\)/\n/g;
			print $html . "<br><br>";
			last DISPLAY;
		}
	}
	close (N);

	if (!$found) {
		&top($zlang{'error'});
		message($zlang{'unknown_article'});
		bottom();
		exit;
	}

	$num = 0;
	if ($settings{'zcomment_text'} ne "no display") { print "<u>$settings{'zcomment_text'}:</u><br>"; }

	open(C, "$settings{'zcomment_location'}$page{'article'}.txt");
	while (<C>) {
		($postid, $subject, $name, $title, $email, $comment) = split (/``x/);

		if (length($_) > 2) {
			if ($num == 0) { $num++; }
			if ($title eq "a" or $title eq "(Anonymous)") { $title = $settings{'zcomment_display_anonymous'}; }
			elsif ($title eq "r" or $title eq "(Registered)") { $title = $settings{'zcomment_display_registered'}; }

			&date();

			eval $settings{'zcomment_display_comment'};

			$html =~ s/\\"/\"/g; $html =~ s/\(ns!x!nl\)/\n/g;
			print $html . "<br><br>";
		}
	}

	if ($num == 0) { print "<em>$zlang{'currently_none'}</em><br><br>"; }

	print qq~
	<b>$zlang{'toolbox'}:</b><br>
	<a href="$settings{'zcomment_url'}?register=change">$zlang{'change_your_password_link'}</a><br>
	<a href="$settings{'zcomment_url'}?register=clear">$zlang{'clear_remember_me_link'}</a><br>
	<a href="$settings{'zcomment_url'}?register=form">$zlang{'register_link'}</a><br><br>

	<form method="post" action="$settings{'zcomment_url'}?id=$page{'article'}">~;
	if ($cookies{'zpass'}) { print qq~ <input type="hidden" name="cookiepass" value="yes"> ~; }
	print qq~
	<table border="0" cellspacing="2" cellpadding="2">
	<tr>
	<td>$settings{'zcomment_display_font'}<b>$zlang{'name'}:</b><b>*</b></font></td><td>$settings{'zcomment_display_font'}<input type="~;

	if ($cookies{'zname'}) { print "hidden"; } else { print "text"; }

	print qq~" name="name" value="$cookies{'zname'}">~;

	if ($cookies{'zname'}) { print $cookies{'zname'}; }

	print qq~</font></td></tr><tr><td>$settings{'zcomment_display_font'}<b>$zlang{'password'}:</b></td><td>$settings{'zcomment_display_font'}<input type="~;

	if ($cookies{'zpass'}) { print "hidden"; } else { print "password"; }

	print qq~" name="pass" value="$cookies{'zpass'}">~;

	if ($cookies{'zpass'}) { print "($zlang{'logged_in'})"; }
	else { print qq~ ($zlang{'register_link_form'} <a href=\"$settings{'zcomment_url'}?register=form\">$zlang{'register'}</a>)~; }

	print qq~</font></td></tr>
	<tr><td>$settings{'zcomment_display_font'}<b>$zlang{'email'}:</b></font></td><td><input type="text" name="email" value="$cookies{'zmail'}" size="30"></td></tr>
	<tr><td>$settings{'zcomment_display_font'}<b>$zlang{'subject'}*:</b></font></td><td><input type="text" name="subject"></td></tr>
	<tr><td colspan="2">$settings{'zcomment_display_font'}<b>$zlang{'comment'}:</b> <b>*</b></font></td></tr>
	<tr><td colspan="2"><textarea cols="50" rows="6" name="comment"></textarea></td></tr>
	</table>
	<input type="checkbox" name="remember" value="yes"~;
	if ($cookies{'zname'}) {
		print " checked";
	} print qq~ > $zlang{'remember_me'}?<br>
	<input type="submit" value="$zlang{'submit'}">
	</form>

	<b>*</b> = Required.
	~;

	bottom();

} elsif ($page{'id'}) {

	$cname = $form{'name'};
	$cname =~ s/  / /g;
	$name = $form{'name'};
	$pass = $form{'pass'};
	$email = $form{'email'};
	$comment = $form{'comment'};
	$remember = $form{'remember'};
	$subject = $form{'subject'};

	$name =~ s/</&lt;/g;
	$name =~ s/>/&gt;/g;
	$name =~ s/`/'/g;

	$email =~ s/</&lt;/g;
	$email =~ s/>/&gt;/g;
	$email =~ s/`/'/g;

	$comment =~ s/</&lt;/g;
	$comment =~ s/>/&gt;/g;
	$comment =~ s/`/'/g;
	$comment =~ s/\n/<Br>/g;
	$comment =~ s/\r//g;
	$comment =~ s/\"/\\"/g;

	$cookiepass = $form{'cookiepass'};

	get_unique();

	if (!$cookiepass) { $pass = crypt($pass, 87); }

	$valid = 0;
	$taken = 0;

	open(U, "zcomment_users.pl") || zdie("Cannot open zcomment_users.pl. <br><Br>$!");
	USERLOOP: while (<U>) {
		($fname, $fpass) = split(/``x/);

		chomp($fpass);

		if (substr($cname, -1, 1) eq " ") { $cname = substr($cname, 0, length($cname) - 1); }
		elsif (substr($cname, 0, 1) eq " ") { $cname = substr($cname, 1, length($cname) - 1); }

		if (lc($cname) eq lc($fname) && $pass ne $fpass) { $taken = 1; }

		if (lc($cname) eq lc($fname) && $pass eq $fpass) {
			$valid = 1;
			$taken = 0;
			last USERLOOP;
		}
	}
	close(U);
	
	if ($valid) { $title="r"; } else { $title="a"; }

	if (length($name) > 1 && length($comment) > 1 && length($subject) > 1) {
		if ($taken) {
			&simplepage($zlang{'error'}, $zlang{'username_taken'});
		} else {
			open (C, ">>$settings{'zcomment_location'}$page{'id'}.txt") || zdie("Cannot open $settings{'zcomment_location'}$page{'id'}.txt. <br><br> $!");
			print C "\n$unique``x$subject``x$name``x$title``x$email``x$comment";
			close (C);

			build();

			if ($remember) {
				print "Set-Cookie: zname=$cname; expires=Thu, 16-Jan-2009 00:00:00 GMT; \n";
				print "Set-Cookie: zmail=$form{'email'}; expires=Thu, 16-Jan-2009 00:00:00 GMT; \n";
				if ($valid) { print "Set-Cookie: zpass=$pass; expires=Thu, 16-Feb-2009 00:00:00 GMT; \n"; }
			} else {
				print "Set-Cookie: zname=; expires=Thu, 16-Jan-1999 00:00:00 GMT; \n";
				print "Set-Cookie: zmail=; expires=Thu, 16-Jan-1999 00:00:00 GMT; \n";
				print "Set-Cookie: zpass=; expires=Thu, 16-Jan-1999 00:00:00 GMT; \n";
			}
				print "Location: $settings{'zcomment_url'}?article=$page{'id'}\n\n";
		}
	} else {
		&simplepage($zlang{'error'}, $zlang{'missing_fields'});
	}

} elsif ($page{'register'} eq "clear") {

	print "Set-Cookie: zname=; expires=Thu, 16-Jan-1980 00:00:00 GMT; \n";
	print "Set-Cookie: zpass=; expires=Thu, 16-Jan-1980 00:00:00 GMT; \n";
	print "Set-Cookie: zmail=; expires=Thu, 16-Jan-1980 00:00:00 GMT; \n";

	&simplepage($zlang{'remember_me'} . " " . $zlang{'info_cleared'}, $zlang{'info_cleared_mess'} . " <a href=\"$ENV{'HTTP_REFERER'}\">$zlang{'go_back'}</a>.");

} elsif ($page{'register'} eq "form") {
	&top($zlang{'register_link'});
	&message($zlang{'register_your_username_mess'});

	if (!$ENV{'HTTP_REFERER'}) { $referer = "$settings{'zcomment_url'}?register=form"; }
	else { $referer = $ENV{'HTTP_REFERER'}; }

	print qq~
	<form method="post" action="$settings{'zcomment_url'}?register=apply">
	<input type="hidden" value="$referer" name="back">
	<table border="0" cellspacing="2" cellpadding="2">
	<tr><td>$settings{'zcomment_display_font'}<b>$zlang{'name'}:</b></font></td><td><input type="text" name="name"></td></tr>
	<tr><td>$settings{'zcomment_display_font'}<b>$zlang{'password'}:</b></font></td><td><input type="password" name="pass"></td></tr>
	<tr><td>$settings{'zcomment_display_font'}<b>$zlang{'confirm_password'}:</b></font></td><td><input type="password" name="pass2"></td></tr>
	</table>
	<input type="submit" value="$zlang{'submit'}">
	</form>

	~;

	bottom();

} elsif($page{'register'} eq "apply") {
	
	$cname = $form{'name'};
	$cname =~ s/  / /g;

	if (substr($cname, -1, 1) eq " ") { $cname = substr($cname, 0, length($cname) - 1); }
	elsif (substr($cname, 0, 1) eq " ") { $cname = substr($cname, 1, length($cname) - 1); }

	$taken = 0;
	open(U, "zcomment_users.pl") || zdie("Cannot open zcomment_users.pl. <br><br> $!");
	REST: while (<U>) {
		($fname, $fpass) = split(/``x/);

		chomp($fpass);

		if (lc($cname) eq lc($fname)) {
			$taken = 1;
			last REST;
		}

	}
	close(U);

	if ($taken) { &simplepage($zlang{'error'}, $zlang{'taken_username'});
	} else {

		$name = $form{'name'};
		$pass = $form{'pass'};
		$pass2 = $form{'pass2'};

		if ($pass eq $pass2) { $go = 1; }

		if (!$go) {
			&simplepage($zlang{'error'}, $zlang{'password_mismatch'});
		} else {

			$pass = crypt($pass, 87);
			
			open (U, ">>zcomment_users.pl") || zdie("Cannot open zcomment_users.pl. <br><br> $!");
			print U "\n$name``x$pass\n";
			close (U);

			&simplepage($zlang{'name_created'}, "$zlang{'name_created_mess'} <br><br> <a href=\"$form{'back'}\">$zlang{'go_back'}</a>.");
		}
	}

} elsif ($page{'register'} eq "change") {

	&top($zlang{'change_your_password'});
	&message($zlang{'change_your_password_mess'});

	print qq~
	
	<form method="post" action="$settings{'zcomment_url'}?register=password">
	<table border="0" cellspacing="2" cellpadding="2">
	<tr><td>$settings{'zcomment_display_font'}<b>$zlang{'name'}:</b></font></td><td><input type="text" name="username"></td></tr>
	<tr><td>$settings{'zcomment_display_font'}<b>$zlang{'old_password'}:</b></font></td><td><input type="password" name="oldpassword"></td></tr>
	<tr><td>$settings{'zcomment_display_font'}<b>$zlang{'password'}:</b></font></td><td><input type="password" name="newpassword"></td></tr>
	<tr><td>$settings{'zcomment_display_font'}<b>$zlang{'confirm_new_password'}:</b></font></td><td><input type="password" name="newpasswordtwo"></td></tr>
	</table>
	<input type="submit" value="$zlang{'submit'}">
	</form>

	~;

	bottom();

} elsif ($page{'register'} eq "password") {

	$username = $form{'username'};
	$oldpass = $form{'oldpassword'};
	$newpass = $form{'newpassword'};
	$newpass2 = $form{'newpasswordtwo'};

		if ($newpass2 eq $newpass && length($newpass2) > 1 && length($newpass) > 1) {

			$valid = 0;
			open (U, "zcomment_users.pl") || zdie("Cannot open zcomment_users.pl. <br><Br> $!");
			VALID: while (<U>) {
				($fname, $fpass) = split(/``x/);
				chomp($fpass);
				if (lc($username) eq lc($fname) && crypt($oldpass, 87) eq $fpass) {
					$valid = 1;
					last VALID;
				}
			}
			close (U);

			if ($valid) {
				open(UV, "zcomment_users.pl") || zdie("Cannot opne zcomment_users.pl. <br><br> $!");
				@users = <UV>;
				close (UV);

				open (U, ">zcomment_users.pl") || zdie("Cannot open zcomment_users.pl. <br><br> $!");
				foreach $u (@users) {
					($name, $pass) = split (/``x/, $u);
					if ($name eq $username) {
						$newpass = crypt($newpass, 87);
						print U "$name``x$newpass\n";
					} else {
						print U $u;
					}
				}
				close (U);
				&simplepage($zlang{'password_changed'}, $zlang{'password_changed_mess'});
				
			} else {
				&simplepage($zlang{'error'}, $zlang{'invalid_password'});
			}

		} else {
			&simplepage($zlang{'error'}, $zlang{'password_mismatch'});
		}

} else { &simplepage("ZComment", $zlang{'powered_by'}); }