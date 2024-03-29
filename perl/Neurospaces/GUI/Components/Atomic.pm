#!/usr/bin/perl -w

##
## Neurospaces: a library which implements a global typed symbol table to
## be used in neurobiological model maintenance and simulation.
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


package Neurospaces::GUI::Components::Atomic;


use strict;


use base qw(Neurospaces::GUI::Components::Node);

use Glib qw/TRUE FALSE/;

use Neurospaces::GUI;
use Neurospaces::Biolevels;


our $atomic_view
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
		      -0.5,
		      1.5,
		      -0.5,
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
       'scale' => [
		   1e7,
		   1e7,
		   1e7,
		  ],
       'dv_zoom' => 0,
       'v_zoom' => 0,
      };

our $movements
    = {
       speed => {
		 heading => 5,
		 move => 1,
		 pilot => 5,
		 roll => 5,
		 zoom => 1e6,
		},
      };


sub draw
{
    my $self = shift;

    my $d3renderer = shift;

    my $options = shift;

    my $gui_command1
	= Neurospaces::GUI::Command->new
	    (
	     {
	      arguments => { view => $atomic_view, },
	      name => 'set_view_atomic',
	      processor => 'view_set',
	      self => $d3renderer,
	      target => $d3renderer,
	     },
	    );

    $gui_command1->execute();

    my $gui_command2
	= Neurospaces::GUI::Command->new
	    (
	     {
	      arguments => { movements => $movements, },
	      name => 'set_movements_atomic',
	      processor => 'movements_set',
	      self => $d3renderer,
	      target => $d3renderer,
	     },
	    );

    $gui_command2->execute();

    my $active_level = $self->{state}->{atomic_active_level};

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
	       name => $self->{context},
	       type => 'cubes',
	      };
    }
    elsif ($active_level eq 'ATOMIC')
    {
	my $contour_start_index;
	my $this_contour_index = 0;

	$result
	    = {
	       coordinates => [
			       map
			       {
				   my $index1 = $_;

				   # a em contour point

				   if ($children->[$index1]->[1] eq 'contou')
				   {
				       # define thickness, depending on start of contour

				       my $thickness
					   = (!defined $contour_start_index
					      ? 5e-6
					      : ($this_contour_index % 10
						 ? 1e-6
						 : 2e-6
						)
					     );

				       # if starting a new contour

				       if (!defined $contour_start_index)
				       {
					   # remember start index

					   $contour_start_index = $index1;
				       }

				       my $index2
					   = ($index1 + 1 <= $#$children
					      && $children->[$index1 + 1]->[1] eq 'contou')
					       ? $index1 + 1
						   : $contour_start_index;

				       $this_contour_index++;

				       (
					# thickness

					$thickness,

					# a rectangle for the point

					[
					 $children->[$index1]->[3]->{this}->{'x'} - 0.001e-6,
					 $children->[$index1]->[3]->{this}->{'y'} - 0.001e-6,
					 $children->[$index1]->[3]->{this}->{'z'},
					],

					[
					 $children->[$index1]->[3]->{this}->{'x'} + 0.001e-6,
					 $children->[$index1]->[3]->{this}->{'y'} - 0.001e-6,
					 $children->[$index1]->[3]->{this}->{'z'},
					],

					[
					 $children->[$index1]->[3]->{this}->{'x'} + 0.001e-6,
					 $children->[$index1]->[3]->{this}->{'y'} - 0.001e-6,
					 $children->[$index1]->[3]->{this}->{'z'},
					],

					[
					 $children->[$index1]->[3]->{this}->{'x'} + 0.001e-6,
					 $children->[$index1]->[3]->{this}->{'y'} + 0.001e-6,
					 $children->[$index1]->[3]->{this}->{'z'},
					],

					[
					 $children->[$index1]->[3]->{this}->{'x'} + 0.001e-6,
					 $children->[$index1]->[3]->{this}->{'y'} + 0.001e-6,
					 $children->[$index1]->[3]->{this}->{'z'},
					],

					[
					 $children->[$index1]->[3]->{this}->{'x'} - 0.001e-6,
					 $children->[$index1]->[3]->{this}->{'y'} + 0.001e-6,
					 $children->[$index1]->[3]->{this}->{'z'},
					],

					[
					 $children->[$index1]->[3]->{this}->{'x'} - 0.001e-6,
					 $children->[$index1]->[3]->{this}->{'y'} + 0.001e-6,
					 $children->[$index1]->[3]->{this}->{'z'},
					],

					[
					 $children->[$index1]->[3]->{this}->{'x'} - 0.001e-6,
					 $children->[$index1]->[3]->{this}->{'y'} - 0.001e-6,
					 $children->[$index1]->[3]->{this}->{'z'},
					],

					# connect with next coordinate

					[
					 $children->[$index1]->[3]->{this}->{'x'},
					 $children->[$index1]->[3]->{this}->{'y'},
					 $children->[$index1]->[3]->{this}->{'z'},
					],

					[
					 $children->[$index2]->[3]->{this}->{'x'},
					 $children->[$index2]->[3]->{this}->{'y'},
					 $children->[$index2]->[3]->{this}->{'z'},
					],
				       );
				   }
				   else
				   {
				       undef $contour_start_index;

				       $this_contour_index = 0;

				       (
					# no coordinates indicator

					undef,
				       );
				   }
			       }
			       0 .. $#$children,
			      ],
	       color => [ 1, 1, 1, ],
 	       light => 0,
	       name => $self->{context},
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
	       name => $self->{context},
	       type => 'cubes',
	      };
    }

#     use Data::Dumper;

#     my $coordinates = $result->{coordinates};

#     print Dumper((@$coordinates)[0 .. 10]);

    return $result;
}


sub get_buttons
{
    my $self = shift;

    my $window = $self->{gui}->{window};

    my $active_level = $self->{state}->{atomic_active_level};

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

					my $d3renderer = $Neurospaces::Studio::d3renderer;

					if (!$d3renderer)
					{
					    print STDERR "d3renderer is not initialized (value is $d3renderer)\n";
					}
					else
					{
					    $d3renderer->symbols_clear();

					    $d3renderer->symbol_add($self);

 					    $d3renderer->start();
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

					$self->{state}->{atomic_active_level} = $active_level;
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
	= [
	   'THICKNESS',
	  ];

    my $result = $self->parameters_2_array_ref($current, $specific_parameters);

    return $result;
}


sub get_visible_coordinates
{
    my $self = shift;

    my $options = shift;

    my $active_level = $self->{state}->{atomic_active_level};

    my $serial = $self->{this};

    my $level = $options->{biolevel} || $Neurospaces::Biolevels::biolevel2internal->{$active_level};

    return SwiggableNeurospaces::swig_get_visible_coordinates($serial, $level, $SwiggableNeurospaces::SELECTOR_BIOLEVEL_INCLUSIVE);
}


sub initialize_state
{
    my $self = shift;

    $self->SUPER::initialize_state(@_);

    $self->{state}->{atomic_active_level} = 'ATOMIC';
}


1;


