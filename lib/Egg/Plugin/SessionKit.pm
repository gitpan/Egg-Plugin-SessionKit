package Egg::Plugin::SessionKit;
#
# Masatoshi Mizuno E<lt>lusheE<64>cpan.orgE<gt>
#
# $Id: SessionKit.pm 136 2007-05-12 12:49:36Z lushe $
#

=head1 NAME

Egg::Plugin::SessionKit - Plugin that manages session.

=head1 SYNOPSIS

  use Egg qw/ SessionKit /;
  
  __PACKAGE__->mk_eggstartup(
    .......
    ...
    plugin_session => {
      base  => 'FileCache',
      issue => 'MD5',
      bind  => 'Cookie',
      store => 'Plain',
      },
    );

  # The session data is acquired.
  my $session = $e->session;
  
  $session->{hoge}= 'in data';
  
  # Refer to present session id.
  tied(%$session)->session_id;

=head1 DESCRIPTION

It is a plugin to manage the session.

=head1 CONFIGRATION

It sets it to 'plugin_session' with HASH.

=head2 base => [HASH]

Setting passed to module that basis operates.

The name since 'Egg::Plugin::SessionKit::Base' is set with the name key.

  plugin_session=> {
    base => {
      name => 'FileCache',
      namespace  => 'sessions',
      cache_root => '/path/to/cache',
      ...
      },
    },

=head2 store => [HASH]

Setting passed to module that manages preservation form of session data.

The name since 'Egg::Plugin::SessionKit::Store' is set with the name key.

  plugin_session=> {
    store => {
      name => 'Base64',
      },
    },

=head2 bind => [HASH]

Setting passed to module that offers method of passing client session id.

The name since 'Egg::Plugin::SessionKit::Bind' is set with the name key.

  plugin_session=> {
    bind => {
      name => 'Cookie',
      cookie_name   => 'sid',
      cookie_path   => '/',
      cookie_secure => 1,
      },
    },

=head2 issue => [HASH]

Setting passed to module to issue session id.

The name since 'Egg::Plugin::SessionKit::Issue' is set with the name key.

  plugin_session=> {
    issue => {
      name => 'MD5',
      id_length => 32,
      },
    },

=head2 ticket => [HASH]

Temporary setting concerning ticket id issue.

=over 4

=item * param_name => [PARAM_NAME]

Name of the form data that handles ticket id.

Default is 'ticket'.

=back

=head2 FORMAT

The setting of 'base', 'store', 'bind', 'issue' supports the following forms.

=over 4

=item * SCALAR

It is acceptable only to set the name directly when there is especially no 
setting except the name.

  plugin_session=> {
    base  => 'FileCache',
    stroe => 'Plain',
    ...
    },

=item * ARRAY

When the name key is not seen to be used easily, it is possible to do as 
follows.

  plugin_session=> {
    base => [ DBI=> {
      .....
      ...
      } ],
    bind => [ Cookie => {
      .....
      ...
      } ],
    },

=back

=cut
use strict;
use warnings;
use UNIVERSAL::require;
use Digest::MD5;

our $VERSION = '2.00';

=head1 METHODS

=head2 session

The session data is returned.

  my $session_hash = $e->session;

This method is generated on the controller of the project.

Data is TIEHASH object.
Tied is used to access this handler object.

  tied(%{$e->session})->session_id;

=over 4

=item * Alias: sss

=back

=cut
*sss= \&session;

sub _setup {
	my($e)= @_;
	my $conf= $e->config->{plugin_session} ||= {};
	my $ticket= $conf->{ticket} ||= {};
	$ticket->{param_name} ||= 'ticket';
	my $handler= $e->global->{session_handler}
	         ||= 'Egg::Plugin::SessionKit::handler';
	$handler->_startup($e, $conf);
	$handler= __PACKAGE__."::Base::$conf->{base}{name}";
	no strict 'refs';  ## no critic
	no warnings 'redefine';
	*{"$e->{namespace}::session"}= sub {
		$_[0]->{session} ||= do {
			my($egg)= @_;
			my %session;
			tie %session, $handler, $egg, $conf;
			tied(%session)->_setup_session_data;
			\%session;
		  };
	  };
	$e->next::method;
}

=head2 mk_md5hex_id ( [LENGTH_SCALAR_REF] )

ID is issued by L<Digest::MD5>::md5_hex.

When LENGTH_SCALAR_REF is omitted, it becomes id of 32 digits.

  my $id= $e->mk_md5hex_id(\'64');

=cut
sub mk_md5hex_id {
	my $e= shift;  rand(1000);
	my $len= ref($_[0]) eq 'SCALAR' ? ${$_[0]}: 32;
	substr(
	  Digest::MD5::md5_hex(
	  Digest::MD5::md5_hex(time. {}. rand(1000). $$)
	  ), 0, $len );
}

=head2 ticket_id ( [BOOL] )

id issued by 'mk_md5hex_id' is set in the session when an effective value to BOOL is given 
and it returns it.

id set to give an invalid value to BOOL in the session is invalidated.

  $e->request->param( ticket => $e->ticket_id(1) );

=cut
sub ticket_id {
	my $e= shift;
	return $e->session->{session_ticket_id} || 0 unless @_;
	$e->session->{session_ticket_id}= $_[0] ? $e->mk_md5hex_id(@_): 0;
}

=head2 ticket_check ( [TICKET_ID] )

It checks whether the ticket on the session set before is corresponding
to TICKET_ID.

When TICKET_ID is omitted, it checks it for the form data corresponding
to ticket->{param_name} of the setting.

  if ($e->ticket_check) {
    print "Ticket OK";
  } else {
    print "Ticket NG";
  }

=cut
sub ticket_check {
	my $e= shift;
	my $ticket= shift
	  || $e->request->params->{$e->config->{plugin_session}{ticket}{param_name}}
	  || return do { $e->debug_out("# - ticket is undefined."); 0 };
	return do { $e->debug_out("# - session_ticket is undefined."); 0 }
	  unless my $id= $e->session->{session_ticket_id};
	return 1 if $id eq $ticket;
	$e->debug_out("# - ticket is unmatched. ($ticket = $id)");
	return 0;
}

=head2 _finalize

For method call that Egg does.

Whether the session is preserved here is judged.

* There might be a thing that doesn't operate normally in the order of loading
  of the plugin. Please adjust the order of loading when the problem occurs.

=cut
sub _finalize {
	my($e)= shift->next::method;
	return $e unless $e->{session};
	untie %{$e->{session}};
	$e->{session}= undef;
	return $e;
}

package Egg::Plugin::SessionKit::handler;
use strict;
use warnings;
use Class::C3;
use UNIVERSAL::require;
use base qw/Class::Accessor::Fast/;

=head1 HANDLER METHODS

Tied is used to access these methods.

  tied(%{$e->session}->method;

These methods are chiefly the one for the component of this plugin.
It is not necessary to use from the application side, and the method of
generating the inconvenience when using it is included usually.

=head2 e

Accessor to Egg object.

=head2 config

Accessor to 'Plugin_session' set value.

=head2 new_entry

True is restored for a new session.

=head2 update_ok

It becomes true if the value is set in the session, and when processing is
ended, the session data is preserved.

=cut

__PACKAGE__->mk_accessors
  (qw/ e config new_entry update_ok rollback param_name id_length /);

=head2 session_id

Accessor to refer to present session id.

=head2 user_agent

Accessor to refer to HTTP_USER_AGENT of accessed client.

=head2 remote_addr

Accessor to refer to REMOTE_ADDR of accessed client.

=head2 create_time

Accessor to refer to epoc value at time that session was made.

=head2 access_time_old

Accessor to refer to epoc value at time accessed last time.

=head2 access_time_now

Accessor to refer to epoc value at present time.

=cut

__PACKAGE__->mk_session_accessors
  (qw/ session_id user_agent remote_addr create_time access_time_old access_time_now /);

sub _startup {
	my($class, $e, $conf)= @_;

	no strict 'refs';  ## no critic.
	$conf->{base}= $class->_get_config($conf, 'base', 'FileCache');
	my $b_class= "Egg::Plugin::SessionKit::Base::$conf->{base}{name}";
	my $isa = \@{"${b_class}::ISA"};
	push @$isa, __PACKAGE__;
	$b_class->require or die $@;
	my @includes;
	for my $a ( [qw/issue MD5/], [qw/bind Cookie/], [qw/store Plain/] ) {
		$conf->{$a->[0]}= $class->_get_config($conf, @$a);
		my $pkg= "Egg::Plugin::SessionKit::"
		       . ucfirst($a->[0]). "::$conf->{$a->[0]}{name}";
		unshift @$isa, $pkg;
		$pkg->require or die $@;
	}
	if ($e->debug) {
		$e->debug_out("# + $e->{namespace} - SessionKit:\n"
		            . "#   - ". join("\n#   - ", @$isa) );
	}

	no warnings 'redefine';
	my $agent= exists($conf->{verifi_agent}) ? $conf->{verifi_agent}: 0;
	*agent_check= $agent ? do {
		$e->debug_out("# + session verifi_agent: ON.");
		sub {
			my $ss= shift;
			my $ua= shift || return 0;
			$ss->e->request->agent eq $ua ? 1: 0;
		  };
	  }: do {
		$e->debug_out("# + session verifi_agent: OFF.");
		sub { 1 };
	  };

	my $level= exists
	  ($conf->{ipaddr_check_level}) ? $conf->{ipaddr_check_level}: 1;
	*ipaddr_check= $level ? do {
		$level=~/^(?:1|C)/i ? do {
			$e->debug_out("# + session ipaddr check: C class.");
			sub {
				my $ss= shift;
				my $addr= shift || return 1;
				my($a1, $a2, $a3)= $addr=~/^(\d+)\.(\d+)\.(\d+)/;
				$ss->e->request->address=~/^$a1\.$a2\.$a3\.\d+$/ ? 1: 0;
			  };
		  }: do {
			$e->debug_out("# + session ipaddr check: Absolute.");
			sub {
				my $ss= shift;
				my $addr= shift || return 0;
				$ss->e->request->address eq $addr ? 1: 0;
			  };
		  };
	  }: do {
		$e->debug_out("# + session ipaddr check: None.");
		sub { 1 };
	  };

	$b_class->startup($e, $conf);
}

sub TIEHASH {
	my($class, $e, $conf)= @_;
	bless {
	  e=> $e, config=> $conf, session=> {},
	  param_name => ($conf->{bind_param_name}
	              || $conf->{bind}{param_name} || ''),
	  id_length  => ($conf->{session_id_length}
	              || $conf->{issue}{id_length} || 32),
	  new_entry  => 0,
	  update_ok  => 0,
	  rollback   => 0,
	  }, $class;
}
sub FETCH    { $_[0]->{session}{$_[1]} }
sub EXISTS   { exists($_[0]->{session}{$_[1]}) }
sub NEXTKEY  { each %{$_[0]->{session}} }
sub FIRSTKEY { my $s= keys %{$_[0]->{session}}; each %{$_[0]->{session}} }

sub STORE {
	my($ss, $key, $value)= @_;
	$ss->update_ok(1) unless $ss->update_ok;
	$ss->{session}{$key}= $value;
}
sub DELETE {
	my($ss, $key)= @_;
	$ss->update_ok(1) unless $ss->update_ok;
	delete($ss->{session}{$key});
}
sub CLEAR {
	my($ss)= @_;
	$ss->update_ok(1) unless $ss->update_ok;
	$ss->{session}= {};
}

=head2 mk_session_accessors ( [ACCESOR_NAME_LIST] )

The accessor for the session data reference is generated.

'session_' adheres to the head of the name of the key without fail.

  __PACKAGE__->mk_session_accessors(qw/ hoge hooo /);

=cut
sub mk_session_accessors {
	my $class= ref($_[0]) || $_[0]; shift;
	no strict 'refs';  ## no critic
	no warnings 'redefine';
	for my $accessor (@_) {
		*{"${class}::$accessor"}=
		  sub { $_[0]->{session}{"session_$accessor"} || 0 };
	}
}

=head2 get_session_id

Session id is returned.

If it is a session of new issue, and generation of id when the session is new,
id in data is returned.

=cut
sub get_session_id {
	my $ss= shift;
	if (my $id= $ss->get_bind_data($ss->param_name)) {
		return ($ss->issue_check_id($id) || $ss->create_session_id);
	} else {
		return  $ss->create_session_id;
	}
}

=head2 create_session_id

Session id is newly issued and a prescribed procedure is done.

=cut
sub create_session_id {
	my($ss)= @_;
	my $id= $ss->issue_id || die q{ e->issue_id doesn't function normally. };
	$ss->e->debug_out("# + session new_entry : $id");
	$ss->new_entry(1);
	$id;
}

=head2 create_session_id ( [SESSION_ID] )

Whether it is effective session ID is checked.

=cut
sub issue_check_id {
	my $ss  = shift;
	my $id  = shift || return 0;
	my $leng= $ss->id_length;
	$id=~/^[A-Fa-f0-9]{$leng}$/ ? $id: 0;
}

=head2 normalize ( [SESSION_DATA_HASH], [SESSION_ID] )

The initial value that is sure to be included in the session data is set up.

=cut
sub normalize {
	my($ss, $data, $id)= @_;
	if (my $agent= $data->{session_user_agent})
	  { $data= {} unless $ss->agent_check($agent) }
	if (my $addr= $data->{session_remote_addr})
	  { $data= {} unless $ss->ipaddr_check($addr) }
	$data->{session_user_agent}   ||= $ss->e->request->agent;
	$data->{session_remote_addr}  ||= $ss->e->request->address;
	$data->{session_session_id}   ||= $id;
	$data->{session_create_time}  ||= time;
	$data->{session_access_time_old}= $data->{session_access_time_now} || 0;
	$data->{session_access_time_now}= time;
	$data;
}

=head2 change

Session id is updated and time that the issue do over again and the session
were made is updated.

Other existing data is maintained as it is.

=cut
sub change {
	my($ss)= @_;
	$ss->{session}{session_session_id} = $ss->create_session_id;
	$ss->{session}{session_create_time}= time;
	$ss->update_ok(1);
	$ss;
}

=head2 clear

It tries to initialize the existing data and to issue session id.

=cut
sub clear {
	my($ss)= @_;
	$ss->{session}= $ss->normalize({}, $ss->create_session_id);
	$ss->update_ok(1);
	$ss;
}

=head2 output_session_id

It prepares it. send the client session id.

=cut
sub output_session_id {
	my $ss= shift;
	my $id= shift || $ss->session_id;
	$ss->set_bind_data( $ss->param_name => $id, @_ );
}

=head2 close

Data is preserved if necessary, and the session is shut.

=cut
sub close {
	my($ss)= @_;
	if ($ss->e && $ss->update_ok && ! $ss->rollback) {
		if ($ss->new_entry) {
			$ss->e->debug_out
			  ("# + session insert: ". $ss->session_id) if $ss->e;
			$ss->insert;
			$ss->output_session_id;
		} else {
			$ss->e->debug_out
			  ("# + session update: ". $ss->session_id) if $ss->e;
			$ss->update;
		}
		$ss->commit_ok(1);
	}
	$ss;
}

=head2 commit_ok

* It is a method of the dummy.

=cut
sub commit_ok { }

=head2 startup

* It is a method of the dummy.

=cut
sub startup   { @_ }

=head2 DESTROY

Close is called.

=cut
sub DESTROY   { $_[0]->close }

sub _get_config {
	my($class, $conf, $name, $default)= @_;
	my $c= $conf->{$name} || {};
	if (my $ref= ref($c)) {
		$c= { name=> $c->[0], %{ $c->[1] || {} } } if $ref eq 'ARRAY';
	} else {
		$c= { name=> $c };
	}
	$c->{name} ||= $default;
	$c;
}
sub _setup_session_data {
	$_[0]->{session}= $_[0]->_get_session_data;
}
sub _get_session_data {
	my($ss)= @_;
	my $id= $ss->get_session_id();
	my $data= {};
	unless ($ss->new_entry) {
		$ss->e->debug_out("# + session restore: $id");
		$data= $ss->restore($id) || do { $id= $ss->create_session_id; {} };
	}
	$ss->normalize($data, $id);
}

=head1 COMPONENTS

It is a list of the component included in this package.

Please it doesn't operate normally according to the combination.

=head2 Base

* L<Egg::Plugin::SessionKit::Base::FileCache>

The session by L<Cache::FileCache> is supported.

* L<Egg::Plugin::SessionKit::Base::DBI>

The session by L<Egg::Model::DBI> is supported.

* L<Egg::Plugin::SessionKit::Base::DBIC>

The session by L<Egg::Model::DBIC> is supported.

=head2 Store

* L<Egg::Plugin::SessionKit::Store::Base64>

The session data is made a text. For preserving it to data base chiefly.

* L<Egg::Plugin::SessionKit::Store::Plain>

When you do not want to give the processing to the session data. For Cache
module chiefly.

=head2 Bind

* L<Egg::Plugin::SessionKit::Bind::Cookie>

Session id is preserved in the client by Cookie.

=head2 Issue

* L<Egg::Plugin::SessionKit::Issue::UniqueID>

Session id is issued with id obtained from mod_unique_id of Apache.

* L<Egg::Plugin::SessionKit::Issue::MD5>

Session ID is issued by L<Digest::MD5>.

* L<Egg::Plugin::SessionKit::Issue::UUID>

Session ID is issued by L<Data::UUID>.

* L<Egg::Plugin::SessionKit::Issue::SHA1>

Session ID is issued by L<Digest::SHA1>.

=head1 SEE ALSO

L<Class::C3>,
L<Digest::MD5>,
L<Class::Accessor::Fast>,
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
