#!/usr/bin/perl -w

##
## Neurospaces: a library which implements a global typed symbol table to
## be used in neurobiological model maintenance and simulation.
##
## $Id: Node.pm 1.27 Sat, 21 Apr 2007 21:21:25 -0500 hugo $
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


package Neurospaces::Studio;


use strict;


sub explore
{
    my $self = shift;

    my $serial = shift;

    my $symbol = Neurospaces::GUI::Components::Node::factory( { serial => $serial, studio => $self, }, );

    $symbol->explore();
}


sub new
{
    my $package = shift;

    my $options = shift || {};

    my $self
	= {
	   %$options,
	  };

    my $root_context = SwiggableNeurospaces::PidinStackParse("/");

    my $root_symbol = $root_context->PidinStackLookupTopSymbol();

    if (!$root_symbol)
    {
	return "Cannot get a root context (has a model been loaded ?)";
    }

    $self->{root_context} = $root_context;

    $self->{root_symbol} = $root_symbol;

    bless $self, $package;

    return $self;
}


sub objectify
{
    my $self = shift;

    my $serial = shift;

    return SwiggableNeurospaces::objectify_serial($serial);
}


1;


