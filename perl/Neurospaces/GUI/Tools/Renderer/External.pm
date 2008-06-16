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


package Neurospaces::GUI::Tools::Renderer::External::Mat;


our @ISA = qw(Neurospaces::GUI::Tools::Renderer::External);


package Neurospaces::GUI::Tools::Renderer::External::NDF;


our @ISA = qw(Neurospaces::GUI::Tools::Renderer::External);


package Neurospaces::GUI::Tools::Renderer::External;


use strict;


use Neurospaces::GUI::Tools::Renderer;

use YAML 'LoadFile';


sub load
{
    my $filename = shift;

    my $d3renderer = $Neurospaces::Studio::d3renderer;

    if (!$d3renderer)
    {
	print STDERR "d3renderer is not initialized (value is $d3renderer)\n";

	return undef;
    }

    my $self;

    # determine file type based on extension

    if ($filename =~ /\.mat$/i)
    {
	# load mat

	my $mat = LoadFile($filename);

	# add to external data for rendering

	$self = bless { data => $mat, identifier => $filename, type => 'mat', }, 'Neurospaces::GUI::Tools::Renderer::External::Mat';
    }

    elsif ($filename =~ /\.ndf$/i)
    {
	#t not sure here, seems a bit out of scope to read it in in neurospaces
    }

    if (defined $self)
    {
	$d3renderer->external_add($self);
    }
    else
    {
	print "$0: *** Error: Unable to determine type of $filename as an external component for the rendering engine\n";
    }
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


