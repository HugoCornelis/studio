#!/usr/bin/perl -w
#

use strict;


my $test
    = {
       command_definitions => [
			       {
				arguments => [
					      '~/neurospaces_project/purkinje-comparison/morphologies/genesis/gp_pc1.p',
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
						   description => "Is the spine count correct ?",
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
			      ],
       description => "information reporting on loaded models",
       name => 'reporting.t',
      };


return $test;


