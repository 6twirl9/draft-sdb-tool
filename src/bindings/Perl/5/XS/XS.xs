#define PERL_NO_GET_CONTEXT
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include <stdio.h>
#include <string.h>

#include "ppport.h"

#include "c_qdp++_sdb.h"

// === hash set macros

#define set_hash_value_array_of_real(href,mom)		\
do{							\
 AV *aref = (AV*) sv_2mortal((SV*)newAV()) ;		\
 for(int i1 = 0 ; i1 < (dump->_)[i0].value.n ; i1 ++ )	\
 {							\
  av_push( aref, newSVnv((dump->_)[i0].value._[i1]) ) ;	\
 }							\
 hv_store(href,#mom,strlen(#mom),newRV((SV*)aref),0) ;	\
}while(0)

#define set_hash_key_array_of_real(href,mom)		\
do{							\
 AV *aref = (AV*) sv_2mortal((SV*)newAV()) ;		\
 for(int i1 = 0 ; i1 < (dump->_)[i0].key.mom.n ; i1 ++ )	\
 {							\
  av_push( aref, newSVnv((dump->_)[i0].key.mom._[i1]) ) ;	\
 }							\
 hv_store(href,#mom,strlen(#mom),newRV((SV*)aref),0) ;	\
}while(0)

#define set_hash_key_array_of_int(href,mom)		\
do{							\
 AV *aref = (AV*) sv_2mortal((SV*)newAV()) ;		\
 for(int i1 = 0 ; i1 < (dump->_)[i0].key.mom.n ; i1 ++ )	\
 {							\
  av_push( aref, newSViv((dump->_)[i0].key.mom._[i1]) ) ;	\
 }							\
 hv_store(href,#mom,strlen(#mom),newRV((SV*)aref),0) ;	\
}while(0)

#define set_hash_key_string(href,mom)			\
do{							\
 STRLEN len ;						\
 SV *sref = newSVpv((dump->_)[i0].key.mom._,len) ;		\
 hv_store(href,#mom,strlen(#mom),sref,0) ;	\
}while(0)

#define set_hash_key_array_of_string(href,mom)		\
do{							\
 AV *aref = (AV*) sv_2mortal((SV*)newAV()) ;		\
 {							\
  STRLEN len ;						\
  av_push( aref, newSVpv((dump->_)[i0].key.mom._,len) ) ;	\
 }							\
 hv_store(href,#mom,strlen(#mom),newRV((SV*)aref),0) ;	\
}while(0)
///

#define HV_FETCH(ret,hash,key) SV **const ret = hv_fetch((HV*)SvRV(hash),#key,strlen(#key),0)

MODULE = NPLQCD::File::Format::SDB::XS		PACKAGE = NPLQCD::File::Format::SDB::XS		

void
c_qdpxx_sdb_validate(param)
 SV * param ;
INIT:
 char *sdb_file ;
 // === Parse input parameters
 if( SvROK(param) && (SvTYPE(SvRV(param)) == SVt_PVHV) )
 {
  {
   SV **const ret = hv_fetch((HV*)SvRV(param),"sdb",strlen("sdb"),0) ;

   if(ret == NULL)
   {
    XSRETURN_UNDEF;
   }
   
   sdb_file = SvPV_nolen(*ret) ;

  }
 }
 else
 {

  if( SvROK(param) )
  {
   XSRETURN_UNDEF;
  }

  sdb_file = SvPV_nolen(param) ;

 }
///
//
CODE:
 c_qdpxx_sdb_validate(sdb_file) ;
//
OUTPUT:

SV *
c_qdpxx_sdb_dump(param)
 SV * param ;
INIT:
 char *sdb_file ;
 int  verbose ;
 // === Parse input parameters
 if( SvROK(param) && (SvTYPE(SvRV(param)) == SVt_PVHV) )
 {
  {
   SV **const ret = hv_fetch((HV*)SvRV(param),"verbose",strlen("verbose"),0) ;
   verbose = (ret == NULL)?0:SvIV(*ret) ;
  }
  {
   SV **const ret = hv_fetch((HV*)SvRV(param),"sdb",strlen("sdb"),0) ;

   if(ret == NULL)
   {
    XSRETURN_UNDEF;
   }

   sdb_file = SvPV_nolen(*ret) ;

  }
 }
 else
 {
  if( SvROK(param) )
  {
   XSRETURN_UNDEF;
  }
  STRLEN len ;
//  sdb_file = SvPV(param,len) ;
  sdb_file = SvPV_nolen(param) ;
  verbose = 0 ;
 }
///
//
CODE:
 // array of hashes
 AV * result = (AV*) sv_2mortal((SV*)newAV()) ;

 //C_QDPXX_SDB_KEY_VALUE_VARARRAY dump ; // used to work
 typedef C_QDPXX_SDB_KEY_VALUE_VARARRAY T ;
 T *dump = (T *)malloc(sizeof(T)) ;

 if( dump )
 {
  c_qdpxx_sdb_dump(sdb_file,dump,verbose) ;

  printf("KEY/VALUE PAIRS: %d\n", dump->n ) ;

  // === PERLrify the KEY/VALUE pairs
  for(int i0 = 0 ; i0 < dump->n ; i0 ++ )
  {
   HV * href     = (HV*) sv_2mortal((SV*)newHV()) ;
   HV * href_key = (HV*) sv_2mortal((SV*)newHV()) ;

   hv_store(href,"key",strlen("key"),newRV((SV*)href_key),0) ;

   set_hash_key_array_of_real(href_key,mom) ;
   set_hash_key_array_of_real(href_key,src_lorentz) ;
   set_hash_key_array_of_real(href_key,snk_lorentz) ;
   set_hash_key_string       (href_key,snk_name) ;
   set_hash_key_string       (href_key,snk_smear) ;
   set_hash_key_string       (href_key,src_name) ;
   set_hash_key_string       (href_key,src_smear) ;

   //set_hash_value_array_of_real(href,correlator) ;
   set_hash_value_array_of_real(href,value) ;
  
   av_push(result,newRV((SV*)href)) ;
  }
///

  c_qdpxx_sdb_wipe(dump) ;

  free(dump) ;
 }

 RETVAL = newRV((SV*)result) ;
//
OUTPUT:

 RETVAL

