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


package Neurospaces::GUI::Tools::Renderer::External;


use strict;


use Neurospaces::GUI::Tools::Renderer;

use YAML 'LoadFile';


sub load
{
    my $filename = shift;

    my $renderer = $Neurospaces::Studio::renderer;

    if (!$renderer)
    {
	print "renderer is not initialized (value is $renderer)\n";
    }

    # load mat

    my $mat = LoadFile($filename);

    # add to external data for rendering

    my $self = bless { data => $mat, identifier => $filename, type => 'mat', }, 'Neurospaces::GUI::Tools::Renderer::External';

    $renderer->external_add($self);
}


sub draw
{
    my $self = shift;

    my $result = {};

    my $type = $self->{type};

    my $mat = $self->{data};

    my $mat_points = $mat->{mat};

    $result
	= {
	   coordinates => [
			   map
			   {
			       my $index1 = $_ - 1;

			       my $index2 = $_;

			       (
				# thickness

				2e-6,

				# a rectangle for the point

				[
				 1e-7 * $mat_points->[$index1]->[0] - 0.0015e-6,
				 1e-7 * $mat_points->[$index1]->[1] - 0.0015e-6,
				 1e-7 * $mat_points->[$index1]->[2],
				],

				[
				 1e-7 * $mat_points->[$index1]->[0] + 0.0015e-6,
				 1e-7 * $mat_points->[$index1]->[1] - 0.0015e-6,
				 1e-7 * $mat_points->[$index1]->[2],
				],

				[
				 1e-7 * $mat_points->[$index1]->[0] + 0.0015e-6,
				 1e-7 * $mat_points->[$index1]->[1] - 0.0015e-6,
				 1e-7 * $mat_points->[$index1]->[2],
				],

				[
				 1e-7 * $mat_points->[$index1]->[0] + 0.0015e-6,
				 1e-7 * $mat_points->[$index1]->[1] + 0.0015e-6,
				 1e-7 * $mat_points->[$index1]->[2],
				],

				[
				 1e-7 * $mat_points->[$index1]->[0] + 0.0015e-6,
				 1e-7 * $mat_points->[$index1]->[1] + 0.0015e-6,
				 1e-7 * $mat_points->[$index1]->[2],
				],

				[
				 1e-7 * $mat_points->[$index1]->[0] - 0.0015e-6,
				 1e-7 * $mat_points->[$index1]->[1] + 0.0015e-6,
				 1e-7 * $mat_points->[$index1]->[2],
				],

				[
				 1e-7 * $mat_points->[$index1]->[0] - 0.0015e-6,
				 1e-7 * $mat_points->[$index1]->[1] + 0.0015e-6,
				 1e-7 * $mat_points->[$index1]->[2],
				],

				[
				 1e-7 * $mat_points->[$index1]->[0] - 0.0015e-6,
				 1e-7 * $mat_points->[$index1]->[1] - 0.0015e-6,
				 1e-7 * $mat_points->[$index1]->[2],
				],

				# connect with next coordinate

				[
				 1e-7 * $mat_points->[$index1]->[0],
				 1e-7 * $mat_points->[$index1]->[1],
				 1e-7 * $mat_points->[$index1]->[2],
				],

				[
				 1e-7 * $mat_points->[$index2]->[0],
				 1e-7 * $mat_points->[$index2]->[1],
				 1e-7 * $mat_points->[$index2]->[2],
				],
			       );
			   }
			   1 .. $#$mat_points,
			  ],
	   color => [ 1, 1, 1, ],
	   light => 0,
	   name => 'contours',
	   type => 'GL_LINES',
	  };

#     use Data::Dumper;

#     print "For Neurospaces::GUI::Tools::Renderer::External:\n" . Dumper($result);

    return $result;
}


1;


