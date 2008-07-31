#!/usr/bin/perl -w
#!/usr/bin/perl -d:ptkdb -w
#
# (C) 2007 Hugo Cornelis hugo.cornelis@gmail.com
#


package Neurospaces::Project::Modules::Morphology;


use strict;


require Exporter;

our @ISA = qw(Exporter);

our @EXPORT_OK
    = qw(
	 all_morphologies
	 all_morphology_groups
	);


sub all_morphologies
{
    my $project = shift;

    my $project_name = $project->{name};

    my $project_root = $project->{root};

    #t replace with File::Find;

    my $result = [ sort map { chomp; $_; } `find "$project_root/$project_name/morphologies" -name "*.ndf" -o -name "*.p" -o -iname "*.swc"`, ];

    return $result;
}


sub all_morphology_groups
{
    my $project = shift;

    my $project_name = $project->{name};

    my $project_root = $project->{root};

    use YAML 'LoadFile';

    my $result;

    eval
    {
	$result = LoadFile("$project_root/$project_name/morphology_groups/descriptor.yml");
    };

    return $result;
}


1;


