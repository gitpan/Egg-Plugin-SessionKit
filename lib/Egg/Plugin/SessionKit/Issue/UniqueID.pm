package Egg::Plugin::SessionKit::Issue::UniqueID;
#
# Copyright (C) 2007 Bee Flag, Corp, All Rights Reserved.
# Masatoshi Mizuno E<lt>lusheE<64>cpan.orgE<gt>
#
# $Id: UniqueID.pm 69 2007-03-26 02:15:26Z lushe $
#
use strict;

our $VERSION= '0.02';

sub issue_id {
	$ENV{UNIQUE_ID}
	  || Egg::Error->throw(q/$ENV{UNIQUE_ID} variable cannot be acquired./);
}
sub issue_check_id {
	$_[1];
}

1;

__END__

=head1 NAME

Egg::Plugin::SessionKit::Issue::UniqueID - Session id is issued by mod_unique_id of Apache module.

=head1 SYNOPSIS

Configuration.

  plugin_session=> {
    issue=> {
      name=> 'UniqueID',
      },
    },

=over 4

=item issue_id, issue_check_id,

These methods are called from the base module.

=back

=head1 DESCRIPTION

mod_unique_id of Apache module should be effective to make this module function effectively.

Apache httpd.conf

  LoadModule unique_id_module  libexec/mod_unique_id.so

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
