#ifndef STDPCCTS_H
#define STDPCCTS_H
/*
 * stdpccts.h -- P C C T S  I n c l u d e
 *
 * Terence Parr, Will Cohen, and Hank Dietz: 1989-2001
 * Purdue University Electrical Engineering
 * With AHPCRC, University of Minnesota
 * ANTLR Version 1.33MR33
 */

#ifndef ANTLR_VERSION
#define ANTLR_VERSION	13333
#endif

#include "pcctscfg.h"
#include "pccts_stdio.h"

#define ZZCOL
#define USER_ZZSYN

#include "config.h"
#include "btparse.h"
#include "attrib.h"
#include "lex_auxiliary.h"
#include "error.h"
#include "my_dmalloc.h"

extern char * InputFilename;            /* for zzcr_ast call in pccts/ast.c */
#define GENAST
#define zzSET_SIZE 4
#include "antlr.h"
#include "ast.h"
#include "tokens.h"
#include "dlgdef.h"
#include "mode.h"
#endif
