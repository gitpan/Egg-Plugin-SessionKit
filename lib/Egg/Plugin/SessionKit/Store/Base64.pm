package Egg::Plugin::SessionKit::Store::Base64;
#
# Copyright (C) 2007 Bee Flag, Corp, All Rights Reserved.
# Masatoshi Mizuno E<lt>lusheE<64>cpan.orgE<gt>
#
# $Id: Base64.pm 69 2007-03-26 02:15:26Z lushe $
#
use strict;
use Storable qw(nfreeze thaw);
use MIME::Base64;

our $VERSION= '0.01';

sub store_decode {
	my $ss  = shift;
	my $data= shift || return 0;
	thaw(decode_base64($$data));
}
sub store_encode {
	my $ss  = shift;
	my $data= shift || return 0;
	encode_base64(nfreeze($data));
}

1;

__END__

=head1 NAME

Egg::Plugin::SessionKit::Store::Base64 - The session data is treated with Base64.

=head1 SYNOPSIS

Configuration.

  plugin_session=> {
    store=> { name=> 'Base64' },
    },

=over 4

=item store_decode, store_encode,

These methods are called from the base module.

=back

=head1 SEE ALSO

L<Egg::Plugin::SessionKit>,
L<Egg::Release>,

=head1 AUTHOR

Masatoshi Mizuno E<lt>lusheE<64>cpan.orgE<gt>

=head1 COPYRIGHT

Copyright (C) 2007 by Bee Flag, Corp. E<lt>L<http://egg.bomcity.com/>E<gt>, All Rights Reserved.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.6 or,
at your option, any later version of Perl 5 you may have available.

=cut
