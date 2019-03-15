
#define C_QDPXX_SDB(_) C_QDPXX_##_
#define c_qdpxx_sdb(_) c_qdpxx_##_

#define VARARRAY(_type_) struct { int n ; _type_* _ ; }

typedef struct
{
 VARARRAY(char)

   snk_name
 , snk_smear
 , src_name
 , src_smear ;

 VARARRAY(int)

   src_lorentz
 , snk_lorentz
 , mom  ;

} C_QDPXX_SDB(SDB_KEY) ;

typedef

 VARARRAY(double)

  C_QDPXX_SDB(SDB_VALUE) ;

typedef struct
{

 C_QDPXX_SDB(SDB_KEY)   key ;
 C_QDPXX_SDB(SDB_VALUE) value ;

} C_QDPXX_SDB(SDB_KEY_VALUE) ;

#ifdef __cplusplus
extern "C"
{
#endif

typedef

 VARARRAY(C_QDPXX_SDB(SDB_KEY_VALUE))

  C_QDPXX_SDB(SDB_KEY_VALUE_VARARRAY) ;

void c_qdpxx_sdb(sdb_validate)    ( char* sdb_file_cstr ) ;
void c_qdpxx_sdb(sdb_spy)         ( char* sdb_file_cstr ) ;
void c_qdpxx_sdb(sdb_dump)        ( char* sdb_file_cstr, C_QDPXX_SDB(SDB_KEY_VALUE_VARARRAY)* result, int verbose ) ;
void c_qdpxx_sdb(sdb_wipe)        (                      C_QDPXX_SDB(SDB_KEY_VALUE_VARARRAY)* result ) ;
void c_qdpxx_sdb(sdb_pretty_print)(                      C_QDPXX_SDB(SDB_KEY_VALUE_VARARRAY)* result ) ;

#ifdef __cplusplus
}
#endif

