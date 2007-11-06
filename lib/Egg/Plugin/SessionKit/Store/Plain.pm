package Egg::Plugin::SessionKit::Store::Plain;
#
# Masatoshi Mizuno E<lt>lusheE<64>cpan.orgE<gt>
#
# $Id: Plain.pm 214 2007-11-06 13:51:19Z lushe $
#
use strict;
use warnings;

our $VERSION= '2.01';

=head1 NAME

Egg::Plugin::SessionKit::Store::Plain - It treats without processing the session data.

=head1 SYNOPSIS

  use Egg qw/ SessionKit /;
  
  __PACKAGE__->egg_startup(
    .......
    ...
    
    plugin_session => {
      component=> [
        [ 'Base::Module' => { ... } ],
        qw/ Bind::Cookie Store::Plain /,
        ],
      },
    );

=head1 DESCRIPTION

When the session data is taken out or is preserved, it doesn't arrange one's
verbs and objects.

=over 4

=item * store_encode, store_decode

=back

=cut

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
