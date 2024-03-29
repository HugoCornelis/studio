#!/usr/bin/perl -w

##
## Neurospaces: a library which implements a global typed symbol table to
## be used in neurobiological model maintenance and simulation.
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


package Neurospaces::GUI::Tools::Renderer;


use strict;


use constant PI => 4 * atan2(1, 1);


use Glib qw/TRUE FALSE/;

use Neurospaces::GUI::Command;


# the current convention is that this package will not load if
# SDL_Perl is not installed.

#! sometimes SDL_Perl, well heh ...

BEGIN
{
    push @INC, "/usr/local/lib/perl/5.8.7/auto/src/SDL/SFont";
    push @INC, "/usr/local/lib/perl/5.8.7/auto/src/SDL/OpenGL";
}

use SDL;
use SDL::App;
use SDL::Event;
use SDL::OpenGL;

use YAML;


our $self_singleton;


sub action_move
{
    my $self = shift;

    my ($command, $down) = @_;

    my $sign = $down ? 1 : -1;

    my $view = $self->{view};

    my $movements = $self->{movements};

    my $speed_roll = $movements->{speed}->{roll};
    my $speed_heading = $movements->{speed}->{heading};

    my $speed_move = $movements->{speed}->{move};

    my $speed_pilot = $movements->{speed}->{pilot};

    my $speed_zoom = $movements->{speed}->{zoom};

    # movement bindings

    my $move_update
	= {
	   '+look_behind'  => [ d_roll  =>  180 ],
	   '+move_back'    => [ dv_forward => -$speed_move ],
	   '+move_down'    => [ dv_up      =>  $speed_move ],
	   '+move_forward' => [ dv_forward =>  $speed_move ],
	   '+move_left'    => [ dv_right   => -$speed_move ],
	   '+move_right'   => [ dv_right   =>  $speed_move ],
	   '+move_up'      => [ dv_up      => -$speed_move ],
	   '+pilot_down'   => [ dv_heading => -$speed_heading ],
	   '+pilot_left'   => [ dv_roll    => -$speed_roll ],
	   'pilot_move'    => [ v_pilot    => -$speed_pilot ],
	   '+pilot_right'  => [ dv_roll    =>  $speed_roll ],
	   '+pilot_up'     => [ dv_heading =>  $speed_heading ],
	   '+zoom'  => [ dv_zoom =>  $speed_zoom ],
	   '-zoom'  => [ dv_zoom => -$speed_zoom ],
	  };

    # select which one to apply

    my $update = $move_update->{$command};

#     use Data::Dumper;

#     print "applying " . Dumper($update);

    if (defined $update)
    {
	# apply the update to the current view

	$view->{$update->[0]} += $update->[1] * $sign;
    }
}


sub action_quit
{
    my $self = shift;

#     print "Closing d3renderer\n";

#     $self->{done} = 1;
}


sub action_screenshot
{
    my $self = shift;

    $self->{need_screenshot} = 1;
}


sub calc_vector_step
{
    my ($v1, $v2, $div) = @_;

    return [($v2->[0] - $v1->[0]) / $div,
            ($v2->[1] - $v1->[1]) / $div,
            ($v2->[2] - $v1->[2]) / $div];
}


sub cleanup
{
    my $self = shift;

    print "\nDone.\n";

#     SDL::Quit();
}


sub command_preprocessor
{
    my $self = shift;

    my $command = shift;

    $command->{self} = $self_singleton;

    return $command;
}


sub command_processor
{
    my $package = shift;

    my $command = shift;

    my $self = $command->{self};

    my $command_name = $command->{name};

    my $commands = $self->{commands};

    # determine the action associated with the command

    my $action = $commands->{$command_name};

    # execute the action

    my $arguments = $command->{arguments};

    $self->$action($command_name, @$arguments);
}


sub commands_init
{
    my $self = shift;

    $self->{commands}
	= {
	   '+look_behind'  => \&action_move,
	   '+move_back'    => \&action_move,
	   '+move_down'    => \&action_move,
	   '+move_forward' => \&action_move,
	   '+move_left'    => \&action_move,
	   '+move_right'   => \&action_move,
	   '+move_up'      => \&action_move,
	   '+pilot_down'   => \&action_move,
	   '+pilot_left'   => \&action_move,
	   'pilot_move'    => \&action_move,
	   '+pilot_right'  => \&action_move,
	   '+pilot_up'     => \&action_move,
	   'quit' => \&action_quit,
	   'screenshot' => \&action_screenshot,
	   '+zoom' => \&action_move,
	   '-zoom' => \&action_move,
	  };
}


sub draw_axes
{
    my $self = shift;

    glDisable(GL_LIGHTING);

    # lines from origin along positive axes, for orientation

#     glEnable(GL_LINE_SMOOTH);

#     glEnable(GL_BLEND);
#     glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
#     # 	glHint(GL_LINE_SMOOTH_HINT, GL_DONT_CARE);
#     glHint(GL_LINE_SMOOTH_HINT, GL_NICEST);

    glPointSize(100);

    glLineWidth(1);

    glBegin(GL_LINES);

    # X axis = red
    glColor(1, 0, 0);
    glVertex(0, 0, 0);
    glLineWidth(100); # $coordinate * 1e6)
    glVertex(1, 0, 0);

    # Y axis = green
    glColor(0, 1, 0);
    glVertex(0, 0, 0);
    glLineWidth(100); # $coordinate * 1e6)
    glVertex(0, 1, 0);

    # Z axis = blue
    glColor(0, 0, 1);
    glVertex(0, 0, 0);
    glLineWidth(100); # $coordinate * 1e6)
    glVertex(0, 0, 1);
    glEnd();

    glEnable(GL_LIGHTING);
}


sub draw_view
{
    my $self = shift;

    # loop over all object in the view

    my $objects = $self->{objects};

    foreach my $object (@$objects)
    {
	# draw the object

	$self->drawing_render($object);
    }
}


sub drawing_cube
{
    my $drawing = shift;

    my $coordinate = shift;

    my $size = shift;

    # simple cube

    my @indices = qw( 4 5 6 7   1 2 6 5   0 1 5 4
                      0 3 2 1   0 4 7 3   2 3 7 6 );

    my @cube = ([-1, -1, -1], [ 1, -1, -1],
		[ 1,  1, -1], [-1,  1, -1],
		[-1, -1,  1], [ 1, -1,  1],
		[ 1,  1,  1], [-1,  1,  1]);

    my @normals = ([0, 0,  1], [ 1, 0, 0], [0, -1, 0],
                   [0, 0, -1], [-1, 0, 0], [0,  1, 0]);

    @cube
	= map
	  {
	      [
	       map
	       {
		   $_ * $size;
	       }
	       @$_,
	      ];
	  }
	      @cube;

    glEnable(GL_LINE_SMOOTH);

    glBegin(GL_QUADS);

    foreach my $face (0 .. 5)
    {
	my @subdivisions;

	# tell opengl the normal of the face for lighting effects

        my $normal = $normals[$face];

        glNormal(@$normal);

        foreach my $vertex (0 .. 3)
	{
            my $index  = $indices[4 * $face + $vertex];

            my $coords = $cube[$index];

	    my $side
		= [
		   $coordinate->{'x'} + $coords->[0],
		   $coordinate->{'y'} + $coords->[1],
		   $coordinate->{'z'} + $coords->[2],
		  ];

            push @subdivisions, $side;
        }

        drawing_quad_face
	    (
	     $drawing,
	     normal    => $normal,
	     corners   => \@subdivisions,
	    );
    }

    glEnd();
}


sub drawing_quad_face
{
    my $drawing = shift;

    my %arguments    = @_;

    my $normal  = $arguments{normal};
    my $corners = $arguments{corners};
    my $div     = $arguments{divisions} || 1;

    my ($a, $b, $c, $d) = @$corners;

    #! note: assumes face is a parallelogram

    my $s_ab = calc_vector_step($a, $b, $div);
    my $s_ad = calc_vector_step($a, $d, $div);

    glNormal(@$normal);

    for my $strip (0 .. $div - 1)
    {
        my @v = (
		 $a->[0] + $strip * $s_ab->[0],
                 $a->[1] + $strip * $s_ab->[1],
                 $a->[2] + $strip * $s_ab->[2],
		);

	glEnable(GL_LINE_SMOOTH);

        glBegin(GL_QUAD_STRIP);

        for my $quad (0 .. $div)
	{
            glVertex(@v);

            glVertex
		(
		 $v[0] + $s_ab->[0],
		 $v[1] + $s_ab->[1],
		 $v[2] + $s_ab->[2],
		);

            $v[0] += $s_ad->[0];
            $v[1] += $s_ad->[1];
            $v[2] += $s_ad->[2];
        }

        glEnd();
    }
}


sub drawing_render
{
    my $self = shift;

    my $drawing = shift;

    my $lists = $self->{models}->{lists};

    $drawing->{light}
	? glEnable(GL_LIGHTING)
	    : glDisable(GL_LIGHTING);

    glColor(@{$drawing->{color}})        if $drawing->{color};

    # push a working matrix for this drawing

    glPushMatrix();

    # set the matrix parameters

    glTranslate(@{$drawing->{position}}) if $drawing->{position};
    glRotate(@{$drawing->{orientation}}) if $drawing->{orientation};

    my $drawing_scale = $drawing->{scale};

    glScale(@$drawing_scale) if $drawing_scale && @$drawing_scale;

#     # apply additional scaling according to zoom factor, for balance

#     my $scale = $self->{view}->{scale};

#     my $scale2
# 	= [
# 	   map
# 	   {
# 	       ($scale->[$_] / ($drawing_scale->[$_] || 1e7)),
# 	   }
# 	   0 .. 2
# 	  ];

#     use Data::Dumper;

#     print Dumper($scale2);

#     glScale(@$scale2);

    # if there is a request to draw from a display list

    if ($drawing->{list})
    {
	my $list = $lists->{$drawing->{list}};

	if (defined $list)
	{
	    glCallList($list);
	}
	else
	{
	    print "list $drawing->{list} does not exist (internal error)\n";
	}
    }

    # for hardcoded drawing routines

    elsif ($drawing->{draw})
    {
	$drawing->{draw}->();
    }

    # else

    else
    {
	if (defined $drawing->{type}
	    && $drawing->{type} eq 'GL_LINES')
	{
	    # 	glEnable(GL_LINE_SMOOTH);

	    # 	glEnable(GL_BLEND);
	    # # 	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	    # # 	glHint(GL_LINE_SMOOTH_HINT, GL_DONT_CARE);
	    # 	glHint(GL_LINE_SMOOTH_HINT, GL_NICEST);

	    # 	glPointSize(100);

	    my $coordinates = $drawing->{coordinates};

	    my $begun = 0;

	    foreach my $coordinate_index (0 .. $#$coordinates)
	    {
		my $coordinate = $coordinates->[$coordinate_index];

		# 	    if ($coordinate_index < 300)
		# 	    {
		# 		use Data::Dumper;

		# 		print "$coordinate_index:" . Dumper($coordinate);
		# 	    }

		# if termination indicator

		if (!defined $coordinate)
		{
		    # terminate line

		    if ($begun)
		    {
			glEnd();

			$begun = 0;
		    }
		}

		# if a thickness

		elsif (!ref $coordinate)
		{
		    # terminate line

		    if ($begun)
		    {
			glEnd();

			$begun = 0;
		    }

		    # set thickness according to diameter

		    my $thickness = $coordinate * 1e6;

		    glLineWidth($thickness);

		}

		# else a regular coordinate

		elsif (ref $coordinate eq 'ARRAY')
		{
		    # start drawing if not needed

		    if (!$begun)
		    {
			glBegin(GL_LINES);

			$begun = 1;
		    }

		    # 		if ($coordinate_index < 300)
		    # 		{
		    # 		    print "Drawing vertex\n";
		    # 		}

		    # vertex x, y, z

		    glVertex(@$coordinate);
		}
		elsif (ref $coordinate eq 'HASH')
		{
		    # terminate line

		    if ($begun)
		    {
			glEnd();

			$begun = 0;
		    }

		    # set color

		    if ($coordinate->{color})
		    {
			my $color = $coordinate->{color};

			glColor(@$color);

		    }
		}
		else
		{
		    die "$0: drawing_render() does not know how to render type $coordinate";
		}
	    }

	    # end drawing

	    if ($begun)
	    {
		glEnd();

		$begun = 0;
	    }
	}
	elsif (defined $drawing->{type}
	       && $drawing->{type} eq 'cubes')
	{
	    my $coordinate_specs = $drawing->{coordinates};

	    foreach my $coordinate_spec (@$coordinate_specs)
	    {
		drawing_cube($drawing, @$coordinate_spec);
	    }
	}

	# pop the matrix that was associated with this drawing

	glPopMatrix();
    }
}


sub events_do
{
    my $self = shift;

    # get list of commands to execute

    #! regular events

    my $queue = $self->events_process();

    #! internally triggered events

    my $triggered = $self->events_trigger();

    push @$queue, @$triggered;

    # loop over the command list

    while (not $self->{done}
	   and @$queue)
    {
	# get next command

        my $command = shift @$queue;

	if ((ref $command) =~ /ARRAY/)
	{
	    # convert to a GUI command

	    my ($command_name, @arguments) = @$command;

	    my $gui_command
		= Neurospaces::GUI::Command->new
		    (
		     {
		      arguments => \@arguments,
		      name => $command_name,
		      preprocessor => 'command_preprocessor',
		      processor => 'command_processor',
		      self => $self,
		      target => 'Neurospaces::GUI::Tools::Renderer',
		     },
		    );

	    if ($gui_command)
	    {
		# execute the GUI command

		$gui_command->execute();
	    }
	}
	else
	{
	    print "Undefined command (not an array): " . YAML::Dump($command);
	}
    }
}

sub events_init
{
    my $self = shift;

    # create an event for the event loop (see events_process()).

    $self->{sdl_event} = SDL::Event->new();

    # configure the event to command translation table

    $self->{event_processor}
	= {
	   &SDL_KEYDOWN => \&process_key,
	   &SDL_KEYUP => \&process_key,
	   &SDL_MOUSEMOTION => \&process_motion,
	   &SDL_QUIT => \&process_quit,
	   &SDL_VIDEORESIZE => \&process_resize,
	  };
}


sub events_process
{
    my $self = shift;

    my $event  = $self->{sdl_event};
    my $event_processor = $self->{event_processor};

    my $result = [];

    # fetch next event if any

    $event->pump();

    #! events are recycled on each iteration, so this loop must copy
    #! the event data if this data is needed for later reference.

    while (not $self->{done}
	   and $event->poll())
    {
	# get SDL event type (e.g. SDL_KEYDOWN)

	my $type = $event->type();

	# get processor registered for this type

        my $processor = $event_processor->{$type};

	if ($processor)
	{
	    # convert to internal command array

	    my $command = $self->$processor($event);

	    if ($command)
	    {
		# push onto internal event list

		push @$result, $command;
	    }
	}
    }

    # return command list

    return $result;
}


sub events_trigger
{
    my $self = shift;

    my @commands;

    if ($self->{conf}->{benchmark}
	and $self->{time} >= 5)
    {
	push @commands, [ 'quit', ];
    }

    # return command list

    return \@commands;
}


sub external_add
{
    my $self = shift;

    my $external = shift;

    my $externals = $self->{externals} || [];

    push @$externals, $external;

    $self->{externals} = $externals;

    return 1;
}


sub fonts_init
{
    my $self  = shift;

    my $fonts
	= {
	   numbers => '/usr/local/neurospaces/studio/Neurospaces/GUI/Tools/numbers-7x11.txt',
	  };

    glPixelStore(GL_UNPACK_ALIGNMENT, 1);

    foreach my $font (keys %$fonts)
    {
        my ($bitmaps, $w, $h) = $self->fonts_read($fonts->{$font});

        my @cps    = sort {$a <=> $b} keys %$bitmaps;
        my $max_cp = $cps[-1];
        my $base   = glGenLists($max_cp + 1);

        foreach my $codepoint (@cps)
	{
            glNewList($base + $codepoint, GL_COMPILE);
            glBitmap($w, $h, 0, 0, $w + 2, 0, $bitmaps->{$codepoint});
            glEndList;
        }

        $self->{fonts}->{$font}->{base} = $base;
    }
}


sub fonts_read
{
    my $self = shift;

    my $file = shift;

    open my $defs, '<', $file
        or die "Could not open '$file': $!";
    local $/ = '';

    my $header  = <$defs>;
    chomp($header);

    # read font metrics

    my ($w, $h) = split /x/, $header;

    # loop over characters in the font file

    my %bitmaps;

    while (my $def = <$defs>)
    {
	# get hex code and char definition

        my ($hex, @rows) = grep /\S/, split /\n/, $def;

	# transliterate char, convert bit string to bytes

        @rows = map { tr/.0/01/; pack 'B*', $_ } @rows;

	# create bitmap

        my $bitmap = join '', reverse @rows;

	# store bitmap

        my $codepoint = hex $hex;

        $bitmaps{$codepoint} = $bitmap;
    }

    # return bitmaps with metrics

    return (\%bitmaps, $w, $h);
}


sub fps_draw
{
    my $self   = shift;

    my $base   = $self->{fonts}->{numbers}->{base};

#     my $d_time = $self->{d_time} || 0.001;
#     my $fps    = int(1 / $d_time);

    my $fps  = int($self->{stats}->{fps}->{cur_fps});

    glColor(1, 1, 1);
    glRasterPos(10, 10, 0);
    glListBase($base);
#     glCallListsString($fps);

    glCallLists($self->{stats}->{fps}->{cur_fps});
}


sub fps_finish
{
    my $self      = shift;

    my $time = time_now();
    my $d_frames = 1;
    my $d_time = $time - $self->{stats}->{fps}->{last_time};
    $d_time += 0.001;

    $self->{stats}->{fps}->{this_time} = $time;
    $self->{stats}->{fps}->{this_fps} = $d_frames / $d_time;
}


sub fps_init
{
    my $self = shift;

    $self->{stats}->{fps}->{cur_fps} = 0;
    $self->{stats}->{fps}->{last_frame} = 0;
    $self->{stats}->{fps}->{last_time} = $self->{time};
}


sub fps_update
{
    my $self      = shift;

    my $frame     = $self->{frame};
    my $time      = $self->{time};

    my $d_frames  = $frame - $self->{stats}->{fps}->{last_frame};
    my $d_time    = $time  - $self->{stats}->{fps}->{last_time};
    $d_time     ||= 0.001;

#     if ($d_time >= .2)
    {
        $self->{stats}->{fps}->{last_frame} = $frame;
        $self->{stats}->{fps}->{last_time} = $time;
        $self->{stats}->{fps}->{cur_fps} = $d_frames / $d_time;
    }
}


sub frame_do
{
    my $self = shift;

    $self->frame_prepare();
    $self->frame_draw();
    $self->frame_end();
}


sub frame_draw
{
    my $self = shift;

    $self->set_projection_3d();
    $self->set_lights_eye();
    $self->set_view_3d();
    $self->set_lights_world();
    $self->draw_view();

    $self->set_projection_2d();
    $self->set_lighting_2d();

    $self->fps_draw();

#     if ($self->{time} >= 500)
#     {
# 	$self->{done} = 1;
#     }
}


sub frame_end
{
    my $self = shift;

    # first synchronize the frame with the buffer

    $self->{sdl_app}->sync();

    # optionally take screenshot

    if ($self->{need_screenshot})
    {
	$self->screenshot();
    }
}


sub frame_preferred_delay
{
    my $self = shift;

    my $fps;

    if (!$self->{done})
    {
	$fps = $self->{stats}->{fps}->{this_fps};
    }
    else
    {
	$fps = 10;
    }

    my $delay = 1000;

    if ($fps != 0)
    {
	$delay = 1000 / $fps;
    }

    if ($delay <= 0)
    {
	$delay = 500;
    }

    $delay += 30;

    return $delay;
}


sub frame_prepare
{
    my $self = shift;

    glClear(GL_COLOR_BUFFER_BIT |
            GL_DEPTH_BUFFER_BIT );

    glEnable(GL_DEPTH_TEST);

    glEnable(GL_LIGHTING);
    glEnable(GL_COLOR_MATERIAL);

    glEnable(GL_NORMALIZE);
}


sub init
{
    my $self = shift;

    $| = 1;

    $self->movements_init();
    $self->commands_init();
    $self->events_init();
    $self->view_init();
    $self->view_window_init();
    $self->window_init();
    $self->time_init();
    $self->fonts_init();
    $self->models_init();
    $self->objects_init();
    $self->fps_init();
}


sub main
{
    my $self = shift;

    $self->init();
    $self->main_loop();
    $self->cleanup();
}


sub main_loop
{
    my $self = shift;

    if (not $self->{done})
    {
        $self->{frame}++;
        $self->time_update();
        $self->fps_update();
	$self->events_do();
	$self->view_update();
	$self->view_window_update();
        $self->frame_do();
	$self->fps_finish();
    }
}


sub models_init
{
    my $self = shift;

    # there are no models defined, so clear out the display lists

    $self->{models}->{lists} = {};

    # assemble the list of models ...

    # ... from symbols

    my $symbols = $self->{symbols};

    # ... and from the external data

    my $externals = $self->{externals};

    my $models
	= {
# 	   cube => \&drawing_cube,
	   (
	    map
	    {
		$_->{context} => $_;
	    }
	    @$symbols,
	   ),
	   (
	    map
	    {
		$_->{identifier} => $_;
	    }
	    @$externals,
	   ),
	  };

    # determine the number of gl lists we will create

    my $number = glGenLists(scalar @$symbols);

    my $display_lists;

    # compile all models

    foreach my $model_name (keys %$models)
    {
	print "Compiling $model_name\n";

	# start the gl list

	glNewList($number, GL_COMPILE);

	# for inline code

	if (ref $models->{$model_name} eq 'CODE')
	{
	    # call the code, supposed to do gl calls

	    $models->{$model_name}->();
	}

	# else a regular interface

	else
	{
	    # compile the object to gl code

	    my $drawing = $models->{$model_name}->draw($self, );

	    print "Created internal drawing for $drawing->{name}\n";

	    #! force an empty list of gl lists

	    $self->drawing_render($drawing, );
	}

	# end the list

	glEndList();

	# assign the number to model

	$display_lists->{$model_name} = $number;

	# next gl list identifier

	$number++;
    }

    # store the compile lists

    $self->{models}->{lists} = $display_lists;
}


sub movements_init
{
    my $self = shift;

    my $movements
	= {
	   speed => {
		     heading => 5,
		     move => 15,
		     pilot => 5,
		     roll => 5,
		     zoom => 1e6,
		    },
	  };

    my $gui_command
	= Neurospaces::GUI::Command->new
	    (
	     {
	      arguments => { movements => $movements, },
	      name => 'set_initial_movements',
	      processor => 'movements_set',
	      self => $self,
	      target => $self,
	     },
	    );

    $gui_command->execute();
}


sub movements_set
{
    my $self = shift;

    my $command = shift;

    my $movements = $command->{arguments}->{movements};

    $self->{movements} = $movements;
}


sub new
{
    my $class = shift;

    if (!$self_singleton)
    {
	my $self
	    = {
	       done => 1,
	       frame => 0,
	       conf => {
			benchmark => 0,
			bind   => {
				   right  => '+move_left',
				   left   => '+move_right',
				   up     => '+move_forward',
				   down   => '+move_back',
				   x   => '+move_up',
				   z   => '+move_down',
				   escape => 'quit',
				   f12    => '+screenshot',
				   a      => '+pilot_left',
				   d      => '+pilot_right',
				   w      => '+pilot_up',
				   's'    => '+pilot_down',
				   space  => 'pilot_move',
				   tab    => '+look_behind',
				   '+' => '+zoom',
				   '=' => '+zoom',
				   '-' => '-zoom',
				   '_' => '-zoom',
				  },
			fovy   => 80,
			height => 1000,
# 			height => 480,
			title  => 'Neurospaces Renderer',
# 			width  => 640,
			width  => 1000,
		       },
	       sdl_app => undef,
	      };

	bless $self, $class;

	$self_singleton = $self;
    }

    return $self_singleton;
}


sub objects_init
{
    my $self = shift;

    # map all objects to their models

    my $symbols = $self->{symbols};

    my $externals = $self->{externals};

    my $objects
	= [
# 	   {
#             draw        => \&draw_axes,
# 	    name        => 'axes',
# 	   },
# 	   {
# 	    lit         => 1,
# 	    color       => [ 1, 1,  1],
# 	    position    => [12, 0, -4],
# 	    scale       => [ 2, 2,  2],
# 	    draw        => \&drawing_cube,
# 	   },
# 	   {
# 	    lit         => 1,
# 	    color       => [ 1, 1, 0],
# 	    position    => [ 4, 0, 0],
# 	    orientation => [40, 0, 0, 1],
# 	    scale       => [.2, 1, 2],
# 	    draw        => \&drawing_cube,
# 	   },
	   (
	    map
	    {
		{ list => $_->{context}, };
	    }
	    @$symbols,
	   ),
	   (
	    map
	    {
		{ list => $_->{identifier}, };
	    }
	    @$externals,
	   ),
	  ];

#     foreach my $num (1 .. 5)
#     {
#         my $scale =   $num * $num / 15;
#         my $pos   = - $num * 2;
#         push @objects, {
# 			lit         => 1,
# 			color       => [ 1, 1,  1],
# 			position    => [$pos, 2.5, 0],
# 			orientation => [30, 1, 0, 0],
# 			scale       => [1, 1, $scale],
# 			draw        => \&drawing_cube,
# 		       };
#     }

#     $self->{objects} = \@objects;

    $self->{objects} = $objects;
}


sub process_key
{
    my $self = shift;

    my $event = shift;

    my $key_sym = $event->key_sym();

    my $name = SDL::GetKeyName($key_sym);

    my $command = $self->{conf}->{bind}->{$name} || '';

    my $down = $event->type() == SDL_KEYDOWN;

    if ($command =~ /^(\+|-)/)
    {
        return [ $command, $down, ];
    }
    else
    {
        return !$down ? $command : '';
    }
}


sub process_motion
{
    my $self = shift;

    my $event = shift;

    my $x = $event->motion_x();

    my $y = $event->motion_y();

    return '';
}


sub process_quit
{
    my $self = shift;

    print "Sending 'quit' command\n";

    $self->{done} = 1;

    return [ 'quit', ];
}


sub process_resize
{
    my $self = shift;

    my $event = shift;

#     no strict "refs";

#     use Data::Dumper;

#     print Dumper(\%{"SDL::Surface::"});

    my $width = $event->resize_w();

    my $height = $event->resize_h();

#     print "$width, $height\n";

    $self->{conf}->{width} = $width;
    $self->{conf}->{height} = $height;

    $self->{sdl_app}->resize($width, $height);

    return '';
}


sub rotate_xz
{
    my ($angle, $x, $z) = @_;

    my $radians = $angle * PI / 180;
    my $cos     = cos($radians);
    my $sin     = sin($radians);

    my $rot_x   =  $cos * $x + $sin * $z;
    my $rot_z   = -$sin * $x + $cos * $z;

    return ($rot_x, $rot_z);
}


sub screenshot
{
    my $self = shift;

    my $file = "screenshot_$self->{frame}.bmp";

    #! note : resizing not included

    my $w = $self->{conf}->{width};
    my $h = $self->{conf}->{height};

    glReadBuffer(GL_FRONT);

    my $data = glReadPixels(0, 0, $w, $h, GL_BGR, GL_UNSIGNED_BYTE);

    SDL::OpenGL::SaveBMP($file, $w, $h, 24, $data);

    print "$0: wrote screenshot to $file\n";

    # no automatic updates for screenshots : clear flag

    $self->{need_screenshot} = 0;
}


sub set_projection_2d
{
    my $self = shift;

    my $w    = $self->{conf}->{width};
    my $h    = $self->{conf}->{height};

    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    gluOrtho2D(0, $w, 0, $h);

    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();

    glDisable(GL_DEPTH_TEST);
}


sub set_projection_3d
{
    my $self = shift;

    my $conf = $self->{conf};

    my ($fovy, $w, $h) = @$conf{qw( fovy width height )};
    my $aspect = $w / $h;

    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    gluPerspective($fovy, $aspect, 1, 1000);

    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
}


sub set_lighting_2d
{
    glDisable(GL_LIGHTING);
}


sub set_lights_eye
{
    glLight(GL_LIGHT1, GL_POSITION, 0.0, 0.0, 1.0, 0.0);
    glLight(GL_LIGHT1, GL_DIFFUSE,  1.0, 1.0, 1.0, 1.0);
    glLight(GL_LIGHT1, GL_LINEAR_ATTENUATION, 0.5);

    #! placeholder only

    glLight(GL_LIGHT1, GL_SPOT_CUTOFF, 30.0);
    glLight(GL_LIGHT1, GL_SPOT_EXPONENT, 80.0);

    glEnable(GL_LIGHT1);
}


sub set_lights_world
{
    glLight(GL_LIGHT0, GL_POSITION, 1.0, 1.0, 1.0, 0.0);

    glEnable(GL_LIGHT0);
}


sub set_view_3d
{
    my $self = shift;

    # move the viewpoint so we can see the origin

    my $view = $self->{view};

    my $normalizer = $view->{normalizer};

    glRotate(@$normalizer, );

    my $pilotview_roll = $view->{pilotview}->{roll};
#     my $pilotview_pitch = $view->{pilotview}->{pitch};
    my $pilotview_heading = $view->{pilotview}->{heading};

    glRotate(@$pilotview_heading, );

    glRotate(@$pilotview_roll, );

#     glRotate(@$pilotview_pitch, );

    # set final origin position

    my $position = $view->{position};

    glTranslate(@$position, );

    # we are dealing with very small thing, zoom to get something out.

    my $scale = $self->{view}->{scale} || [ 1e6, 1e6, 1e6, ];

    glScale(@$scale);

}


sub symbol_add
{
    my $self = shift;

    my $symbol = shift;

    my $symbols = $self->{symbols} || [];

    push @$symbols, $symbol;

    $self->{symbols} = $symbols;
}


# sub symbol_set
# {
#     my $self = shift;

#     my $symbol = shift;

#     $self->{symbols} = [ $symbol, ];

#     $self->{done} = 0;

#     $self->init();
# }


sub symbols_clear
{
    my $self = shift;

    $self->{symbols} = [];
}


sub start
{
    my $self = shift;

    $self->{done} = 0;

    $self->init();
}


sub time_init
{
    my $self = shift;

    $self->{time} = time_now();
}


sub time_now
{
    return SDL::GetTicks() / 1000;
}


sub time_update
{
    my $self = shift;

    my $now  = time_now();

    $self->{d_time} = $now - $self->{time};
    $self->{time}   = $now;
}


our $global_view
    = {
       'd_roll' => 0,
       'd_heading' => 0,
       'dv_forward' => 0,
       'dv_up' => 0,
       'dv_roll' => 0,
       'dv_heading' => 0,
       'v_right' => 0,
       'v_forward' => 0,
       'v_up' => 0,
       'position' => [
		      -200,
		      50,
		      -30,
		     ],
       'pilotview' => {
		       roll => [
				-35, 0.0, 0.0, 1.0,
			       ],
		       pitch => [
				 0.0, 0.0, 1.0, 0.0,
				],
		       heading => [
				   0.0, 1.0, 0.0, 0.0,
				  ],
		       move => {
				v_pilot => 0,
				d_pilot => 0,
				dv_pilot => 0,
			       },
		      },
       'dv_right' => 0,
       'normalizer' => [
			-90,
			1,
			0,
			0
		       ],
       'v_roll' => 0,
       'v_heading' => 0,
       'dv_zoom' => 0,
       'v_zoom' => 0,
      };


sub view_init
{
    my $self = shift;

    my $gui_command
	= Neurospaces::GUI::Command->new
	    (
	     {
	      arguments => { view => $global_view, },
	      name => 'set_initial_view',
	      processor => 'view_set',
	      self => $self,
	      target => $self,
	     },
	    );

    $gui_command->execute();
}


sub view_set
{
    my $self = shift;

    my $command = shift;

    my $view = $command->{arguments}->{view};

    $self->{view} = $view;
}


sub view_update
{
    my $self = shift;

    my $view = $self->{view};
    my $d_time = $self->{d_time};

    # apply offset deltas for rotation

    $view->{pilotview}->{roll}->[0] += $view->{d_roll};
    $view->{pilotview}->{heading}->[0] += $view->{d_heading};

    # clear out deltas, have been applied

    $view->{d_roll} = 0;
    $view->{d_heading} = 0;

    # apply speeds for rotation

    $view->{v_roll} += $view->{dv_roll};
    $view->{dv_roll} = 0;
    $view->{pilotview}->{roll}->[0] += $view->{v_roll};

    $view->{v_heading} += $view->{dv_heading};
    $view->{dv_heading} = 0;
    $view->{pilotview}->{heading}->[0] += $view->{v_heading};

    # apply offset of pilot view

    $view->{pilotview}->{move}->{d_pilot} += $view->{v_pilot} || 0;

    $view->{v_pilot} = 0;

    # apply speed for position

    $view->{v_right}        += $view->{dv_right};
    $view->{dv_right}        = 0;
    $view->{v_forward}      += $view->{dv_forward};
    $view->{dv_forward}      = 0;
    $view->{v_up}      += $view->{dv_up};
    $view->{dv_up}      = 0;

    my $vx =  $view->{v_right};
    my $vy =  $view->{v_up};
    my $vz = -$view->{v_forward};

    my $pilot_position
	= [
	   $view->{pilotview}->{move}->{d_pilot},
	   0,
	   0,
	  ];

    # apply and clear out pilot velocity such that it only is applied once (we do not have breaks yet)

    $view->{pilotview}->{move}->{d_pilot} = 0;

    # apply new position

    $view->{position}->[0]    += $vx * $d_time;
    $view->{position}->[1]    += $vy * $d_time;
    $view->{position}->[2]    += $vz * $d_time;

    # apply zoom changes

    $view->{v_zoom} += $view->{dv_zoom};
    $view->{dv_zoom} = 0;

    foreach (0 .. 2)
    {
	$view->{scale}->[$_] -= $view->{v_zoom};
    }
}


sub view_window_init
{
    my $self = shift;

    if ($self->{gui}->{windows}->{d3renderer})
    {
	return;
    }

    my $constructor
	= {
	   arguments => '',
	   method => 'Neurospaces::GUI::Tools::Renderer',
	  };

    my $window = Neurospaces::GUI::window_factory('d3renderer_view', $constructor);

    $self->{gui}->{windows}->{d3renderer} = $window;

    $window->set_title("Pilot View : Coordinates & Angles");

    $window->set_default_size(500, 300);

    $window->signal_connect(delete_event => sub { Neurospaces::GUI::window_close($window); }, );

    $window->set_border_width(10);

    # everything contained in a horizontal layout

    my $hbox = Gtk2::HBox->new();

    $window->add($hbox);

    {
	# center : scrollable text

	my $table_scroller = Gtk2::ScrolledWindow->new();

	$table_scroller->set_size_request(200, 300);

	$table_scroller->set_policy (qw/automatic automatic/);

	$hbox->pack_start ($table_scroller, 1, 1, 0);

	my $textbuffer_view = Gtk2::TextBuffer->new();

	$self->{gtk2_textbuffer_view} = $textbuffer_view;

	my $text_view = Gtk2::TextView->new();

	$text_view->set_editable(FALSE);

	$text_view->set_buffer($textbuffer_view);

	$table_scroller->add($text_view);
    }

    # show the window

    $window->show_all();

    return $window;
}


sub view_window_update
{
    my $self = shift;

    # fill the text buffer

    my $textbuffer_view = $self->{gtk2_textbuffer_view};

    my $view = $self->{view};

    my $pilotview = $view->{pilotview};

    $textbuffer_view->set_text
	(
	 YAML::Dump
	 (
	  {
	   angles => {
		      'x' => $pilotview->{heading}->[0],
		      'y' => $pilotview->{roll}->[0],
		     },
	   perspective => $self->{conf}->{fovy},
	   position => $view->{position},
	   scale => $view->{scale},
	  },
	 )
	);
}


sub window_init
{
    my $self = shift;

    my $conf = $self->{conf};

    my ($title, $w, $h) = @$conf{qw( title width height )};

    $self->{sdl_app}
	= SDL::App->new
	    (
	     -gl => 1,
	     -height => $h,
# 	     -resizeable => 1,
	     -title => $title,
	     -width => $w,
	    );

    SDL::ShowCursor(1);
}


1;


