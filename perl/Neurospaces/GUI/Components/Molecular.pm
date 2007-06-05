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


package Neurospaces::GUI::Components::Molecule;


use strict;


use base qw(Neurospaces::GUI::Components::Node);

use Glib qw/TRUE FALSE/;

use Neurospaces::GUI;
use Neurospaces::Biolevels;


our $molecular_view
    = {
       'd_roll' => 0,
       'd_heading' => 0,
       'dv_forward' => 0,
       'dv_up' => 0,
       'dv_roll' => 0,
       'dv_heading' => 0,
       'v_right' => 0,
       'v_forward' => 0,
       'v_up' => 0,
       'position' => [
		      -18,
		      30,
		      -12,
		     ],
       'pilotview' => {
		       roll => [
				0, 0.0, 0.0, 1.0,
			       ],
		       pitch => [
				 0.0, 0.0, 1.0, 0.0,
				],
		       heading => [
				   0.0, 1.0, 0.0, 0.0,
				  ],
		       move => {
				v_pilot => 0,
				d_pilot => 0,
				dv_pilot => 0,
			       },
		      },
       'dv_right' => 0,
       'normalizer' => [
			-90,
			1,
			0,
			0
		       ],
       'v_roll' => 0,
       'v_heading' => 0,
      };

our $movements
    = {
       speed => {
		 heading => 5,
		 move => 5,
		 pilot => 5,
		 roll => 5,
		},
      };


sub draw
{
    my $self = shift;

    my $renderer = shift;

    my $options = shift;

    my $gui_command1
	= Neurospaces::GUI::Command->new
	    (
	     {
	      arguments => { view => $molecular_view, },
	      name => 'set_view_molecular',
	      processor => 'view_set',
	      self => $renderer,
	      target => $renderer,
	     },
	    );

    $gui_command1->execute();

    my $gui_command2
	= Neurospaces::GUI::Command->new
	    (
	     {
	      arguments => { movements => $movements, },
	      name => 'set_movements_molecular',
	      processor => 'movements_set',
	      self => $renderer,
	      target => $renderer,
	     },
	    );

    $gui_command2->execute();

    my $active_level = $self->{state}->{molecule_active_level};

    # obtain coordinates

    my $children = $self->get_visible_coordinates($options, );

    my $size = 5e-6;

    my $result;

#     use Data::Dumper;

#     print Dumper($children);

#     print Dumper($children->[0]->[3]);
#     print Dumper($children->[0]->[3]->{this});

    if ($active_level eq 'MOLECULAR')
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
	       name => 'sections',
	       type => 'cubes',
	      };
    }
    elsif ($active_level eq 'ATOMIC')
    {
	$result
	    = {
	       coordinates => [
			       map
			       {
				   my $index1 = $_;

				   my $index2
				       = $_ + 1 > $#$children
					   ? 0
					       : $_ + 1;

				   (
				    # dia

				    1e-6,

				    # two coordinates

				    [
				     $children->[$index1]->[3]->{this}->{'x'} * 1e2,
				     $children->[$index1]->[3]->{this}->{'y'} * 1e2,
				     $children->[$index1]->[3]->{this}->{'z'} * 1e2,
				    ],

				    [
				     $children->[$index2]->[3]->{this}->{'x'} * 1e2,
				     $children->[$index2]->[3]->{this}->{'y'} * 1e2,
				     $children->[$index2]->[3]->{this}->{'z'} * 1e2,
				    ],
				   ),
			       }
			       0 .. $#$children
			      ],
	       color => [ 1, 1, 1, ],
 	       light => 0,
	       name => 'contours',
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
	       name => 'sections',
	       type => 'cubes',
	      };
    }

#     use Data::Dumper;

#     print Dumper($result);

    return $result;
}


sub get_buttons
{
    my $self = shift;

    my $window = $self->{gui}->{window};

    my $active_level = $self->{state}->{molecule_active_level};

    my $all_levels
	= [
	   sort
	   grep { /atom|molec/i }
	   keys %$Neurospaces::Biolevels::biolevel2internal,
	  ];

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
			      @$all_levels,
			     ),

			     # select active level

			     {
			      set_active => [
					     grep
					     {
						 $all_levels->[$_] =~ /$active_level/
					     }
					     0 .. $#$all_levels,
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

					my $active_level = $all_levels->[$active_index];

					$self->{state}->{molecule_active_level} = $active_level;
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

    $self->{state}->{molecule_active_level} = 'MOLECULAR';
}


sub get_visible_coordinates
{
    my $self = shift;

    my $options = shift;

    my $active_level = $self->{state}->{molecule_active_level};

    my $serial = $self->{this};

    my $level = $options->{biolevel} || $Neurospaces::Biolevels::biolevel2internal->{$active_level};

    return SwiggableNeurospaces::swig_get_visible_coordinates($serial, $level);
}


1;

