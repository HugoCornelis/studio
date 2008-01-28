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

use YAML;


my $view_angles_yaml
    = "---
e1cb4a1_CNG:
 angles:
  x: 90
  y: 140
 position:
  - -5.75
  - 8.25
  - -17.0
e1cb4a5_CNG:
 angles:
  x: 90
  y: 50
 position:
  - -3.0
  - -2.0
  - -17.0
e4cb2a2_CNG:
 angles:
  x: 90
  y: 25
 position:
  - 0.0
  - -6.0
  - -17.0
e4cb3a1_CNG:
 angles:
  x: 90
  y: -25
 position:
  - 0.0
  - -6.0
  - -27.0
fish1:
 angles:
  x: 90
  y: 0
 position:
  - 0.0
  - -20.0
  - -37.0
fish2_remesh:
 angles:
  x: 90
  y: 0
 position:
  - 0.0
  - -20.0
  - -37.0
gp_pc1:
 angles:
  x: 90
  y: -180
 position:
  - 0.0
  - 14.0
  - -37.0
gp_pc2:
 angles:
  x: 90
  y: -215
 position:
  - -1.4
  - 9.0
  - -27.0
gp_pc3:
 angles:
  x: 90
  y: -205
 position:
  - -5.0
  - 10.0
  - -27.0
p19_CNG:
 angles:
  x: 90
  y: 40
 position:
  - -5.0
  - -6.0
  - -27.0
p20_CNG:
 angles:
  x: 90
  y: 0
 position:
  - 0.0
  - -6.0
  - -27.0
Purk2M9s:
 angles:
  x: 0
  y: 0
 position:
  - 0.0
  - 27.0
  - -10.0
RatPC1_copy:
 angles:
  x: 90
  y: -165
 position:
  - -5.0
  - 8.0
  - -37.0
RatPC2_110104:
 angles:
  x: 90
  y: 0
 position:
  - 0.0
  - -6.0
  - -27.0
RatPC3_072205:
 angles:
  x: 90
  y: -110
 position:
  - 7.2
  - 3.5
  - -27.0
TurtlePC1_110504:
 angles:
  x: 90
  y: -15
 position:
  - 1.0
  - -4.0
  - -37.0
TurtlePC2_020105:
 angles:
  x: 90
  y: -180
 position:
  - 0.0
  - 14.0
  - -37.0
comps10:
 angles:
  x: 90
  y: -180
 position:
  - 0.0
  - 14.0
  - -37.0
comps40:
 angles:
  x: 90
  y: -180
 position:
  - 0.0
  - 14.0
  - -37.0
TurtlePC3_061105:
 angles:
  x: 90
  y: -25
 position:
  - 10.0
  - -12.0
  - -37.0
";


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

    # register the morphology_name

    my $morphology_name = $ARGV[0];

    $morphology_name =~ s/.*\///;

    $morphology_name =~ s/\.swc$//i;
    $morphology_name =~ s/\.p$//i;

    $morphology_name =~ s/\./_/g;

    # determine the angles from the morphology name

    {
	my $view_angles = YAML::Load($view_angles_yaml);

	if ($view_angles->{$morphology_name})
	{
	    print "$0: Using predetermined viewing angles for $morphology_name\n";

	    $molecular_view->{pilotview}->{heading}->[0] = $view_angles->{$morphology_name}->{angles}->{x};
	    $molecular_view->{pilotview}->{roll}->[0] = $view_angles->{$morphology_name}->{angles}->{y};

	    $molecular_view->{position}->[0] = $view_angles->{$morphology_name}->{position}->[0];
	    $molecular_view->{position}->[1] = $view_angles->{$morphology_name}->{position}->[1];
	    $molecular_view->{position}->[2] = $view_angles->{$morphology_name}->{position}->[2];
	}
	else
	{
	    print "$0: No predetermined viewing angles for $morphology_name\n";
	}
    }

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

    # create a colormap

    my $colormap;

    {
	my $colormap_filename = "/tmp/colormap.yml";

	if (-e $colormap_filename)
	{
	    print "$0: Using predetermined colormap $colormap_filename\n";

	    $colormap = YAML::LoadFile("<$colormap_filename");
	}
	else
	{
	    my $colormap_resolution = 24;

	    print "$0: No predetermined colormap, generating one with 4 * ($colormap_resolution + 1) entries\n";

	    $colormap
		= [
		   (
		    map
		    {
			[ 1, $_ / $colormap_resolution, 0, ];
		    }
		    0 .. $colormap_resolution,
		   ),
		   (
		    map
		    {
			[ 1 - $_ / $colormap_resolution, 1, 0, ];
		    }
		    0 .. $colormap_resolution,
		   ),
		   (
		    map
		    {
			[ 0, 1, $_ / $colormap_resolution, ];
		    }
		    0 .. $colormap_resolution,
		   ),
		   (
		    map
		    {
			[ 0, 1 - $_ / $colormap_resolution, 1, ];
		    }
		    0 .. $colormap_resolution,
		   ),
		  ];
	}
    }

    my $max = -0.0600877445620876; # -0.0600877445620876;
    my $min = -0.0700314819036194; # -0.0636427866426715;

    my $protocol = $::option_protocol || 'soma_pclamp';

    {
	my $value_ranges
	    = {
	       'stddev' => {
		            min => 0.02, # 0.0199325696618813,
		            max => 1.36395750246899e-05,
		           },
	       'average' => {
		             max => -0.0600877445620876,
		             min => -0.0760314819036194,
		            },
	       'amplitude' => {
# 			       min => -0.00114801,
# 			       max => -0.0799868,
# 			       min => -0.0745612,
# 			       max => -0.0745795,
			       min => -0.078356,
			       max => -0.0799249,
			      },
	       'ttp' => {
			 max => 1000, # 2433,
			 min => 48,
			},
	       'soma_pclamp' => {
				 max => -0.04,
				 min => -0.063474, # -0.071965,
# 				 min => -0.0462597, # -0.063474, # -0.071965,
				},
	       'dendrite_pclamp' => {
				     max => -0.08,
				     min => -0.04,
				    },
	      };

	foreach my $range_type (sort keys %$value_ranges)
	{
	    if ($protocol =~ /$range_type/)
	    {
		$max = $value_ranges->{$range_type}->{max};
		$min = $value_ranges->{$range_type}->{min};

		print "$0: selected color coding range $range_type for protocol $protocol (min:$min, max:$max)\n";

	    }
	}
    }

    my $colors;

    # if a color map can be found

    my $colors_filename = "colormaps/${morphology_name}_${protocol}.yml";

    if (-e $colors_filename)
    {
	print "$0: using color coding values from $colors_filename\n";

	$colors = YAML::LoadFile("<$colors_filename");

	# we are only interested in the colors key

	if (exists $colors->{colors})
	{
	    $colors = $colors->{colors};
	}
    }

    # else

    else
    {
	# replace the color map with a full white one

	print "$0: $colors_filename not found, replacing color map with a white scale bar\n";

	$colormap
	    = [
	       (
		map
		{
		    [ 1, 1, 1, ];
		}
		0 .. $#$colormap,
	       ),
	      ];
    }

    # convert keys to serials, convert result values to color codes

    {
	# create a mapping from component names to serials

	my $name_convertor
	    = {
	       map
	       {
		   $_->[5] => $_->[0];
	       }
	       @$children,
	      };

# 	use Data::Dumper;

# 	print Dumper($name_convertor);

	my $converted_colors;

	foreach my $component_name (
				    sort
				    {
					(
					 $a eq 'soma'
					 ? -1
					 : (
					    $b eq 'soma'
					    ? 1
					    : $a cmp $b
					   )
					)
				    }
				    keys %$colors
				   )
	{
	    # map name to serial

	    my $component_serial = $component_name;

	    if ($component_serial !~ /^[0-9]+$/)
	    {
		$component_serial =~ s/\/synchan$//;

		$component_serial =~ s/.*\///;

		$component_serial = $name_convertor->{$component_serial};

# 		delete $name_convertor->{$component_serial};
	    }

	    # get color value

	    my $value = $colors->{$component_name};

	    # convert to color code from the colormap

	    if (ref $value ne 'ARRAY')
	    {
		$value -= $min;

		#! I can get a too high value when I use scalar @$colormap,
		#! due to rounding or so, so I use $#$colormap.

		$value *= $#$colormap / ($max - $min);

		if ($value > $#$colormap)
		{
		    $value = $#$colormap;
		}
		elsif ($value < 0)
		{
		    $value = 0;
		}

		# get corresponding from the color map

		$converted_colors->{$component_serial} = $colormap->[$value];
	    }
	}

	$colors = $converted_colors;
    }

    my $coordinates = [];

    foreach my $child (@$children)
    {
	my $coordinate
	    = [
	       (
		# dia

		(
# 		 (
# 		  print $file "  - $child->[0]\n"
# 		 )
		 1 && $child->[4]),

# 		{
# 		 color => [ 1 - $child->[4] * 1e5, 1 - $child->[4] * 1e5, 1 - $child->[4] * 1e5, ],
# 		},

		{
		 color => defined $colors->{$child->[0]} ? $colors->{$child->[0]} : [ 1, 1, 1, ],
		},

		# two coordinates

		[
		 $child->[3]->{this}->{'x'},
		 $child->[3]->{this}->{'y'},
		 $child->[3]->{this}->{'z'},
		],

		[
		 $child->[3]->{parent}->{'x'},
		 $child->[3]->{parent}->{'y'},
		 $child->[3]->{parent}->{'z'},
		],
	       ),
	      ];

	push @$coordinates, @$coordinate;
    }

    my $visible_colorbar = 0;

    if ($visible_colorbar)
    {
	#! gives 100 entries of 1um, so 100um or 0.1 mm.

	my $colormap_coordinates
	    = [
	       10e-6,
	       (
		map
		{
		    (
		     {
		      color => $colormap->[$_],
		     },
		     [ -2.5e-4 + ($_ * 1e-6), -1e-5, -10e-6, ],
		     [ -2.5e-4 + (($_ + 1) * 1e-6), -1e-5, -10e-6, ],
		    );
		}
		0 .. $#$colormap,
	       ),
	      ];

	push @$coordinates, @$colormap_coordinates;
    }

    my $result
	= {
	   coordinates => $coordinates,
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


