package Egg::Plugin::SessionKit::Issue::UUID;
#
# Masatoshi Mizuno E<lt>lusheE<64>cpan.orgE<gt>
#
# $Id: UUID.pm 159 2007-05-24 08:38:09Z lushe $
#
use strict;
use warnings;
use Data::UUID;

our $VERSION= '2.01';

=head1 NAME

Egg::Plugin::SessionKit::Issue::UUID - Session ID is issued by Data::UUID.

=head1 SYNOPSIS

  use Egg qw/ SessionKit /;
  
  __PACKAGE__->mk_eggstartup(
    .......
    ...
    plugin_session => {
      issue => {
        name => 'UUID',
        },
      .......
      ...
      },
    );

=head1 DESCRIPTION

Session ID is issued by L<Data::UUID>.

=head1 METHODS

=head2 issue_id

Session id is issued.

=cut
sub issue_id {
	Data::UUID->new->create_str();
}

=head2 issue_check_id ( [SESSION_ID] )

Whether it is effective session ID is checked.

=cut
sub issue_check_id {
	my $ss  = shift;
	my $id  = shift || return 0;
	$id=~m{^[A-Fa-f0-9\-]+$} ? $id: 0;
}

=head1 SEE ALSO

L<Data::UUID>,
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
