#!/usr/bin/perl -w
#!/usr/bin/perl -d:ptkdb -w
#
# (C) 2007 Hugo Cornelis hugo.cornelis@gmail.com
#


package Neurospaces::Morphology;


use strict;


require Exporter;

our @ISA = qw(Exporter);

our @EXPORT_OK = qw(all_morphologies);


sub average_branchpoints_per_tip
{
    my $self = shift;

    my $component_name = shift;

    $self->branchpoints_per_tip($component_name);

    my $result = 0;

    foreach my $tip (keys %{$self->{branchpoints_per_tip}})
    {
	$result += $self->{branchpoints_per_tip}->{$tip};
    }

    return $result / scalar keys %{$self->{branchpoints_per_tip}};
}


sub average_diameter
{
    my $self = shift;

    my $component_name = shift;

    my $self_commands
	= join
	    ' ',
		(
		 map
		 {
		     "--command '$_'"
		 }
		 @{$self->{commands}},
		);

    my $self_options
	= join
	    ' ',
		(
		 map
		 {
		     "--backend-option '$_'"
		 }
		 @{$self->{backend_options}},
		);

    my $system_command = "neurospaces 2>&1 $self_options $self_commands --traversal-symbol / '--type' '^T_sym_segment\$' '--reporting-fields' 'DIA' --operator average \"$self->{filename}\"";

    print STDERR "executing ($system_command)\n";

    my $yaml_average_diameter_string = join '', `$system_command`;

    $self->set_ndf_filename($yaml_average_diameter_string);

    $yaml_average_diameter_string =~ s/.*---/---/gs;

    # 	$yaml_average_diameter_string =~ s/\n.*$/\n/;

    # 	print "($yaml_average_diameter_string)";

    use YAML;

    my $average_diameter = Load($yaml_average_diameter_string);

    # cache results

    $self->{average_diameter} = $average_diameter;

    # return result

    return $self->{average_diameter};
}


sub average_tip_lengths
{
    my $self = shift;

    my $component_name = shift;

    my $tip_lengths = $self->tip_lengths($component_name);

    my $result = 0;

    foreach my $tip (keys %$tip_lengths)
    {
	my $length = $tip_lengths->{$tip};

	$result += $length;
    }

    return $result / scalar keys %$tip_lengths;
}


sub branchpoints
{
    my $self = shift;

    my $component_name = shift;

    my $self_commands
	= join
	    ' ',
		(
		 map
		 {
		     "--command '$_'"
		 }
		 @{$self->{commands}},
		);

    my $self_options
	= join
	    ' ',
		(
		 map
		 {
		     "--backend-option '$_'"
		 }
		 @{$self->{backend_options}},
		);

    my $system_command = "neurospaces 2>&1 $self_options $self_commands --command 'segmentersetbase $component_name' --traversal-symbol / '--type' '^T_sym_segment\$' '--reporting-fields' 'BRANCHPOINT' \"$self->{filename}\"";

    print STDERR "executing ($system_command)\n";

    my $yaml_branchpoints_string = join '', `$system_command`;

    $self->set_ndf_filename($yaml_branchpoints_string);

    $yaml_branchpoints_string =~ s/.*---/---/gs;

    # 	$yaml_branchpoints_string =~ s/\n.*$/\n/;

    # 	print "($yaml_branchpoints_string)";

    use YAML;

    my $branchpoints = Load($yaml_branchpoints_string);

    # cache results

    $self->{branchpoint_parameters} = $branchpoints->{parameters};

    $self->{branchpoints}
	= {
	   map
	   {
	       $_ => $branchpoints->{parameters}->{$_};
	   }
	   grep
	   {
	       $branchpoints->{parameters}->{$_} ne -1
		   and $branchpoints->{parameters}->{$_} ne 0
	   }
	   keys %{$branchpoints->{parameters}},
	  };

    # return result

    return $self->{branchpoints};
}


sub branchpoints_per_tip
{
    my $self = shift;

    my $component_name = shift;

    $self->dendritic_tips($component_name);

    my $self_commands
	= join
	    ' ',
		(
		 map
		 {
		     "--command '$_'"
		 }
		 @{$self->{commands}},
		);

    my $self_options
	= join
	    ' ',
		(
		 map
		 {
		     "--backend-option '$_'"
		 }
		 @{$self->{backend_options}},
		);

    my $system_command = "neurospaces 2>&1 $self_options $self_commands --command 'segmentersetbase $component_name' --traversal-symbol / '--type' '^T_sym_segment\$' '--reporting-fields' 'SOMATOPETAL_BRANCHPOINTS' \"$self->{filename}\"";

    print STDERR "executing ($system_command)\n";

    my $yaml_branchpoints_per_tip_string = join '', `$system_command`;

    $self->set_ndf_filename($yaml_branchpoints_per_tip_string);

    $yaml_branchpoints_per_tip_string =~ s/.*---/---/gs;

    # 	$yaml_branchpoints_per_tip_string =~ s/\n.*$/\n/;

    # 	print "($yaml_branchpoints_per_tip_string)";

    use YAML;

    my $branchpoints_per_tip = Load($yaml_branchpoints_per_tip_string);

    # cache results

    $self->{branchpoints_per_tip_parameters} = $branchpoints_per_tip->{parameters};

    $self->{branchpoints_per_tip}
	= {
	   map
	   {
	       $_ => $self->{branchpoints_per_tip_parameters}->{$_ . "->SOMATOPETAL_BRANCHPOINTS"};
	   }
	   @{$self->{dendritic_tips}->{tips}->{names}},
	  };

    # return result

    return $self->{branchpoints_per_tip};
}


sub dendritic_tips
{
    my $self = shift;

    my $component_name = shift;

    my $self_commands
	= join
	    ' ',
		(
		 map
		 {
		     "--command '$_'"
		 }
		 @{$self->{commands}},
		);

    my $self_options
	= join
	    ' ',
		(
		 map
		 {
		     "--backend-option '$_'"
		 }
		 @{$self->{backend_options}},
		);

    my $system_command1 = "neurospaces $self_options $self_commands --command 'segmentertips $component_name' \"$self->{filename}\"";

    print STDERR "executing ($system_command1)\n";

    my $yaml_tips_string = join '', `$system_command1`;

    $self->set_ndf_filename($yaml_tips_string);

    $yaml_tips_string =~ s/.*---/---/gs;

    # 	$yaml_tips_string =~ s/\n.*$/\n/;

    # 	print "($yaml_tips_string)";

    use YAML;

    my $dendritic_tips = Load($yaml_tips_string);

    my $system_command2 = "neurospaces $self_options $self_commands --command 'segmenterlinearize $component_name' \"$self->{filename}\"";

    print STDERR "executing ($system_command2)\n";

    my $yaml_linearize_string = join '', `$system_command2`;

    $self->set_ndf_filename($yaml_linearize_string);

    $yaml_linearize_string =~ s/.*---/---/gs;

    # 	$yaml_linearize_string =~ s/\n.*$/\n/;

    # 	print "($yaml_linearize_string)";

    use YAML;

    my $linearize = Load($yaml_linearize_string);

    # cache results

    $self->{linearize} = $linearize;

    $self->{dendritic_tips} = $dendritic_tips;

    # return result

    return $dendritic_tips;
}


sub instantiate_backend
{
    my $self = shift;

    if (!$self->{backend})
    {
	my $neurospaces = Neurospaces->new();

	$self->{backend} = $neurospaces;

	#t consolidation and grouping / structuring of these settings is really required

	if (defined $self->{model_library})
	{
	    $neurospaces->{model_library} = $self->{model_library};
	}
    }

    return 1;
}


sub length_surface_volume
{
    my $self = shift;

    my $component_name = shift;

    my $self_commands
	= join
	    ' ',
		(
		 map
		 {
		     "--command '$_'"
		 }
		 @{$self->{commands}},
		);

    my $self_options
	= join
	    ' ',
		(
		 map
		 {
		     "--backend-option '$_'"
		 }
		 @{$self->{backend_options}},
		);

    my $system_command = "neurospaces $self_options $self_commands --command 'delete $component_name/segments/soma' --command 'printparameter $component_name TOTALLENGTH' --command 'printparameter $component_name TOTALSURFACE' --command 'printparameter $component_name TOTALVOLUME' \"$self->{filename}\"";

    print STDERR "executing ($system_command)\n";

    my $output_command = join '', `$system_command`;

    $self->set_ndf_filename($output_command);

    $output_command =~ /TOTALLENGTH.*?= (\S+)/s;

    my $total_length = $1;

    $output_command =~ /TOTALSURFACE.*?= (\S+)/s;

    my $total_surface_area = $1;

    $output_command =~ /TOTALVOLUME.*?= (\S+)/s;

    my $total_volume = $1;

    $self->{length_surface_volume}->{total_length} = $total_length;

    $self->{length_surface_volume}->{total_surface_area} = $total_surface_area;

    $self->{length_surface_volume}->{total_volume} = $total_volume;

    # return result

    return $self->{length_surface_volume};
}


sub load
{
    my $self = shift;

    my $morphology = shift;

    $self->instantiate_backend();

    $self->{filename} = $morphology;

    my $success
	= $self->{backend}->load
	    (
	     $self,
	     [
	      defined $self->{description} ? $self->{description} : 'description missing',
	     ],
	    );

    return $success;
}


sub new
{
    my $package = shift;

    my $options = shift || {};

    my $self
	= {
	   %$options,
	  };

    bless $self, $package;

#     # cache dendritic tips

#     if ($self->{dendritic_tips_request})
#     {
# 	$self->cache_dendritic_tips($self->{dendritic_tips_request});
#     }

    return $self;
}


sub set_ndf_filename
{
    my $self = shift;

    my $text = shift;

    if ($text =~ m((/tmp/morphology.*\.ndf)))
    {
	$self->{ndf_filename} = $1;

	$self->{original_filename} = $self->{filename};

	$self->{filename} = $self->{ndf_filename};
    }
}


sub somatopetaldistances
{
    my $self = shift;

    my $result;

    my $self_commands
	= join
	    ' ',
		(
		 map
		 {
		     "--command '$_'"
		 }
		 @{$self->{commands}},
		);

    my $self_options
	= join
	    ' ',
		(
		 map
		 {
		     "--backend-option '$_'"
		 }
		 @{$self->{backend_options}},
		);

    my $system_command = "neurospaces 2>&1 $self_options $self_commands --traversal-symbol / --reporting-field SOMATOPETAL_DISTANCE --type segment \"$self->{filename}\"";

    print STDERR "executing ($system_command)\n";

    my $yaml_distances_string = join '', `$system_command`;

    $self->set_ndf_filename($yaml_distances_string);

    $yaml_distances_string =~ s/.*---/---/gs;

    # 	$yaml_distances_string =~ s/\n.*$/\n/;

    # 	print "($yaml_distances_string)";

    use YAML;

    my $distances = Load($yaml_distances_string);

    $result->{somatopetaldistances} = $distances;

    # cache result

    $self->{somatopetaldistances} = $result;

    # return result

    return $result;
}


sub spiny_length
{
    my $self = shift;

    my $component_name = shift;

    my $dia = shift;

    my $result;

    my $self_commands
	= join
	    ' ',
		(
		 map
		 {
		     "--command '$_'"
		 }
		 @{$self->{commands}},
		);

    my $self_options
	= join
	    ' ',
		(
		 map
		 {
		     "--backend-option '$_'"
		 }
		 @{$self->{backend_options}},
		);

    my $system_command = "neurospaces $self_options $self_commands  --traversal-symbol / '--type' '^T_sym_segment\$' '--reporting-fields' 'LENGTH' --operator cumulate --condition 'SwiggableNeurospaces::symbol_parameter_resolve_value(\$d->{_symbol}, \$d->{_context}, \"DIA\") < $dia' \"$self->{filename}\"";

    print STDERR "executing ($system_command)\n";

    my $output_command = join '', `$system_command`;

    $self->set_ndf_filename($output_command);

    $output_command =~ /final_value: (\S+)/;

    $result = $1;

    return $result;
}


sub structure_summary
{
    my $self = shift;

    my $component_name = shift;

    my $result
	= {
	   average_branchpoints_per_tip => $self->average_branchpoints_per_tip($component_name),
	   average_diameter => $self->average_diameter($component_name),
	   average_tip_lengths => $self->average_tip_lengths($component_name),
	   branchpoints => scalar keys %{$self->branchpoints($component_name)},
 	   tips => $self->dendritic_tips($component_name),
	   total_length => $self->total_length($component_name),
	   total_surface_area => $self->total_surface_area($component_name),
	   total_volume => $self->total_volume($component_name),
	  };

    $result->{tips}->{tip_count} = scalar @{$result->{tips}->{tips}->{names}};

    return $result;
}


sub tip_lengths
{
    my $self = shift;

    my $component_name = shift;

    my $dendritic_tips = $self->dendritic_tips($component_name);

    my $somatopetaldistances = $self->somatopetaldistances();

    my $result
	= {
	   map
	   {
	       $_ => $somatopetaldistances->{somatopetaldistances}->{parameters}->{"$_->SOMATOPETAL_DISTANCE"};
	   }
	   @{$dendritic_tips->{tips}->{names}},
	  };

    $self->{tip_lengths} = $result;

    return $result;
}


sub total_length
{
    my $self = shift;

    my $component_name = shift;

    if (!$self->{length_surface_volume})
    {
	$self->length_surface_volume($component_name);
    }

    return $self->{length_surface_volume}->{total_length};
}


sub total_surface_area
{
    my $self = shift;

    my $component_name = shift;

    if (!$self->{length_surface_volume})
    {
	$self->length_surface_volume($component_name);
    }

    return $self->{length_surface_volume}->{total_surface_area};
}


sub total_volume
{
    my $self = shift;

    my $component_name = shift;

    if (!$self->{length_surface_volume})
    {
	$self->length_surface_volume($component_name);
    }

    return $self->{length_surface_volume}->{total_volume};
}


1;


