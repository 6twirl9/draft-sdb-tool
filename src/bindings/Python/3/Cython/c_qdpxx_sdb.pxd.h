
#include "c_qdp++_sdb.h"

@PYTHON

cdef extern from "c_qdp++_sdb.h":

 ctypedef struct VARARRAY_char:
  int  n
  char *_

 ctypedef struct VARARRAY_int:
  int  n
  int  *_

 ctypedef struct C_QDPXX_SDB(SDB_VALUE):
  int  n
  double *_

 ctypedef struct C_QDPXX_SDB(SDB_KEY):
  VARARRAY_char snk_name, snk_smear, src_name, src_smear
  VARARRAY_int  src_lorentz, snk_lorentz, mom

 ctypedef struct C_QDPXX_SDB(SDB_KEY_VALUE):
  C_QDPXX_SDB(SDB_KEY)   key ;
  C_QDPXX_SDB(SDB_VALUE) value ;

 ctypedef struct C_QDPXX_SDB(SDB_KEY_VALUE_VARARRAY):
  int n
  C_QDPXX_SDB(SDB_KEY_VALUE) *_

 void c_qdpxx_sdb(sdb_validate)    ( char * sdb_file_cstr )
 void c_qdpxx_sdb(sdb_spy)         ( char * sdb_file_cstr )
 void c_qdpxx_sdb(sdb_dump)        ( char *sdb_file_cstr, C_QDPXX_SDB(SDB_KEY_VALUE_VARARRAY) *result, int verbose )

 void c_qdpxx_sdb(sdb_wipe)        ( C_QDPXX_SDB(SDB_KEY_VALUE_VARARRAY) *result )
 void c_qdpxx_sdb(sdb_pretty_print)( C_QDPXX_SDB(SDB_KEY_VALUE_VARARRAY) *result )

