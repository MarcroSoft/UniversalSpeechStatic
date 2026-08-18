/*
Copyright (c) 2011-2012, Quentin Cosendey
This code is part of universal speech which is under multiple licenses.
Please refer to the readme file provided with the package for more information.
*/
#ifndef _____SRAPI_PRIVATE____
#define _____SRAPI_PRIVATE____

/* Stack allocation of a size only known at run time. The three sites that
   need it used C99 variable-length arrays, which gcc accepts and MSVC has
   never supported in C, so the library would not build with MSVC at all.
   _alloca and alloca are the same thing under different spellings. */
#include <malloc.h>
#if defined(_MSC_VER)
#define SR_STACK_ALLOC(type, count) ((type*)_alloca((count) * sizeof(type)))
#else
#define SR_STACK_ALLOC(type, count) ((type*)alloca((count) * sizeof(type)))
#endif

typedef struct {
const void* name;
int(*isAvailable)(void) ;
int(*say)(const void*, int) ;
int(*stop)(void);
int(*braille)(const void*);
int(*setValue)(int, int) ;
int(*getValue)(int) ;
int(*setString)(int, const void*);
const void*(*getString)(int);
int(*unload)(void);
} engine;

#endif
