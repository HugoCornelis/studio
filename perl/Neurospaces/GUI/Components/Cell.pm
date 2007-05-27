#!/usr/bin/perl -w

##
## Neurospaces: a library which implements a global typed symbol table to
## be used in neurobiological model maintenance and simulation.
##
## $Id: Cell.pm 1.23 Thu, 10 May 2007 20:53:37 -0500 hugo $
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


package Neurospaces::GUI::Components::Cell;


use strict;


use base qw(Neurospaces::GUI::Components::Node);

use Glib qw/TRUE FALSE/;

use Neurospaces_embed;
use Neurospaces::GUI;
use Neurospaces::Biolevels;


sub draw
{
    my $self = shift;

    my $renderer = shift;

    my $options = shift;

    # obtain coordinates

    my $children = $self->get_visible_coordinates($options, );

    my $result
	= {
	   coordinates => [
			   map
			   {
			       (
				# dia

				$_->[4],

				# two coordinates

				[
				 $_->[3]->{this}->{'x'},
				 $_->[3]->{this}->{'y'},
				 $_->[3]->{this}->{'z'},
				],

				[
				 $_->[3]->{parent}->{'x'},
				 $_->[3]->{parent}->{'y'},
				 $_->[3]->{parent}->{'z'},
				],
			       );
			   }
			   @$children
			  ],
	   color => [ 1, 1, 1, ],
	   light => 0,
	   name => 'segment_group',
	   type => 'GL_LINES',
	  };

    return $result;
}


sub get_buttons
{
    my $self = shift;

    my $window = $self->{gui}->{window};

    my $active_level = $self->{state}->{cell_active_level};

    my $result
	= [
	   {
	    name => '_Render',
	    signals => {
			clicked => {
				    handler =>
				    sub
				    {
					my $widget = shift;

					my $renderer = $Neurospaces::renderer;

					if (!$renderer)
					{
					    print "renderer is not initialized (value is $renderer)\n";
					}
					else
					{
					    $renderer->symbol_set($self);
					}
				    },
				    arguments => [],
				   },
		       },
	    tip => 'Render Component',
	   },
	   {
	    constructor => {
			    method => 'new_text',
			    arguments => [],
			   },
	    constructors => [
			     (
			      map
			      {
				  {
				      append_text => [ $_ ]
				  }
			      }
			      sort grep { /cell|segment|popul/i } keys %$Neurospaces::Biolevels::biolevel2internal,
			     ),

			     # select active level

			     {
			      set_active => [
					     grep
					     {
						 (sort grep { /cell|segment|popul/i } keys %$Neurospaces::Biolevels::biolevel2internal)[$_] =~ /$active_level/
					     }
					     0 .. (scalar grep { /cell|segment|popul/i } keys %$Neurospaces::Biolevels::biolevel2internal) - 1,
					    ],
			     },
			    ],
	    signals => {
			changed => {
				    handler =>
				    sub
				    {
					my $combo = shift;

					my $active_index = $combo->get_active();

					my $active_level = (sort grep { /cell|segment|popul/i } keys %$Neurospaces::Biolevels::biolevel2internal)[$active_index];

					$self->{state}->{cell_active_level} = $active_level;
				    },
				   },
		       },
	    tip => 'Allows to set the detail for rendering',
	    type => 'Gtk2::ComboBox',
	   },
	  ];

    $result = [ @$result, @{ $self->SUPER::get_buttons(@_), }, ];

    return $result;
}


sub initialize_state
{
    my $self = shift;

    $self->SUPER::initialize_state(@_);

    $self->{state}->{cell_active_level} = 'SEGMENT';
}


sub get_visible_coordinates
{
    my $self = shift;

    my $options = shift;

    my $active_level = $self->{state}->{cell_active_level};

    my $serial = $self->{this};

    my $level = $options->{biolevel} || $Neurospaces::Biolevels::biolevel2internal->{$active_level};

#     print "Cell.pm: Drawing level is $level\n";

    return Neurospaces::get_visible_coordinates($serial, $level);
}


1;


