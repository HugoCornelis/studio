dnl
dnl The neurospaces studio: a frontend for neurospaces, including a GUI.
dnl

dnl ##########################################################################
dnl 
dnl The neurospaces studio.
dnl 
dnl Copyright (C) 2007 Hugo Cornelis
dnl 
dnl Hugo Cornelis, hugo.cornelis@gmail.com
dnl 
dnl ##########################################################################

# Process this file with autoconf to produce a configure script.

AC_PREREQ(2.59)

# $Format: "AC_INIT(${package}, ${label}, ${email})"$
AC_INIT(studio, i64-4, hugo.cornelis@gmail.com)

AC_CONFIG_SRCDIR([studio_test.pm])

# $Format: "AM_INIT_AUTOMAKE(${package}, ${label})"$
AM_INIT_AUTOMAKE(studio, i64-4)

PERL_EMBED_DATA=`(cd perl ; find . -name "*.pm" -printf "%p ")`
AC_SUBST(PERL_EMBED_DATA)

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

