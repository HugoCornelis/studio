#!/usr/bin/perl -w

##
## Neurospaces: a library which implements a global typed symbol table to
## be used in neurobiological model maintenance and simulation.
##
## $Id: Command.pm 1.6 Sat, 21 Apr 2007 21:21:25 -0500 hugo $
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


package Neurospaces::GUI::Command;


use strict;


use Glib qw/TRUE FALSE/;


# global array for executed commands

my $global_commands = [];


sub archive
{
    use Data::Dumper;

    use IO::File;

    my $commands_file = IO::File->new("> $ENV{HOME}/.neurospaces_commands");

    my $count = scalar @$global_commands;

    print "Saving $count commands\n";

    print $commands_file Dumper($global_commands);

    $commands_file->close();
}


sub execute
{
    my $self = shift;

    # no double execution of commands

    if ($self->{executed})
    {
	print STDERR "Warning: double execution of $self->{name}\n";

	return undef;
    }

    # execute the command

    my $target = $self->{target};

    my $processor = $self->{processor};

    my $result = $target->$processor($self);

    # archive the command

    $self = { %$self, };

    my $name = $self->{name};

    $self->{executed} = "$name: ($self)->executed()";

    push @$global_commands, $self;

    # return result of execution

    return $result;
}


sub new
{
    my $class = shift;

    my $options = shift;

    my $self = { %$options, };

    bless $self, $class;

    return $self;
}


1;


