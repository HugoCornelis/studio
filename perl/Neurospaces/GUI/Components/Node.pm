#!/usr/bin/perl -w

##
## Neurospaces: a library which implements a global typed symbol table to
## be used in neurobiological model maintenance and simulation.
##
## $Id: Node.pm 1.27 Sat, 21 Apr 2007 21:21:25 -0500 hugo $
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


package Neurospaces::GUI::Components::Node;


use strict;


use Glib qw/TRUE FALSE/;

use Gtk2::SimpleList;

use Neurospaces_embed;
use Neurospaces::GUI;


sub explore
{
    my $self = shift;

    $self->{serial_column} = 8;

#     print "In explore:\n" . Dumper(\@_);

    my $window = $self->window_create();

    $self->window_add_layout($window);

    my $list = $self->{gtk2_list};

    $list->signal_connect
	(
	 row_activated => sub { $self->signal_refiner(@_); },
	);

    my $textbuffer_parameters = $self->{gtk2_textbuffer_parameters};

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
		 $symbol->[2]->{'x'}, $symbol->[2]->{'y'}, $symbol->[2]->{'z'},
		 $symbol->[3]->{'x'}, $symbol->[3]->{'y'}, $symbol->[3]->{'z'},
		 $symbol->[4],
		];
    }

    $window->show_all();
}


sub get_buttons
{
    my $self = shift;

    my $window = $self->{gui}->{window};

    my $result
	= [
# 	   [
# 	    'Delete',
# 	    'Delete item',
# 	    sub
# 	    {
# 		my ($widget, $window) = @_;

# 		print "selected indices: "
# 		    . join(", ", $list->get_selected_indices())
# 			. "\n";

# 		foreach my $index ($list->get_selected_indices())
# 		{
# 		    delete $list->{data}->[$index];
# 		}
# 	    },
# 	   ],
	   {
	    constructor => {
			    arguments => [],
			   },
	    name => 'separator',
	    tip => 'Separate specific buttons from general ones',
	    type => 'Gtk2::HSeparator',
	   },
	   {
	    name => '_Information Extractor',
	    tip => 'Extract information of this model and generate overviews and tables',
	    signals => {
			clicked => {
				    handler =>
				    sub
				    {
					my $widget = shift;

					my $extractor = Neurospaces::GUI::Extractor->new( { context => $self->{context}, serial => $self->{this}, }, );

					$extractor->explore();
				    },
				    arguments => [],
				   },
		       },
	   },
	   {
	    name => 'Open _Parent',
	    signals => {
			clicked => {
				    handler =>
				    sub
				    {
					my $widget = shift;

					print "Exploring parent of $self->{this}\n";

					my $parent = Neurospaces::GUI::Components::Node::factory( { serial => $self->{parent}, studio => $self->{studio}, }, );

					$parent->explore();
				    },
				    arguments => [],
				   },
		       },
	    tip => 'Explore the parent component',
	   },
	   {
	    name => 'Open Pr_ototype',
	    signals => {
			clicked => {
				    handler =>
				    sub
				    {
					my $widget = shift;

					print "Exploring prototype of $self->{this}\n";

					#t get reference to prototype

					my $prototype = Neurospaces::GUI::Components::Node::factory( { serial => $self->{parent}, studio => $self->{studio}, }, );

					$prototype->explore();
				    },
				    arguments => [],
				   },
		       },
	    tip => 'Explore the prototype component (if any)',
	   },
	   {
	    name => 'Open _Menu',
	    signals => {
			clicked => {
				    handler =>
				    sub
				    {
					Neurospaces::GUI::gui('g from node');
				    },
				    arguments => [],
				   },
		       },
	    tip => 'Explore the parent component',
	   },
	   {
	    name => '_Close',
	    signals => {
			clicked => {
				    handler =>
				    sub
				    {
					my $widget = shift;

					print "Closing symbol explorer\n";

					Neurospaces::GUI::window_close($window);
				    },
				    arguments => [],
				   },
		       },
	    tip => 'Close window',
	   },
	  ];

    return $result;
}


sub get_children
{
    my $self = shift;

    my $result = SwiggableNeurospaces::swig_get_children($self->{this});

    return $result;
}


sub get_long_label
{
    my $self = shift;

    my $result = $self->{context};

    $result =~ s(.*/)();

    return $result;
}


sub get_parameters
{
    my $self = shift;

    my $current = shift;

    my $result = [ SwiggableNeurospaces::swig_get_parameters($current), ];

    return $result;
}


sub initialize_state
{
    my $self = shift;

    $self->{state} = {};
}


sub factory
{
    my $options = shift;

    my $self = $options->{studio}->objectify($options->{serial});

    $self->{studio} = $options->{studio};

#     use Data::Dumper;

#     print Dumper($self);

    my $perl_types
	= {
	   T_sym_cell => 'Neurospaces::GUI::Components::Cell',
	   T_sym_connection => 'Neurospaces::GUI::Components::Link',
	   T_sym_network => 'Neurospaces::GUI::Components::Network',
	   T_sym_population => 'Neurospaces::GUI::Components::Network',
	   T_sym_projection => 'Neurospaces::GUI::Components::Link',
	   T_sym_v_connection => 'Neurospaces::GUI::Components::Link',
	  };

    my $perl_type = $perl_types->{$self->{type}} || 'Neurospaces::GUI::Components::Node';

    bless $self, $perl_type;

    $self->initialize_state();

    return $self;
}


sub factory_with_window
{
    factory(@_)->explore();
}


sub signal_cursor_changed
{
    my ($self, $widget) = @_;

    my $cursor = $widget->get_cursor();

    my $selection = $widget->get_selection();

    my $rows = [ $selection->get_selected_rows(), ];

    #! index '0' means first selected row, we select one row at most...

    my $row = $rows->[0];

    if ($row)
    {
	my $indices = [ $row->get_indices(), ];

	#! index '0', see above...

	my $index = $indices->[0];

	my $selected = $widget->{data}->[$index]->[$self->{serial_column}];

	my $current = $self->{this} + $selected;

	print "Parameters for symbol $current\n";

	my $parameters = $self->get_parameters($current);

	my $textbuffer_parameters = $self->{gtk2_textbuffer_parameters};

	$textbuffer_parameters->set_text(YAML::Dump($parameters));
    }
}


sub signal_refiner
{
    my ($self, $widget, $path, $column) = @_;

    my $row_ref = $widget->get_row_data_from_path($path);

    my $selected = $row_ref->[$self->{serial_column}];

    my $current = $self->{this} + $selected;

    print "Exploring symbol $current\n";

    my $child = Neurospaces::GUI::Components::Node::factory({ serial => $current, studio => $self->{studio}, }, );

    $child->explore();
}


sub window_add_buttons
{
    my $self = shift;

    my $vbox = shift;

    # define buttons for this particular window

    my $buttons = $self->get_buttons();

    foreach my $button (@$buttons)
    {
	# construct button

	my $name = $button->{name};

	my $type = $button->{type} || "Gtk2::Button";

	my $constructor = $button->{constructor}->{method} || 'new';

	my $arguments = $button->{constructor}->{arguments} || [ $name ];

	my $but = $type->$constructor(@$arguments);

	# set tooltip

	my $tooltip = $button->{tip};

	$Neurospaces::GUI::tooltips->set_tip($but, $tooltip);

	# handle constructor arguments

	my $constructors = $button->{constructors} || [];

	foreach my $constructor (@$constructors)
	{
	    foreach my $method (keys %$constructor)
	    {
		my $args = $constructor->{$method};

		$but->$method(@$args);
	    }
	}

	# set signal handlers

	my $signals = $button->{signals};

	foreach my $signal (keys %$signals)
	{
	    my $handler = $signals->{$signal}->{handler};

	    my $args = $signals->{$signal}->{arguments};

	    $but->signal_connect($signal => $handler, $self, @$args);
	}

	$vbox->pack_start($but, 0, 1, 0);
    }
}


sub window_add_layout
{
    my $self = shift;

    my $window = shift;

    # everything contained in a horizontal layout

    my $hbox = Gtk2::HBox->new();

    $window->add($hbox);

    {
	# left : component scroller

	my $list_scroller = Gtk2::ScrolledWindow->new();

	$list_scroller->set_policy (qw/automatic automatic/);

	$hbox->pack_start ($list_scroller, 1, 1, 0);

	my $list
	    = Gtk2::SimpleList->new
		(
		 'Name' => 'text',
		 'Type'  => 'text',
		 # 	     ''  => 'pixbuf',
		 'l X' => 'double',
		 'l Y' => 'double',
		 'l Z' => 'double',
		 'a X' => 'double',
		 'a Y' => 'double',
		 'a Z' => 'double',
		 'Index' => 'int',
		);

	$self->{gtk2_list} = $list;

	$list->get_selection()->set_mode('single');

	$list_scroller->add($list);

	# center : scrollable text

	my $table_scroller = Gtk2::ScrolledWindow->new();

	$table_scroller->set_size_request(250, 300);

	$table_scroller->set_policy (qw/automatic automatic/);

	$hbox->pack_start ($table_scroller, 0, 1, 0);

	my $textbuffer_parameters = Gtk2::TextBuffer->new();

	$self->{gtk2_textbuffer_parameters} = $textbuffer_parameters;

	my $text_parameters = Gtk2::TextView->new();

	$text_parameters->set_editable(FALSE);

	$text_parameters->set_buffer($textbuffer_parameters);

	$table_scroller->add($text_parameters);

	# right : vertical layout

	my $vbox = Gtk2::VBox->new (0, 6);

	$hbox->pack_start($vbox, 0, 1, 0);

	$self->window_add_buttons($vbox);
    }

    $Neurospaces::GUI::tooltips->enable();

}


sub window_create
{
    my $self = shift;

#     use Data::Dumper;

#     print Dumper($self);

    my $constructor
	= {
	   arguments => { serial => $self->{this}, },
	   method => 'Neurospaces::GUI::Components::Node::factory_with_window',
	  };

    my $window = Neurospaces::GUI::window_factory('node', $constructor);

    $self->{gui}->{window} = $window;

    $window->set_title("$self->{context} ($self->{type},$self->{this})");

    $window->set_default_size(800, 300);

    # When the window is given the "delete_event" signal (this is given
    # by the window manager, usually by the "close" option, or on the
    # titlebar), we ask it to call the delete_event () functio
    # as defined above. No data is passed to the callback function.
    $window->signal_connect(delete_event => sub { Neurospaces::GUI::window_close($window); }, );

#     # Here we connect the "destroy" event to a signal handler.
#     # This event occurs when we call Gtk2::Widget::destroy on the window,
#     # or if we return FALSE in the "delete_event" callback. Perl supports
#     # anonymous subs, so we can use one of them for one line callbacks.
#     $window->signal_connect(destroy => sub { Gtk2->main_quit(); });

    # Sets the border width of the window.
    $window->set_border_width(10);

    return $window;
}


1;


