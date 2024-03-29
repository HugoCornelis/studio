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
##' Copyright (C) 1999-2008 Hugo Cornelis
##'
##' functional ideas ..	Hugo Cornelis, hugo.cornelis@gmail.com
##'
##' coding ............	Hugo Cornelis, hugo.cornelis@gmail.com
##'
##############################################################################


package Neurospaces::Studio;


use strict;


use Glib qw/TRUE FALSE/;

# use Gtk2 '-init';
# use Gtk2::Helper;


push @INC, './perl';

my $loaded_neurospaces_gui_tools_d3renderer = eval "require Neurospaces::GUI::Tools::Renderer;";

if ($@)
{
    no strict "refs";

    if (exists ${"::"}{verbose} && $::option_verbose)
    {
	print STDERR "$0: cannot load rendering module because of: $@\n";
	print STDERR "$0: continuing.\n";
    }
}

our $d3renderer
    = ($loaded_neurospaces_gui_tools_d3renderer
       ? (print STDERR "$0: initialized rendering engine\n" || 1) && Neurospaces::GUI::Tools::Renderer->new()
       : (print STDERR "$0: could not initialize rendering engine\n" || 1) && 0);


my $loaded_geometry = eval "require Geometry;";

if ($@)
{
    no strict "refs";

    if (exists ${"::"}{verbose} && $::option_verbose)
    {
	print STDERR "$0: cannot load the geometry module because of: $@\n";
	print STDERR "$0: continuing.\n";
    }
}

our $geometry
    = ($loaded_geometry
       ? (print STDERR "$0: initialized geometry module\n" || 1)
       : (print STDERR "$0: could not initialize geometry module\n" || 1) && 0);


sub explore
{
    my $self = shift;

    my $serial = shift;

    # \todo because of the dependency on serials, it is impossible to
    # explore models in a namespace, should be solved.

    my $symbol = Neurospaces::GUI::Components::Node::factory( { serial => $serial, studio => $self, }, );

#     use Data::Dumper;

#     print Dumper($symbol);

    $symbol->explore();
}


sub initialize
{
#
# flags are :
#

# * 'in' / 'G_IO_IN'
# * 'out' / 'G_IO_OUT'
# * 'pri' / 'G_IO_PRI'
# * 'err' / 'G_IO_ERR'
# * 'hup' / 'G_IO_HUP'
# * 'nval' / 'G_IO_NVAL'

#     Glib::IO->add_watch
# 	    (
# 	     $fd,
# 	     [ 'in', 'hup', 'out' ],
# 	     sub
# 	     {
# 		 my ($fd, $condition) = @_;

# 		 handle_input();
# 	     },
# 	    );

#     Glib::IO->add_watch
# 	    (
# 	     1,
# 	     [ 'in', 'hup', 'out' ],
# 	     sub
# 	     {
# 		 my ($fd, $condition) = @_;

# 		 handle_input();
# 	     },
# 	    );

#     Glib::IO->add_watch
# 	    (
# 	     2,
# 	     [ 'in', 'hup', 'out' ],
# 	     sub
# 	     {
# 		 my ($fd, $condition) = @_;

# 		 handle_input();
# 	     },
# 	    );

#     Gtk2::Helper->add_watch
# 	    (
# 	     $fd,
# 	     'in',
# 	     sub
# 	     {
# 		 my ($fd, $condition) = @_;

# 		 handle_input();

# 		 1;
# 	     },
# 	    );

#     Gtk2::Helper->add_watch
# 	    (
# 	     1,
# 	     'out',
# 	     sub
# 	     {
# 		 my ($fd, $condition) = @_;

# 		 handle_input();

# 		 1;
# 	     },
# 	    );

#     Gtk2::Helper->add_watch
# 	    (
# 	     2,
# 	     'out',
# 	     sub
# 	     {
# 		 my ($fd, $condition) = @_;

# 		 handle_input();

# 		 1;
# 	     },
# 	    );

    my $timed_code;

    my $install_timer
	= sub
	  {
	      # reinstall a new timer, based on the frame rate

	      my $delay = $d3renderer->frame_preferred_delay();

	      my $timer = Glib::Timeout->add($delay, $timed_code, "got it\n", );
	  };

    $timed_code
	= sub
	  {
	      if ($d3renderer)
	      {
		  $d3renderer->main_loop();

		  &$install_timer();

		  # return false to and remove this timer

		  return 0;
	      }
	  };

    my $timer = Glib::Timeout->add(110, $timed_code, "got it\n", );

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

    $self->initialize();

    return $self;
}


sub objectify
{
    my $self = shift;

    my $serial = shift;

    return SwiggableNeurospaces::objectify_serial($serial);
}


1;


