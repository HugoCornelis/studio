#!/usr/bin/perl -w

##
## Neurospaces: a library which implements a global typed symbol table to
## be used in neurobiological model maintenance and simulation.
##
## $Id: Mechanism.pm 1.23 Thu, 10 May 2007 20:53:37 -0500 hugo $
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


package Neurospaces::GUI::Components::Mechanism;


use strict;


use base qw(Neurospaces::GUI::Components::Node);

use Glib qw/TRUE FALSE/;

use Neurospaces::GUI;
use Neurospaces::Biolevels;


my $tabulator_formats
    = {
       'alpha-beta' => 0,
       'steadystate-tau' => 0,
       'A-B' => 0,
#        'internal*dt' => 0,
       'internal' => 1,
      };

sub get_buttons
{
    my $self = shift;

    my $window = $self->{gui}->{window};

    my $active_level = $self->{state}->{tabulator_active_level};

    my $result
	= [
	  ];

    my $has_tables = 0;

    if ($has_tables)
    {
	$result
	    = [
	       {
		name => '_Render',
		signals => {
			    clicked => {
					handler =>
					sub
					{
					    my $widget = shift;

					    my $loaded_heccer_tabulator = eval "require Heccer";

					    if ($loaded_heccer_tabulator)
					    {
						my $tabulator
						    = Heccer::Tabulator->construct
							(
							 {
							  model_source => {
									   service_name => 'neurospaces',
# 									   service_backend => $service_backend,
									   modelname => $self->{context},
									  },
							 },
							);

						if (!$tabulator)
						{
						    print STDERR "cannot construct a tabulator\n";
						}
						else
						{
						    $tabulator->start();
						}
					    }
					    else
					    {
						print STDERR "cannot load the Heccer tabulator\n";
					    }
					},
					arguments => [],
				       },
			   },
		tip => 'Render channel kinetics',
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
				  sort keys %$tabulator_formats,
				 ),

				 # select active level

				 {
				  set_active => [
						 grep
						 {
						     (sort keys %$tabulator_formats)[$_] =~ /$active_level/
						 }
						 0 .. (scalar keys %$tabulator_formats) - 1,
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

					    my $active_level = (sort keys %$tabulator_formats)[$active_index];

					    $self->{state}->{tabulator_active_level} = $active_level;
					},
				       },
			   },
		tip => 'Set the format of rendered table kinetics',
		type => 'Gtk2::ComboBox',
	       },
	      ];
    }

    $result = [ @$result, @{ $self->SUPER::get_buttons(@_), }, ];

    return $result;
}


sub get_specific_parameters
{
    my $self = shift;

    my $current = shift;

    my $specific_parameters
	= [
	   'LENGTH',
	   'DIA',
	  ];

    my $result = $self->parameters_2_array_ref($current, $specific_parameters);

    return $result;
}


sub initialize_state
{
    my $self = shift;

    $self->SUPER::initialize_state(@_);

    $self->{state}->{tabulator_active_level} = 'alpha-beta';
}


1;


