/*
 * A n t l r  T r a n s l a t i o n  H e a d e r
 *
 * Terence Parr, Will Cohen, and Hank Dietz: 1989-2001
 * Purdue University Electrical Engineering
 * With AHPCRC, University of Minnesota
 * ANTLR Version 1.33MR33
 *
 *   antlr -gt -fe err.c -fh stdpccts.h -fl parser.dlg -ft tokens.h bibtex.g
 *
 */

#define ANTLR_VERSION	13333
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

#include "ast.h"

#define zzSET_SIZE 4
#include "antlr.h"
#include "tokens.h"
#include "dlgdef.h"
#include "mode.h"

/* MR23 In order to remove calls to PURIFY use the antlr -nopurify option */

#ifndef PCCTS_PURIFY
#define PCCTS_PURIFY(r,s) memset((char *) &(r),'\0',(s));
#endif

#include "ast.c"
zzASTgvars

ANTLR_INFO

void
#ifdef __USE_PROTOS
bibfile(AST**_root)
#else
bibfile(_root)
AST **_root;
#endif
{
  zzRULE;
  zzBLOCK(zztasp1);
  zzMake0;
  {
  AST *last; (*_root) = NULL;
  {
    zzBLOCK(zztasp2);
    zzMake0;
    {
    while ( (LA(1)==AT) ) {
      _ast = NULL; entry(&_ast);
      /* a little creative forestry... */
      if ((*_root) == NULL)
      (*_root) = zzastArg(1);
      else
      last->right = zzastArg(1);
      last = zzastArg(1);
      zzLOOP(zztasp2);
    }
    zzEXIT(zztasp2);
    }
  }
  zzEXIT(zztasp1);
  return;
fail:
  zzEXIT(zztasp1);
  zzsyn(zzMissText, zzBadTok, (ANTLRChar *)"", zzMissSet, zzMissTok, zzErrk, zzBadText);
  zzresynch(setwd1, 0x1);
  }
}

void
#ifdef __USE_PROTOS
entry(AST**_root)
#else
entry(_root)
AST **_root;
#endif
{
  zzRULE;
  zzBLOCK(zztasp1);
  zzMake0;
  {
  bt_metatype metatype;
  zzmatch(AT);  zzCONSUME;
  zzmatch(NAME); zzsubroot(_root, &_sibling, &_tail);
  
  metatype = entry_metatype();
  zzastArg(1)->nodetype = BTAST_ENTRY;
  zzastArg(1)->metatype = metatype;
 zzCONSUME;

  body(zzSTR, metatype ); zzlink(_root, &_sibling, &_tail);
  zzEXIT(zztasp1);
  return;
fail:
  zzEXIT(zztasp1);
  zzsyn(zzMissText, zzBadTok, (ANTLRChar *)"", zzMissSet, zzMissTok, zzErrk, zzBadText);
  zzresynch(setwd1, 0x2);
  }
}

void
#ifdef __USE_PROTOS
body(AST**_root,bt_metatype metatype)
#else
body(_root,metatype)
AST **_root;
 bt_metatype metatype ;
#endif
{
  zzRULE;
  zzBLOCK(zztasp1);
  zzMake0;
  {
  if ( (LA(1)==STRING) ) {
    if (!(metatype == BTE_COMMENT )      ) {zzfailed_pred("   metatype == BTE_COMMENT ",0 /* report */, { 0; /* no user action */ } );}
    zzmatch(STRING); zzsubchild(_root, &_sibling, &_tail);
    zzastArg(1)->nodetype = BTAST_STRING;
 zzCONSUME;

  }
  else {
    if ( (LA(1)==ENTRY_OPEN) ) {
      zzmatch(ENTRY_OPEN);  zzCONSUME;
      contents(zzSTR, metatype ); zzlink(_root, &_sibling, &_tail);
      zzmatch(ENTRY_CLOSE);  zzCONSUME;
    }
    else {zzFAIL(1,zzerr1,&zzMissSet,&zzMissText,&zzBadTok,&zzBadText,&zzErrk); goto fail;}
  }
  zzEXIT(zztasp1);
  return;
fail:
  zzEXIT(zztasp1);
  zzsyn(zzMissText, zzBadTok, (ANTLRChar *)"", zzMissSet, zzMissTok, zzErrk, zzBadText);
  zzresynch(setwd1, 0x4);
  }
}

void
#ifdef __USE_PROTOS
contents(AST**_root,bt_metatype metatype)
#else
contents(_root,metatype)
AST **_root;
 bt_metatype metatype ;
#endif
{
  zzRULE;
  zzBLOCK(zztasp1);
  zzMake0;
  {
  if ( (setwd1[LA(1)]&0x8)&&(metatype == BTE_REGULAR /* || metatype == BTE_MODIFY */ ) ) {
    if (!(metatype == BTE_REGULAR /* || metatype == BTE_MODIFY */ )      ) {zzfailed_pred("   metatype == BTE_REGULAR /* || metatype == BTE_MODIFY */ ",0 /* report */, { 0; /* no user action */ } );}
    {
      zzBLOCK(zztasp2);
      zzMake0;
      {
      if ( (LA(1)==NAME) ) {
        zzmatch(NAME); zzsubchild(_root, &_sibling, &_tail); zzCONSUME;
      }
      else {
        if ( (LA(1)==NUMBER) ) {
          zzmatch(NUMBER); zzsubchild(_root, &_sibling, &_tail); zzCONSUME;
        }
        else {zzFAIL(1,zzerr2,&zzMissSet,&zzMissText,&zzBadTok,&zzBadText,&zzErrk); goto fail;}
      }
      zzEXIT(zztasp2);
      }
    }
    zzastArg(1)->nodetype = BTAST_KEY;
    zzmatch(COMMA);  zzCONSUME;
    fields(zzSTR); zzlink(_root, &_sibling, &_tail);
  }
  else {
    if ( (setwd1[LA(1)]&0x10)&&(metatype == BTE_MACRODEF ) ) {
      if (!(metatype == BTE_MACRODEF )        ) {zzfailed_pred("   metatype == BTE_MACRODEF ",0 /* report */, { 0; /* no user action */ } );}
      fields(zzSTR); zzlink(_root, &_sibling, &_tail);
    }
    else {
      if ( (setwd1[LA(1)]&0x20)&&(metatype == BTE_PREAMBLE ) ) {
        if (!(metatype == BTE_PREAMBLE )          ) {zzfailed_pred("   metatype == BTE_PREAMBLE ",0 /* report */, { 0; /* no user action */ } );}
        value(zzSTR); zzlink(_root, &_sibling, &_tail);
      }
      else {zzFAIL(1,zzerr3,&zzMissSet,&zzMissText,&zzBadTok,&zzBadText,&zzErrk); goto fail;}
    }
  }
  zzEXIT(zztasp1);
  return;
fail:
  zzEXIT(zztasp1);
  zzsyn(zzMissText, zzBadTok, (ANTLRChar *)"", zzMissSet, zzMissTok, zzErrk, zzBadText);
  zzresynch(setwd1, 0x40);
  }
}

void
#ifdef __USE_PROTOS
fields(AST**_root)
#else
fields(_root)
AST **_root;
#endif
{
  zzRULE;
  zzBLOCK(zztasp1);
  zzMake0;
  {
  if ( (LA(1)==NAME) ) {
    field(zzSTR); zzlink(_root, &_sibling, &_tail);
    {
      zzBLOCK(zztasp2);
      zzMake0;
      {
      if ( (LA(1)==COMMA) ) {
        zzmatch(COMMA);  zzCONSUME;
        fields(zzSTR); zzlink(_root, &_sibling, &_tail);
      }
      else {
        if ( (LA(1)==ENTRY_CLOSE) ) {
        }
        else {zzFAIL(1,zzerr4,&zzMissSet,&zzMissText,&zzBadTok,&zzBadText,&zzErrk); goto fail;}
      }
      zzEXIT(zztasp2);
      }
    }
  }
  else {
    if ( (LA(1)==ENTRY_CLOSE) ) {
    }
    else {zzFAIL(1,zzerr5,&zzMissSet,&zzMissText,&zzBadTok,&zzBadText,&zzErrk); goto fail;}
  }
  zzEXIT(zztasp1);
  return;
fail:
  zzEXIT(zztasp1);
  zzsyn(zzMissText, zzBadTok, (ANTLRChar *)"", zzMissSet, zzMissTok, zzErrk, zzBadText);
  zzresynch(setwd1, 0x80);
  }
}

void
#ifdef __USE_PROTOS
field(AST**_root)
#else
field(_root)
AST **_root;
#endif
{
  zzRULE;
  zzBLOCK(zztasp1);
  zzMake0;
  {
  zzmatch(NAME); zzsubroot(_root, &_sibling, &_tail);
  zzastArg(1)->nodetype = BTAST_FIELD; check_field_name (zzastArg(1));
 zzCONSUME;

  zzmatch(EQUALS);  zzCONSUME;
  value(zzSTR); zzlink(_root, &_sibling, &_tail);
  
#if DEBUG > 1
  printf ("field: fieldname = %p (%s)\n"
  "       first val = %p (%s)\n",
  zzastArg(1)->text, zzastArg(1)->text, zzastArg(2)->text, zzastArg(2)->text);
#endif
  zzEXIT(zztasp1);
  return;
fail:
  zzEXIT(zztasp1);
  zzsyn(zzMissText, zzBadTok, (ANTLRChar *)"", zzMissSet, zzMissTok, zzErrk, zzBadText);
  zzresynch(setwd2, 0x1);
  }
}

void
#ifdef __USE_PROTOS
value(AST**_root)
#else
value(_root)
AST **_root;
#endif
{
  zzRULE;
  zzBLOCK(zztasp1);
  zzMake0;
  {
  simple_value(zzSTR); zzlink(_root, &_sibling, &_tail);
  {
    zzBLOCK(zztasp2);
    zzMake0;
    {
    while ( (LA(1)==HASH) ) {
      zzmatch(HASH);  zzCONSUME;
      simple_value(zzSTR); zzlink(_root, &_sibling, &_tail);
      zzLOOP(zztasp2);
    }
    zzEXIT(zztasp2);
    }
  }
  zzEXIT(zztasp1);
  return;
fail:
  zzEXIT(zztasp1);
  zzsyn(zzMissText, zzBadTok, (ANTLRChar *)"", zzMissSet, zzMissTok, zzErrk, zzBadText);
  zzresynch(setwd2, 0x2);
  }
}

void
#ifdef __USE_PROTOS
simple_value(AST**_root)
#else
simple_value(_root)
AST **_root;
#endif
{
  zzRULE;
  zzBLOCK(zztasp1);
  zzMake0;
  {
  if ( (LA(1)==STRING) ) {
    zzmatch(STRING); zzsubchild(_root, &_sibling, &_tail);
    zzastArg(1)->nodetype = BTAST_STRING;
 zzCONSUME;

  }
  else {
    if ( (LA(1)==NUMBER) ) {
      zzmatch(NUMBER); zzsubchild(_root, &_sibling, &_tail);
      zzastArg(1)->nodetype = BTAST_NUMBER;
 zzCONSUME;

    }
    else {
      if ( (LA(1)==NAME) ) {
        zzmatch(NAME); zzsubchild(_root, &_sibling, &_tail);
        zzastArg(1)->nodetype = BTAST_MACRO;
 zzCONSUME;

      }
      else {zzFAIL(1,zzerr6,&zzMissSet,&zzMissText,&zzBadTok,&zzBadText,&zzErrk); goto fail;}
    }
  }
  zzEXIT(zztasp1);
  return;
fail:
  zzEXIT(zztasp1);
  zzsyn(zzMissText, zzBadTok, (ANTLRChar *)"", zzMissSet, zzMissTok, zzErrk, zzBadText);
  zzresynch(setwd2, 0x4);
  }
}
