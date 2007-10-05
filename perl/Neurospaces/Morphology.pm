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
	my $yaml_tips_string = join '', `echo segmentertips "$component_name" | neurospaces --query "$self->{filename}"`;

	$yaml_tips_string =~ s/.*---/---/gs;

	$yaml_tips_string =~ s/\n.*$/\n/;

# 	print "($yaml_tips_string)";

	use YAML;

	my $tips = Load($yaml_tips_string);

	$result->{tips} = $tips;

	my $yaml_linearize_string = join '', `echo segmenterlinearize "$component_name" | neurospaces --query "$self->{filename}"`;

	$yaml_linearize_string =~ s/.*---/---/gs;

	$yaml_linearize_string =~ s/\n.*$/\n/;

# 	print "($yaml_tips_string)";

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

    return $self;
}


1;


