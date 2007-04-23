//
// Neurospaces: a library which implements a global typed symbol table to
// be used in neurobiological model maintenance and simulation.
//
// $Id: Neurospaces.h 1.10 Sun, 18 Feb 2007 15:53:33 -0600 hugo $
//

//////////////////////////////////////////////////////////////////////////////
//'
//' Neurospaces : testbed C implementation that integrates with genesis
//'
//' Copyright (C) 1999-2007 Hugo Cornelis
//'
//' functional ideas ..	Hugo Cornelis, hugo.cornelis@gmail.com
//'
//' coding ............	Hugo Cornelis, hugo.cornelis@gmail.com
//'
//////////////////////////////////////////////////////////////////////////////



#ifndef NEUROSPACES_PERL_H
#define NEUROSPACES_PERL_H


#include <EXTERN.h>
#include <perl.h>


//f functions originally implemented for the GUI.

void attachment_to_attachments(char *pcAttachment);

void attachment_to_connections(char *pcAttachment);

int biolevel2biogroup(int iLevel);

int context2serial(char *pcContext);

SV * get_algorithms(char *);

SV * get_children(int iContext);

SV * get_files();

SV * get_generators(char *pcVoid);

SV * get_namespaces(char *pcNamespace);

void get_parameters(int iContext);

SV * get_projections(char *pcVoid);

SV * get_receivers(char *pcVoid);

SV * get_visible_coordinates(int iContext, int iLevel);

SV * get_workload(int iContext, int iNodes, int iLevel);

/* void handle_input(); */

SV * objectify(int iContext);

SV * pq_get();

void pq_set(char *pcLine);

int symboltype2biolevel(int iSymboltype);


//f functions implemented when working on ssp

void ns_new();

void ns_read(SV *args, ...);


#endif


