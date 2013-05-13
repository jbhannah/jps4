#! CRADDON 1
#! NAME News Categories
#! DESCRIPTION Allows news items to be categorized and allows profiles to include only certain categories of news.
#! VERSION build 8

# This is a semi-addon. Some categories functionality is already built in, such as:
# - Categories support when building news. (Enabled if $EnableCategories is true.)
# - Categories support when reading/writing profiles.
# - The $Category field is standard.
# This could all have been done via an addon, but given how common and central
# categories are, and given the luxury of being able to put this stuff in the core,
# it... wasn't.

# Will compile & work with the following.
#use strict;
#use vars qw(%newscategories %Subs %in %userdata $EnableCategories %CConfig);

my $addon = new Addon('News Categories');
$addon->checkBuild(31);
$addon->isPrivacyCompatible;
$addon->addAdminFunction('News Categories', 'Create and modify different categories that news items can be placed in.', 'newscatmain');
$addon->registerAdminFunction('newscatmain', 'NewsCategoriesMain');
$addon->registerAdminFunction('createcat', 'NewsCategories_CreateCat');
$addon->registerAdminFunction('editcat', 'NewsCategories_EditCat');
$addon->registerAdminFunction('editcatsave', 'NewsCategories_EditCatSave');
$addon->registerAdminFunction('delcat', 'NewsCategories_DeleteCat');

my $EditProfDefinition_1 = <<'END_CODE';
	my %selectedcats;
	foreach $i (@{$newsprofiles{$prof}->{'cats'}}) {
		$selectedcats{$i} = 'selected';
	}
	my $catselect = '';
	foreach $i (keys %newscategories) {
		unless ($i eq '(default)') {
			$catselect .= qq~
			<option value="$i" $selectedcats{$i}>$i</option>~;
		}
	}
	push(@EditProfileSettings,
		['cats', 'Categories', "Only news from selected categories will be included in this profile. Multiple selections are allowed: to make multiple selections, Windows users hold down CTRL, Mac users hold down Option, most UNIX users hold down CTRL, users of other operating systems see your browser's help.",
		qq~<select name="cats" size="6" multiple>
		<option value="AllCategories" $selectedcats{'AllCategories'}>(All Categories)</option>
		<option value="(default)" $selectedcats{'(default)'}>(Default Category)</option>
		$catselect
		</select>~]);
END_CODE

my $DisplaySubForm_TopRow = <<'END_CODE';
	print $addon->fieldsTableRow('Category', NewsCategories_GetCatSelect('Category', '(default)'));
END_CODE

my $SaveNews_1 = <<'END_CODE';
	$Category = $in{'Category'};
	$addon->minorError('You must provide a category.') unless $Category;
	$addon->minorError("That category doesn't exist.") unless $newscategories{$Category};
	unless  ($newscategories{$Category}->{'(AllUsers)'} || # The category is open to all
		($newscategories{$Category}->{'(High)'} && $up == 2) || # The category is open to High levelers
		$newscategories{$Category}->{$CurrentUser} || # This user has been granted permission
		$up == 3) { # User is an admin
		$addon->minorError("You are not authorized to submit items into this category.");
	}
END_CODE

my $ModifyNews_Permissions = <<'END_CODE';
	unless  ($newscategories{$Category}->{'(AllUsers)'} || # The category is open to all
		($newscategories{$Category}->{'(High)'} && $up == 2) || # The category is open to High levelers
		$newscategories{$Category}->{$CurrentUser} || # This user has been granted permission
		$up == 3) { # User is an admin
		#next NDLOOP;
		$stoppermnow = 1;
	}
END_CODE

my $ModifyNews_Delete_1 = <<'END_CODE';
	unless  ($newscategories{$Category}->{'(AllUsers)'} || # The category is open to all
		($newscategories{$Category}->{'(High)'} && $up == 2) || # The category is open to High levelers
		$newscategories{$Category}->{$CurrentUser} || # This user has been granted permission
		$up == 3) { # User is an admin
		$addon->minorError("You are not authorized to delete items from this category.");
	}
END_CODE

my $ModifyNews_Edit_TopRow = <<'END_CODE';
	unless  ($newscategories{$Category}->{'(AllUsers)'} || # The category is open to all
		($newscategories{$Category}->{'(High)'} && $up == 2) || # The category is open to High levelers
		$newscategories{$Category}->{$CurrentUser} || # This user has been granted permission
		$up == 3) { # User is an admin
		$addon->minorError("You are not authorized to modify items in this category.");
	}
	print $addon->fieldsTableRow('Category', NewsCategories_GetCatSelect('Category', $Category));
END_CODE

my $ModifyNews_EditSave_Permissions = <<'END_CODE';
	unless  ($newscategories{$Category}->{'(AllUsers)'} || # The category is open to all
		($newscategories{$Category}->{'(High)'} && $up == 2) || # The category is open to High levelers
		$newscategories{$Category}->{$CurrentUser} || # This user has been granted permission
		$up == 3) { # User is an admin
		$addon->minorError("You are not authorized to modify items in this category.");
	}
	if ($in{'Category'} && $newscategories{$in{'Category'}}) {
		$Category = $in{'Category'};
		unless  ($newscategories{$Category}->{'(AllUsers)'} || # The category is open to all
			($newscategories{$Category}->{'(High)'} && $up == 2) || # The category is open to High levelers
			$newscategories{$Category}->{$CurrentUser} || # This user has been granted permission
			$up == 3) { # User is an admin
			$addon->minorError("You are not authorized to move items into this category.");
		}
	}		
END_CODE

my $ModifyNews_NewColumn_1 = <<'END_CODE';
	if ($ColCount % 2) {
		print q~<td class="yellowbg">~;
	} 
	else {
		print q~<td class="lightgbg">~;
	}
	print '<div align="center"><b>Cat.</b></div></td>';
	$ColCount++;
END_CODE

my $ModifyNews_NewColumn_2 = <<'END_CODE';
	if ($ColCount % 2) {
		print q~<td class="navlink"><div align="center">~;
	}
	else {
		print q~<td class="lightgbg"><div align="center" class="footnote">~;
	}
	print $Category;
	print '</div></td>';
	$ColCount++;
END_CODE

my $EditProfileSave = <<'END_CODE';
	if ($in{'cats'}) {
		@{$newsprofiles{$prof}->{'cats'}} = split(/\|x\|/, $in{'cats'});
		delete $in{'cats'};
	}
END_CODE

my $ModifyNews_NewSearchField_1 = <<'END_CODE';
	print qq~<option value="Category">$Messages{'Category'}</option>~;
END_CODE

my $ModifyNews_NewSearchField_2 = <<'END_CODE';
	if ($in{'searchfield'} eq 'Category') {
		$FilterData{'field'} = 'Category';
	}
END_CODE


$addon->hook('EditProfDefinition_1', \$EditProfDefinition_1, 5);
$addon->hook('EarlyHook', 'NewsCategories_ReadCategoryInfo', 5);
$addon->hook('DisplaySubForm_TopRow', \$DisplaySubForm_TopRow, 1);
$addon->hook('SaveNews_1', \$SaveNews_1, 6);
$addon->hook('ModifyNews_Permissions', \$ModifyNews_Permissions, 1);
$addon->hook('ModifyNews_Delete_1', \$ModifyNews_Delete_1, 1);
$addon->hook('ModifyNews_Edit_TopRow', \$ModifyNews_Edit_TopRow, 1);
$addon->hook('ModifyNews_EditSave_Permissions', \$ModifyNews_EditSave_Permissions, 1);
$addon->hook('ModifyNews_NewColumn_1', \$ModifyNews_NewColumn_1, -5);
$addon->hook('ModifyNews_NewColumn_2', \$ModifyNews_NewColumn_2, -5);
$addon->hook('EditProfileSave', \$EditProfileSave);
$addon->hook('ModifyNews_NewSearchField_1', \$ModifyNews_NewSearchField_1);
$addon->hook('ModifyNews_NewSearchField_2', \$ModifyNews_NewSearchField_2);


sub NewsCategories_ReadCategoryInfo {
	%newscategories = ();
	ReadInnerHash('NewsCategories', 'Category', \%newscategories);
	$newscategories{'(default)'}->{'(AllUsers)'} = 1 unless $newscategories{'(default)'};
	$EnableCategories = 1;
}

sub NewsCategories_WriteCategoryInfo {
	WriteInnerHash('NewsCategories', 'Category', \%newscategories);
}

$Subs{'NewsCategoriesMain'} = <<'END_SUB';
sub NewsCategoriesMain {
	my $addon = shift;
	$addon->pageHeader('News Categories', 1);
	print $addon->heading('Current Categories');
	my $i;
	foreach $i (sort keys %newscategories) {
		my ($name, $desc, $actions);
		$name = $i;
		my $value = $newscategories{$i};
		if ($value->{'(AllUsers)'}) {
			$desc = 'This category is available to all users.';
		}
		else {
			my @userlist;
			$desc = 'This category is available to: <b>';
			if ($value->{'(High)'}) {
				@userlist = ('High level users')
			}
			push(@userlist, grep(!/^\(/, keys %$value));
			if (@userlist) {
				$desc .= join(', ', @userlist);
			}
			else {
				$desc .= 'nobody';
			}
			$desc .= '</b>.';
		}
		$actions = '[' . $addon->link({'action' => 'admin', 'adminarea' => 'delcat', 'cat' => $name}) .
			'Delete</a>] ' unless $name eq '(default)';
		$actions .= '[' . $addon->link({'action' => 'admin', 'adminarea' => 'editcat', 'cat' => $name}) . 
			'Edit Permissions</a>]';
		print $addon->itemTable($name, $desc, $actions);
	}
	print $addon->heading('Create New Category'),
		$addon->form({'action' => 'admin', 'adminarea' => 'createcat'}),
		$addon->settingTable('Category Name:', '<input type="text" name="cat">', 'Category names may only contain letters, numbers, and underscores (_).'),
		$addon->submitButton('Create Category'), '</form>';
	$addon->pageFooter;
}
END_SUB

$Subs{'NewsCategories_CreateCat'} = <<'END_SUB';
sub NewsCategories_CreateCat {
	my $addon = shift;
	my $cat = $in{'cat'};
	$addon->minorError("The entered category name contains illegal characters.") if ($cat =~ /[^a-zA-Z0-9_]/);
	$addon->minorError("Category $cat already exists.") if $newscategories->{$cat};
	$newscategories{$cat} = {'(AllUsers)' => 1};
	NewsCategories_WriteCategoryInfo();
	NewsCategoriesMain($addon);
}
END_SUB

$Subs{'NewsCategories_EditCat'} = <<'END_SUB';
sub NewsCategories_EditCat {
	my $addon = shift;
	my $cat = $in{'cat'};
	$addon->minorError("Category $cat doesn't exist.") unless $newscategories{$cat};
	$addon->pageHeader("Edit Category $cat", 1);
	my $nc = $newscategories{$cat};
	my $userselect = '<select name="catperm" size="8" multiple><option value="(AllUsers)" ' .
		($nc->{'(AllUsers)'} ? 'selected' : '') . '>(All Users)</option><option value="(High)"' .
		($nc->{'(High)'} ? ' selected' : '') . '>(High Level Users)</option>';
	my $i;
	foreach $i (sort keys %userdata) {
		$userselect .= qq~<option value="$i"~ . 
			($nc->{$i} ? ' selected' : '') .
			">$i</option>";
	}
	$userselect .= '</select>';
	print $addon->form({'action' => 'admin', 'adminarea' => 'editcatsave', 'cat' => $cat}),
		$addon->settingTable('Permissions:', $userselect, 
		qq~Users that you select will be able to submit items to, and modify items in, category &quot;$cat&quot;.
		You may select multiple users (by using your CTRL or Option key). Administrator users will always
		have full access to every category.~),
		'<div align="center"><input type="submit" value="Save Changes"></div></form>';
	$addon->pageFooter;
}
END_SUB

$Subs{'NewsCategories_EditCatSave'} = <<'END_SUB';
sub NewsCategories_EditCatSave {
	my $addon = shift;
	my $cat = $in{'cat'};
	$addon->minorError("Category $cat doesn't exist.") unless $newscategories{$cat};
	my $i;
	$newscategories{$cat} = {};
	foreach $i (split(/\|x\|/, $in{'catperm'})) {
		$newscategories{$cat}->{$i} = 1;
	}
	NewsCategories_WriteCategoryInfo();
	NewsCategoriesMain($addon);
}
END_SUB

$Subs{'NewsCategories_DeleteCat'} = <<'END_SUB';
sub NewsCategories_DeleteCat {
	NeedCFG();
	my $addon = shift;
	my $cat = $in{'cat'};
	$addon->minorError("Category $cat doesn't exist.") unless $newscategories{$cat};
	$addon->minorError("You can't do that!") if $cat eq '(default)';
	AreYouSure("If you delete this category, all items which were previously in this category will be moved into the default category. Are you sure you want to delete it?") unless $in{'really'};
	delete $newscategories{$cat};
	delete $CConfig{"Category-$cat"};
	
	my ($fh, $fh2) = EditNewsdat_Start();
	
	NDLOOP: while (<$fh>) {
		chomp($_);
		SplitDataFile($_);
		if ($Category eq $cat) {
			$Category = '(default)';
			my $newsline = JoinDataFile();
			print $fh2 $newsline, "\n";
		}
		else {
			print $fh2 $_, "\n";
		}
	}
	
	close($fh);
	close($fh2);
	EditNewsdat_Finish();
	&NewsCategoriesMain($addon);
}
END_SUB

$Subs{'NewsCategories_GetCatSelect'} = <<'END_SUB';
sub NewsCategories_GetCatSelect {
	my ($name, $selected) = @_;
	my $select = qq~<select name="$name">~;
	my $cats;
	foreach $cats (sort keys %newscategories) {
		if ($newscategories{$cats}->{'(AllUsers)'} || # The category is open to all
			($newscategories{$cats}->{'(High)'} && $up == 2) || # The category is open to High levelers
			$newscategories{$cats}->{$CurrentUser} || # This user has been granted permission
			$up == 3) { # User is an admin
			$select .= qq~<option value="$cats"~ . ($cats eq $selected ? ' selected' : '') . ">$cats</option>";
		}
	}
	$select .= '</select>';
	return $select;
}
END_SUB

1;
