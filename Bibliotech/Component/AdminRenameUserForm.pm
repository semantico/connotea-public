# Copyright 2006 Nature Publishing Group
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# The Bibliotech::Component::AdminRenameUserForm class provides an
# interface to submit usernames of spammers for torture, er, removal.

package Bibliotech::Component::AdminRenameUserForm;
use strict;
use base 'Bibliotech::Component';

sub last_updated_basis {
  'NOW';
}

sub rename {
  my ($self, $old_username, $new_username) = @_;
  my $renaming_user = Bibliotech::User->new($old_username) or die "Cannot find user \"$old_username\".\n";
  $renaming_user->rename($new_username);
}

sub html_content {
  my ($self, $class, $verbose, $main) = @_;

  my $user       = $self->getlogin or return $self->saylogin('to deactive spammers');
  my $username   = $user->username;
  my $bibliotech = $self->bibliotech;
  my $cgi        = $bibliotech->cgi;
  my $validationmsg;
  my @report;

  if (my $old = $self->cleanparam($cgi->param('old')) and
      my $new = $self->cleanparam($cgi->param('new')) and
      $cgi->request_method eq 'POST') {
    eval {
      $self->rename($old => $new);
      push @report, "Renamed \"$old\" to \"$new\".";
    };
    $validationmsg = $@ if $@;
  }

  my $o = '';

  $o .= $cgi->div({class => 'errormsg'}, $validationmsg) if $validationmsg;
  $o .= $cgi->div({class => 'actionmsg'}, map { $_.$cgi->br } @report) if @report;

  $o .= $cgi->div($cgi->h1('Rename User'),
		  $cgi->start_form(-method => 'POST', -action => $bibliotech->location.'adminrenameuser'),
		  'Old username:', $cgi->br,
		  $cgi->textfield(-id => 'oldbox', -class => 'searchtextctl', -name => 'old', -size => 20),
		  $cgi->br,
		  'New username:', $cgi->br,
		  $cgi->textfield(-id => 'newbox', -class => 'searchtextctl', -name => 'new', -size => 20),
		  $cgi->br,
		  $cgi->submit(-id => 'submitbutton', -class => 'buttonctl', -name => 'button', -value => 'Submit'),
		  $cgi->end_form,
		  );

  return Bibliotech::Page::HTML_Content->simple($o);
}

1;
__END__
