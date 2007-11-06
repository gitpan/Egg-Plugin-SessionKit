package Egg::Plugin::SessionKit::Base::DBI;
#
# Masatoshi Mizuno E<lt>lusheE<64>cpan.orgE<gt>
#
# $Id: DBI.pm 214 2007-11-06 13:51:19Z lushe $
#
use strict;
use warnings;
use Time::Piece::MySQL;
use base qw/ Class::Data::Inheritable /;

our $VERSION = '2.10';

=head1 NAME

Egg::Plugin::SessionKit::DBI - Egg::Model::DBI for session.

=head1 SYNOPSIS

  use Egg qw/ DBI::Transaction SessionKit /;
  
  __PACKAGE__->egg_startup(
    .......
    ...
    MODEL => [ [ DBI => { ... } ] ],
    
    plugin_session => {
      key_name => 'ss',
      component=> [
  
        [ 'Base::DBI' => {
          dbname     => 'sessions',
          data_field => 'a_session',
          time_field => 'lastmod',
          } ],
  
        qw/ Bind::Cookie Store::Base64 /,
  
        ],
      },
    );

=head1 DESCRIPTION

The session by L<Egg::Model::DBI> is supported.

It is necessary to load L<Egg::Plugin::DBI::Transaction>.

Please make the table for the following sessions for the data base used.

  CREATE TABLE sessions (
    id        char(32)   primary key,
    lastmod   timestamp,
    a_session text
    );

* It is not forgotten to set an appropriate authority.

* Please set L<Egg::Plugin::SessionKit::Store::Base64> to the Store module.

* The function to clear the data not used is not included.
 Separately, it is necessary to delete it with cron etc. regularly.

=head1 CONFIGRATION

=head2 dbname

Name of table for session used.

Default is 'sessions'.

=head2 data_field

Name of column that stores session data.

Default is 'a_session'.

=head2 time_field

Name of column that stores updated day and hour.

Default is 'lastmod'.

=head1 METHODS

=head2 startup

The setting is checked.

=head2 dbh

The data base handler is returned.

=head2 restore ( [SESSION_ID] )

The session data is acquired.

=head2 insert

New session data is added.

=head2 update

Existing session data is updated.

=head2 delete ( [SESSION_ID] )

The data of SESSION_ID is deleted.

=head2 clear_sessions ( [TIME] )

The session data before TIME is deleted.

=head2 commit_ok

Accessor to $e->commit_ok.

=head2 close

Rollback is set if there are signs where some errors occurred before shutting
the session.

=cut

__PACKAGE__->mk_classdata('dbname');
__PACKAGE__->mk_classdata('timefield');
__PACKAGE__->mk_classdata('restore_sql');
__PACKAGE__->mk_classdata('insert_sql');
__PACKAGE__->mk_classdata('uodate_sql');

sub startup {
	my($class, $e, $conf)= @_;
	$e->isa('Egg::Plugin::DBI::Transaction')
	   || die q{ Please build in Egg::Plugin::DBI::Transaction. };
	my $cf= $conf->{base_dbi};
	my $dbname   = $cf->{dbname}     || 'sessions';
	my $datafield= $cf->{data_field} || 'a_session';
	my $timefield= $cf->{time_field} || 'lastmod';
	$class->dbname($dbname);
	$class->timefield($timefield);
	$class->restore_sql(qq{SELECT ${datafield} FROM ${dbname} WHERE id = ?});
	$class->insert_sql(qq{INSERT INTO ${dbname}}
	  . qq{ (id, ${datafield}, ${timefield}) VALUES (?, ?, ?)});
	$class->uodate_sql(qq{UPDATE ${dbname}}
	  . qq{ SET ${datafield} = ?, ${timefield} = ? WHERE id = ?});
	$class->next::method($e, $conf);
}
sub TIEHASH {
	my($ss)= shift->next::method(@_);
	$ss->attr->{dbh}= $ss->e->model('DBI')->dbh;
	$ss;
}
sub dbh { $_[0]->attr->{dbh} }

sub restore {
	my $ss = shift;
	my $id = shift || return 0;
	my $sesson;
	my $restore= $ss->dbh->prepare($ss->restore_sql);
	$restore->execute($id);
	$restore->bind_columns(\$sesson);
	$restore->fetch; $restore->finish;
	$sesson ? $ss->store_decode(\$sesson): 0;
}
sub insert {
	my($ss)= @_;
	$ss->e->debug_out("# + session dbi insert : ". $ss->insert_sql);
	$ss->dbh->do($ss->insert_sql, undef, $ss->is_session_id,
	    $ss->store_encode($ss->[0]), localtime(time)->mysql_datetime );
}
sub update {
	my($ss)= @_;
	$ss->e->debug_out("# + session dbi update : ". $ss->uodate_sql);
	$ss->dbh->do($ss->uodate_sql, undef, $ss->store_encode($ss->[0]),
	    localtime(time)->mysql_datetime, $ss->session_id );
}
sub delete {
	my $ss = shift;
	my $id = shift || return 0;
	my $dbname= $ss->dbname;
	$ss->dbh->do(qq{DELETE FROM ${dbname} WHERE id = ?}, undef, $id);
}
sub clear_sessions {
	my $ss= shift;
	my $datetime = shift || die q{ I want time. };
	my $dbname   = $ss->dbname;
	my $timefield= $ss->timefield;
	$ss->dbh->do(qq{DELETE FROM ${dbname} WHERE ${timefield} < ?},
	         undef, localtime($datetime)->mysql_datetime );
}
sub commit_ok {
	shift->e->commit_ok(@_);
}
sub DESTROY {
	my($ss)= @_;
	$ss->attr->{rollback}= 1 if $ss->e->rollback_ok;
	$ss->next::method;
}

=head1 SEE ALSO

L<Egg::Model::DBI>,
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
