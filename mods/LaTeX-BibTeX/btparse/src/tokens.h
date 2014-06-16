#ifndef tokens_h
#define tokens_h
/* tokens.h -- List of labelled tokens and stuff
 *
 * Generated from: bibtex.g
 *
 * Terence Parr, Will Cohen, and Hank Dietz: 1989-2001
 * Purdue University Electrical Engineering
 * ANTLR Version 1.33MR33
 */
#define zzEOF_TOKEN 1
#define AT 2
#define COMMENT 4
#define NUMBER 9
#define NAME 10
#define LBRACE 11
#define RBRACE 12
#define ENTRY_OPEN 13
#define ENTRY_CLOSE 14
#define EQUALS 15
#define HASH 16
#define COMMA 17
#define STRING 25

#ifdef __USE_PROTOS
void bibfile(AST**_root);
#else
extern void bibfile();
#endif

#ifdef __USE_PROTOS
void entry(AST**_root);
#else
extern void entry();
#endif

#ifdef __USE_PROTOS
void body(AST**_root,bt_metatype metatype);
#else
extern void body();
#endif

#ifdef __USE_PROTOS
void contents(AST**_root,bt_metatype metatype);
#else
extern void contents();
#endif

#ifdef __USE_PROTOS
void fields(AST**_root);
#else
extern void fields();
#endif

#ifdef __USE_PROTOS
void field(AST**_root);
#else
extern void field();
#endif

#ifdef __USE_PROTOS
void value(AST**_root);
#else
extern void value();
#endif

#ifdef __USE_PROTOS
void simple_value(AST**_root);
#else
extern void simple_value();
#endif

#endif
extern SetWordType zzerr1[];
extern SetWordType zzerr2[];
extern SetWordType zzerr3[];
extern SetWordType zzerr4[];
extern SetWordType zzerr5[];
extern SetWordType setwd1[];
extern SetWordType zzerr6[];
extern SetWordType setwd2[];
