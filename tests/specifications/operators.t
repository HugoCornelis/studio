#!/usr/bin/perl -w
#

use strict;


use YAML 'LoadFile';

my $neurospaces_config = LoadFile('/etc/neurospaces/project_browser/project_browser.yml');

my $project_name = 'purkinje-comparison';

my $subproject_name = 'morphologies';

my $morphology_name1 = 'genesis/gp_pc1.p';

my $morphology_name2 = 'genesis/gp_pc2.p';

my $morphologies = $neurospaces_config->{project_browser}->{root_directory} . "$project_name/$subproject_name";


my $test
    = {
       command_definitions => [
			       {
				arguments => [
					      "$morphologies/$morphology_name1",
					      '--no-use-library',
					      '--shrinkage',
					      '1.114',
					      '--traversal-symbol',
					      '/',
					      '--type',
					      '^T_sym_segment$',
					      '--reporting-fields',
					      'LENGTH',
					      '--condition',
					      '$d->{context} !~ /Purk_spine/i',
					      '--operator',
					      'cumulate',
					     ],
				command => 'bin/neurospaces',
				command_tests => [
						  {
						   description => "Is surface accumulation done correctly ?",
						   read => 'cumulate:
  description: cumulated value
  final_value: 0.012075620569123',
						   timeout => 1000000,
						   write => undef,
						  },
						 ],
				description => "surface accumulation",
				disabled => (-e "$morphologies/$morphology_name1" ? '' : "$morphologies/$morphology_name1 not found"),
			       },
			       {
				arguments => [
					      "$morphologies/$morphology_name1",
					      '--no-use-library',
					      '--shrinkage',
					      '1.114',
					      '--traversal-symbol',
					      '/',
					      '--type',
					      '^T_sym_segment$',
					      '--reporting-fields',
					      'LENGTH',
					      '--condition',
					      '$d->{context} !~ /Purk_spine/i',
					      '--condition',
					      '$d->{context} !~ /soma/i',
					      '--operator',
					      'minimum',
					     ],
				command => 'bin/neurospaces',
				command_tests => [
						  {
						   description => "Is the minimum operator applied correctly ?",
						   read => 'minimum:
  description: /gp_pc1/segments/p0b1b2b2b2b1b2b2b2b1b2[1]->LENGTH
  final_value: 5.56999999999999e-07
',
						   timeout => 10,
						   write => undef,
						  },
						 ],
				description => "minimum operator",
				disabled => (-e "$morphologies/$morphology_name1" ? '' : "$morphologies/$morphology_name1 not found"),
			       },
			       {
				arguments => [
					      "$morphologies/$morphology_name1",
					      '--no-use-library',
					      '--shrinkage',
					      '1.114',
					      '--traversal-symbol',
					      '/',
					      '--type',
					      '^T_sym_segment$',
					      '--reporting-fields',
					      'LENGTH',
					      '--condition',
					      '$d->{context} !~ /Purk_spine/i',
					      '--operator',
					      'maximum',
					     ],
				command => 'bin/neurospaces',
				command_tests => [
						  {
						   description => "Is the maximum operator applied correctly ?",
						   read => 'maximum:
  description: /gp_pc1/segments/p0b1b2b2b2b2b2b2b2b2b2b2b2b2b2b2b1b2b2b2b2b2[0]->LENGTH
  final_value: 2.64677585375113e-05
',
						   timeout => 10,
						   write => undef,
						  },
						 ],
				description => "maximum operator",
				disabled => (-e "$morphologies/$morphology_name1" ? '' : "$morphologies/$morphology_name1 not found"),
			       },
			      ],
       description => "application of operators to reported fields",
       name => 'operators.t',
      };


return $test;


