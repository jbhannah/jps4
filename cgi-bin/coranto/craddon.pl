# Coranto addon architecture
#
# This file is not really commented -- see documentation for information
# about the addon interface.

#######
# INTERNAL/LOADING/ERRORS
#######

$Addons++; # Lets parts of coranto know that there are addons loaded.

# Traps addon errors & offers to disable the addon.
sub AErr {
	my ($addon, $errmsg) = @_;
	if ($CConfig{'AutoDisableAddons'}) {
		ForceDisableAddon($addon->{'file'});
	}
	my $msg = "Addon $addon->{'name'} ($addon->{'file'}) caused an error. ";
	if ($up == 3) {
		$msg .= PageLink({'action' => 'fdisableaddon', 'addon' => $addon->{'file'}}) .
		"Disable the addon</a> to prevent this error from recurring. ";
	}
	$msg .= "Error: $errmsg";
	CRdie($msg, 1);
}

# Disables an addon
$Subs{'ForceDisableAddon'} = <<'END_OF_SUB';
sub ForceDisableAddon {
	my $addon = shift;
	my @AddonsLoaded = split(/~/, $CConfig{'AddonsLoaded'});
	@AddonsLoaded = grep(!/\Q$addon\E/, @AddonsLoaded);
	$CConfig{'AddonsLoaded'} = join('~', @AddonsLoaded);
}
END_OF_SUB

my ($NextAddon, %AddonAdminSubs, %AddonFunctionSubs, @AddonAvailableFunctions, @AddonAdminFunctions, @isPrivacyCompatible);
my (@AddonAdvancedSettings, @AddonProfileTypes, @AddonStyleTypes, @AddonSortOrders);

# These are subroutines coranto uses to access read-only addon variables, set via the interface by addons.
sub GetAddonAdminSubs { %AddonAdminSubs; }
sub GetAddonFunctionSubs { %AddonFunctionSubs; }
sub GetAddonAvailableFunctions { @AddonAvailableFunctions; }
sub GetAddonAdminFunctions { @AddonAdminFunctions; }
sub GetAddonAdvancedSettings { @AddonAdvancedSettings; }
sub GetAddonProfileTypes { @AddonProfileTypes; }
sub GetAddonStyleTypes { @AddonStyleTypes; }
sub GetAddonSortOrders { @AddonSortOrders; }

# Loads all enabled addons.
sub LoadAddons {
	if ($in{'action'} eq 'fdisableaddon' && $in{'addon'} && $up == 3) {
		ForceDisableAddon($in{'addon'});
		$in{'action'} = '';
	}
	my @addons = split(/~/, $CConfig{'AddonsLoaded'});
	my $i;
	foreach $i (@addons) {
		$NextAddon = $i;
		eval { require "$CConfig{'admin_path'}/$i"; };
		if ($@) {
			my $msg = $@;
			undef %Addons;
			if (-e "$CConfig{'admin_path'}/$i") {
				my $diemsg = "Addon '$i' caused a syntax error when loaded. ";
				if ($up == 3) {
					$diemsg .= PageLink({'action' => 'fdisableaddon', 'addon' => $i}) .
					"Disable the addon</a> to prevent this error from recurring. ";
				}
				$diemsg .= "Error: $msg";
				CRdie($diemsg, 1);
			}
			else {
				ForceDisableAddon($i);
				CRcough("Addon '$i' does not appear to exist. It has been disabled. Reload/refresh this page to continue. Full error: $msg");
			}
		}
		unless ($CConfig{'PublicOrPrivate'} or grep /^\Q$i\E$/, @isPrivacyCompatible) {
			ForceDisableAddon($i);
			CRcough("Since you have enabled this Coranto installation to operate as a private installation, and addon '$i' does not appear to comply with the security policies set for addons running under private installations, addon '$i' has been disabled.");
		}
		if ($NextAddon) {
			undef %Addons;
			ForceDisableAddon($i);
			#CRdie("Addon $i misbehaved by not registering itself when loaded. It had been disabled.");
		}
	}
}	


#######
# ADDON CLASS (THE ADDON INTERFACE)
#######
			
package Addon;

# Allows subroutines to be cached in memory, speeding compile time.
sub AUTOLOAD {
	my $sub = $AUTOLOAD;
	main::CRdie("Error: AUTOLOAD called without providing subroutine. ($sub)") unless $sub;
	$sub =~ s/.+\:\://;
	if ($Subs{$sub}) {
		eval $Subs{$sub};
	}
	else {
		main::CRdie("Subroutine $AUTOLOAD was called, but does not exist. (It isn't already loaded, and it isn't in the cache.)");
	}
	delete $Subs{$sub};
	goto &$AUTOLOAD;
}

sub DESTROY { } # Autoload'll complain when we destroy objects if this isn't here.

# Creates a new Addon object
sub new {
	my $class = shift;
	my $name = shift;
	unless ($name) {
		main::ForceDisableAddon($NextAddon);
		main::CRdie("Addon $NextAddon did not provide a name. It has been disabled.");
	}
	main::CRdie("Addon $name is attempting to register without being enabled by the user.") unless $NextAddon;
	my $self = {};
	$self->{'name'} = $name;
	$self->{'file'} = $NextAddon;
	$NextAddon = '';
	bless $self, $class;
}

# Allows an addon to hook itself in at a particular point.
sub hook {
	my ($self, $hook, $code, $priority) = @_;
	unless (ref($code)) {
		# translate all code to the reference format
		my $newcode = "&$code(\$addon);";
		$code = \$newcode;
	}
	$priority = 0 unless $priority;
	my @hc = ($code, $priority, $self);
	INSHOOK: {
		if ($main::Addons{$hook}) {
			# There are already addons at this hook; insert our addon in correct priority position.
			my $i;
			my $len = @{$main::Addons{$hook}};
			for ($i = 0; $i < $len; $i++) {
				if ($priority >= ${$main::Addons{$hook}}[$i]->[1]) {
					splice(@{$main::Addons{$hook}}, $i, 0, \@hc);
					last INSHOOK;
				}
			}
			splice(@{$main::Addons{$hook}}, $len, 0, \@hc);
		}
		else {
			$main::Addons{$hook} = [ \@hc ];
		}
	}
}

# The following are the addon interface functions.
# Most are simple wrappers to internal Coranto functions.

sub open {
	my $self = shift;
	main::CRopen($_[0], $self->{'file'}, $self->{'name'});
}

sub registerMainFunction {
	my ($self, $name, $subname) = @_;
	$AddonFunctionSubs{$name} = [$subname, $self];
}

sub registerAdminFunction {
	my ($self, $name, $subname) = @_;
	$AddonAdminSubs{$name} = [$subname, $self];
}	

sub isPrivacyCompatible {
	my $self = shift;
	push @isPrivacyCompatible, $self->{'file'};
}

sub addMainFunction {
	shift;
	push(@AddonAvailableFunctions, [ @_ ]);
}

sub addAdminFunction {
	shift;
	push(@AddonAdminFunctions, [ @_ ]);
}

sub addAdvancedSetting {
	shift;
	push(@AddonAdvancedSettings, [ @_ ]);
}

sub addAdvancedSettingHeading {
	shift;
	my $name = shift;
	push(@AddonAdvancedSettings, [ "heading: $name" ]);
}

sub addProfileType {
	shift;
	push(@AddonProfileTypes, @_);
}

sub addStyleType {
	shift;
	push(@AddonStyleTypes, @_);
}

sub addSortOrder {
	shift;
	push(@AddonSortOrders, [ @_ ]);
}

sub checkBuild {
	my ($self, $build) = @_;
	if ($build > $main::crcgiBuild) {
		main::ForceDisableAddon($self->{'file'});
		main::CRcough("Addon $self->{'name'} requires build $build or higher of Coranto. You are running build $main::crcgiBuild. Please upgrade. This addon has been disabled; re-enable it via the Addon Manager once you've upgraded.");
	}
}

sub inputField {
	my($self,$type,$name,$value) = @_;
	return qq~<input type="$type" name="$name" value="$value">~;
}

%Subs = (
	
'pageHeader' => <<'END_SUB',
sub pageHeader {
	shift;
	main::CRHTMLHead(@_);
}
END_SUB

'pageFooter' => <<'END_SUB',
sub pageFooter {
	main::CRHTMLFoot();
}
END_SUB

'simplePage' => <<'END_SUB',
sub simplePage {
	shift;
	main::SimpleConfirmationPage(@_);
}
END_SUB

'heading' => <<'END_SUB',
sub heading {
	shift;
	main::MidHeading(@_);
}
END_SUB

'itemTable' => <<'END_SUB',
sub itemTable {
	shift;
	main::Tricolore(@_);
}
END_SUB

'settingTable' => <<'END_SUB',
sub settingTable {
	shift;
	main::SettingsTable(@_);
}
END_SUB

'fieldsTable' => <<'END_SUB',
sub fieldsTable {
	main::StartFieldsTable();
}
END_SUB

'fieldsTableRow' => <<'END_SUB',
sub fieldsTableRow {
	shift;
	main::FieldsRow(@_);
}
END_SUB

'descParagraph' => <<'END_SUB',
sub descParagraph {
	shift;
	main::MidParagraph(@_);
}
END_SUB

'submitButton' => <<'END_SUB',
sub submitButton {
	shift;
	main::SubmitButton(@_);
}
END_SUB

'fatalError' => <<'END_SUB',
sub fatalError {
	main::AErr(@_);
}
END_SUB

'minorError' => <<'END_SUB',
sub minorError {
	my $self = shift;
	my $err = shift;
	$err = main::HTMLescape($err);
	my $msg = "Addon $self->{'name'} reported an error: $err ";
	if ($main::up == 3) {
		$msg .= '(' . main::PageLink({'action' => 'fdisableaddon', 'addon' => $self->{'file'}}) .
		"disable addon $self->{'name'}</a>)";
	}
	main::CRcough($msg, 1);
}
END_SUB

'link' => <<'END_SUB',
sub link {
	shift;
	main::PageLink(@_);
}
END_SUB

'form' => <<'END_SUB',
sub form {
	shift;
	main::StartForm(@_);
}
END_SUB

'hello' => <<'END_SUB',
sub hello {
	my $self = shift;
	print "<b>Addon $self->{'name'} says hello!</b>";
}
END_SUB

'addNewsField' => <<'END_SUB',
sub addNewsField {
	my ($self, $fieldname, $fieldtype, $dispname) = @_;
	main::NeedFile('cradmin.pl');
	main::AddNewsField_Internal($fieldname, $fieldtype, $dispname);
}
END_SUB

'removeNewsField' => <<'END_SUB',
sub removeNewsField {
	my ($self, $fieldname) = @_;
	main::NeedFile('cradmin.pl');
	main::RemoveNewsField_Internal($fieldname);
}
END_SUB

'readHash' => <<'END_SUB',
sub readHash {
	my ($self, $list, $prefix) = @_;
	my %hash = ();
	main::ReadInnerHash($list, $prefix, \%hash);
	return %hash;
}
END_SUB

'writeHash' => <<'END_SUB'
sub writeHash {
	my ($self, $list, $prefix, %hash) = @_;
	main::WriteInnerHash($list, $prefix, \%hash);
}
END_SUB

);
1;
