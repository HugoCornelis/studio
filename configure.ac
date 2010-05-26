dnl
dnl The neurospaces studio: a frontend for neurospaces, including a GUI.
dnl

dnl ##########################################################################
dnl 
dnl The neurospaces studio.
dnl 
dnl Copyright (C) 2007-2008 Hugo Cornelis
dnl 
dnl Hugo Cornelis, hugo.cornelis@gmail.com
dnl 
dnl ##########################################################################

# Process this file with autoconf to produce a configure script.

AC_PREREQ(2.59)

# $Format: "AC_INIT(${package}, ${major}.${minor}.${micro}-${label}, ${email})"$
AC_INIT(studio, 0.0.0-alpha, hugo.cornelis@gmail.com)

AC_CONFIG_SRCDIR([bin/neurospaces])

# $Format: "AM_INIT_AUTOMAKE(${package}, ${major}.${minor}.${micro}-${label})"$
AM_INIT_AUTOMAKE(studio, 0.0.0-alpha)

PERL_MODULES=`(cd perl && find . -name "*.pm" | perl -pe 's/\n/ /g')`
AC_SUBST(PERL_MODULES)

PERL_DATA=`(cd perl && find . -name "numbers-7x11.txt" | perl -pe 's/\n/ /g')`
AC_SUBST(PERL_DATA)

# Checks for programs.

# Checks for libraries.

# Checks for header files.

# Checks for typedefs, structures, and compiler characteristics.

# Checks for library functions.

AC_CONFIG_FILES([Makefile
		 perl/Makefile
		 tests/Makefile
		])

AC_OUTPUT

