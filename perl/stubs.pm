#!/usr/bin/perl -w

##
## Neurospaces: a library which implements a global typed symbol table to
## be used in neurobiological model maintenance and simulation.
##
## $Id: stubs.pm 1.4 Sun, 18 Feb 2007 15:53:33 -0600 hugo $
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


package Neurospaces;


use strict;


sub symboltype2biolevel
{
    return 10;
}


sub biolevel2biogroup
{
    return 20;
}


sub get_algorithms
{
    return
	[
	 {
	  "Class name" => "spines",
	  "Instance name" => "spines instance",
	 },
	];
}


sub get_children
{
    return
	[
	 [
	  "Granules",
	  "POPU",
	  {
	   'x' => 0.0000001,
	   'y' => 0.00000001,
	   'z' => 0.00000005,
	  },
	  {
	   'x' => 0.0000001,
	   'y' => 0.00000001,
	   'z' => 0.00000005,
	  },
	  1,
	 ],
	 [
	  "Golgis",
	  "POPU",
	  {
	   'x' => 0.0000002,
	   'y' => 0.00000002,
	   'z' => 0.000000025,
	  },
	  {
	   'x' => 0.0000002,
	   'y' => 0.00000002,
	   'z' => 0.000000025,
	  },
	  2,
	 ],
	];

#     av_push(pavChild, psvName);
#     av_push(pavChild, psvType);
#     av_push(pavChild, psvCoordLocal);
#     av_push(pavChild, psvCoordAbsolute);
#     av_push(pavChild, psvSerial);

}


sub get_files
{
# /local_home/local_home/hugo/neurospaces_project/neurospaces/source/c/snapshots/0/perl
    return
	[
	 "/local_home/local_home/hugo/neurospaces_project/neurospaces/source/c/snapshots/0/perl/stubs.pm",
	];
}


sub get_namespaces
{
    return
	[
	 {
	  filename => "/local_home/local_home/hugo/neurospaces_project/neurospaces/source/c/snapshots/0/perl/stubs.pm",
	  namespace => "::",
	 },
	];
}


sub get_workload
{
    return
	[
	 {
	  "Total workload" => 1000,
	  "Number of partitions" => 10,
	  "Partial workload" => 100,
	 },
	 [
	  {
	   "Serial Range" => "0 -- 100",
	   "Context" => '/',
	   "Workload" => "101",
	  },
	  {
	   "Serial Range" => "101 -- 1000",
	   "Context" => '/100',
	   "Workload" => "101",
	  },
	 ],
	];
}


sub objectify
{
    my $serial = shift;

    if ($serial eq 0)
    {
	return
	{
	 context => '/',
	 parent => '/',
	 this => $serial,
	 type => 'TYPE_HSLE_ROOT',
	};
    }

    elsif ($serial eq 1)
    {
	return
	{
	 context => '/',
	 parent => '/',
	 this => $serial,
	 type => 'TYPE_HSLE_NETWORK',
	};
    }

    else
    {
	return
	{
	 context => '/',
	 parent => '/',
	 this => $serial,
	 type => 'TYPE_HSLE_CELL',
	};
    }
}


sub pq_get
{
    return
    {
     cache => {},
     projections => [
		     {
		      context => "/CerebellarCortex/ForwardProjection",
		      serial => 10,
		      source => 1,
		      target => 2,
		     },
		     {
		      context => "/CerebellarCortex/BackwardProjection",
		      serial => 10,
		      source => 2,
		      target => 1,
		     },
		    ],
    };
}


1;


