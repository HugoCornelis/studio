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


sub dendritic_tips
{
    my $self = shift;

    my $component_name = shift;

    my $result;

    my $in_memory = 0;

    if ($in_memory)
    {
	# get context

	my $context = SwiggableNeurospaces::PidinStackParse($component_name);

	# get component

	my $component = $context->PidinStackLookupTopSymbol();

	$component->SymbolLinearize($context);

    }

    else
    {
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

	$yaml_tips_string =~ s/.*---/---/gs;

# 	$yaml_tips_string =~ s/\n.*$/\n/;

# 	print "($yaml_tips_string)";

	use YAML;

	my $tips = Load($yaml_tips_string);

	$result->{tips} = $tips;

	my $system_command2 = "neurospaces $self_options $self_commands --command 'segmenterlinearize $component_name' \"$self->{filename}\"";

	my $yaml_linearize_string = join '', `$system_command2`;

	$yaml_linearize_string =~ s/.*---/---/gs;

# 	$yaml_linearize_string =~ s/\n.*$/\n/;

# 	print "($yaml_linearize_string)";

	use YAML;

	my $linearize = Load($yaml_linearize_string);

	$result->{linearize} = $linearize;
    }

    # cache result

    $self->{dendritic_tips} = $result;

    # return result

    return $result;
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


1;


