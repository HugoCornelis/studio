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


