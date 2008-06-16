#!/usr/bin/perl -w

##
## Neurospaces: a library which implements a global typed symbol table to
## be used in neurobiological model maintenance and simulation.
##
## $Id: Namespaces.pm 1.10 Sat, 21 Apr 2007 21:21:25 -0500 hugo $
##

##############################################################################
##'
##' Neurospaces : testbed C implementation that integrates with genesis
##'
##' Copyright (C) 1999-2008 Hugo Cornelis
##'
##' functional ideas ..	Hugo Cornelis, hugo.cornelis@gmail.com
##'
##' coding ............	Hugo Cornelis, hugo.cornelis@gmail.com
##'
##############################################################################


package Neurospaces::GUI::Namespaces;


use strict;


use Neurospaces::GUI;


sub explore
{
    my $self = shift;

    $self->namespaces_create_window();

    # fill the namespaces list

    my $list_namespaces = $self->{gtk2_namespaces_list};

    $list_namespaces->signal_connect
	(
	 row_activated => sub { $self->signal_refiner(1, @_); },
	);

    my $namespaces = $self->{state}->{namespaces};

    foreach my $namespace_array (@$namespaces)
    {
	my $filename = $namespace_array->{filename};

	my $path = $filename;

	$filename =~ s|.*/||;

	my $namespace = $namespace_array->{namespace};

	push
	    @{$list_namespaces->{data}},
		[
		 $filename,
		 $namespace . "::",
		 $path,
		];
    }
}


sub namespaces_create_window
{
    my $self = shift;

    my $constructor
	= {
	   arguments => { namespace => $self->{state}->{this}, },
	   method => 'Neurospaces::GUI::Namespaces::new_with_window',
	  };

    my $window = Neurospaces::GUI::window_factory('namespaces', $constructor);

    $self->{gui}->{windows}->{namespaces} = $window;

    $window->set_title("Loaded namespaces and their files");

    $window->set_default_size(500, 300);

    $window->signal_connect(delete_event => sub { Neurospaces::GUI::window_close($window); }, );

    $window->set_border_width(10);

    # everything contained in a horizontal layout

    my $hbox = Gtk2::HBox->new();

    $window->add($hbox);

    my $list_scroller = Gtk2::ScrolledWindow->new();

    $list_scroller->set_policy (qw/automatic automatic/);

    $hbox->pack_start($list_scroller, 1, 1, 0);

    my $list
	= Gtk2::SimpleList->new
	    (
	     'Filename' => 'text',
	     'Namespace' => 'text',
	     'Path' => 'text',
	    );

    $self->{gtk2_namespaces_list} = $list;

    $list->get_selection()->set_mode('single');

    $list_scroller->add($list);

    # show the window

    $window->show_all();

    return $window;
}


sub initialize_state
{
    my $self = shift;

    $self->{state}->{namespaces} = SwiggableNeurospaces::swig_get_namespaces($self->{state}->{this}, );
}


sub new
{
    my $class = shift;

    my $options = shift;

    my $self = {};

    $self->{state}->{this} = $options->{namespace};

    bless $self, $class;

    $self->initialize_state();

    return $self;
}


sub new_with_window
{
    new('Neurospaces::GUI::Namespaces', @_)->explore();
}


sub signal_refiner
{
    my ($self, $serial_column, $widget, $path, $column) = @_;

    my $row_ref = $widget->get_row_data_from_path($path);

    my $selected = $self->{state}->{this} . $row_ref->[$serial_column];

    print "Exploring namespace $selected\n";

    my $namespace = Neurospaces::GUI::Namespaces->new( { namespace => $selected, }, );

    $namespace->explore();
}


1;


