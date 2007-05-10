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
					      '--traversal-symbol',
					      '/',
					      '--spine',
					      'Purk_spine',
					      '--condition',
					      '$d->{context} =~ m(segments/.{20}/.*par/exp)i',
					     ],
				command => 'bin/neurospaces',
				command_tests => [
						  {
						   comment => 'the condition forces to report only a few of the spines present.',
						   description => "Are spines present ?",
						   read => '/gp_pc1/segments/p0b1b1[0]/Purk_spine/head/par/exp2
/gp_pc1/segments/p0b1b1[1]/Purk_spine/head/par/exp2
/gp_pc1/segments/p0b1b1[2]/Purk_spine/head/par/exp2
/gp_pc1/segments/p0b1b1[3]/Purk_spine/head/par/exp2
/gp_pc1/segments/p0b1b1[4]/Purk_spine/head/par/exp2
',
						   timeout => 100,
						   write => undef,
						  },

						 ],
				description => "spine reporting for a passive morphology that was populated with active channels and spines",
			       },
			       {
				arguments => [
					      "$morphologies/$morphology_name1",
					      '--traversal-symbol',
					      '/',
					      '--shrinkage',
					      '1.1111111',
					      '--condition',
					      '$d->{context} =~ m(kdr)i',
					      '--reporting-fields',
					      'GMAX',
					     ],
				command => 'bin/neurospaces',
				command_tests => [
						  {
						   description => "Are delayed rectifier channels present ?",
						   read => '/gp_pc1/segments/soma/kdr->GMAX = 6000
/gp_pc1/segments/p0b1[0]/kdr->GMAX = 600
/gp_pc1/segments/p0b1[1]/kdr->GMAX = 600
/gp_pc1/segments/p0b1[2]/kdr->GMAX = 600
/gp_pc1/segments/p0b1[3]/kdr->GMAX = 600
/gp_pc1/segments/p0b1b2[0]/kdr->GMAX = 600
/gp_pc1/segments/p0b1b2b2[0]/kdr->GMAX = 600
/gp_pc1/segments/p0b1b2b2[1]/kdr->GMAX = 600
/gp_pc1/segments/p0b1b2b2[2]/kdr->GMAX = 600
/gp_pc1/segments/p0b1b2b2b2[0]/kdr->GMAX = 600
',
						   timeout => 100,
						   write => undef,
						  },
						 ],
				description => "delayed rectifier reporting for a passive morphology that was populated with active channels",
			       },
			       {
				arguments => [
					      "$morphologies/$morphology_name2",
					      '--shrinkage',
					      '1.1111111',
					      '--spine',
					      'Purk_spine',
					      '--algorithm',
					      'Spines',
					     ],
				command => 'bin/neurospaces',
				command_tests => [
						  {
						   comment => 'This test can suffer from arithmetic rounding',
						   description => "Has the spines algorithm worked correctly ?",
						   read => [
							    '-re',
							    '---
name: SpinesInstance Spines__0__Purk_spine
report:
    number_of_added_spines: 1444
    number_of_virtual_spines: 111513.676986
    number_of_tries_adding_spines: 1444
    number_of_failures_adding_spines: 0
    SpinesInstance_prototype: Purk_spine
    SpinesInstance_surface: 1.33079e-12
',
							   ],
						   timeout => 100,
						   write => undef,
						  },
						 ],
				description => "spines algorithm reporting for a passive morphology that was populated with active channels",
			       },
			      ],
       description => "information reporting on loaded models",
       name => 'reporting.t',
      };


return $test;


