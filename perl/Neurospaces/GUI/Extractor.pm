#!/usr/bin/perl -w

##
## Neurospaces: a library which implements a global typed symbol table to
## be used in neurobiological model maintenance and simulation.
##
## $Id: Extractor.pm 1.16 Mon, 23 Apr 2007 11:23:34 -0500 hugo $
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


package Neurospaces::GUI::Extractor::Overview;


my $loaded_graphviz = eval "require GraphViz";


if ($@)
{
    print STDERR "$0: cannot load graphviz module because of: $@\n";
    print STDERR "$0: continuing.\n";
}


sub conclude
{
    my $self = shift;

    my ($graph, $shapes) = @$self{qw(graph shapes)};

    # visualize the graph

    my $ps = $graph->as_ps();

    use File::Temp;

    my $tmpfile = File::Temp->new();

    $tmpfile->unlink_on_destroy(0);

    my $tmpfilename = $tmpfile->filename();

    print "Sending output to $tmpfilename\n";

    print $tmpfile $ps;

    $tmpfile->close();

    system "gv $tmpfilename &";
}


sub extract
{
    my $self = shift;

    my $symbol = shift;

    my ($graph, $shapes) = @$self{qw(graph shapes)};

    my $parent = Neurospaces::GUI::Components::Node::factory( { serial => $symbol->{parent}, studio => $symbol->{studio}, }, );

    # get unqualified symbol name

    my $symbol_name = $symbol->get_long_label();

    my $symbol_type = $symbol->{type};

    $symbol_type =~ s/^T_sym_//;

    $symbol_type = "HIERARCHY_TYPE_$symbol_type";

    $graph->add_node
	(
	 $symbol->{this},
	 label => $symbol_name,
	 shape => $shapes->{$symbol_type} || $shapes->{default},
	);

    # get unqualified symbol name for parent

    my $parent_name = $parent->get_long_label();

    my $parent_type = $parent->{type};

    $parent_type =~ s/^T_sym_//;

    $parent_type = "HIERARCHY_TYPE_$parent_type";

    $graph->add_node
	(
	 $parent->{this},
	 label => $parent_name,
	 shape => $shapes->{$parent_type} || $shapes->{default},
	);

    $graph->add_edge( $parent->{this} => $symbol->{this}, );
}


sub new
{
    if (!$loaded_graphviz)
    {
	return "GraphViz is not loaded\n";
    }

    my $class = shift;

    my $options = shift;

    #! philosophy :
    #!
    #! real biological components : with corners
    #! attachment points related : with curves

    my $shapes
	= {
	   default => 'egg',
	   HIERARCHY_TYPE_network => 'octagon',
	   HIERARCHY_TYPE_projection => 'ellipse',
	   HIERARCHY_TYPE_population => 'hexagon',
	   HIERARCHY_TYPE_cell => 'house',
	   HIERARCHY_TYPE_segment => 'box',
	   HIERARCHY_TYPE_channel => 'triangle',
	   HIERARCHY_TYPE_pool => 'triangle',
	  };

    my $graph = GraphViz->new();

    my $self
	= {
	   graph => $graph,
	   shapes => $shapes,
	  };

    bless $self, $class;

    return $self;
}


package Neurospaces::GUI::Extractor::ChannelTable;


sub conclude
{
    my $self = shift;

    use Data::Dumper;

    print Dumper($self);

    #t convert to ps

#     use PostScript::Simple;
#     use PostScript::Simple::Table;

}


sub extract
{
    my $self = shift;

    my $symbol = shift;

    if ($symbol->{type} eq 'HIERARCHY_TYPE_channel')
    {
	my $name = $symbol->{context};

	$name =~ s/.*\///;

	my $parameters = [ SwiggableNeurospaces::swig_get_parameters($symbol->{this}), ];

	my $reversal = [ grep { $_->{Name} eq 'Erev' } @$parameters, ];

	$reversal = $reversal->[0]->{'Resolved Value'};

	my $conductance = [ grep { $_->{Name} eq 'G_MAX' } @$parameters, ];

	$conductance = $conductance->[0]->{'Resolved Value'};

	my $result = $self->{result};

	push
	    @$result,
	    {
	     name => $name,
	     reversal => $reversal,
	     conductance => $conductance,
	    };
    }
}


sub new
{
    my $class = shift;

    my $options = shift;

    my $self
	= {
	   result => [],
	  };

    bless $self, $class;

    return $self;
}


package Neurospaces::GUI::Extractor;


use strict;


use Neurospaces::GUI;


sub extractor_create_window
{
    my $self = shift;

    my $constructor
	= {
	   arguments => { serial => $self->{serial}, },
	   method => 'Neurospaces::GUI::Extractor::new_with_window',
	  };

    print Dumper($constructor);

    my $window = Neurospaces::GUI::window_factory('extractor', $constructor);

    $self->{gui}->{windows}->{extractor} = $window;

    $window->set_title("Extractor : $self->{context}");

    $window->set_default_size(100, 100);

    $window->signal_connect(delete_event => sub { Neurospaces::GUI::window_close($window); }, );

    $window->set_border_width(10);

    # everything contained in a horizontal layout

    my $hbox = Gtk2::HBox->new();

    $window->add($hbox);

    my $image_scroller = Gtk2::ScrolledWindow->new();

    $image_scroller->set_policy (qw/automatic automatic/);

    $hbox->pack_start($image_scroller, 1, 1, 0);

#        pixbuf = Gtk2::Gdk::Pixbuf->new_from_file ($filename)

    my $vbox = Gtk2::VBox->new();

    my $combobox_types = Gtk2::ComboBox->new_text();

    my $plugins
	= [
	   'Overview',
	   'ChannelTable',
	  ];

    map
    {
	$combobox_types->append_text($_);
    }
	sort @$plugins;

    $combobox_types->set_active(1);

    $vbox->pack_start($combobox_types, 1, 1, 0);

    $combobox_types->signal_connect
	(
	 changed =>
	 sub
	 {
	     my $combo = shift;

	     my $active_index = $combo->get_active();

	     my $type = (sort @$plugins)[$active_index];

	     $self->{state}->{type} = $type;
	 },
	);

    my $combobox_nodes = Gtk2::ComboBox->new_text();

    map
    {
	$combobox_nodes->append_text('Generate max. ' . $_ * 100 . ' nodes');
    }
	( 1 .. 10 );

    $combobox_nodes->set_active($self->{state}->{max_nodes} / 100 - 1);

    $vbox->pack_start($combobox_nodes, 1, 1, 0);

    $combobox_nodes->signal_connect
	(
	 changed =>
	 sub
	 {
	     my $combo = shift;

	     my $active_index = $combo->get_active();

	     $self->{state}->{max_nodes} = ($active_index + 1) * 100;
	 },
	);

    my $combobox_level = Gtk2::ComboBox->new_text();

    my $biogroup_terminators = $self->{state}->{biogroup_terminators};

    map
    {
	$combobox_level->append_text($_);
    }
	sort keys %$biogroup_terminators;

    #! presumed to be cell

    my $active_level = $self->{state}->{active_level};

    $combobox_level->set_active
	(
	 grep
	 {
	     (sort keys %$biogroup_terminators)[$_] =~ /$active_level/
	 }
	 0 .. (scalar keys %$biogroup_terminators) - 1,
	);

    $vbox->pack_start($combobox_level, 1, 1, 0);

    $combobox_level->signal_connect
	(
	 changed =>
	 sub
	 {
	     my $combo = shift;

	     my $active_index = $combo->get_active();

	     my $active_level = (sort keys %$biogroup_terminators)[$active_index];

	     $self->{state}->{active_level} = $active_level;
	 },
	);

    my $button = Gtk2::Button->new('_Render');

    $button->signal_connect( clicked => sub { $self->extract(); } );

    $vbox->pack_start($button, 1, 1, 0);

    $button = Gtk2::Button->new('_Close');

    $button->signal_connect( clicked => sub { Neurospaces::GUI::window_close($window); }, );

    $vbox->pack_start($button, 1, 1, 0);

    $hbox->pack_start($vbox, 1, 1, 0);

    # show the window

    print "creating\n";

    $window->show_all();

    return $window;
}


sub explore
{
    my $self = shift;

    $self->extractor_create_window();
}


sub initialize_state
{
    my $self = shift;

    $self->{state} = { active_level => 'NETWORK', };

    # my $biogroup_terminators
    #     = {
    #        NERVOUS_SYSTEM => 0,
    #        BRAIN_STRUCTURE => 0,
    #        NETWORK => 0,
    #        CELL => 1,
    #        SEGMENT => 1,
    #        MECHANISM => 1,
    #       };

    my $biogroup_terminators
	= {
	   BRAIN_STRUCTURE => 0,
	   CELL => 0,
	   MECHANISM => 1,
	   NERVOUS_SYSTEM => 0,
	   NETWORK => 0,
	   SEGMENT => 1,
	  };

    $self->{state}->{biogroup_terminators} = $biogroup_terminators;

    # an extraction cannot generate more than say 200 nodes

    $self->{state}->{max_nodes} = 200;

    # set default plugin to use

    $self->{state}->{type} = 'Overview';
}


sub new
{
    my $class = shift;

    my $options = shift;

    my $self = {};

    $self->{context} = $options->{context};

    $self->{serial} = $options->{serial};

    $self->{studio} = $options->{studio};

    bless $self, $class;

    $self->initialize_state();

    return $self;
}


sub new_with_window
{
    new('Neurospaces::GUI::Extractor', @_)->explore();
}


sub extract
{
    my $self = shift;

#     print Dumper($self);

    # synchronize the rendering selection levels with the current state

    $self->synchronize();

    my $root = $self->{serial};

    my $biogroup_terminators = $self->{state}->{biogroup_terminators};

    my $max_nodes = $self->{state}->{max_nodes};

    my $plugin = $self->{state}->{type};

    my $constructor = "Neurospaces::GUI::Extractor::" . $plugin . "->new()";

    my $d3renderer = eval $constructor;

    # initialize : push the serial on the queue to investigate

    my $nodes = [ $root ];

    my $seen = {};

    my $count = 0;

    # loop over all nodes

    print "Processing ";

 NODES:
    while (@$nodes)
    {
	my $node = shift @$nodes;

	print "node $node ";

	# if cycled graph

	if ($seen->{$node})
	{
	    # stop now

	    print "Recursion detected for node $node, internal error in datastructure core\n";

	    last NODES;
	}

# 	print "Seen $node\n";

	$seen->{$node}++;

	my $symbol = Neurospaces::GUI::Components::Node::factory( { serial => $node, studio => $self->{studio}, }, );

	# collect biolevel info about the symbol

	my $symbol_type = $symbol->{type};

	$symbol_type =~ s/^T_sym_//;

	$symbol_type = "HIERARCHY_TYPE_$symbol_type";

	my $symboltype = $Neurospaces::Biolevels::symboltype2internal->{$symbol_type};

	my $biolevel = $Neurospaces::Biolevels::symboltype2biolevel->{$symbol_type};

# 	print "in extract(), type is : ($symbol->{type}, $symbol_type, $symboltype)\n";

# 	print Dumper($Neurospaces::Biolevels::internal2biolevel, $Neurospaces::Biolevels::symboltype2biolevel);

	my $biolevel_name = $Neurospaces::Biolevels::internal2biolevel->{$biolevel};

	my $biogroup = defined $biolevel && $Neurospaces::Biolevels::biolevel_internal2biogroup_internal->{$biolevel};

	my $biogroup_name = defined $biogroup && $Neurospaces::Biolevels::internal2biogroup->{$biogroup};

	# if this is a low level biogroup

	if (!defined $biolevel_name)
	{
	    #! this can happen for types on an axis that is orthogonal to the application axis
	    #! includes general purpose types, e.g. HIERARCHY_TYPE_group

	    #t check if the symbol has a BIOGROUP parameter, and try that.

	    # default, biolevel is one less as the biolevel of the parent

	    if (!defined $symbol->{parent})
	    {
		print "Unable to define biolevel_name for symbol type $symbol->{type}, parent not found\n";

		next;
	    }

	    my $parent = Neurospaces::GUI::Components::Node::factory( { serial => $symbol->{parent}, studio => $symbol->{studio}, }, );

	    my $parent_type = $parent->{type};

	    $parent_type =~ s/^T_sym_//;

	    $parent_type = "HIERARCHY_TYPE_$parent_type";

	    my $biolevel = $Neurospaces::Biolevels::symboltype2biolevel->{$parent_type};

# 	    print Data::Dumper::Dumper($Neurospaces::Biolevels::symboltype2biolevel);

	    #t should be supported at C level, ie. in Neurospaces core.

	    $biolevel += 10;

	    $biolevel_name = $Neurospaces::Biolevels::internal2biolevel->{$biolevel};

	    if (!defined $biolevel_name)
	    {
		print "Unable to define biolevel_name for symbol type $symbol->{type}, parent is $parent->{type}\n";

		next;
	    }

	    #! commented out, gives quadratic performance or something

# 	    # overwrite biogroup and biogroup_name

# 	    $biogroup = defined $biolevel && $Neurospaces::Biolevels::biolevel_internal2biogroup_internal->{$biolevel};

# 	    $biogroup_name = defined $biogroup && $Neurospaces::Biolevels::internal2biogroup->{$biogroup};

	}

	if (defined $biolevel_name && !defined $biogroup_name)
	{
	    print "biolevel_name defined, biogroup_name not defined for this symbol :\n";

	    use Data::Dumper;

	    print Dumper($node, $symbol, $symboltype, $biolevel_name, $biolevel, $biogroup_name, $biogroup);

	    last NODES;
	}

	if (!defined $biogroup_terminators->{$biogroup_name})
	{
	    print "biogroup_terminators not defined for symbol $symbol->{this}\n";

# 	    use Data::Dumper;

# 	    print Dumper($node, $symbol, $symboltype, $biolevel_name, $biolevel, $biogroup_name, $biogroup);

	    #! for nodes that map between different modelling domain types.

# 	    last NODES;
	}

	# if configured to continue at this biogroup level

	if ($biogroup_terminators->{$biogroup_name})
	{
	    # for non root symbol

	    if ($symbol->{parent} ne 0)
	    {
		$count++;

		if ($count > $max_nodes)
		{
		    print "More than $max_nodes nodes in the extraction, aborting\n";

		    last NODES;
		}

		# extract info via plugin

		$d3renderer->extract($symbol);
	    }

	    # get children

	    my $children = $symbol->get_children();

	    # push children on the queue

	    my $serials
		= [
		   map
		   {
		       my $serial = $symbol->{this} + $_->[4];

# 		       print "Adding $symbol->{this} + $_->[4] = $serial\n";

		       $serial;
		   }
		   @$children, ];

	    push @$nodes, @$serials;
	}

	# else

	else
	{
	    # do not process
	}
    }

    # render extracted info

    $d3renderer->conclude();
}


sub synchronize
{
    my $self = shift;

    # get internal code for active biogroup

    my $active_level = $self->{state}->{active_level};

    my $active_biogroup = $Neurospaces::Biolevels::biogroup2internal->{$active_level};

    # loop over all terminators

    my $biogroup_terminators = $self->{state}->{biogroup_terminators};

    foreach my $biogroup_terminator (keys %$biogroup_terminators)
    {
	# get internal representation

	my $biogroup = $Neurospaces::Biolevels::biogroup2internal->{$biogroup_terminator};

	# if more detailed than the active group

	if ($biogroup > $active_biogroup)
	{
	    # disable this level

	    $biogroup_terminators->{$biogroup_terminator} = 0;
	}

	# else less detail

	else
	{
	    # enable this level

	    $biogroup_terminators->{$biogroup_terminator} = 1;
	}
    }
}


1;


