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


sub get_buttons
{
    my $self = shift;

    my $window = $self->{gui}->{window};

    my $result
	= [
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
	  ];

    my $result = $self->parameters_2_array_ref($current, $specific_parameters);

    return $result;
}


sub initialize_state
{
    my $self = shift;

    $self->SUPER::initialize_state(@_);
}


1;


