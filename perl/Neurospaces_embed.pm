#!/usr/bin/perl -w
#!/usr/bin/perl -d:ptkdb -w
#

##
## Neurospaces: a library which implements a global typed symbol table to
## be used in neurobiological model maintenance and simulation.
##
## $Id: Neurospaces_embed.pm 1.44 Sun, 22 Apr 2007 11:41:03 -0500 hugo $
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


my $c_code;

our $working_directory;

our $neurospaces_core_directory;

our $neurospaces_perl_modules;

my $package;


BEGIN
{
    use Cwd ();

    $working_directory = Cwd::getcwd();

    # get abs path where this module is located

    $neurospaces_perl_modules = $working_directory . '/' . $0;

    print "\$0 is $0\n";

    $package = __PACKAGE__;

    $package =~ s(::)(/)g;

    # get dir where this package was found

    #! called from Neurospaces core

    $neurospaces_perl_modules =~ s((.*)/${package}_embed\.pm$)($1);

    #! called from perl test script

    $neurospaces_perl_modules =~ s((.*)/-e$)($1);

    # add to include paths

    unshift @INC, $neurospaces_perl_modules;

    # tell perl this module is already loaded

    $INC{"${package}_embed.pm"} = "evaled";

    # find the Neurospaces c core directory

    $neurospaces_core_directory = $working_directory;

    $neurospaces_core_directory =~ s((.*)/perl)($1);

    #! automake uses a separate _build directory, not sure what to do with it, just remove it.

    $neurospaces_core_directory =~ s((.*)/_build)($1);

    # have inline to do its compilations in the neurospaces core directory

    print "Changing to neurospaces core directory : $neurospaces_core_directory\n";

    chdir $neurospaces_core_directory;
}


BEGIN
{


    $c_code = `cat $neurospaces_perl_modules/Neurospaces.c`;
}


use Data::Dumper;

use Glib qw/TRUE FALSE/;

use Gtk2 '-init';
use Gtk2::Helper;

use IO::File;

BEGIN
{
    if (defined $ARGV[0]
	&& $ARGV[0] eq 'debug')
    {
	do "stubs.pm";
    }
    else
    {
	#t note that building in /tmp could be a security risk
# 		DIRECTORY => '/tmp/neurospaces/inline',

	eval "
    use Inline (
		C => \$c_code,
		INC => \"-I$neurospaces_core_directory/algorithms/event -I$neurospaces_core_directory/algorithms/symbol -I$neurospaces_core_directory/ -g -Wmissing-prototypes -Wmissing-declarations -include config.h -DPRE_PROTO_TRAVERSAL\",
		LIBS => \"-L$neurospaces_core_directory -lneurospacesread -L$neurospaces_core_directory/algorithms/event -levent_algorithms -L$neurospaces_core_directory/algorithms/symbol -lsymbol_algorithms -lm -lreadline -lhistory\",
		CLEAN_AFTER_BUILD => 0,
	       );
";
    }
}

use Neurospaces::Biolevels;
use Neurospaces::GUI;
my $loaded_neurospaces_gui_tools_renderer = eval "require Neurospaces::GUI::Tools::Renderer;";
# use Neurospaces::GUI::Tools::Renderer; my $loaded_neurospaces_gui_tools_renderer = 1;


use YAML ();


BEGIN
{
    # go back to the original execution directory

    print "Changing to $working_directory\n";

    chdir $working_directory;
}


our $renderer = $loaded_neurospaces_gui_tools_renderer ? Neurospaces::GUI::Tools::Renderer->new() : 0;


sub initialize
{
    my $fd = shift;

    #! called during neurospaces initialization, meant for
    #! initialization of the perl modules.

    print "Initializing perl modules (in $0), input is coming from fd $fd\n";

    print "Neurospaces core assumed to be in $neurospaces_core_directory\n";

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

	      my $delay = $renderer->frame_preferred_delay();

	      my $timer = Glib::Timeout->add($delay, $timed_code, "got it\n", );
	  };

    $timed_code
	= sub
	  {
	      $renderer->main_loop();

	      &$install_timer();

	      # return false to and remove this timer

	      return 0;
	  };

    my $timer = Glib::Timeout->add(110, $timed_code, "got it\n", );

}


if (defined $ARGV[0]
    && $ARGV[0] eq 'debug')
{
    initialize(1);

    Neurospaces::GUI::gui("gtk");
}


1;


