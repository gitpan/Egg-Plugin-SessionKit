package Egg::Plugin::SessionKit::Store::Plain;
#
# Masatoshi Mizuno E<lt>lusheE<64>cpan.orgE<gt>
#
# $Id: Plain.pm 136 2007-05-12 12:49:36Z lushe $
#

=head1 NAME

Egg::Plugin::SessionKit::Store::Plain - It treats without processing the session data.

=head1 SYNOPSIS

  use Egg qw/ SessionKit /;
  
  __PACKAGE__->mk_eggstartup(
    .......
    ...
    
    plugin_session => {
      store => {
        name       => 'Plain',
        },
      .......
      ...
      },
    );

=head1 DESCRIPTION

When the session data is taken out or is preserved, it doesn't arrange one's
verbs and objects.

=over 4

=item * store_encode, store_decode

=back

=cut
use strict;
use warnings;

our $VERSION= '2.00';

sub store_encode { $_[1] }
sub store_decode { ${$_[1]} }

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

1;
