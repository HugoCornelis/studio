##
## Neurospaces studio: a tool set for use with Neurospaces.
##

##############################################################################
##'
##' Neurospaces studio: a tool set for use with Neurospaces.
##'
##' Copyright (C) 1999-2007 Hugo Cornelis, hugo.cornelis@gmail.com
##'
##############################################################################

SUBDIRS = perl tests

dist_bin_SCRIPTS = bin/neurospaces

#check_SCRIPTS = $(srcdir)/tests/run

#TESTS = $(srcdir)/tests/run

perl_HEADERS = studio_test.pm

#TESTS = studio_test.pm

test: check

#html-upload-prepare:
#	rm -fr html/htdocs/neurospaces_project/neurospaces
#	mkdir --parents html/htdocs/neurospaces_project/neurospaces
## $Format: "	( cd tests && ./tests_2_html --header '<img src=\"ns-main-logo-dark2-notext-32x32.jpg\" alt=\"Main Neurospaces logo\"> $ProjectHeader$<hr>' )" $
#	( cd tests && ./tests_2_html --header '<img src="ns-main-logo-dark2-notext-32x32.jpg" alt="Main Neurospaces logo"> neurospaces 0.1042 Sun, 22 Apr 2007 20:42:55 -0500 hugo<hr>' )
#	tar cfh - tests/html | ( cd html/htdocs/neurospaces_project/neurospaces && tar vxf - )

#html-upload: html-upload-prepare
#	scp -pr html/htdocs/* hcornelis@shell.sourceforge.net:/home/groups/n/ne/neurospaces/htdocs/

perldir = $(prefix)/glue/swig/perl

nobase_perl_DATA = \
	studio_test.pm 

