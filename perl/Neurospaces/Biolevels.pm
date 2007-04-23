#!/usr/bin/perl -w

##
## Neurospaces: a library which implements a global typed symbol table to
## be used in neurobiological model maintenance and simulation.
##
## $Id: Biolevels.pm 1.7 Sat, 21 Apr 2007 21:21:25 -0500 hugo $
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


package Neurospaces::Biolevels;


use strict;

use Neurospaces_embed;


our $biogroup2internal = {};

our $biolevel2internal = {};

our $biolevel_internal2biogroup_internal = {};

our $internal2biogroup = {};

our $internal2biolevel = {};

our $internal2symboltype = {};

our $symboltype2internal = {};

our $symboltype2biolevel = {};


sub define_biogroups
{
    my $c_code = shift;

    # first find all biolevel definitions

    my $biogroup_lines = [ grep { /^#define BIOLEVELGROUP_/ } split '\n', $c_code, ];

    # make them available at perl level

    map
    {
	/BIOLEVELGROUP_(\S*)\s+(\S*)/;

	$biogroup2internal->{$1} = $2;
    }
	@$biogroup_lines;

    # define the inverse relation

    $internal2biogroup
	= {
	   reverse %$biogroup2internal,
	  };
}


sub define_biolevels
{
    my $c_code = shift;

    # first find all biolevel definitions

    my $biolevel_lines = [ grep { /^#define BIOLEVEL_/ && $_ !~ /^#define BIOLEVEL_H$/ } split '\n', $c_code, ];

    # make them available at perl level

    map
    {
	/BIOLEVEL_(\S*)\s+(\S*)/;

	$biolevel2internal->{$1} = $2;
    }
	@$biolevel_lines;

    # define the inverse relation

    $internal2biolevel
	= {
	   reverse %$biolevel2internal,
	  };
}


sub define_symboltypes
{
    my $c_code = shift;

    # first find all symboltype definitions

    my $symboltype_lines = [ grep { /^#define TYPE_HSLE_/ } split '\n', $c_code, ];

    # make them available at perl level

    map
    {
	/(TYPE_HSLE_\S*)\s+(\S*)/;

	$symboltype2internal->{$1} = $2;

	$symboltype2biolevel->{$1} = Neurospaces::symboltype2biolevel($2);
    }
	@$symboltype_lines;

    # define the inverse relation

    $internal2symboltype
	= {
	   reverse %$symboltype2internal,
	  };
}


sub define_transitions
{
    $biolevel_internal2biogroup_internal
	= {
	   map
	   {
	       my $group = Neurospaces::biolevel2biogroup($_);

	       $_ => $group;
	   }
	   values %$biolevel2internal,
	  };
}


sub main
{
    use Data::Dumper;

    # read biolevel definitions in the Neurospaces core

    my $biolevel_code = `cat $Neurospaces::neurospaces_core_directory/neurospaces/biolevel.h`;

#     print Dumper($biolevel_code);

    # define biogroups

    define_biogroups($biolevel_code);

    # define biolevels

    define_biolevels($biolevel_code);

    # read symboltype definitions in the Neurospaces core

    my $symboltype_code = `cat $Neurospaces::neurospaces_core_directory/neurospaces/symboltable.h`;

#     print Dumper($symboltype_code);

    # define symbol types, associate with biolevels

    define_symboltypes($symboltype_code);

    define_transitions();

#     print Dumper($biogroup2internal, $biolevel2internal);

    # return success

    return 1;
}


main();


