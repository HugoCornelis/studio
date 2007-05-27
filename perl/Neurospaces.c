//
// Neurospaces: a library which implements a global typed symbol table to
// be used in neurobiological model maintenance and simulation.
//
// $Id: Neurospaces.c 1.31 Sun, 18 Feb 2007 15:53:33 -0600 hugo $
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


#include <EXTERN.h>
#include <perl.h>

#include "Neurospaces.h"

#include "neurospaces/br2p.h"
#include "neurospaces/biolevel.h"
#include "neurospaces/defsym.h"
#include "neurospaces/dependencyfile.h"
#include "neurospaces/importedfile.h"
#include "neurospaces/iohier.h"
#include "neurospaces/namespace.h"
#include "neurospaces/neurospaces.h"
#include "neurospaces/pidinstack.h"
#include "neurospaces/projectionquery.h"
#include "neurospaces/querymachine.h"
#include "neurospaces/symbols.h"
/* #include "neurospaces/symboltable.h" */


//d size hack

#define SIZE_COMMANDLINE	1000


//f functions originally implemented for the GUI.

void attachment_to_connections(char *pcAttachment)
{
    //- attachment context

    struct PidinStack *ppistAttachment = PidinStackParse(pcAttachment);

    struct symtab_HSolveListElement *phsleAttachment = PidinStackLookupTopSymbol(ppistAttachment);

    printf("Getting attachments for %s\n", pcAttachment);

    extern struct Neurospaces *pneuroGlobal;

    AV * pavReceivers = br2p_attachment_to_attachments_2_array(my_perl, pneuroGlobal, phsleAttachment, ppistAttachment);

    Inline_Stack_Vars;
    Inline_Stack_Reset;

#define ARRAY
#ifdef ARRAY

    I32 iMax = av_len(pavReceivers);

    I32 i;

    for (i = 0; i <= iMax; i++)
    {
	SV **ppsvReceiver = av_fetch(pavReceivers, i, 0);

	Inline_Stack_Push(*ppsvReceiver);
    }

#else

    SV * psvReceivers = newRV_noinc((SV *)pavReceivers);

    Inline_Stack_Push(psvReceivers);

#endif

    Inline_Stack_Done;
}


int biolevel2biogroup(int iLevel)
{
    int iResult = Biolevel2Biolevelgroup(iLevel);

    return iResult;
}


int context2serial(char *pcContext)
{
    struct PidinStack *ppist = PidinStackParse(pcContext);

    struct symtab_HSolveListElement *phsle = PidinStackLookupTopSymbol(ppist);

    int iResult = PidinStackToSerial(ppist);

    return iResult;
}


SV * get_algorithms(char *pcVoid)
{
    extern struct Neurospaces *pneuroGlobal;

    struct Neurospaces *pneuro = pneuroGlobal;

    if (!pneuroGlobal)
    {
	printf("pneuroGlobal\n");
    }

    //- create result

    AV * pavResult = br2p_algorithms_2_array(my_perl, pneuroGlobal);

    SV * psvResult = newRV_noinc((SV *)pavResult);

    return(psvResult);
}


SV * get_children(int iContext)
{
    //- root context

    struct PidinStack *ppistRoot = PidinStackParse("/");

    struct symtab_HSolveListElement *phsleRoot = PidinStackLookupTopSymbol(ppistRoot);

    if (!phsleRoot)
    {
	return(NULL);
    }

    //- get context

    struct PidinStack *ppistContext
	= SymbolPrincipalSerial2Context(phsleRoot,ppistRoot,iContext);

    //- get symbol under consideration

    struct symtab_HSolveListElement *phsleContext = PidinStackLookupTopSymbol(ppistContext);

    if (!phsleContext)
    {
	PidinStackFree(ppistRoot);

	ppistRoot = NULL;

	PidinStackFree(ppistContext);

	ppistContext = NULL;

	printf("Unable to find this symbol, lookup failed (internal error).\n");

	return;
    }

    char pcContext[1000];

    PidinStackString(ppistContext,pcContext,1000);

    printf("Getting children from %s\n", pcContext);

    AV * pavChildren = br2p_children_2_array(my_perl, phsleContext, ppistContext);

    //- free allocated memory

    PidinStackFree(ppistRoot);

    PidinStackFree(ppistContext);

    //- return result

    SV * psvResult = newRV_noinc((SV *)pavChildren);

    return(psvResult);
}


SV * get_files()
{
    //- create result

    AV * pavResult = newAV();

    SV * psvResult = newRV_noinc((SV *)pavResult);

    //- get globally registered projection query

    extern struct Neurospaces *pneuroGlobal;

    struct Neurospaces *pneuro = pneuroGlobal;

    if (!pneuroGlobal)
    {
	printf("pneuroGlobal\n");
    }

    //m symbol table

    struct Symbols *pisSymbols = pneuroGlobal->psym;

    //- loop over the imported files

    struct ImportedFile *pifLoop
	= (struct ImportedFile *)
	  HSolveListHead(&pisSymbols->hslFiles);

    while (HSolveListValidSucc(&pifLoop->hsleLink))
    {
	//- get name of file

	SV * psvFilename = newSVpv(pifLoop->pcFilename, 0);

	//- add to result

	av_push(pavResult, psvFilename);

	//- go to next imported file

	pifLoop = (struct ImportedFile *)HSolveListNext(&pifLoop->hsleLink);
    }

    //- return result

    return psvResult;
}


SV * get_generators(char *pcVoid)
{
    //- root context

    struct PidinStack *ppistRoot = PidinStackParse("/");

    struct symtab_HSolveListElement *phsleRoot = PidinStackLookupTopSymbol(ppistRoot);

    if (!phsleRoot)
    {
	return(NULL);
    }

    printf("Getting all generators\n");

    AV * pavGenerators = br2p_generators_2_array(my_perl, phsleRoot, ppistRoot);

    //- free allocated memory

    PidinStackFree(ppistRoot);

    //- return result

    SV * psvResult = newRV_noinc((SV *)pavGenerators);

    return(psvResult);
}


SV * get_namespaces(char *pcNamespace)
{
    //- create result

    AV * pavResult = newAV();

    //- get globally registered projection query

    extern struct Neurospaces *pneuroGlobal;

    struct Neurospaces *pneuro = pneuroGlobal;

    if (!pneuroGlobal)
    {
	printf("pneuroGlobal\n");
    }

    //- parse command line element

    struct PidinStack *ppist = PidinStackParse(pcNamespace);

    //- find namespace

    struct ImportedFile *pif = SymbolsLookupNameSpace(pneuro->psym, ppist);

    //- if found

    if (pif)
    {
	//- get pointer to defined symbols in imported file

	struct DefinedSymbols *pdefsym
	    = ImportedFileGetDefinedSymbols(pif);

	//- loop over dependency files

	struct DependencyFile *pdf
	    = (struct DependencyFile *)
	      HSolveListHead(&pdefsym->hslDependencyFiles);

	if (HSolveListValidSucc(&pdf->hsleLink))
	{
	    while (HSolveListValidSucc(&pdf->hsleLink))
	    {
		//- get filename, namespace

		char *pcFilename = ImportedFileGetFilename(DependencyFileGetImportedFile(pdf));
		char *pcNamespace = DependencyFileGetNameSpace(pdf);

		//- put in result hash

		SV * psvFilename = newSVpv(pcFilename, 0);
		SV * psvNamespace = newSVpv(pcNamespace, 0);

		HV * phvDependencyFile = newHV();

		hv_store(phvDependencyFile, "filename", 8, psvFilename, 0);
		hv_store(phvDependencyFile, "namespace", 9, psvNamespace, 0);

		SV * psvDependencyFile = newRV_noinc((SV *)phvDependencyFile);

		av_push(pavResult, psvDependencyFile);

		//- goto next dependency file

		pdf = (struct DependencyFile *)HSolveListNext(&pdf->hsleLink);
	    }
	}
	else
	{
	    fprintf(stdout,"No namespaces\n");
	}

    }

    //- else

    else
    {
	//- diag's

	fprintf(stdout,"no imported file with given namespace found\n");
    }

    //- free allocated memory

    PidinStackFree(ppist);

    //- return result

    SV * psvResult = newRV_noinc((SV *)pavResult);

    return psvResult;
}


void get_parameters(int iContext)
{
    //- root context

    struct PidinStack *ppistRoot = PidinStackParse("/");

    struct symtab_HSolveListElement *phsleRoot = PidinStackLookupTopSymbol(ppistRoot);

    if (!phsleRoot)
    {
	return/* (NULL) */;
    }

    //- get context

    struct PidinStack *ppistContext
	= SymbolPrincipalSerial2Context(phsleRoot,ppistRoot,iContext);

    PidinStackFree(ppistRoot);

    ppistRoot = NULL;

    //- get symbol under consideration

    struct symtab_HSolveListElement *phsleContext = PidinStackLookupTopSymbol(ppistContext);

    if (!phsleContext)
    {
	PidinStackFree(ppistRoot);

	ppistRoot = NULL;

	PidinStackFree(ppistContext);

	ppistContext = NULL;

	printf("Unable to find this symbol, lookup failed (internal error).\n");

	return;
    }

    char pcContext[1000];

    PidinStackString(ppistContext,pcContext,1000);

    printf("Getting parameters from %s\n", pcContext);

    AV * pavParameters = br2p_parameters_2_array(my_perl, phsleContext, ppistContext);

    Inline_Stack_Vars;
    Inline_Stack_Reset;

#define ARRAY
#ifdef ARRAY

    I32 iMax = av_len(pavParameters);

    I32 i;

    for (i = 0; i <= iMax; i++)
    {
	SV **ppsvParameter = av_fetch(pavParameters, i, 0);

	Inline_Stack_Push(*ppsvParameter);
    }

#else

    SV * psvParameters = newRV_noinc((SV *)pavParameters);

    Inline_Stack_Push(psvParameters);

#endif

    Inline_Stack_Done;

    PidinStackFree(ppistRoot);

    ppistRoot = NULL;

    PidinStackFree(ppistContext);

    ppistContext = NULL;
}


SV * get_projections(char *pcVoid)
{
    //- root context

    struct PidinStack *ppistRoot = PidinStackParse("/");

    struct symtab_HSolveListElement *phsleRoot = PidinStackLookupTopSymbol(ppistRoot);

    if (!phsleRoot)
    {
	return(NULL);
    }

    printf("Getting all projections\n");

    AV * pavProjections = br2p_projections_2_array(my_perl, phsleRoot, ppistRoot);

    //- free allocated memory

    PidinStackFree(ppistRoot);

    //- return result

    SV * psvResult = newRV_noinc((SV *)pavProjections);

    return(psvResult);
}


SV * get_receivers(char *pcVoid)
{
    //- root context

    struct PidinStack *ppistRoot = PidinStackParse("/");

    struct symtab_HSolveListElement *phsleRoot = PidinStackLookupTopSymbol(ppistRoot);

    if (!phsleRoot)
    {
	return(NULL);
    }

    printf("Getting all receivers\n");

    AV * pavReceivers = br2p_receivers_2_array(my_perl, phsleRoot, ppistRoot);

    //- free allocated memory

    PidinStackFree(ppistRoot);

    //- return result

    SV * psvResult = newRV_noinc((SV *)pavReceivers);

    return(psvResult);
}


SV * get_visible_coordinates(int iContext, int iLevel)
{
    //- root context

    struct PidinStack *ppistRoot = PidinStackParse("/");

    struct symtab_HSolveListElement *phsleRoot = PidinStackLookupTopSymbol(ppistRoot);

    if (!phsleRoot)
    {
	return(NULL);
    }

    //- get context

    struct PidinStack *ppistContext
	= SymbolPrincipalSerial2Context(phsleRoot,ppistRoot,iContext);

    //- get symbol under consideration

    struct symtab_HSolveListElement *phsleContext = PidinStackLookupTopSymbol(ppistContext);

    if (!phsleContext)
    {
	PidinStackFree(ppistRoot);

	ppistRoot = NULL;

	PidinStackFree(ppistContext);

	ppistContext = NULL;

	printf("Unable to find this symbol, lookup failed (internal error).\n");

	return;
    }

    char pcContext[1000];

    PidinStackString(ppistContext,pcContext,1000);

    printf("Getting children from %s\n", pcContext);

    AV * pavCoordinates = br2p_coordinates_2_array(my_perl, phsleContext, ppistContext, iLevel);

    //- free allocated memory

    PidinStackFree(ppistRoot);

    PidinStackFree(ppistContext);

    //- return result

    SV * psvResult = newRV_noinc((SV *)pavCoordinates);

    return(psvResult);
}


SV * get_workload(int iContext, int iNodes, int iLevel)
{
    //- root context

    struct PidinStack *ppistRoot = PidinStackParse("/");

    struct symtab_HSolveListElement *phsleRoot = PidinStackLookupTopSymbol(ppistRoot);

    if (!phsleRoot)
    {
	return(NULL);
    }

    //- get context

    struct PidinStack *ppistContext
	= SymbolPrincipalSerial2Context(phsleRoot,ppistRoot,iContext);

    //- get symbol under consideration

    struct symtab_HSolveListElement *phsleContext = PidinStackLookupTopSymbol(ppistContext);

    if (!phsleContext)
    {
	PidinStackFree(ppistRoot);

	ppistRoot = NULL;

	PidinStackFree(ppistContext);

	ppistContext = NULL;

	printf("Unable to find this symbol, lookup failed (internal error).\n");

	return;
    }

    char pcContext[1000];

    PidinStackString(ppistContext,pcContext,1000);

    printf("Getting workload for %s\n", pcContext);

    AV * pavWorkload = br2p_workload(my_perl, phsleContext, ppistContext, iNodes, iLevel);

    printf("Done workload for %s, %i entries\n", pcContext, av_len(pavWorkload));

    //- free allocated memory

    PidinStackFree(ppistRoot);

    PidinStackFree(ppistContext);

    //- return result

    SV * psvResult = newRV_noinc((SV *)pavWorkload);

    return(psvResult);
}


/* void handle_input() */
/* { */
/*     //v user command line */

/*     char pcCommandLine[SIZE_COMMANDLINE]; */

/*     //- accept input */

/*     QueryMachineInput(pcCommandLine); */

/*     extern struct Neurospaces *pneuroGlobal; */

/*     int bEOF = QueryMachineHandle(pcCommandLine, pneuroGlobal); */
/* } */


SV * objectify(int iContext)
{
    //- root context

    struct PidinStack *ppistRoot = PidinStackParse("/");

    struct symtab_HSolveListElement *phsleRoot = PidinStackLookupTopSymbol(ppistRoot);

    if (!phsleRoot)
    {
	return(NULL);
    }

    //- get context

    struct PidinStack *ppistContext
	= SymbolPrincipalSerial2Context(phsleRoot,ppistRoot,iContext);

    //- get symbol under consideration

    struct symtab_HSolveListElement *phsleContext = PidinStackLookupTopSymbol(ppistContext);

    if (!phsleContext)
    {
	PidinStackFree(ppistRoot);

	ppistRoot = NULL;

	printf("Unable to find this symbol, lookup failed (internal error).\n");

	return &PL_sv_undef;
    }

    //- get serial of parent

    int iParent = iContext - SymbolGetPrincipalSerialToParent(phsleContext);

    //- construct perl value with serial

    SV * psvSerial = newSViv(iContext);

    //- construct perl value with parent serial

    SV * psvParent = newSViv(iParent);

    //- construct string with context

    char pcContext[10000];

    PidinStackString(ppistContext, pcContext, 10000);

    SV * psvContext = newSVpv(pcContext, 0);

    //- construct string with type

    SV * psvType = newSVpv(ppc_symbols_long_descriptions[phsleContext->iType], 0);

/*     fprintf(stdout, "Type is %s\n", ppc_symbols_long_descriptions[phsleContext->iType]); */

    //- create result

    HV * phvResult = newHV();

    hv_store(phvResult, "context", 7, psvContext, 0);
    hv_store(phvResult, "parent", 6, psvParent, 0);
    hv_store(phvResult, "this", 4, psvSerial, 0);
    hv_store(phvResult, "type", 4, psvType, 0);

    PidinStackFree(ppistRoot);

    ppistRoot = NULL;

    PidinStackFree(ppistContext);

    ppistContext = NULL;

    SV * psvResult = newRV_noinc((SV *)phvResult);

    return psvResult;
}


SV * pq_get()
{
    //- create result

    HV * phvResult = newHV();

    SV * psvResult = newRV_noinc((SV *)phvResult);

    //- get globally registered projection query

    extern struct Neurospaces *pneuroGlobal;

    struct Neurospaces *pneuro = pneuroGlobal;

    if (!pneuroGlobal)
    {
	printf("pneuroGlobal\n");
    }

    struct ProjectionQuery *ppq = pneuro->ppq;

    if (!ppq)
    {
	printf("No projectionquery defined yet.\n");

	return(psvResult);
    }

    //- loop over projections

    AV * pavProjections = newAV();

    SV * psvProjections = newRV_noinc((SV *)pavProjections);

    int i;

    for (i = 0 ; i < ppq->iProjections ; i++)
    {
	//- create a hash for the current projection

	HV * phvProjection = newHV();

	//- context of this projection

	char pcContext[1000];

	PidinStackString(ppq->pppist[i], pcContext, 1000);

	SV * psvContext = newSVpv(pcContext, 0);

	hv_store(phvProjection, "context", 7, psvContext, 0);

	//- get serial

	int iSerial = PidinStackToSerial(ppq->pppist[i]);

	SV * psvSerial = newSViv(iSerial);

	hv_store(phvProjection, "serial", 6, psvSerial, 0);

	//- source of this projection

	SV * psvSource = newSViv(ppq->piSource[i]);

	hv_store(phvProjection, "source", 6, psvSource, 0);

	//- target of this projection

	SV * psvTarget = newSViv(ppq->piTarget[i]);

	hv_store(phvProjection, "target", 6, psvTarget, 0);

	//- add projection info to result

	SV * psvProjection = newRV_noinc((SV *)phvProjection);

	av_push(pavProjections, psvProjection);
    }

    //- create a hash for the cache

    HV * phvCache = newHV();

    SV * psvCache = newRV_noinc((SV *)phvCache);

    //- deal with caching entries

    if (ppq->bCaching)
    {
	//m connection cache

	struct ConnectionCache *pcc;

	//m connection cache sorted on pre synaptic principal

	struct OrderedConnectionCache *poccPre;

	//m connection cache sorted on post synaptic principal

	struct OrderedConnectionCache *poccPost;
    }

    //- store everything in the result

    hv_store(phvResult, "cache", 7, psvCache, 0);
/*     hv_store(phvResult, "connections", 11, psvConnections, 0); */
    hv_store(phvResult, "projections", 11, psvProjections, 0);

    //- return result

    return psvResult;
}


void pq_set(char *pcLine)
{
    extern struct Neurospaces *pneuroGlobal;

    int bEOF = QueryMachineHandle(pcLine, pneuroGlobal);
}



int symboltype2biolevel(int iType)
{
    int iResult = SymbolType2Biolevel(iType);

    return iResult;
}


//f functions implemented when working on ssp

void ns_new()
{
    extern struct Neurospaces *pneuroGlobal;

    pneuroGlobal = NeurospacesNew();
}


void ns_read(SV *args, ...)
{
    Inline_Stack_Vars;

    int argc;

    char **argv = (char **)calloc(100, sizeof(char *));

    int i;

    for (i = 0; i < Inline_Stack_Items; i++) 
    {
	argv[i] = SvPV(Inline_Stack_Item(i), PL_na);
    }

    Inline_Stack_Void;

    argc = i;

    argv[argc] = NULL;

    extern struct Neurospaces *pneuroGlobal;

    int iResult = NeurospacesRead(pneuroGlobal, argc, argv);

    free(argv);
}


