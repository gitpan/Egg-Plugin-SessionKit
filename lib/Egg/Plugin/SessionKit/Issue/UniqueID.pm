package Egg::Plugin::SessionKit::Issue::UniqueID;
#
# Masatoshi Mizuno E<lt>lusheE<64>cpan.orgE<gt>
#
# $Id: UniqueID.pm 136 2007-05-12 12:49:36Z lushe $
#

=head1 NAME

Egg::Plugin::SessionKit::Issue::UniqueID - Session id is issued by mod_unique_id of Apache.

=head1 SYNOPSIS

  use Egg qw/ SessionKit /;
  
  __PACKAGE__->mk_eggstartup(
    .......
    ...
    plugin_session => {
      issue => {
        name      => 'UniqueID',
        },
      .......
      ...
      },
    );

=head1 DESCRIPTION

'mod_unique_id' of the Apache WEB server is used to issue session ID.

=cut
use strict;
use warnings;

our $VERSION= '2.00';

=head1 METHODS

=head2 issue_id

Session ID is issued.

=cut
sub issue_id {
	$ENV{UNIQUE_ID} || die q{ $ENV{UNIQUE_ID} variable cannot be acquired. };
}

=head2 issue_check_id

Effective session ID is not checked. Untouched through.

=cut
sub issue_check_id { $_[1] }

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
