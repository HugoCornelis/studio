##
## Neurospaces: a library which implements a global typed symbol table to
## be used in neurobiological model maintenance and simulation.
##
## $Id: Makefile.am 1.152 Sun, 22 Apr 2007 20:42:55 -0500 hugo $
##

##############################################################################
##'
##' Neurospaces : testbed C implementation that integrates with genesis
##'
##' Copyright (C) 1999-2007 Hugo Cornelis
##'
##' functional ideas ..	Hugo Cornelis, hugo.cornelis@gmail.com
##'
##' coding ............	Hugo Cornelis, hugo.cornelis@gmail.com
##'
##############################################################################

SUBDIRS = perl

dist_bin_SCRIPTS = bin/neurospaces

#check_SCRIPTS = $(srcdir)/tests/run

#TESTS = $(srcdir)/tests/run

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

