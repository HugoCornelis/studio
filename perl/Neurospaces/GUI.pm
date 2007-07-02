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


package Neurospaces::GUI;


use strict;


use Glib qw/TRUE FALSE/;

use Gtk2 '-init';
use Gtk2::Helper;

use Neurospaces::Biolevels;
use Neurospaces::GUI::Command;
use Neurospaces::GUI::Components::Cell;
use Neurospaces::GUI::Components::Link;
use Neurospaces::GUI::Components::Network;
use Neurospaces::GUI::Components::Node;
use Neurospaces::GUI::Algorithms;
use Neurospaces::GUI::Files;
use Neurospaces::GUI::Extractor;
use Neurospaces::GUI::Matrix;
use Neurospaces::GUI::Namespaces;
use Neurospaces::GUI::Workload;
use Neurospaces::Studio;


our $option_verbose = '';

our $tooltips = Gtk2::Tooltips->new();


sub commands_replay
{
    #t have to Sesa stuff here

    my $commands_text = `cat $ENV{HOME}/.neurospaces_commands`;

    my $commands;

    {
	my $VAR1;

	$commands = eval $commands_text;
    }

    if ($@)
    {
	print "error restoring previous commands : $@\n";

	return;
    }

    print "Playing " . (scalar @$commands) . " commands\n";

    my $serial = $commands->[0]->{self}->{symbol}->{this};

    $serial = 1;

    my $symbol = Neurospaces::GUI::Components::Node::factory( { serial => $serial, }, );

    my $renderer = $Neurospaces::Studio::renderer;

    if (!$renderer)
    {
	print "No rendering engine defined\n";
    }
    else
    {
	$renderer->symbol_add($symbol);

	$renderer->start();

	foreach my $command (@$commands)
	{
	    print "Executing command $command->{name}\n";

	    if ($command->{target} eq 'Neurospaces::GUI::Tools::Renderer')
	    {
		$command = Neurospaces::GUI::Tools::Renderer->command_preprocessor($command);

		Neurospaces::GUI::Tools::Renderer->command_processor($command);
	    }
	}

	print "Played " . (scalar @$commands) . " commands\n";
    }
}


sub create_menu
{
    my $studio = shift;

    my $serializers = shift;

    # create main window

    my $constructor
	= {
	   arguments => [ $serializers, ],
	   method => 'Neurospaces::GUI::create_menu',
	  };

    my $window = Neurospaces::GUI::window_factory('main', $constructor, );

#     my $window = Gtk2::Window->new('toplevel');

    $window->set_title("Neurospaces");

    $window->signal_connect(delete_event => sub { return 1; }, );

    my $vbox = Gtk2::VBox->new();

    $window->add($vbox);

    foreach (
	     [
	      '_Information Extractor',
	      'Extract information of this model and generate overviews and tables',
	      sub
	      {
		  my $widget = shift;

		  my $extractor = Neurospaces::GUI::Extractor->new( { context => '/', serial => 0, studio => $studio, }, );

		  if ($extractor)
		  {
		      $extractor->explore();
		  }
		  else
		  {
		      print STDERR "$0: cannot create an extractor\n";
		  }
	      },
	     ],
	     [
	      '_Explorer',
	      'Explore the current model',
	      sub
	      {
# 		  my $widget = shift;

# 		  my $symbol = Neurospaces::GUI::Components::Node::factory( { serial => 0, }, );

		  $studio->explore(0);
	      },
	     ],
	     [
	      'Connection _Matrix',
	      'Inspect & explore network connectivity',
	      sub
	      {
		  my $widget = shift;

		  my $matrix = Neurospaces::GUI::Matrix->new();

		  $matrix->explore();
	      },
	     ],
	     [
	      '_File Browser',
	      'Browse files that have been loaded',
	      sub
	      {
		  my $widget = shift;

		  my $files = Neurospaces::GUI::Files->new();

		  $files->explore();
	      },
	     ],
	     [
	      '_Namespaces',
	      'Explore namespaces and prototypes',
	      sub
	      {
		  my $widget = shift;

		  my $namespace = Neurospaces::GUI::Namespaces->new( { namespace => "::", }, );

		  $namespace->explore();
	      },
	     ],
	     [
	      '_Algorithm Report',
	      'Report on all algorithm instances',
	      sub
	      {
		  my $widget = shift;

		  my $algorithms = Neurospaces::GUI::Algorithms->new();

		  $algorithms->explore();
	      },
	     ],
	     [
	      '_Workload & Partitioning',
	      'Model Workload Information and Partitioning Configuration & Report',
	      sub
	      {
		  my $widget = shift;

		  my $workload = Neurospaces::GUI::Workload->new();

		  $workload->explore();
	      },
	     ],
	     $serializers
	     ? [
		'_Save session',
		'Save the current window session',
		sub
		{
		    my ($widget, $window) = @_;

		    print "Saving window session\n";

		    Neurospaces::GUI::window_session_archive();
		},
		$window,
	       ]
	     : (),
	     $serializers
	     ? [
		'_Save command list',
		'Save the current command list, allowing for modification and playback later on',
		sub
		{
		    my ($widget, $window) = @_;

		    print "Saving command list\n";

		    Neurospaces::GUI::Command::archive();
		},
		$window,
	       ]
	     : (),
	     [
	      '_Close',
	      'Close window',
	      sub
	      {
		  my ($widget, $window) = @_;

		  print "Closing Neurospaces GUI main window\n";

		  Neurospaces::GUI::window_close($window);
	      },
	      $window,
	     ],
	     [
	      '_Quit',
	      'Close all windows & Quit',
	      sub
	      {
		  window_close_all();
	      },
	      $window,
	     ],
	    )
    {
	my $button = Gtk2::Button->new($_->[0]);

	$tooltips->set_tip($button, $_->[1]);

	$button->signal_connect (clicked => $_->[2], $_->[3]);

	$vbox->pack_start($button, 0, 1, 0);
    }

    $tooltips->enable();

    $window->show_all();

    return $window;
}


sub factory_command
{
    my $command = shift;

    $command =~ /\s([0-9]+)/;

    my $serial;

    if (defined $1)
    {
	$serial = $1;
    }
    else
    {
	$command =~ /\s(.+)/;

	my $context = $1;

	$serial = SwiggableNeurospaces::swig_context2serial($context);
    }

    my $symbol = Neurospaces::GUI::Components::Node::factory( { serial => $serial, }, );

    $symbol->explore();
}


our $global_windows = {};

our $window_count = 0;

sub gui
{
    my $line = shift;

    my $studio = Neurospaces::Studio->new();

    #! if option_restore is a global, you used to get infinite loops,
    #! not sure how it behaves now.

    my $option_commands = '';

    my $option_restore = '';

    my $option_serializers = '';

    {
	use Getopt::Long;

	local @ARGV;

	@ARGV = split '\s+', $line;

	my $result
	    = GetOptions
		(
		 "commands!" => \$option_commands,
		 "restore!" => \$option_restore,
		 "serializers!" => \$option_serializers,
		 "verbose+"  => \$option_verbose,
		);
    }

    # if restoring a previous session

    if ($option_restore)
    {
	# restore the previous session

	window_session_restore($studio);

	# perhaps need to replay commands

	if ($option_commands)
	{
	    commands_replay($studio);
	}
    }

    # else creating a new session

    else
    {
	# create the menu window

	my $window = create_menu($studio, $option_serializers, );
    }

    # start main loop

    window_main($studio);
}


sub window_close
{
    my $window = shift;

    $window_count--;

    delete $global_windows->{$window};

    if ($window_count == 0)
    {
	Gtk2->main_quit();
    }

    $window->destroy();
}


sub window_close_all
{
    foreach my $window (values %$global_windows)
    {
	window_close($window->{window});
    }
}


sub window_factory
{
    my $type_name = shift;

    my $constructor = shift;

    my $command
	= Neurospaces::GUI::Command->new
	    (
	     {
	      archive => {
			  type_name => $type_name,
			  constructor => $constructor,
			 },
	      name => $type_name . $window_count,
	      processor => 'window_command_executor',
	      target => 'Neurospaces::GUI',
	     },
	    );

    my $window = $command->execute();

    $global_windows->{$window}
	= {
	   constructor => $constructor,
	   type_name => $type_name,
	   window => $window,
	  };

    $window_count++;

    return $window;
}


sub window_command_executor
{
    my $self = shift;

    my $command = shift;

    my $window = Gtk2::Window->new('toplevel');

    return $window;
}


sub window_main
{
    print "Calling event handler\n";

    Gtk2->main();
}


sub window_open
{
    my $window_specification = shift;

    my $window;

    # instantiate the window

    my $type_name = $window_specification->{type_name};

    my $constructor = $window_specification->{constructor};

    my $constructor_arguments = $constructor->{arguments};

    my $constructor_data = $constructor->{data};

    my $constructor_method = $constructor->{method};

    print "restoring $type_name\n";

    if ($constructor_data)
    {
	# virtual method call

	$window = $constructor_data->$constructor_method($constructor_arguments);
    }
    else
    {
	# class call

# 	#! no better way to resolve dynamic class calls ?

# 	my ($package, $method) = ($constructor_method =~ /(.+::)(.+)/);

	#! see Exporter

	if ($constructor_method)
	{
	    #! hack : get this to work with the renderer

	    if ($constructor_method =~ /::Renderer$/)
	    {
		my $symbol = 1;

		my $renderer = $Neurospaces::Studio::renderer;

		$renderer->init();
	    }
	    else
	    {
		my $code = \&{"$constructor_method"};

		$window = &$code($constructor_arguments);
	    }
	}
    }

    return $window;
}


sub window_session_archive
{
    use Data::Dumper;

    use IO::File;

    my $session_file = IO::File->new("> $ENV{HOME}/.neurospaces_session");

    my $session
	= {
	   windows => $global_windows,
	  };

    print $session_file Dumper($session);

    $session_file->close();
}


sub window_session_restore
{
    #t have to Sesa stuff here

    my $session_text = `cat $ENV{HOME}/.neurospaces_session`;

    my $session;

    {
	no strict;

	$session = eval $session_text;
    }

    if ($@)
    {
	print "error restoring previous session : $@\n";

	return;
    }

    my $windows = $session->{windows};

    print "restoring previous session\n";

#     print Dumper($windows);

    # tell the loop how many windows we are going to open

    my $main_count = -(scalar keys %$windows) - 1;

    print "restoring " . ( - $main_count - 1) . " window(s)\n";

    # post processing : loop over all windows in the session

    foreach my $window (values %$windows)
    {
	# restore window

	window_open($window);
    }
}


1;


