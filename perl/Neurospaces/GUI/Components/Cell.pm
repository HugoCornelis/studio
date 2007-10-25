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
		      -5,
		      20,
		      -10,
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
		   1e5,
		   1e5,
		   1e5,
		  ],
       'dv_zoom' => 0,
       'v_zoom' => 0,
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

    # obtain coordinates

    my $children = $self->get_visible_coordinates($options, );

#     use Data::Dumper;

#     print Dumper($children->[0]);

#     print Dumper($children->[$#$children]);
#     print Dumper($children->[- 1]);

#     use IO::File;

#     my $file = IO::File->new(">/tmp/coordinates");

    my $colors_filename = "/tmp/coloring.yml";

    my $colors;

    if (-e $colors_filename)
    {
	use YAML;

	$colors = YAML::LoadFile("<$colors_filename");
    }

    my $result
	= {
	   coordinates => [
			   map
			   {
			       (
				# dia

				(
# 				 (
# 				  print $file "  - $_->[0]\n"
# 				 )
				 1 && $_->[4]),

# 				{
# 				 color => [ 1 - $_->[4] * 1e5, 1 - $_->[4] * 1e5, 1 - $_->[4] * 1e5, ],
# 				},

				{
				 color => defined $colors ? $colors->{colors}->{$_->[0]} : [ 1, 1, 1, ],
				},

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
	   name => $self->{context},
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

					my $renderer = $Neurospaces::Studio::renderer;

					if (!$renderer)
					{
					    print STDERR "renderer is not initialized (value is $renderer)\n";
					}
					else
					{
					    $renderer->symbols_clear();

					    $renderer->symbol_add($self);

 					    $renderer->start();
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


sub get_specific_parameters
{
    my $self = shift;

    my $current = shift;

    my $specific_parameters
	= [
	   'SURFACE',
	   'TOTALSURFACE',
	  ];

    my $result = $self->parameters_2_array_ref($current, $specific_parameters);

    return $result;
}


sub get_visible_coordinates
{
    my $self = shift;

    my $options = shift;

    my $active_level = $self->{state}->{cell_active_level};

    my $serial = $self->{this};

    my $level = $options->{biolevel} || $Neurospaces::Biolevels::biolevel2internal->{$active_level};

#     print "Cell.pm: Drawing level is $level\n";

    return SwiggableNeurospaces::swig_get_visible_coordinates($serial, $level, $SwiggableNeurospaces::SELECTOR_BIOLEVEL_EXCLUSIVE);
}


sub initialize_state
{
    my $self = shift;

    $self->SUPER::initialize_state(@_);

    $self->{state}->{cell_active_level} = 'SEGMENT';
}


1;


