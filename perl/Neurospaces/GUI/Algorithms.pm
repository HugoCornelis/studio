#!/usr/bin/perl -w

##
## Neurospaces: a library which implements a global typed symbol table to
## be used in neurobiological model maintenance and simulation.
##
## $Id: Algorithms.pm 1.11 Sat, 21 Apr 2007 21:21:25 -0500 hugo $
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


package Neurospaces::GUI::Algorithms;


use strict;


use Glib qw/TRUE FALSE/;

use Neurospaces::GUI;


sub algorithms_create_window
{
    my $self = shift;

    my $constructor
	= {
	   arguments => '',
	   method => 'Neurospaces::GUI::Algorithms::new_with_window',
	  };

    my $window = Neurospaces::GUI::window_factory('algorithms', $constructor);

    $self->{gui}->{windows}->{algorithms} = $window;

    $window->set_title("Instantiated Algorithms");

    $window->set_default_size(500, 300);

    $window->signal_connect(delete_event => sub { Neurospaces::GUI::window_close($window); }, );

    $window->set_border_width(10);

    # everything contained in a horizontal layout

    my $hbox = Gtk2::HBox->new();

    $window->add($hbox);

    {
	# center : scrollable text

	my $table_scroller = Gtk2::ScrolledWindow->new();

	$table_scroller->set_size_request(200, 300);

	$table_scroller->set_policy (qw/automatic automatic/);

	$hbox->pack_start ($table_scroller, 1, 1, 0);

	my $textbuffer_algorithms = Gtk2::TextBuffer->new();

	$self->{gtk2_textbuffer_algorithms} = $textbuffer_algorithms;

	my $text_algorithms = Gtk2::TextView->new();

	$text_algorithms->set_editable(FALSE);

	$text_algorithms->set_buffer($textbuffer_algorithms);

	$table_scroller->add($text_algorithms);
    }

    # show the window

    $window->show_all();

    return $window;
}


sub explore
{
    my $self = shift;

    $self->algorithms_create_window();

    # fill the text buffer

    my $textbuffer_algorithms = $self->{gtk2_textbuffer_algorithms};

    $textbuffer_algorithms->set_text(YAML::Dump($self->{state}->{algorithm_report}));
}


sub initialize_state
{
    my $self = shift;

    $self->{state}->{algorithm_report} = SwiggableNeurospaces::swig_get_algorithms("");
}


sub new
{
    my $class = shift;

    my $options = shift;

    my $self = {};

    bless $self, $class;

    $self->initialize_state();

    return $self;
}


sub new_with_window
{
    new('Neurospaces::GUI::Algorithms', @_)->explore();
}


1;


