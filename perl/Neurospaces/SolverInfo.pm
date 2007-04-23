##
## Neurospaces: a library which implements a global typed symbol table to
## be used in neurobiological model maintenance and simulation.
##
## $Id: SolverInfo.pm 1.3 Sun, 18 Feb 2007 15:53:33 -0600 hugo $
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


package Neurospaces::SolverInfo;


use strict;


print "In package Neurospaces::SolverInfo\n";


sub registrations
{
    my $arg = shift;

    print "In sub Neurospaces::SolverInfo::registrations\n";

    print "Argument : ", $arg, "\n";
}


1;


