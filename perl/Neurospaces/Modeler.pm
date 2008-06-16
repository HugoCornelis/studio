#!/usr/bin/perl -w

##
## Neurospaces: a library which implements a global typed symbol table to
## be used in neurobiological model maintenance and simulation.
##
## $Id: Modeler.pm 1.6 Sat, 21 Apr 2007 21:21:25 -0500 hugo $
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


package Neurospaces::Modeler;


use strict;


# sub consider
# {
#     my $self = shift;

#     #! 'cell', 'population', 'projection'

#     my $type = shift;

#     my $symbol = shift;

#     my $registration_name = shift;

#     # get solver type

#     my $solver_type = $self->{solver_instantiation}->{$type};

#     if (!defined $solver_type)
#     {
# 	return "no solver type found for this model type $type";
#     }

#     # lookup the solver type in the loaded solver classes

#     my $solver_classes = $self->{solver_classes};

#     if (!exists $solver_classes->{$solver_type})
#     {
# 	return "the solver_type $type is not available in the solver_classes (yet).";
#     }

#     # lookup the symbol

#     my $serial = SwiggableNeurospaces::swig_context2serial($symbol);

#     # create a record for the scheduler

#     my $schedulee_constructor = $self->{scheduler} . '::' . 'Schedulee';

#     my $schedulee
# 	= $schedulee_constructor->new
# 	    (
# 	     {
# 	      '2_name' => $registration_name,
# 	      '2_serial' => $serial,
# 	      'instance' => undef,
# 	     },
# 	    );

#     # map the solver registration name to its serial

#     #! so the tree below $serial is implicitly mapped.

#     $self->{solver_registration}->{'2_serial'}->{$registration_name} = $serial;

#     $self->{solver_registration}->{'2_name'}->{$serial} = $registration_name;

#     # return the scheduler record

#     return $schedulee;
# }


# sub new
# {
#     my $class = shift;

#     my $options = shift;

#     my $self = {};

#     bless $self, $class;

#     # set environment if needed

#     if (exists $self->{library})
#     {
# 	$ENV{NEUROSPACES_NMC_MODELS} = $self->{library};
#     }

#     # create the low level object

#     Neurospaces::ns_new();

#     #t so solvermapper specific stuff if needed

#     # construct neurospaces from model spec if needed

#     if (exists $self->{model})
#     {
# 	my $model = $self->{model};

# 	$self->read(@$model);
#     }

#     # return neurospaces object

#     return $self;
# }


# sub read
# {
#     my $self = shift;

#     my $model = [ $@, ];

#     # forward the call to the inline code

#     Neurospaces::ns_read($self, @$model);

#     # return failure

#     return 0;
# }


1;


