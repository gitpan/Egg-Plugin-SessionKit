package Egg::Plugin::SessionKit::Base::DBIC;
#
# Masatoshi Mizuno E<lt>lusheE<64>cpan.orgE<gt>
#
# $Id: DBIC.pm 136 2007-05-12 12:49:36Z lushe $
#

=head1 NAME

Egg::Plugin::SessionKit::DBI - Egg::Model::DBI for session.

=head1 SYNOPSIS

  use Egg qw/ SessionKit DBIC::Transaction /;
  
  __PACKAGE__->mk_eggstartup(
    .......
    ...
    MODEL => [ [ DBIC => {} ] ],
    
    plugin_session => {
      base => {
        name        => 'DBIC',
        schema_name => 'MySchema',
        source_name => 'Sessions',
        data_field  => 'a_session',
        time_field  => 'lastmod',
        },
      .......
      ...
      },
    );

=head1 DESCRIPTION

The session by L<Egg::Model::DBIC> is supported.

It is necessary to load L<Egg::Plugin::DBIC::Transaction>.

Please make the table for the following sessions for the data base used.

  CREATE TABLE sessions (
    id        char(32)   primary key,
    lastmod   timestamp,
    a_session text
    );

* It is not forgotten to set an appropriate authority.

And, the helper of L<Egg::Model::DBIC> is executed and Schema is made.

* Please set L<Egg::Plugin::SessionKit::Store::Base64> to the Store module.

* The function to clear the data not used is not included.
  Separately, it is necessary to delete it with cron etc. regularly.

=head1 CONFIGRATION

=head2 schema_name

Name of Schema used.

There is no default. Please set it.

=head2 source_name

Name of table module for session.

There is no default. Please set it.

=head2 data_field

Name of column that stores session data.

Default is 'a_session'.

=head2 time_field

Name of column that stores updated day and hour.

Default is 'lastmod'.

=cut
use strict;
use warnings;
use Time::Piece::MySQL;

our $VERSION = '2.00';

__PACKAGE__->mk_accessors(qw/ model dbic schema datafield timefield /);

=head1 METHODS

=head2 startup

The setting is checked.

=cut
sub startup {
	my($class, $e, $conf)= @_;
	$e->isa('Egg::Plugin::DBIC::Transaction')
	   || die q{ Please build in plugin 'DBIC::Transaction'. };
	my $base= $conf->{base} ||= {};
	my $schema= lc($base->{schema_name})
	          || die q{ I want setup 'schema_name'. };
	my $source= lc($base->{source_name})
	          || die q{ I want setup 'source_name'. };
	$e->is_model("${schema}:${source}")
	          || die qq{ '${schema}:${source}' model is not found. };
	$base->{schema_name}= "${schema}";
	$base->{model_name} = "${schema}:${source}";
	$base->{data_field} ||= 'a_session';
	$base->{time_field} ||= 'lastmod';
	$class->next::method($e, $conf);
}

sub TIEHASH {
	my($ss)= shift->SUPER::TIEHASH(@_);
	my $base= $ss->config->{base};
	$ss->datafield($base->{data_field});
	$ss->timefield($base->{time_field});
	$ss->schema($base->{schema_name});
	$ss->model($ss->e->model($base->{model_name}));
	$ss;
}

=head2 restore ( [SESSION_ID] )

The session data is acquired.

=cut
sub restore {
	my $ss= shift;
	my $id= shift || return 0;
	my $datafield= $ss->datafield;
	$ss->dbic($ss->model->find($id)) || return 0;
	my $data= $ss->dbic->$datafield;
	return $ss->store_decode(\$data);
}

=head2 insert

New session data is added.

=cut
sub insert {
	my($ss)= @_;
	$ss->dbic(0) if $ss->dbic;
	$ss->model->create({
	  id => $ss->session_id,
	  $ss->datafield=> $ss->store_encode($ss->{session}),
	  $ss->timefield=> localtime(time)->mysql_datetime,
	  });
}

=head2 update

Existing session data is updated.

=cut
sub update {
	my($ss)= @_;
	my($datafield, $timefield)= ($ss->datafield, $ss->timefield);
	$ss->dbic->$datafield( $ss->store_encode($ss->{session}) );
	$ss->dbic->$timefield( localtime(time)->mysql_datetime );
	$ss->dbic->update;
}

=head2 commit_ok

Accessor to $e-E<gt>[SCHEMA_NAME]_commit_ok.

=cut
sub commit_ok {
	my $ss= shift;
	my $commit_ok= $ss->schema. "_commit_ok";
	return $ss->e->$commit_ok(@_);
}

=head2 close

Rollback is set if there are signs where some errors occurred before shutting
the session.

=cut
sub close {
	my($ss)= @_;
	my $rollback_ok= $ss->schema. "_rollback_ok";
	$ss->rollback(1) if $ss->e->$rollback_ok;
	$ss->next::method;
}

=head1 SEE ALSO

L<Egg::Model::DBIC>,
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
