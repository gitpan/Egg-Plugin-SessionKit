package Egg::Plugin::SessionKit::Issue::SHA1;
#
# Masatoshi Mizuno E<lt>lusheE<64>cpan.orgE<gt>
#
# $Id: SHA1.pm 137 2007-05-12 12:50:54Z lushe $
#

=head1 NAME

Egg::Plugin::SessionKit::Issue::SHA1 - Session id is issued by Digest::SHA1.

=head1 SYNOPSIS

  use Egg qw/ SessionKit /;
  
  __PACKAGE__->mk_eggstartup(
    .......
    ...
    plugin_session => {
      issue => {
        name      => 'SHA1',
        id_length => 32,
        },
      .......
      ...
      },
    );

=head1 DESCRIPTION

Session ID is issued by L<Digest::SHA1>.

=cut
use strict;
use warnings;
use Digest::SHA1 qw/sha1_hex/;

our $VERSION = '2.00';

=head1 METHODS

=head2 issue_id

Session id is issued.

=cut
sub issue_id {
	rand(1000);
	substr(sha1_hex(time. {}. rand(1000). $$), 0, $_[0]->id_length);
}

=head1 SEE ALSO

L<Digest::SHA1>,
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
