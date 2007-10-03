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

    my $result = [];

    # get context

    my $context = SwiggableNeurospaces::PidinStackParse($component_name);

    # get component

    my $component = $context->PidinStackLookupTopSymbol();

    $component->SymbolLinearize($context);

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
    }

    return 1;
}


sub load
{
    my $self = shift;

    my $morphology = shift;

    $self->instantiate_backend();

    my $success
	= $self->{backend}->load
	    (
	     {
	      %$self,
	      'filename' => $morphology,
	     },
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


