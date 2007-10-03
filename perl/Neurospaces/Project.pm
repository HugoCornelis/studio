#!/usr/bin/perl -w

##
## Neurospaces: a library which implements a global typed symbol table to
## be used in neurobiological model maintenance and simulation.
##
## $Id: GUI.pm 1.27 Sat, 21 Apr 2007 21:21:25 -0500 hugo $
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


package Neurospaces::Project;


use strict;


sub load
{
    my $package = shift;

    my $options = shift;

    if (!defined $options->{name})
    {
	die "$0: need a project name";
    }

    use YAML 'LoadFile';

    my $neurospaces_config = LoadFile('/etc/neurospaces/project_browser/project_browser.yml');

    my $project_config = LoadFile("$neurospaces_config->{project_browser}->{root_directory}/$options->{name}/configuration.yml");

    my $result
	= Neurospaces::Project->new
	    (
	     {
	      config => $project_config,
	      name => $options->{name},
	      root => "$neurospaces_config->{project_browser}->{root_directory}",
	     },
	    );
}


sub new
{
    my $package = shift;

    my $options = shift || {};

    my $self
	= {
	   %$options,
	  };

    bless $self, $package;

    return $self;
}


1;


