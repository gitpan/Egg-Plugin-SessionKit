package Egg::Plugin::SessionKit::Store::Plain;
#
# Copyright (C) 2007 Bee Flag, Corp, All Rights Reserved.
# Masatoshi Mizuno E<lt>lusheE<64>cpan.orgE<gt>
#
# $Id: Plain.pm 266 2007-03-01 13:14:01Z lushe $
#
use strict;

our $VERSION= '0.01';

sub store_decode { ${$_[1]} }
sub store_encode { $_[1] }

1;

__END__

=head1 NAME

Egg::Plugin::SessionKit::Store::Plain - When the session data is treated, nothing is done.

=head1 SYNOPSIS

Configuration.

  plugin_session=> {
    store=> { name=> 'Plain' },
    },

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
