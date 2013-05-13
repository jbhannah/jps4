#!C:/Perl/bin/perl.exe

###############################################
# Read ZCOMMENT.CGI for licencing information #
###############################################

$zcommentbuild = 8;

# BELOW IS ABSOLUTLY, POSITIVLY REQUIRED IF YOU USE IIS!
# Specify the absolute path to the directory ZComment is stored in,
# not the file.
$abs = "";
push (@INC, $abs) if ($abs);

print "Content-type: text/html\n";

eval {
 require "zcomment_include.cgi";
};

if ($@) {
	print "Content-type: text/html\n\n";
	print "<b>Critical Error:</b> Cannot read <b>zcomment_include.cgi</b>, please be sure it is uploaded and set accordingly.";
	exit;
}

if ($zcommentbuild != $includebuild) {
	print "Content-type: text/html\n\n";
	print "<b>Critical Error:</b> The versions of <b>zcomment_include.cgi</b> and <b>zcomment.cgi</b> do not match.";
	exit;
}

$admin = $page{'admin'};

if (!$ENV{'QUERY_STRING'}) {
	if ($cookies{'admin'} eq $settings{'zcomment_pass'}) {
		print "Location: zcomment_admin.cgi?admin=main\n\n";
	} else {
		&top("Administrative Login");
		&message("Please login to the administrative password below...");
		print qq~
		<form method="post" action="zcomment_admin.cgi?admin=auth">
		<b>Password:</b> <input type="password" name="pass">
		<input type="submit" value="Login">
		</form>
		~;
		bottom();
	}
} elsif ($admin eq "auth") {

	
	if ($form{'pass'} eq $settings{'zcomment_pass'}) {
		if ($IIS) {
			print "HTTP/1.0 200 OK\n";
		}
		print "Set-Cookie: admin=$form{'pass'};\n";
		&simplepage("Login Sucessful", "You have been sucessfully logged in.<br><br><a href=\"zcomment_admin.cgi?admin=main\">Continue</a> - Go To Administrative Main Page");
	} else { &simplepage("Invalid Password", "The password you entered was invalid. Please try again."); }

} elsif ($admin eq "main") {

	if ($cookies{'admin'} eq $settings{'zcomment_pass'}) {
		&top("Administration Main");
		&message("Welcome to ZComment's administrative section. The version you are using is <b>beta build 7</b>. You might want to check out <a href=\"http://zcomment.b000.net/\">the official website</a> for updates.<br><br>");
		print qq~
		Administer:<br>
		[<a href="zcomment_admin.cgi?admin=users">Users</a>] [<a href="zcomment_admin.cgi?admin=comments">Comments</a>].
		<br><br>
		<a href="zcomment_admin.cgi?admin=logout">Logout</a> - Exit the script and kill all cookies.
		~;
		bottom();
	} else { &simplepage("Invalid Password", "The password you entered was invalid. Please try again."); }

} elsif ($admin eq "logout") {
	if ($IIS) { print "HTTP/1.0 200 OK\n"; }

	print "Content-Type: text/html\n";
	print "Set-Cookie: admin=;\n\n";

	&simplepage("Logged Out", "You have been sucessfully logged out.");

} elsif ($admin eq "comments") {

	if ($cookies{'admin'} eq $settings{'zcomment_pass'}) {
		&top("Comments Administration");
		&message("Should be self explanitory. <a href=\"zcomment_admin.cgi?admin=main\">Back To Administrative Main</a><br><br>");

		open(N, "$newsdatpath") || zdie("Cannot open $newsdatpath. <br><Br> $!");
		while (<N>) {
			($subject, $name, $post, $id, $date, $cat) = split (/``x/);
			print "[<a href=\"zcomment_admin.cgi?admin=view&post=$id\">View</a>] [<a href=\"zcomment_admin.cgi?admin=prune&post=$id\">Remove All</a>] comments for \"$subject\" by $name.<br>";
		}
		close (N);
		bottom();
	} else { &simplepage("Invalid Password", "The password you entered was invalid. Please try again."); }

} elsif ($admin eq "view") {

	if ($cookies{'admin'} eq $settings{'zcomment_pass'}) {
		&top("Viewing Comments For $page{'post'}");
		message("For the post id $page{'post'}.<br><br>");

		my $num = 0;

		open (C, "$settings{'zcomment_location'}$page{'post'}.txt");
		while (<C>) {
			($id, $subject, $name, $title, $email, $comment) = split (/``x/);

			if (length($_) > 4) {
				$num++;
				print qq~$subject... by <b>$name</b> $title... [<a href="zcomment_admin.cgi?admin=delete&rem=$id&mom=$page{'post'}">Delete</a>] [<a href="zcomment_admin.cgi?admin=edit&edi=$id&mom=$page{'post'}">Edit</a>]<br>~;
			}
		}
		close (C);

		unless ($num) {
			print "Currently are no comments for this post.";
		}
		bottom();

	} else { &simplepage("Invalid Password", "The password you entered was invalid. Please try again."); }

} elsif ($admin eq "delete") {

	if ($cookies{'admin'} eq $settings{'zcomment_pass'}) {
		open (C, "$settings{'zcomment_location'}$page{'mom'}.txt") || zdie("Cannot open $settings{'zcomment_location'}$page{'mom'}.txt. <br><Br> $!");
		while(<C>) {
			($id, $mommy, $name, $title, $email, $comment) = split (/``x/);
			unless ($id eq $page{'rem'}) {
				$comments .= $_;
			}
		}
		close (C);
		

		open (C, ">$settings{'zcomment_location'}$page{'mom'}.txt") || zdie("Cannot open $settings{'zcomment_location'}$page{'mom'}.txt. <br><br> $!");
		print C $comments;
		close (C);

		build();

		print "Location: zcomment_admin.cgi?admin=view&post=$page{'mom'}\n\n";

	} else { &simplepage("Comment Deletion", "The password you entered was invalid. Please try again."); }

} elsif ($admin eq "prune") {

	if ($page{'confirm'}) {
		unlink <$settings{'zcomment_location'}$page{'post'}.txt>;
		print "Location: zcomment_admin.cgi?admin=comments\n\n";
		build();
	} else { &simplepage("Prune Confirmation", "Are you sure you want to remove all comments for coranto id '$page{'post'}'?<br><br><a href=\"zcomment_admin.cgi?admin=prune&post=$page{'post'}&confirm=yes\">Yes</a> &nbsp;&nbsp; <a href=\"zcomment_admin.cgi?admin=comments\">No</a>"); }

} elsif ($admin eq "edit") {

	if ($cookies{'admin'} eq $settings{'zcomment_pass'}) {
		&top("Editing Comment ID $page{'edi'}");

		&message("Fill out the form below to edit the comment... <a href=\"zcomment_admin.cgi?admin=comments\">Back To Comments Administration Page</a><br><br>");
	
		open (C, "$settings{'zcomment_location'}$page{'mom'}.txt") || zdie("Cannot open $settings{'zcomment_location'}$page{'mom'}.txt. <br><br> $!");
		USER: while (<C>) {
			($id, $subject, $name, $title, $email, $comment) = split (/``x/);
	
			$comment =~ s/<Br>/\n/g;

			if ($id eq $page{'edi'}) {
				print qq~
				<form method="post" action="zcomment_admin.cgi?admin=editform&edi=$id&mom=$page{'mom'}">
				<b>Name:</b> <input type="text" name="name" value="$name"><br>
				<b>E-Mail:</b> <input type="text" name="email" value="$email"><br>
				<b>Subject:</b> <input type="text" name="subject" value="$subject"><br>
				<b>Comment:</b><br>
				<textarea rows="6" cols="50" name="comment">$comment</textarea><br>
				<input type="submit" value="Edit">

				</form>
				~;

				last USER;
			}
		}
		close (C);
		bottom();
	} else { &simplepage("Invalid Password", "The password you entered was invalid. Please try again."); }

} elsif ($admin eq "editform") {

	if ($cookies{'admin'} eq $settings{'zcomment_pass'}) {
	
		
		$name = $form{'name'};
		$email = $form{'email'};
		$comment = $form{'comment'};
		$subject = $form{'subject'};

		$subject =~ s/</&lt;/g;
		$subject =~ s/>/&gt;/g;
		$subject =~ s/`/'/g;
		
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

		$comments = 0;

		open (C, "$settings{'zcomment_location'}$page{'mom'}.txt") || zdie("Cannot open $settings{'zcomment_location'}$page{'mom'}.txt. <br><br> $!");
		while(<C>) {
			($fid, $mommy, $fname, $title, $femail, $fcomment) = split (/``x/);
			if ($fid eq $page{'edi'}) {
				$comments .= "$fid``x$subject``x$name``x$title``x$email``x$comment\n";
			} else {
				$comments .= $_;
			}
		}
		close(C);

		open (C, ">$settings{'zcomment_location'}$page{'mom'}.txt") || zdie("Cannot open $settings{'zcomment_location'}$page{'mom'}.txt. <br><br> $!");
		print C $comments;
		close (C);

		print "Location: zcomment_admin.cgi?admin=view&post=$page{'mom'}\n\n";

	} else { &simplepage("Invalid Password", "The password you entered was invalid. Please try again."); }

} elsif ($admin eq "users") {

	if ($cookies{'admin'} eq $settings{'zcomment_pass'}) {

		top("User Administration");

		&message("To delete a user, click the [delete] link next to their name. <a href=\"zcomment_admin.cgi?admin=main\">Back To Administrative Main</a><br><br>");

		open (U, "zcomment_users.pl") || zdie("Cannot open zcomment_users.pl. <br><br> $!");
		while (<U>) {
			($name, $pass) = split (/``x/);

			if (length($_) > 2) { print qq~$name - [<a href="zcomment_admin.cgi?admin=deluser&user=$name">delete</a>]<br>~; }
		}
		close(U);

		bottom();

	} else { &simplepage("Invalid Password", "The password you entered was invalid. Please try again."); }

} elsif ($admin eq "deluser") {

	if ($cookies{'admin'} eq $settings{'zcomment_pass'}) {

		open (U, "zcomment_users.pl") || zdie("Cannot open zcomment_users.pl. <br><Br> $!");
		while (<U>) {
			($name, $pass) = split (/``x/);
			unless ($page{'user'} eq $name) {
				$users .= $_;
			}
		}
		close (U);
	
		open (U, ">zcomment_users.pl") || zdie("Cannot open zcomment_users.pl. <br><Br> $!");
		print U $users;
		close (U);

		print "Location: zcomment_admin.cgi?admin=users\n\n";

	} else { &simplepage("Invalid Password", "The password you entered was invalid. Please try again."); }

} else {
	&simplepage("Powered By ZComment", "Powered By <a href=\"http://zcomment.b000.net/\">ZComment</a>.");
}
