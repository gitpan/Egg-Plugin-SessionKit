package Egg::Plugin::SessionKit::Issue::MD5;
#
# Masatoshi Mizuno E<lt>lusheE<64>cpan.orgE<gt>
#
# $Id: MD5.pm 214 2007-11-06 13:51:19Z lushe $
#
use strict;
use warnings;
use Digest::MD5;

our $VERSION= '2.10';

=head1 NAME

Egg::Plugin::SessionKit::Issue::MD5 - Session id is issued by Digest::MD5.

=head1 SYNOPSIS

  use Egg qw/ SessionKit /;
  
  __PACKAGE__->egg_startup(
    .......
    ...
    
    plugin_session => {
      component=> [
        [ 'Base::Module' => { ... } ],
  
        [ 'Issue::MD5' => { id_length => 32 } ],
  
        qw/ Bind::Cookie Store::Plain /,
        ],
      },
    );

=head1 DESCRIPTION

Session ID is issued by L<Digest::MD5>.

=cut

sub startup {
	my($class, $e, $conf)= @_;
	$conf->{issue_md5}{id_length} ||= 32;
	$class->next::method($e, $conf);
}
sub issue_id {
	substr(
	  Digest::MD5::md5_hex(time. {}. rand(1000). $$),
	  0, $_[0]->mod_conf->{issue_md5}{id_length},
	  );
}

=head1 METHODS

=head2 startup

Configuration check.

=head2 issue_id

Session id is issued.

=head1 SEE ALSO

L<Digest::MD5>,
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
