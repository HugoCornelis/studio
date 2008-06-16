#!/usr/bin/perl -w

##
## Neurospaces: a library which implements a global typed symbol table to
## be used in neurobiological model maintenance and simulation.
##
## $Id: Workload.pm 1.11 Sat, 21 Apr 2007 21:21:25 -0500 hugo $
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


package Neurospaces::GUI::Workload;


use strict;


use Glib qw/TRUE FALSE/;

use Neurospaces::Biolevels;
use Neurospaces::GUI;


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
    new('Neurospaces::GUI::Workload', @_)->explore();
}


sub workload_create_window
{
    my $self = shift;

    my $constructor
	= {
	   arguments => '',
	   method => 'Neurospaces::GUI::Workload::new_with_window',
	  };

    my $window = Neurospaces::GUI::window_factory('workload', $constructor);

    $self->{gui}->{windows}->{workload} = $window;

    $window->set_title("Workload and Partitioning");

    $window->set_default_size(500, 300);

    $window->signal_connect(delete_event => sub { Neurospaces::GUI::window_close($window); }, );

    $window->set_border_width(10);

    # everything contained in a horizontal layout

    my $hbox = Gtk2::HBox->new();

    $window->add($hbox);

    {
	# left panel : scrollable text

	my $table_scroller = Gtk2::ScrolledWindow->new();

	$table_scroller->set_size_request(200, 300);

	$table_scroller->set_policy (qw/automatic automatic/);

	$hbox->pack_start ($table_scroller, 1, 1, 0);

	my $textbuffer_workload = Gtk2::TextBuffer->new();

	$self->{gtk2_textbuffer_workload} = $textbuffer_workload;

	my $text_workload = Gtk2::TextView->new();

	$text_workload->set_editable(FALSE);

	$text_workload->set_buffer($textbuffer_workload);

	$table_scroller->add($text_workload);
    }

    {
	my $vbox = Gtk2::VBox->new();

	# right panel : action button, number of partitions textbox

	my $combobox_partitions = Gtk2::ComboBoxEntry->new_text;
	
	$combobox_partitions->append_text("2");
	$combobox_partitions->append_text("5");
	$combobox_partitions->append_text("10");
	$combobox_partitions->append_text("20");
	$combobox_partitions->append_text("30");

	my $child = $combobox_partitions->child();

       $child->signal_connect
	   (
	    'changed' =>
	    sub
	    {
		my $entry = shift;

		my $value = $entry->get_text();

		$self->{state}->{partitions} = $value;
	    },
	   );
		
	$combobox_partitions->set_active(0);

	$vbox->pack_start($combobox_partitions, 0, 1, 0);

	my $button = Gtk2::Button->new('_Partition');

	$button->signal_connect
	    (
	     clicked =>
	     sub
	     {
		 $self->partition();
	     },
	    );

	$vbox->pack_start($button, 0, 1, 0);

	# add the right panel

	$hbox->pack_start($vbox, 1, 1, 0);
    }

    # show the window

    $window->show_all();

    return $window;
}


sub explore
{
    my $self = shift;

    $self->workload_create_window();
}


sub initialize_state
{
    my $self = shift;

    $self->{state}
	= {
	   detail_level => $Neurospaces::Biolevels::biolevel2internal->{'MECHANISM'},
	   partitions => 2,
	  };
}


sub partition
{
    my $self = shift;

    $self->{state}->{workload_report}
	= SwiggableNeurospaces::swig_get_workload
	    (
	     0,
	     $self->{state}->{partitions},
	     $self->{state}->{detail_level},
	    );

    # fill the text buffer

    my $textbuffer_workload = $self->{gtk2_textbuffer_workload};

    $textbuffer_workload->set_text(YAML::Dump($self->{state}->{workload_report}));

}


1;


