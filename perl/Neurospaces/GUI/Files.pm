#!/usr/bin/perl -w

##
## Neurospaces: a library which implements a global typed symbol table to
## be used in neurobiological model maintenance and simulation.
##
## $Id: Files.pm 1.10 Sat, 21 Apr 2007 21:21:25 -0500 hugo $
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


package Neurospaces::GUI::Files;


use strict;


use Glib qw/TRUE FALSE/;

use Neurospaces::GUI;


sub explore
{
    my $self = shift;

    $self->files_create_window();

    # fill the files list

    my $list_files = $self->{gtk2_files_list};

    my $files = $self->{state}->{files};

    foreach my $file (@$files)
    {
	push
	    @{$list_files->{data}},
		[
		 $file,
		];
    }

    $list_files->signal_connect
	(
	 row_activated =>
	 sub
	 {
	     my ($widget, $path, $column) = @_;

	     my $row_ref = $widget->get_row_data_from_path($path);

	     my $filename = $row_ref->[0];

	     $self->show_file($filename);
	 },
	);
}


sub files_create_window
{
    my $self = shift;

    my $constructor
	= {
	   arguments => '',
	   method => 'Neurospaces::GUI::Files::new_with_window',
	  };

    my $window = Neurospaces::GUI::window_factory('files', $constructor);

    $self->{gui}->{windows}->{files} = $window;

    $window->set_title("All loaded files");

    $window->set_default_size(500, 300);

    $window->signal_connect(delete_event => sub { Neurospaces::GUI::window_close($window); }, );

    $window->set_border_width(10);

    # everything contained in a horizontal layout

    my $hbox = Gtk2::HBox->new();

    $window->add($hbox);

    my $list_scroller = Gtk2::ScrolledWindow->new();

    $list_scroller->set_policy (qw/automatic automatic/);

    $hbox->pack_start($list_scroller, 1, 1, 0);

    my $list
	= Gtk2::SimpleList->new
	    (
	     'Name' => 'text',
	    );

    $self->{gtk2_files_list} = $list;

    $list->get_selection()->set_mode('single');

    $list_scroller->add($list);

    # show the window

    $window->show_all();

    return $window;
}


sub initialize_state
{
    my $self = shift;

    $self->{state}->{files} = SwiggableNeurospaces::swig_get_files();

    $self->{state}->{files} = [ sort @{$self->{state}->{files}}, ];
}


sub new
{
    my $class = shift;

    my $options = shift;

    my $self = {};

    bless $self, $class;

    $self->initialize_state();

    return $self;
}


sub new_with_window
{
    new('Neurospaces::GUI::Files', @_)->explore();
}


sub show_file
{
    #! self not used, interferes with session management

    my $self = shift;

    my $filename = shift;

    my $constructor
	= {
	   arguments => [ {}, $filename, ],
	   method => 'Neurospaces::GUI::Files::show_file',
	  };

    my $window = Neurospaces::GUI::window_factory('show_file', $constructor);

#     $self->{gui}->{windows}->{show_file}->{$filename} = $window;

    $window->set_title($filename);

    $window->set_default_size(500, 300);

    $window->signal_connect(delete_event => sub { Neurospaces::GUI::window_close($window); }, );

    $window->set_border_width(10);

    # everything contained in a horizontal layout

    my $hbox = Gtk2::HBox->new();

    $window->add($hbox);

    # left panel : scrollable text

    my $table_scroller = Gtk2::ScrolledWindow->new();

    $table_scroller->set_size_request(200, 300);

    $table_scroller->set_policy (qw/automatic automatic/);

    $hbox->pack_start ($table_scroller, 1, 1, 0);

    my $textbuffer_content = Gtk2::TextBuffer->new();

    my $text_content = Gtk2::TextView->new();

    $text_content->set_editable(FALSE);

    $text_content->set_buffer($textbuffer_content);

    my $content = `cat $filename`;

    $textbuffer_content->set_text($content);

    $table_scroller->add($text_content);

    # show the window

    $window->show_all();
}


1;


