#!/usr/bin/perl -w

##
## Neurospaces: a library which implements a global typed symbol table to
## be used in neurobiological model maintenance and simulation.
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


package Neurospaces::GUI::Components::Network;


use strict;


use base qw(Neurospaces::GUI::Components::Node);

use Glib qw/TRUE FALSE/;

use Neurospaces::GUI;
use Neurospaces::Biolevels;


sub draw
{
    my $self = shift;

    my $renderer = shift;

    my $options = shift;

    my $active_level = $self->{state}->{network_active_level};

    # obtain coordinates

    my $children = $self->get_visible_coordinates($options, );

    my $size = 5e-6;

    my $result;

#     use Data::Dumper;

#     print Dumper($children);

#     print Dumper($children->[0]->[3]);
#     print Dumper($children->[0]->[3]->{this});

    if ($active_level eq 'CELL')
    {
	$result
	    = {
	       coordinates => [
			       map
			       {
				   [ $_->[3]->{this}, $size, ];
			       }
			       @$children
			      ],
	       color => [ 1, 1, 1, ],
	       light => 1,
	       name => 'population',
	       type => 'cubes',
	      };
    }
    elsif ($active_level eq 'SEGMENT')
    {
	$result
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
				   ),
			       }
			       @$children
			      ],
	       color => [ 1, 1, 1, ],
 	       light => 0,
	       name => 'population',
	       type => 'GL_LINES',
	      };
    }
    else
    {
	$result
	    = {
	       coordinates => [
			       map
			       {
				   [ $_->[3]->{this}, $size, ];
			       }
			       @$children
			      ],
	       color => [ 1, 1, 1, ],
 	       light => 1,
	       name => 'population',
	       type => 'cubes',
	      };
    }

    return $result;
}


sub get_buttons
{
    my $self = shift;

    my $window = $self->{gui}->{window};

    my $active_level = $self->{state}->{network_active_level};

    my $result
	= [
	   {
	    name => '_Render',
	    tip => 'Render Component',
	    signals => {
			clicked => {
				    handler =>
				    sub
				    {
					my $widget = shift;

					my $renderer = $Neurospaces::Studio::renderer;

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

					$self->{state}->{network_active_level} = $active_level;
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


sub get_specific_parameters
{
    my $self = shift;

    my $current = shift;

    my $specific_parameters
	= {
	  };

    my $result = $self->parameters_2_array_ref($current, $specific_parameters);

    return $result;
}


sub get_visible_coordinates
{
    my $self = shift;

    my $options = shift;

    my $active_level = $self->{state}->{network_active_level};

    my $serial = $self->{this};

    my $level = $options->{biolevel} || $Neurospaces::Biolevels::biolevel2internal->{$active_level};

    return SwiggableNeurospaces::swig_get_visible_coordinates($serial, $level, $SwiggableNeurospaces::SELECTOR_BIOLEVEL_EXCLUSIVE);
}


sub initialize_state
{
    my $self = shift;

    $self->SUPER::initialize_state(@_);

    $self->{state}->{network_active_level} = 'CELL';
}


1;


