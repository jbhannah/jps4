#! CRADDON 1
#! NAME Backup
#! DESCRIPTION Keeps backups of your news database that are updated weekly.
#! VERSION build 2
#! UPGRADECHECK backup,1
#! DOC 1

$BackupTime = 60 * 60 * 24 * 7; # The frequency of backups, in seconds.

my $addon = new Addon('Backup');
$addon->checkBuild(31);
$addon->isPrivacyCompatible;

my $Backup = <<'END_CODE';
	if ($CConfig{'Backup_LastBackup'} && ($CurrentTime - $CConfig{'Backup_LastBackup'}) > $BackupTime && $BackupTime) {
		# It's time for a backup
		my $b1e = -e "$CConfig{'htmlfile_path'}/newsbak1.txt";
		my $b2e = -e "$CConfig{'htmlfile_path'}/newsbak2.txt";
		my $ntmp = -s "$CConfig{'htmlfile_path'}/ndtmp2.txt";
		return 0 unless $ntmp;
		if ($b2e) {
			# Delete backup #2
			unlink "$CConfig{'htmlfile_path'}/newsbak2.txt" || $addon->fatalError("Could not delete backup file $CConfig{'htmlfile_path'}/newsbak2.txt");
		}
		if ($b1e) {
			# Rotate backup #1 to backup #2
			rename("$CConfig{'htmlfile_path'}/newsbak1.txt", "$CConfig{'htmlfile_path'}/newsbak2.txt") || $addon->fatalError("Could not rename backup file $CConfig{'htmlfile_path'}/newsbak1.txt to $CConfig{'htmlfile_path'}/newsbak2.txt");
		}
		# Rotate ndtmp2.txt (previous newsdat) to backup #1
		rename("$CConfig{'htmlfile_path'}/ndtmp2.txt", "$CConfig{'htmlfile_path'}/newsbak1.txt") || $addon->fatalError("Could not rename news database $CConfig{'htmlfile_path'}/ndtmp2.txt to backup file $CConfig{'htmlfile_path'}/newsbak1.txt");
		# Save time of backup
		$CConfig{'Backup_LastBackup'} = $CurrentTime;
		# Create dummy ndtmp2.txt so that coranto doesn't create an error when it tries to delete it.
		my $fh = $addon->open(">>$CConfig{'htmlfile_path'}/ndtmp2.txt");
		close($fh);
	}
	elsif (!$CConfig{'Backup_LastBackup'}) {
		$CConfig{'Backup_LastBackup'} = $CurrentTime;
	}
END_CODE

$addon->hook('EditNewsdat_Finish', \$Backup);

1;

__END__

=head1 Backup

=head2 DESCRIPTION & USAGE

The Backup addon maintains two rotating backups of your news database, updated weekly. The backups are kept in your News Files path; newsbak1.txt is a backup of newsdat.txt from 0 to 7 days old, and newsbak2.txt is between 7 and 14 days old.

The Backup addon operates transparently. When enabled, it will maintain the backup when necessary as you submit new news items. Though maintaining two extra copies of your news database will increase disk space requirements, the Backup addon should not noticeably slow anything down.

=head2 CONFIGURATION

Generally, there is no configuration to be done. There is one optional setting: the time interval after which backups are updated. By default, this is seven days. To change this, edit cra_backup.pl and see the $BackupTime line near the top.

=head2 IN CASE OF FIRE

If something happens to your news database (newsdat.txt) and you need to restore from backup, rename newsbak1.txt to newsdat.txt. If necessary, an even older backup should be available in newsbak2.txt.