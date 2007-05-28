#!/usr/bin/perl -w

##
## Neurospaces: a library which implements a global typed symbol table to
## be used in neurobiological model maintenance and simulation.
##
## $Id: Matrix.pm 1.16 Sat, 21 Apr 2007 21:21:25 -0500 hugo $
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


package Neurospaces::GUI::Matrix;


use strict;


use Neurospaces_embed;
use Neurospaces::GUI;


sub result_create_window
{
    my $self = shift;

    my $constructor
	= {
	   arguments => '',
	   method => 'Neurospaces::GUI::Matrix::new_with_window',
# 	   method => '',
	  };

    my $window = Neurospaces::GUI::window_factory('matrix_results', $constructor);

    $self->{gui}->{windows}->{results} = $window;

    $window->set_title("Connection matrix : result set");

    $window->set_default_size(300, 300);

    $window->signal_connect(delete_event => sub { Neurospaces::GUI::window_close($window); }, );

    $window->set_border_width(10);

    # everything contained in a horizontal layout

    my $hbox = Gtk2::HBox->new();

    $window->add($hbox);

    my $list_scroller_results = Gtk2::ScrolledWindow->new();

    $list_scroller_results->set_policy (qw/automatic automatic/);

    $hbox->pack_start($list_scroller_results, 1, 1, 0);

    my $list_results
	= Gtk2::SimpleList->new
	    (
	     'Name' => 'text',
	     'Index' => 'int',
	     'Weight' => 'int',
	     'Delay' => 'int',
	     'Connection' => 'text',
	    );

    $self->{gtk2_results_list} = $list_results;

    $list_results->signal_connect
	(
	 row_activated => sub { $self->signal_refiner(1, @_); },
	);

    $list_scroller_results->add($list_results);

    # show the window

    $window->show_all();

    return $window;
}


sub domain_mappers_create_window
{
    my $self = shift;

    my $constructor
	= {
	   arguments => '',
	   method => '',
	  };

    my $window = Neurospaces::GUI::window_factory('matrix_domain_mappers', $constructor);

    $self->{gui}->{windows}->{domain_mappers} = $window;

    $window->set_title("Connection matrix : spiking related elements");

    $window->set_default_size(800, 300);

    $window->signal_connect(delete_event => sub { Neurospaces::GUI::window_close($window); }, );

    $window->set_border_width(10);

    # everything contained in a horizontal layout

    my $hbox = Gtk2::HBox->new();

    $window->add($hbox);

    my $list_scroller_generators = Gtk2::ScrolledWindow->new();

    $list_scroller_generators->set_policy (qw/automatic automatic/);

    $hbox->pack_start($list_scroller_generators, 1, 1, 0);

    my $list_generators
	= Gtk2::SimpleList->new
	    (
	     'Name' => 'text',
	     'Index' => 'int',
	    );

    $self->{gtk2_generators_list} = $list_generators;

    $list_generators->get_selection()->set_mode('multiple');

    $list_generators->signal_connect
	(
	 row_activated => sub { $self->signal_refiner(1, @_); },
	);

    $list_generators->signal_connect
	(
	 cursor_changed => sub { $self->signal_cursor_changed_typed('generator', 'receiver', @_); },
	);

    $list_scroller_generators->add($list_generators);

    my $list_scroller_receivers = Gtk2::ScrolledWindow->new();

    $list_scroller_receivers->set_policy (qw/automatic automatic/);

    $hbox->pack_start($list_scroller_receivers, 1, 1, 0);

    my $list_receivers
	= Gtk2::SimpleList->new
	    (
	     'Name' => 'text',
	     'Index' => 'int',
	    );

    $self->{gtk2_receivers_list} = $list_receivers;

    $list_receivers->get_selection()->set_mode('multiple');

    $list_receivers->signal_connect
	(
	 row_activated => sub { $self->signal_refiner(1, @_); },
	);

    $list_receivers->signal_connect
	(
	 cursor_changed => sub { $self->signal_cursor_changed_typed('receiver', 'generator', @_); },
	);

    $list_scroller_receivers->add($list_receivers);

    # show the window

    $window->show_all();

    return $window;
}


sub explore
{
    my $self = shift;

    $self->projections_create_window();

    $self->domain_mappers_create_window();

    $self->result_create_window();

    # fill the projection list

    my $list_projections = $self->{gtk2_projections_list};

    $list_projections->signal_connect
	(
	 row_activated => sub { $self->signal_refiner(2, @_); },
	);

    my $projections = $self->{state}->{projections};

    foreach my $projection (@$projections)
    {
	push
	    @{$list_projections->{data}},
		[
		 $projection->[0],
		 $projection->[1],
		 $projection->[2],
		];
    }

    # fill the generators list

    my $list_generators = $self->{gtk2_generators_list};

    my $generators = $self->{state}->{generators};

    foreach my $generator (@$generators)
    {
	push
	    @{$list_generators->{data}},
		[
		 $generator->[0],
		 $generator->[1],
		 $generator->[2],
		];
    }

    # fill the receivers list

    my $list_receivers = $self->{gtk2_receivers_list};

    my $receivers = $self->{state}->{receivers};

    foreach my $receiver (@$receivers)
    {
	push
	    @{$list_receivers->{data}},
		[
		 $receiver->[0],
		 $receiver->[1],
		 $receiver->[2],
		];
    }
}


sub initialize_state
{
    my $self = shift;

    my $pq = SwiggableNeurospaces::swig_pq_get();

    $self->{state}->{pq} = $pq;

    my $projections = SwiggableNeurospaces::get_projections("void");

    $self->{state}->{projections} = $projections;

    my $receivers = SwiggableNeurospaces::get_receivers("void");

    $self->{state}->{receivers} = $receivers;

    my $generators = SwiggableNeurospaces::get_generators("void");

    $self->{state}->{generators} = $generators;
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
    new('Neurospaces::GUI::Matrix', @_)->explore();
}


sub projections_create_window
{
    my $self = shift;

    my $constructor
	= {
	   arguments => '',
	   method => '',
	  };

    my $window = Neurospaces::GUI::window_factory('matrix_projections', $constructor);

    $self->{gui}->{windows}->{projections} = $window;

    $window->set_title("Connection matrix : projections");

    $window->set_default_size(300, 300);

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
	     'Name' => 'text',
	     'Type'  => 'text',
	     'Index' => 'int',
# 	     'Source' => 'text',
# 	     'Target' => 'text',
	    );

    $self->{gtk2_projections_list} = $list;

    $list->get_selection()->set_mode('multiple');

    $list->get_selection()->signal_connect
	(
	 changed =>
	 sub
	 {
	     my ($selection) = @_;

	     my $rows = [ $selection->get_selected_rows(), ];

	     my $indices = [ map { $_->get_indices(); } @$rows, ];

	     my $contexts = [ map { $list->{data}->[$_]->[0]; } @$indices, ];

	     my $line = join ', ', @$contexts;

	     print "Changing projection query to $line\n";

	     $line =~ s/,//g;

	     if ($line =~ /\S/)
	     {
		 $line = "pqset c $line";

		 Neurospaces::pq_set($line);
	     }
	 },
	);

    $list_scroller->add($list);

    # show the window

    $window->show_all();

    return $window;
}


sub signal_cursor_changed_typed
{
    my ($self, $type1, $type2, $widget) = @_;

    my ($path, $column) = $widget->get_cursor();

#     #! results in $column

#     my $cursor = $widget->get_cursor();

    my $index = $path->get_indices();

    #! arggh, singular to plural conversion, should keep linguistics out here.

    my $list = $self->{"gtk2_${type1}s_list"};

    my $attachment = $list->{data}->[$index]->[0];

    my $connections = [ Neurospaces::attachment_to_connections($attachment), ];

    $self->{result_data} = $connections;

    my $result_list = $self->{gtk2_results_list};

    @{$result_list->{data}} = ();

    foreach my $connection (@$connections)
    {
	push
	    @{$result_list->{data}},
		[
		 $connection->{$type2}->{context},
		 $connection->{$type2}->{serial},
		 $connection->{attributes}->{weight},
		 $connection->{attributes}->{delay},
		 $connection->{group}->{context},
		];
    }
}


sub signal_refiner
{
    my ($self, $serial_column, $widget, $path, $column) = @_;

    my $row_ref = $widget->get_row_data_from_path($path);

    my $selected = $row_ref->[$serial_column];

    print "Exploring symbol $selected\n";

    my $symbol = Neurospaces::GUI::Components::Node::factory({ serial => $selected, }, );

    $symbol->explore();
}


1;


