package CRcrypt;

# Original version by Chris Monson (chris@bouncingchairs.net) (thanks!)
# You can get the original at http://bouncingchairs.net/ (It's called SHAPerl.)
# In fact, you probably want to use that version... this version was slightly
# modified to fit my purposes, and is missing some documentation and features.
# Licensed under the LGPL (http://www.gnu.org/copyleft/lgpl.html)
# That basically means that all changes to this library must be made
# freely available under the LGPL, but anyone can use this library in
# any project.

# Usage: 
# require 'crcrypt.pl';
# my $crcrypt = new CRcrypt;
# my $hash = $crcrypt->GetHash('text');

# Will compile under use strict.
# use strict;

sub new {
	my $package = shift;
	my $self = {};
	bless $self, $package;
	$self->_init_( @_ );
}

sub _init_ {
	my $self = shift;
	%$self = @_;
	return $self;
}


sub GetHash {
	my $self = shift;
	my $str = shift;
	my $ra_bytes = [];
	my $len = length $str;
	foreach (my $i=0; $i<$len; ++$i)
	{
		push @$ra_bytes, ord( substr( $str, $i, 1 ) ) & 0xff;
	}
	$self->init();
	$self->update($ra_bytes);
	my $numhash = $self->final();
	my @str = map {sprintf( "%08x", $_ )} @$numhash;
	return join( '', @str );
}

sub init {
	my $self = shift;
	$self->{A} = 0x67452301;
	$self->{B} = 0xefcdab89;
	$self->{C} = 0x98badcfe;
	$self->{D} = 0x10325476;
	$self->{E} = 0xc3d2e1f0;
	$self->{a} = $self->{A};
	$self->{b} = $self->{B};
	$self->{c} = $self->{C};
	$self->{d} = $self->{D};
	$self->{e} = $self->{E};
	$self->{K0_19} = 0x5a827999;
	$self->{K20_39} = 0x6ed9eba1;
	$self->{K40_59} = 0x8f1bbcdc;
	$self->{K60_79} = 0xca62c1d6;

	$self->{buffer} = [];
	$self->{buffsize} = 0;
	$self->{totalsize} = 0;
}

sub update {
	my $self = shift;
	my $ra_bytes = shift || die "No byte array specified for update";

	my $index = 0;
	my $length = @$ra_bytes;

	# Process each full block
	while (($length - $index) + $self->{buffsize} >= 64)
	{
		for( my $i=$self->{buffsize}; $i<64; ++$i)
		{
			$self->{buffer}->[$i] = 
				$ra_bytes->[$index + $i - $self->{buffsize}];
		}
		$self->process_block( bytes_to_words( $self->{buffer} ) );
		$index += 64;
		$self->{buffsize} = 0;
	}

	my $remaining = $length - $index;
	for( my $i=0; $i<$remaining; ++$i)
	{
		$self->{buffer}->[$self->{buffsize} + $i] = 
			$ra_bytes->[$index + $i];
	}
	$self->{buffsize} += $remaining;
	$self->{totalsize} += $length;
}

sub final {
	# Pad and process the buffer
	my $self = shift;
	my $ra_last_block = [];
	for( my $i=0; $i<$self->{buffsize}; ++$i)
	{
		$ra_last_block->[$i] = $self->{buffer}->[$i];
	}
	$self->{buffsize} = 0;
	# Pad the block:
	$ra_last_block = pad_block( $ra_last_block, $self->{totalsize} );
	# Process the last one (or two) blocks
	my $index = 0;
	my $length = @$ra_last_block;
	while ($index < $length)
	{
		my $ra_block = [];
		for( my $i=0; $i<64; ++$i)
		{
			$ra_block->[$i] = $ra_last_block->[$i + $index];
		}
		$self->process_block( bytes_to_words( $ra_block ) );
		$index += 64;
	}

	my $ra_result = [];
	push @$ra_result, $self->{A};
	push @$ra_result, $self->{B};
	push @$ra_result, $self->{C};
	push @$ra_result, $self->{D};
	push @$ra_result, $self->{E};

	return $ra_result;
}

sub bytes_to_words {
	my $ra_block = shift;
	my $ra_nblk = [];
	for (my $i=0; $i<16; ++$i)
	{
		my $index = $i * 4;
		$ra_nblk->[$i] = 0;
		$ra_nblk->[$i] |= ($ra_block->[$index] & 0xff) << 24;
		$ra_nblk->[$i] |= ($ra_block->[$index+1] & 0xff) << 16;
		$ra_nblk->[$i] |= ($ra_block->[$index+2] & 0xff) << 8;
		$ra_nblk->[$i] |= ($ra_block->[$index+3] & 0xff);
	}
	return $ra_nblk;
}

sub pad_block {
	my $ra_block = shift;
	my $size = shift;
	
	my $ra_newblock = [];
	my $blksize = @$ra_block;
	my $bits = $size * 8;

	@$ra_newblock = @$ra_block;
	push @$ra_newblock, 0x80;
	while ((@$ra_newblock % 64) != 56)
	{
		push @$ra_newblock, 0;
	}
	# Add the size
	for( my $i=0; $i<8; ++$i )
	{
		push @$ra_newblock, ($i<4) ? 0 : ($bits >> ((7-$i)*8)) & 0xff;
	}
	return $ra_newblock;
}

sub circ_shl {
	my $num = shift;
	my $amt = shift || die "No shift amount specified";

	my $leftmask = 0xffffffff;
	$leftmask <<= 32 - $amt;
	my $rightmask = 0xffffffff;
	$rightmask <<= $amt;
	$rightmask = ~$rightmask;

	my $remains = $num & $leftmask;
	$remains >>= 32 - $amt;
	$remains &= $rightmask;

        my $res = ($num << $amt) | $remains;
	return $res;
}

sub f0_19 {
	my ($x, $y, $z) = @_;
	return ($x & $y) | (~$x & $z);
}

sub f20_39 {
	my ($x, $y, $z) = @_;
	return ($x ^ $y ^ $z);
}

sub f40_59 {
	my ($x, $y, $z) = @_;
	return ($x & $y) | ($x & $z) | ($y & $z);
}

sub f60_79 {
	return f20_39(@_);
}

sub expand_block {
	my $ra_block = shift;

	my $ra_nblk = [];
	@$ra_nblk = @$ra_block;
	for( my $i=16; $i<80; ++$i)
	{
		$ra_nblk->[$i] =
			circ_shl(
				$ra_nblk->[$i-3] ^ $ra_nblk->[$i-8] ^
				$ra_nblk->[$i-14] ^ $ra_nblk->[$i-16],
				1
			);
	}
	return $ra_nblk;
}


sub add {
    # Special add to keep overflow from occurring -- some Perl versions
    # have difficulties with this.
    my ($a, $b) = @_;
    my $ma = ($a >> 16) & 0xffff;
    my $la = ($a) & 0xffff;
    my $mb = ($b >> 16) & 0xffff;
    my $lb = ($b) & 0xffff;

    my $ls = $la + $lb;
    # Carry
    if ($ls > 0xffff)
    {
        $ma += 1;
        $ls &= 0xffff;
    }
    my $ms = $ma + $mb;
    $ms &= 0xffff;

    return ($ms << 16) | $ls;
}

sub process_block {
	my $self = shift;
        my $ra_blk = shift;
	$ra_blk = expand_block( $ra_blk );

	for( my $i=0; $i<80; ++$i) {
		my $temp = circ_shl( $self->{a}, 5 );
		my $func;
		my $k;
		if ($i<20) { $func = \&f0_19; $k=$self->{K0_19}; }
		elsif ($i<40) { $func = \&f20_39; $k=$self->{K20_39}; }
		elsif ($i<60) { $func = \&f40_59; $k=$self->{K40_59}; }
		else { $func = \&f60_79; $k=$self->{K60_79}; }

                my $f = $func->($self->{b}, $self->{c}, $self->{d});
                $temp = add( $temp, $f );
                $temp = add( $temp, $self->{e});
                $temp = add( $temp, $ra_blk->[$i] );
                $temp = add( $temp, $k );

		$self->{e} = $self->{d};
		$self->{d} = $self->{c};
		$self->{c} = circ_shl( $self->{b}, 30 );
		$self->{b} = $self->{a};
		$self->{a} = $temp;
	}

	$self->{A} = add( $self->{A}, $self->{a} );
	$self->{B} = add( $self->{B}, $self->{b} );
	$self->{C} = add( $self->{C}, $self->{c} );
	$self->{D} = add( $self->{D}, $self->{d} );
	$self->{E} = add( $self->{E}, $self->{e} );
}

1;
