package Egg::Plugin::SessionKit::Store::Base64;
#
# Masatoshi Mizuno E<lt>lusheE<64>cpan.orgE<gt>
#
# $Id: Base64.pm 159 2007-05-24 08:38:09Z lushe $
#
use strict;
use warnings;
use Storable qw(nfreeze thaw);
use MIME::Base64;

our $VERSION= '2.01';

=head1 NAME

Egg::Plugin::SessionKit::Store::Base64 - Session data is made a text for preservation.

=head1 SYNOPSIS

  use Egg qw/ SessionKit /;
  
  __PACKAGE__->mk_eggstartup(
    .......
    ...
    MODEL => [ [ DBI => { ... } ] ],
    
    plugin_session => {
      store => {
        name       => 'Base64',
        },
      .......
      ...
      },
    );

=head1 DESCRIPTION

The means to make the session data a text for preservation is offered.

=head1 METHODS

=head2 store_encode

The session data is made a text.

=cut
sub store_encode {
	my $ss  = shift;
	my $data= shift || return 0;
	encode_base64(nfreeze($data));
}

=head2 store_decode

The session data made a text is restored.

=cut
sub store_decode {
	my $ss  = shift;
	my $data= shift || return 0;
	thaw(decode_base64($$data));
}

=head1 SEE ALSO

L<Storable>,
L<MIME::Base64>,
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

1;
