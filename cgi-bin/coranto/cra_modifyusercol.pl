#! CRADDON 1
#! NAME Modify News: User Column
#! DESCRIPTION Adds a User column to Modify News pages.
#! VERSION build 2
#! DOC 1

my $addon = new Addon('Modify News: User Column');
$addon->checkBuild(31);
$addon->isPrivacyCompatible;

my $hook1 = <<'END_CODE';
	if ($ColCount % 2) {
		print q~<td class="yellowbg">~;
	} 
	else {
		print q~<td class="lightgbg">~;
	}
	print qq~<div align="center"><b>$Messages{'User'}</b></div></td>~;
	$ColCount++;
END_CODE

my $hook2 = <<'END_CODE';
	if ($ColCount % 2) {
		print q~<td class="navlink"><div align="center">~;
	}
	else {
		print q~<td class="lightgbg"><div align="center" class="footnote">~;
	}
	print $User;
	print '</div></td>';
	$ColCount++;
END_CODE

$addon->hook('ModifyNews_NewColumn_1', \$hook1);
$addon->hook('ModifyNews_NewColumn_2', \$hook2);

1;

__END__

=head1 Modify News: User Column

=head2 USAGE

This simple sample addon adds a User column, containing the name of the user that posted an item, to Modify News pages when enabled.
