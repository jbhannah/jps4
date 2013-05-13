#!C:\Perl\bin\perl.exe

# Name of style to use if none is set in the url.
my $VNStyle = 'Default News Style';

# Name of template to use if none is set in the url (without .tmpl extension).
my $VNTMPL = 'viewnews';

# END OF SETTINGS (unless you encounter problems - then fill out the next section)

# EXTRA SERVER INFORMATION
# Coranto tries to determine its path and URL automatically. This works in 90%
# of cases, but some servers aren't cooperative and don't allow this information
# to be found automatically. Though it won't hurt, there's no need to fill this out
# unless you encounter problems.

$abspath = '';
# Set the above to the absolute path to Coranto's directory, without
# a trailing slash. Example:
# $abspath = '/absolute/path/to/coranto';

$scripturl = '';
# Set the above to the URL to coranto.cgi. Example:
# $scripturl = 'http://www.myserver.com/coranto/coranto.cgi';
# END EXTRA SERVER INFORMATION

#######
# START (Unless you know Perl, don't change anything after this point.)
#######

$crcgiBuild = 39;
$crcgiVer = '1.24';
$crcgiRC = 0;

eval {
   &main;
};
CRdie("Untrapped Error: $@") if $@;

sub main {
   # Try and be compatible with Microsoft IIS.
   unshift @INC, $1 if $0 =~ m!(.*)(\\|\/)!;

   # If extra server information was specified, use it.
   push @INC, $abspath if $abspath;
   
   NeedFile('cruser.pl');
   NeedFile('crcore.pl');
   NeedFile('crlib.pl');
   print &header;
   &NeedCFG;
   
   $CurrentTime = time;
   # Put the script's URL into $scripturl.
   # Don't if it was already set as a server problem workaround.
   $scripturl = &GetScriptURL unless $scripturl;

   # Get form input
   &ReadForm;
   
   # Read in settings
   &ReadConfigInfo;
   $CConfig{'neverSave'} = 1;

   if ($CConfig{'CorantoSQL_built'} eq 'yes') {
      eval {
         require DBI;
         DBI->import;
      };
      CRdie("DBI could not be found. Therefore, you cannot use Coranto SQL (please disable it and try again).") if $@;
      $CConfig{'CorantoSQL_path'} = $CConfig{'htmlfile_path'} unless $CConfig{'CorantoSQL_path'};
      NeedFile("$CConfig{'CorantoSQL_path'}/crsql_sqlstuff.pl");
   }
   
   if ($CConfig{'AddonsLoaded'}) {
      NeedFile('craddon.pl');
      &LoadAddons;
   }
   
   package main;
   &ReadProfileInfo;

   # Initialize the date-retrieval subroutines.
   InitGTD($CConfig{'DateFormat'}, 'GetTheDate');
   InitGTD($CConfig{'InternalDateFormat'}, 'GetTheDate_Internal');

   # HOOK: ViewNews_If
   if($Addons{'ViewNews_If'}){for my $w (@{$Addons{'ViewNews_If'}}){my $addon=$w->[2];eval ${$w->[0]};AErr($addon,$@)if $@;};}
   
   # compatibility
   $in{'id'} = $1 if $ENV{'QUERY_STRING'} =~ /newsid(\w+)$/;
   
   ViewNews(
      (exists $in{'id'} ? 1 : 2),
      ($in{'id'} or $in{'cat'}),
      ($in{'style'} or $VNStyle),
      ($in{'tmpl'} or $VNTMPL)
   ) if exists $in{'id'} or exists $in{'cat'};

   CRdie('No parameters given.');
}

sub ViewNews {
   my ($mode, $id, $style, $tmpl) = @_;
   
   CRdie("The ID contains an invalid character. Please check the link and try again!") if $mode == 1 and $id =~ /[^0-9a-zA-Z]/;

   # HOOK: ViewNews_0
   if($Addons{'ViewNews_0'}){for my $w (@{$Addons{'ViewNews_0'}}){my $addon=$w->[2];eval ${$w->[0]};AErr($addon,$@)if $@;};}

   my ($newshtml, $newsnum, $title);

   if ($style =~ /Default News Style$/i) {
      $style = 'Default';
   } elsif ($style =~ /Default Headline Style$/i) {
      $style = 'DefaultHeadline';
   } else {
      $style =~ s/ /_/g;
      $style = lc $style;
      $style =~ s/[^a-z0-9_]//g;
   }

   # HOOK: ViewNews_1
   if($Addons{'ViewNews_1'}){for my $w (@{$Addons{'ViewNews_1'}}){my $addon=$w->[2];eval ${$w->[0]};AErr($addon,$@)if $@;};}

   if ($CConfig{'CorantoSQL_built'} eq 'yes') {
      my $dbh = &CorantoSQL_connectdb;
      my $sth = $dbh->prepare(qq~SELECT * FROM $CConfig{'CorantoSQL_tblname'} WHERE Category='$id' OR newsid='$id'~);
      $sth->execute;
      $newsnum = 1;
      NCLOOP: while ($corantosql_ref = $sth->fetchrow_hashref) {
         &GetSQLFields;
         next NCLOOP if $mode == 1 and $newsid ne $id or $mode == 2 and $Category ne $id;
         $FileName = 'viewnews';
         $ProfileName = 'viewnews';
         $Date = GetTheDate($newstime);
         $title = $mode == 1 ? $Subject : $Category;
         &ReadUserInfo;
         &InitUserFieldVars;

         # HOOK: ViewNews_2
         if($Addons{'ViewNews_2'}){for my $w (@{$Addons{'ViewNews_2'}}){my $addon=$w->[2];eval ${$w->[0]};AErr($addon,$@)if $@;};}

         $newshtml .= &{"NewsStyle_$style"};

         # HOOK: ViewNews_3
         if($Addons{'ViewNews_3'}){for my $w (@{$Addons{'ViewNews_3'}}){my $addon=$w->[2];eval ${$w->[0]};AErr($addon,$@)if $@;};}
         
         $newsnum++;
      }
      $sth->finish;
      $dbh->disconnect;
   }
   else {
      my $ndfh = CRopen("$CConfig{'htmlfile_path'}/newsdat.txt");
      $newsnum = 1;
      NCLOOP: while (<$ndfh>) {
         chomp;
         SplitDataFile($_);
         next NCLOOP if $mode == 1 and $newsid ne $id or $mode == 2 and $Category ne $id;
         $FileName = 'viewnews';
         $ProfileName = 'viewnews';
         $Date = GetTheDate($newstime);
         $title = $mode == 1 ? $Subject : $Category;
         &ReadUserInfo;
         &InitUserFieldVars;

         # HOOK: ViewNews_2
         if($Addons{'ViewNews_2'}){for my $w (@{$Addons{'ViewNews_2'}}){my $addon=$w->[2];eval ${$w->[0]};AErr($addon,$@)if $@;};}

         $newshtml .= &{"NewsStyle_$style"};

         # HOOK: ViewNews_3
         if($Addons{'ViewNews_3'}){for my $w (@{$Addons{'ViewNews_3'}}){my $addon=$w->[2];eval ${$w->[0]};AErr($addon,$@)if $@;};}
         
         $newsnum++;

         # BUG FIXED IN 1.03
         last NCLOOP if $mode == 1 and $newsid eq $id;
      }
      close $ndfh;
   }

   # HOOK: ViewNews_4
   if($Addons{'ViewNews_4'}){for my $w (@{$Addons{'ViewNews_4'}}){my $addon=$w->[2];eval ${$w->[0]};AErr($addon,$@)if $@;};}

   CRdie('Could not find that news entry or category.') if $newsnum == 1;
   GenPage(\$newshtml, $title, $tmpl);
   exit;
}

# Gets our full URL. Needed for error messages.
sub GetScriptURL {
   my $url = ($ENV{'HTTPS'} ? 'https://' : 'http://') . ($ENV{'HTTP_HOST'} ? $ENV{'HTTP_HOST'} : $ENV{'SERVER_NAME'}) .  
   ($ENV{'SERVER_PORT'} != 80 && $ENV{'HTTP_HOST'} !~ /:/ ? ":$ENV{'SERVER_PORT'}" : '') .
   $ENV{'SCRIPT_NAME'};
   return $url;
   
}

sub CRdie {
   print "Content-type: text/html\n\n" unless $HeaderPrinted;
   print "<html><body><h1>Error</h1>$_[0]</body></html>";
   exit;
}

sub GenPage {
   my ($content, $title, $tmpl) = @_;
   print ProcessTMPL("$CConfig{admin_path}/$tmpl.tmpl", $content, $title, 0, 1);
}

sub AUTOLOAD {
   my $sub = $AUTOLOAD;
   $sub =~ s/.+\:\://;
   if ($Subs{$sub}) {
      eval $Subs{$sub};
      if ($@) { die ("Subroutine $AUTOLOAD encountered a compile error during autoload: $@"); }
   }
   else {
      die("Subroutine $AUTOLOAD was called, but does not exist. (It isn't already loaded, and it isn't in the cache.)");
   }
   delete $Subs{$sub};
   goto &$AUTOLOAD;
}

sub CRopen ($;$$) {
   my $filename = shift;
   my $filehandle = do { local *FH };
   $filename = SecurePath($filename);
   open($filehandle, $filename) or CRdie("Could not open file $filename. $@");
   return $filehandle;
}

my %LoadedFiles;  
sub NeedFile {
   my $file = shift;
   unless (exists $LoadedFiles{$file}) {
      eval { require $file; };
      CRdie("Could not load file $file.") if $@;
      $LoadedFiles{$file} = 1;
   }
}

sub CRHTMLHead {
   my $title = shift;
   print qq~<!doctype html public "-//W3C//DTD HTML 4.0 Transitional//EN"><html><head><title>View News: $title</title></head><body>~;
}

sub CRHTMLFoot_NoNav { &CRHTMLFoot; }

sub CRHTMLFoot {
   print '</body></html>';
}
