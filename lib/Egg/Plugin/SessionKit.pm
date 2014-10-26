package Egg::Plugin::SessionKit;
#
# Masatoshi Mizuno E<lt>lusheE<64>cpan.orgE<gt>
#
# $Id: SessionKit.pm 214 2007-11-06 13:51:19Z lushe $
#
use strict;
use warnings;
use base qw/ Egg::Plugin::IxHash /;

our $VERSION = '2.10';

=head1 NAME

Egg::Plugin::SessionKit - Plugin that manages session.

=head1 SYNOPSIS

  use Egg qw/ SessionKit /;
  
  __PACKAGE__->mk_eggstartup(
    .......
    ...
    plugin_session => {
      key_name           => 'ss',
      verifi_agent       => 1,
      ipaddr_check_level => 1,
      component=> [qw/ Base::DBI Bind::Cookie Store::Base64 /],
      },
    );

  # �Z�b�V�����f�[�^���l���B
  my $session = $e->session;
  
  $session->{hoge}= 'in data';
  
  # ���݂̃Z�b�V�����h�c���Q�ƁB
  $session->session_id;

=head1 DESCRIPTION

�Z�b�V�����Ǘ����s���ׂ̃v���O�C���ł��B

* �ȑO�̃o�[�W�����Ƃ͎d�l���኱�ς��Ă��܂��B

* ���̃v���O�C���� Egg::Plugin::IxHash ���p�����Ă��܂��̂ŁAEgg::Plugin::IxHash
  ��ʂɃ��[�h����K�v�͂���܂���B

=head1 CONFIGRATION

'plugin_session' �ɂ��̃��W���[���̐ݒ���s���ĉ������B

=head2 key_name

�N�b�L�[�ȂǂɎg�p����Z�b�V�����h�c�擾�p�̃p�����[�^�̖��O�B

  plugin_session=> {
    key_name=> 'session_id',
    ...
    },

�f�t�H���g�� ss �ł��B

=head2 verifi_agent

�ȑO�Ɠ����Z�b�V�������v������Ă��AHTTP_USER_AGENT ����v���Ȃ���ΕʃZ�b�V�����Ƃ��Ĉ����܂��B

  plugin_session=> {
    verifi_agent=> 1,
    ...
    },

�f�t�H���g�͖���`�ł��B

=head2 ipaddr_check_level

�ȑO�Ɠ����Z�b�V�������v�����ꂽ���̂h�o�A�h���X�ƌ��݂̂h�o�A�h���X�̈�v�����`�F�b�N���܂��B
��v����������ΕʃZ�b�V�����Ƃ��Ĉ����܂��B

1 ���� C ��ݒ肷��� C�N���X �̃`�F�b�N�A1 ���� C �ȊO�̕�����ݒ肷��Ɗ��S��v�Ń`�F�b�N���܂��B
0 ���� ����` �Ȃ�S�ē���Z�b�V�����Ƃ��Ĉ����܂��B

  plugin_session=> {
    ipaddr_check_level=> 1,
    ...
    },

�f�t�H���g�͖���`�ł��B

=head2 component

���̃Z�b�V�������W���[�����ǂݍ��ފe�R���|�[�l���g�E���W���[�����w�肵�܂��B

�f�t�H���g�͂���܂���̂ŁA�ǂݍ��ރR���|�[�l���g�͑S�Đݒ肷��K�v������܂��B

�ݒ�͕K�� ARRAY ���t�@�����X�ōs���A�ŏ��̒l�� Base�n�R���|�[�l���g��ݒ肷�鎖�B

Base �n�R���|�[�l���g�ȍ~�͓��ɏ��ԂɍS��܂��񂪁AStore�n �� Bind�n �̃R���|�[�l���g��
�ݒ肪�K���K�v�ɂȂ�܂��B Issue�n �R���|�[�l���g�͏ȗ��ł��܂��B

  plugin_session=> {
    ...
    component=> [qw/ Base::FileCache Bind::Cookie Store::Base64 /],
    },

�܂��e�l�ɃI�v�V������ݒ肷��ꍇ�͎��̂悤�Ȋ����ɂȂ�܂��B

  plugin_session=> {
    ...
    component=> [
      [ 'Base::FileCache' => {
        namespace  => 'sessions',
        cache_root => '/path/to/cache',
        ...
        } ],
      qw/ Bind::Cookie Store::Base64 /,
      ],
    },

  plugin_session=> {
    ...
    component=> [
      [ 'Base::FileCache' => {
        namespace  => 'sessions',
        cache_root => '/path/to/cache',
        ...
        } ],
      [ 'Bind::Cookie' => {
        cookie_name   => 'sid',
        cookie_path   => '/',
        ...
        } ],
      'Store::Base64',
      ],
    },

=head2 ticket

  plugin_session=> {
    ...
    ticket => {
      param_name => 'my_ticket',
      },
    },

�ꎞ�`�P�b�g���t�H�[������󂯎��ׂ̖��̂� param_name �Őݒ肵�܂��B

�f�t�H���g�� ticket �ł��B

=head1 METHODS

=head2 session

�Z�b�V�����E�I�u�W�F�N�g��Ԃ��܂��B

  my $session= $e->session;

�l���Z�b�g����ꍇ�͕��ʂɑ������Ηǂ��ł��B

  $session->{data}= 'foo';

=head2 ticket_id

1 ��^����ƈꎞ�`�P�b�g�h�c�𐶐����ĕԂ��܂��B

  my $ticket_id= $e->ticket_id(1);

����͎��̂悤�ȃR�[�h�Ɠ����ł��B

  my $ticket_id= $e->session->{session_ticket}= $e->session->create_id;

0 ��^����ƈꎞ�`�P�b�g�h�c�𖳌��ɂ��܂��B

  $e->ticket_id(0);

=head2 ticket_check

�ꎞ�`�P�b�g�h�c���Z�b�V�����ɕۑ�����Ă���h�c�ƈ�v����� true ��Ԃ��܂��B

  if ($e->ticket_check($e->req->param('ticket'))) {
     Ticket ID is corresponding.
  } else {
     Ticket ID is a disagreement.
  }

�������ȗ������ param_name �ɐݒ肵���N�G���[�̒l���r�ΏƂɂ��܂��B

  if ($e->ticket_check) {
     Ticket ID is corresponding.
  } else {
     Ticket ID is a disagreement.
  }

=head2 session_close

�Z�b�V�����𖾎��I�ɃN���[�Y���܂��B

* ����͒ʏ� _finalize �ŌĂ΂��ׁA�A�v���P�[�V�������ŃR�[������K�v�͂���܂���B

=head1 HANDLER_METHODS

=head2 new

�Z�b�V�����n���h���[�I�u�W�F�N�g��Ԃ��܂��B

  my $session= $e->session;

=head2 session_id

���݃Z�b�g����Ă���Z�b�V�����h�c��Ԃ��܂��B

  my $session_id= $e->session->session_id;

=head2 session_ticket

���݃Z�b�g����Ă���ꎞ�`�P�b�g�h�c��Ԃ��܂��B

  my $ticket_id= $e->session->session_ticket || undef;

=head2 access_time_now

�Z�b�V�������I�[�v���������� time �l��Ԃ��܂��B

=head2 access_time_old

�O��Z�b�V�������I�[�v���������� access_time_now �̒l��Ԃ��܂��B

=head2 context

�Z�b�V������ TieHash �I�u�W�F�N�g��Ԃ��܂��B

=head2 session

�Z�b�V������ TieHash ���g��Ԃ��܂��B

=head2 e

�v���W�F�N�g�E�I�u�W�F�N�g��Ԃ��܂��B

=head2 conf

�Z�b�V�����̃R���t�B�O���[�V������Ԃ��܂��B

=head2 attr

�Z�b�V�����֘A�̊e�푮������Ԃ��܂��B(HASH���t�@�����X)

=head2 is_handler

�Z�b�V������ TieHash �Ɏg���Ă���n���h���[����Ԃ��܂��B

=head2 is_update

�Z�b�V�����ɉ����l��������čX�V����K�v������� true ��Ԃ��܂��B

=head2 is_newentry

���݂̃Z�b�V�������V�K�Z�b�V�����h�c�ɂ����̂Ȃ� true ��Ԃ��܂��B

=head2 create_id ([ID_LENGTH])

SHA1 �ɂ�胆�j�[�N�Ȃh�c�𐶐����܂��B

���̃��\�b�h�� Issue�n �R���|�[�l���g�ɂ���ăI�[�o�[���C�h����鎖������܂��B

  my $id= $session->create_id(32);

* ID_LENGTH �̃f�t�H���g�� 32 �ł����ASHA1 ���g�͒ʏ�40����Ԃ��܂��̂� 40 �ȏ���w�肵�Ă�
  ���Ӗ��ł��B

=head2 change

�V�����h�c�ŕʃZ�b�V�����ɕύX���܂��B�f�[�^�͑S�ĈȑO�̂��̂������p���܂��B

=head2 clear

�V�����h�c�ŕʃZ�b�V�����ŏ��������܂��B�f�[�^�͑S�ăN���A����܂��B

=head2 delete ([KEY_NAME])

�w�肵���L�[�̃f�[�^���폜���܂��B

  $session->delete('fooo');

����͎��̃R�[�h�Ɠ����ł��B

  delete($session->{fooo});

=head1 TIEHASH_HANDLER

�����̃��\�b�h�̓A�v���P�[�V���������璼�ڌĂяo����鎖��z�肵�Ă��܂���B

=head2 e

�v���W�F�N�g�I�u�W�F�N�g��Ԃ��܂��B

=head2 conf, mod_conf, config

�R���t�B�O���[�V������Ԃ��܂��B

=head2 attr

�Z�b�V�����֘A�̊e�푮������Ԃ��܂��B(HASH���t�@�����X)

=head2 session_id

�Z�b�V�����h�c��Ԃ��܂��B

=head2 new_entry

���݂̃Z�b�V�������V�K�Z�b�V�����h�c�ɂ����̂Ȃ� true ��Ԃ��܂��B

=head2 agent_key_name

HTTP_USER_AGENT ���ۑ�����Ă���Z�b�V�����̃L�[��Ԃ��܂��B

=head2 addr_key_name

REMOTE_ADDR ���ۑ�����Ă���Z�b�V�����̃L�[��Ԃ��܂��B

=head2 initialize

�Z�b�V�����f�[�^�����������܂��B

=head2 normalize

�Z�b�V�����ɕۑ����鏉���f�[�^���Z�b�g�A�b�v���܂��B

=head2 create_session_id

�V�����Z�b�V�����h�c�𔭍s���܂��B

=head2 issue_id

�Z�b�V�����h�c�𔭍s���܂��B
���̃��\�b�h�� Issue�n �R���|�[�l���g����ăI�[�o�[���C�h����܂��B

=head2 issue_check_id

�󂯎�����h�c�̏������`�F�b�N���܂��B

=head2 commit_ok

�g�����U�N�V�����������ׂ̈̃_�~�[���\�b�h

=head2 insert

�V�����Z�b�V������ۑ�����ׂ̃��\�b�h

=head2 update

�Z�b�V�������X�V����ׂ̃��\�b�h

=head2 restore

�Z�b�V������ǂݍ��ވׂ̃��\�b�h

=head2 set_bind_data

�Z�b�V�����h�c�� Cookie ���ɃZ�b�g����ׂ̃��\�b�h

=head2 get_bind_data

�Z�b�V�����h�c�� Cookie �����瓾��ׂ̃��\�b�h

=head2 startup

�����Z�b�g�A�b�v�p�̃��\�b�h

=cut

{
	my($handler, $config, $ticket_param_name);
	sub _setup {
		my($e)= @_;
		$config= $e->config->{plugin_session} ||= {};
		my $ticket= $config->{ticket} ||= {};
		$ticket_param_name= $ticket->{param_name} || 'ticket';
		$handler= $e->{session_handler} ||= 'Egg::Plugin::SessionKit::handler';
		$handler->_startup($e, $config, $handler);
		$e->next::method;
	}
	sub _prepare {
		my($e)= @_;
		$handler->_prepare($e, $config);
		$e->next::method;
	}
	sub _finalize {
		my($e)= @_;
		$e->next::method;
		if ($e->{sessionkit}) {
			$handler->_finalize($e, $config);
			$e->session_close;
		}
		$e;
	}
	sub _finalize_error {
		my($e)= @_;
		$e->next::method;
		if (my $ss= $e->{sessionkit}) {
			$ss->attr->{rollback}= 1;
			$handler->_finalize($e, $config);
			$e->session_close;
		}
		$e;
	}
	sub session {
		$_[0]->{sessionkit} ||= $handler->new(shift, $config, @_);
	}
	sub ticket_check {
		my $e= shift;
		my $ticket= shift
		  || $e->request->param($ticket_param_name)
		  || return do { $e->debug_out("# - ticket is undefined."); 0 };
		return do { $e->debug_out("# - session_ticket is undefined."); 0 }
		  unless my $id= $e->session->session_ticket;
		return 1 if $id eq $ticket;
		$e->debug_out("# - ticket is unmatched. ($ticket = $id)");
		return 0;
	}
  };

sub ticket_id {
	my $e= shift;
	return $e->session->session_ticket || 0 unless @_;
	$e->session->session_ticket
	   ( $_[0] ? $e->session->create_id($_[0] > 1 ? $_[0]: 0): 0 );
}
sub session_close {
	my($e)= @_;
	return $e unless $e->{sessionkit};
	untie %{$e->{sessionkit}};
	undef $e->{sessionkit};
	$e;
}

package Egg::Plugin::SessionKit::handler;
use strict;
use warnings;
use UNIVERSAL::require;
use Digest::SHA1 qw/sha1_hex/;
use base qw/Class::Accessor::Fast/;

__PACKAGE__->mk_accessors
   (qw/ session_id session_ticket access_time_now access_time_old /);

my $tie_handler;

sub _prepare  {}
sub _finalize {}

sub _startup {
	my($class, $e, $cf, $handler)= @_;
	my $compo= $cf->{component}
	   || [qw/ Base::FileCache Bind::Cookie Store::Plain /];
	$cf->{key_name} ||= 'ss';
	my $conf= $cf->{config}= $e->ixhash;
	   $tie_handler= "${handler}::TieHash";
	my $pkg_name   = 'Egg::Plugin::SessionKit';
	my $base_name  = "${pkg_name}::base";
	no strict 'refs';  ## no critic.
	my $isa= \@{"${tie_handler}::ISA"};
	my @pkg;
	for (1..$#{$compo}) {
		my $name= __sessionkit_config($conf, $compo->[$_]);
		push @$isa, "${pkg_name}::${name}";
		push @pkg,  "${pkg_name}::${name}";
	}
	my $base= __sessionkit_config($conf, $compo->[0]);
	$base=~m{^Base\:+} || die q{ A 'Base' component is not specified. };
	push @$isa, "${pkg_name}::${base}";
	push @$isa, $base_name;
	$_->require or die $@ for (@pkg, "${pkg_name}::${base}");

	no strict 'refs';  ## no critic.
	no warnings 'redefine';

	*{"${base_name}::agent_check"}= $cf->{verifi_agent} ? do {
		$e->debug_out("# + session verifi_agent: ON.");
		sub {
			my($self, $data)= @_;
			my $agent= $data->{$self->agent_key_name} || return 1;
			$self->e->request->agent eq $agent ? 1: 0;
		};
	  }: do {
		$e->debug_out("# + session verifi_agent: OFF.");
		sub { 1 };
	  };

	*{"${base_name}::ipaddr_check"}= $cf->{ipaddr_check_level} ? do {
		$cf->{ipaddr_check_level}=~m{^(?:1|C)}i ? do {
			$e->debug_out("# + session ipaddr check: C class.");
			sub {
				my($self, $data)= @_;
				my $addr= $data->{$self->addr_key_name} || return 1;
				my($level)= $addr=~/^(\d+\.\d+\.\d+)/;
				$self->e->request->address=~/^${level}\.\d+$/ ? 1: 0;
			  };
		  }: do {
			$e->debug_out("# + session ipaddr check: Absolute.");
			sub {
				my($self, $data)= @_;
				my $addr= $data->{$self->addr_key_name} || return 1;
				$self->e->request->address eq $addr ? 1: 0;
			  };
		  };
	  }: do {
		$e->debug_out("# + session ipaddr check: None.");
		sub { 1 };
	  };

	$tie_handler->startup($e, $conf);
	$class;
}
sub new {
	my $class= shift;
	my %session;
	tie %session, $tie_handler, @_;
	my $self= bless \%session, $class;
	tied(%session)->initialize($self);
	$self;
}
sub context { tied(%{$_[0]}) }
sub session { $_[0]->context->[0] }
sub e       { $_[0]->context->[1] }
sub conf    { $_[0]->context->[2] }
sub attr    { $_[0]->context->[3] }

sub is_handler  { $tie_handler }
sub is_update   { $_[0]->attr->{update}   }
sub is_newentry { $_[0]->attr->{newentry} }

sub create_id {
	my $self= shift;
	my $leng= shift || 32;  ## rand(1000);
	substr( sha1_hex(time. {}. rand(1000). $$), 0, $leng );
}
sub change {
	my($self)= @_;
	$self->context->normalize
	   ($self->context->create_session_id, $self->session);
	$self;
}
sub clear {
	my($self)= @_;
	$self->context->normalize
	   ($self->context->create_session_id, {});
	$self;
}
sub delete {
	my $self= shift;
	$self->context->delete(@_);
}
sub __sessionkit_config {
	my $conf= shift;
	my $data= shift || die q{ I want sessionkit setup. };
	ref($data) eq 'HASH' ? do {
		my $cname= $data->{name}
		   || die q{ I want sessionkit setup 'component name' };
		$conf->{ __sessionkit_name_conv($cname) }= $data->{conf} || {};
		return $cname;
	  }:
	ref($data) eq 'ARRAY' ? do {
		my $cname= $data->[0]
		   || die q{ I want sessionkit setup 'component name' };
		$conf->{ __sessionkit_name_conv($cname) }= $data->[1] || {};
		return $cname;
	  }: do {
		$conf->{ __sessionkit_name_conv($data) }= {};
		return $data;
	  };
}
sub __sessionkit_name_conv {
	my($name)= @_;
	$name=~s{\:\:} [_]g;
	lc($name);
}

package Egg::Plugin::SessionKit::handler::TieHash;
use strict;
use warnings;

package Egg::Plugin::SessionKit::base;
use strict;
use warnings;
use Tie::Hash;
use Class::C3;

our @ISA = 'Tie::ExtraHash';

__PACKAGE__->mk_ro_accessors
  (qw/ parent is_update is_newentry is_rollback is_output_id is_session_id /);

sub e    { $_[0][1] }
sub conf { $_[0][2] }
sub attr { $_[0][3] }
sub mod_conf { $_[0]->conf->{config} }

sub mk_ro_accessors {
	my $proto= shift;
	my $class= ref($proto) || $proto;
	no strict 'refs';  ## no critic.
	no warnings 'redefine';
	for (@_) {
		my $key= $_; $key=~s{^is_} [];
		*{"${class}::$_"}= sub { $_[0][3]{$key} };
	}
}
*config     = \&conf;
*new_entry  = \&is_newentry;
*session_id = \&is_session_id;

sub agent_key_name { 'session_user_agent' }
sub addr_key_name  { 'session_remote_addr' }

sub TIEHASH {
	my($class, $e, $conf, $id)= @_;
	bless [{}, $e, $conf, {
	  update    => 0,
	  newentry  => 0,
	  rollback  => 0,
	  output_id => 0,
	  session_id=> ($id || ""),
	  }], $class;
}
sub STORE {
	my $self= shift;
	$self->attr->{update}= 1;
	$self->[0]{$_[0]}= $_[1];
}
sub DELETE {
	my $self= shift;
	$self->attr->{update}= 1;
	delete($self->[0]{$_[0]});
}
sub initialize {
	my $self= shift;
	$self->attr->{parent}= shift;
	my($session_id, $session_data);
	if ($session_id= $self->get_bind_data($self->conf->{key_name})) {
		$session_id= 0 unless $self->issue_check_id($session_id);
	}
	if ($session_id) {
		$self->e->debug_out("# + session restore: ${session_id}");
		$session_data= $self->restore($session_id)
		   || do { $session_id= $self->create_session_id; {} };
	} else {
		$session_id= $self->create_session_id;
		$session_data= {};
	}
	$self->normalize($session_id, $session_data);
}
sub normalize {
	my $self= shift;
	my $id  = shift || $self->is_session_id;
	my $data= shift || $self->[0];
	$data= {} unless $self->agent_check($data);
	$data= {} unless $self->ipaddr_check($data);
	$data->{session_id}= $self->attr->{session_id}= $id;
	$data->{session_create_time} ||= time;
	$data->{$self->agent_key_name}= $self->e->request->agent;
	$data->{$self->addr_key_name }= $self->e->request->address;
	$data->{access_time_old}= $data->{access_time_now} || 0;
	$data->{access_time_now}= time;
	$self->[0]= $data;
	$self;
}
sub create_session_id {
	my($self)= @_;
	my $id= $self->issue_id
	     || die q{ 'Issue_id' method doesn't return the value. };
	$self->attr->{newentry}= $self->attr->{output_id}= 1;
	$self->e->debug_out("# + session newentry : $id");
	$id;
}
sub output_session_id {
	my $self= shift;
	my $id  = shift || $self->is_session_id;
	$self->set_bind_data($self->conf->{key_name}, $id, @_);
}
sub issue_id {
	$_[0]->parent->create_id(32);
}
sub issue_check_id {
	my $self= shift;
	my $id  = shift || return 0;
	$id=~/^[A-Fa-f0-9]{32}$/ ? $id: 0;
}
sub commit_ok { }
sub insert  { die q{ There is no 'insert' method. } }
sub update  { die q{ There is no 'update' method. } }
sub restore { die q{ There is no 'restore' method. } }
sub set_bind_data { die q{ There is no 'set_bind_data' method. } }
sub get_bind_data { die q{ There is no 'get_bind_data' method. } }
sub startup { @_ }

sub DESTROY {
	my($self)= @_;
	return 1 unless $self->[0];
	if ($self->is_update and ! $self->is_rollback) {
		my $method= $self->is_newentry ? 'insert': 'update';
		$self->e->debug_out("# + session ${method}: ". $self->is_session_id);
		$self->$method;
		$self->commit_ok(1);
	}
	$self->output_session_id if $self->is_output_id;
}

1;

__END__

=head1 SEE ALSO

L<Class::C3>,
L<Digest::SHA1>,
L<Class::Accessor::Fast>,
L<Tie::Hash>,
L<Egg::Plugin::IxHash>,
L<Egg::Release>,

=head1 AUTHOR

Masatoshi Mizuno E<lt>lusheE<64>cpan.orgE<gt>

=head1 COPYRIGHT

Copyright (C) 2007 by Bee Flag, Corp. E<lt>http://egg.bomcity.com/E<gt>, All Rights Reserved.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.6 or,
at your option, any later version of Perl 5 you may have available.

=cut

