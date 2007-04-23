#!/usr/bin/perl -w

##
## Neurospaces: a library which implements a global typed symbol table to
## be used in neurobiological model maintenance and simulation.
##
## $Id: Link.pm 1.12 Sat, 21 Apr 2007 21:21:25 -0500 hugo $
##

##############################################################################
##'
##' Neurospaces : testbed C implementation that integrates with genesis
##'
##' Copyright (C) 1999-2007 Hugo Cornelis
##'
##' functional ideas ..	Hugo Cornelis, hugo.cornelis@gmail.com
##'
##' coding ............	Hugo Cornelis, hugo.cornelis@gmail.com
##'
##############################################################################


package Neurospaces::GUI::Components::Link;


use strict;


use base qw(Neurospaces::GUI::Components::Node);

use Glib qw/TRUE FALSE/;

use Neurospaces_embed;
use Neurospaces::GUI;


sub explore
{
    my $self = shift;

    $self->{serial_column} = 2;

#     print "In explore:\n" . Dumper(\@_);

    my $window = $self->window_create();

    $self->window_add_layout($window);

    my $list = $self->{gtk2_list};

    $list->signal_connect
	(
	 row_activated => sub { $self->signal_refiner(@_); },
	);

    $list->signal_connect
	(
	 cursor_changed => sub { $self->signal_cursor_changed(@_); },
	);

#     my @pixbufs;
#     foreach (qw/gtk-ok gtk-cancel gtk-quit gtk-apply gtk-clear 
# 		gtk-delete gtk-execute gtk-dnd/)
#     {
# 	push @pixbufs, $window->render_icon ($_, 'menu');
#     }
#     # so some will be blank
#     push @pixbufs, undef;

    my $symbols = $self->get_children();

    foreach my $symbol (@$symbols)
    {
	push
	    @{$list->{data}},
		[
		 $symbol->[0],
		 $symbol->[1],
# 		 $pixbufs[rand($#pixbufs)],
		 $symbol->[4],
		];
    }

    $window->show_all();
}


sub get_long_label
{
    my $self = shift;

    my $result = $self->SUPER::get_long_label();

    my $source
	= [
	   map { s(.*/)(); $_ }
	   map { $_->{Value} }
	   grep { $_->{Name} =~ /SOURCE|PRE/ }
	   Neurospaces::get_parameters($self->{this}),
	  ];

    $source = join ', ', @$source;

    my $target
	= [
	   map { s(.*/)(); $_ }
	   map { $_->{Value} }
	   grep { $_->{Name} =~ /TARGET|POST/ }
	   Neurospaces::get_parameters($self->{this}),
	  ];

    $target = join ', ', @$target;

    if ($source || $target)
    {
	$result .= '\n' . (join ' -> ', $source, $target);
    }

    return $result;
}

sub window_add_layout
{
    my $self = shift;

    my $window = shift;

    my $hbox = Gtk2::HBox->new();

    $window->add($hbox);

    my $list_scroller = Gtk2::ScrolledWindow->new();

    $list_scroller->set_policy (qw/automatic automatic/);

    $hbox->pack_start ($list_scroller, 1, 1, 0);

    my $list
	= Gtk2::SimpleList->new
	    (
	     'Name' => 'text',
	     'Type'  => 'text',
# 	     ''  => 'pixbuf',
	     'index' => 'int',
	    );

    $self->{gtk2_list} = $list;

    $list->get_selection()->set_mode('single');

    $list_scroller->add($list);

    my $table_scroller = Gtk2::ScrolledWindow->new();

    $table_scroller->set_size_request(200, 300);

    $table_scroller->set_policy (qw/automatic automatic/);

    $hbox->pack_start ($table_scroller, 0, 1, 0);

    my $textbuffer_parameters = Gtk2::TextBuffer->new();

    $self->{gtk2_textbuffer_parameters} = $textbuffer_parameters;

    my $text_parameters = Gtk2::TextView->new();

    $text_parameters->set_editable(FALSE);

    $text_parameters->set_buffer($textbuffer_parameters);

    $table_scroller->add($text_parameters);

    my $vbox = Gtk2::VBox->new (0, 6);

    $hbox->pack_start($vbox, 0, 1, 0);

    $self->window_add_buttons($vbox);

    $Neurospaces::GUI::tooltips->enable();

}


1;


