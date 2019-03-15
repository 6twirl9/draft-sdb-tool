// === include

#include "qdp.h"
#include "qdp_db.h"

using namespace QDP;

// Import the key/Data structures from chroma.

#include "contrib/chroma/lib/util/ferm/key_val_db.h"
#include "contrib/chroma/lib/util/ferm/key_hadron_2pt_corr.h"
#include "contrib/chroma/lib/util/ferm/key_hadron_2pt_corr.cc"
#include "qdp_map_obj_disk.h"

#include "contrib/aycaramba/_/macro/loop.h"

///

#include "c_qdp++_sdb.h"

using namespace std;
using namespace Chroma ;

typedef KeyHadron2PtCorr_t  KEY ;
typedef multi1d<ComplexD>   VALUE ;

typedef SerialDBKey<KEY>    SDB_KEY ;
typedef SerialDBData<VALUE> SDB_VALUE ;

// === C++ I/O redirect
struct iostream_redirect
{
 iostream_redirect( ostream& s_new, ostream& s_old_0 )
 {
  n = 1 ;
  s_new_p = &s_new ; s_new_rdbuf = s_new.rdbuf() ;
  s_old_p[0] = &s_old_0 ; s_old_rdbuf[0] = s_old_0.rdbuf( s_new_rdbuf ) ;
 }
 iostream_redirect( ostream& s_new, ostream& s_old_0, ostream& s_old_1 )
 {
  n = 2 ;
  s_new_p = &s_new ; s_new_rdbuf = s_new.rdbuf() ;
  s_old_p[0] = &s_old_0 ; s_old_rdbuf[0] = s_old_0.rdbuf( s_new_rdbuf ) ;
  s_old_p[1] = &s_old_1 ; s_old_rdbuf[1] = s_old_1.rdbuf( s_new_rdbuf ) ;
 }
 void operator()( ostream& s_new, ostream& s_old_0 )
 {
  n = 1 ;
  s_new_p = &s_new ; s_new_rdbuf = s_new.rdbuf() ;
  s_old_p[0] = &s_old_0 ; s_old_rdbuf[0] = s_old_0.rdbuf( s_new_rdbuf ) ;
 }
 void operator()( ostream& s_new, ostream& s_old_0, ostream& s_old_1 )
 {
  n = 2 ;
  s_new_p = &s_new ; s_new_rdbuf = s_new.rdbuf() ;
  s_old_p[0] = &s_old_0 ; s_old_rdbuf[0] = s_old_0.rdbuf( s_new_rdbuf ) ;
  s_old_p[1] = &s_old_1 ; s_old_rdbuf[1] = s_old_1.rdbuf( s_new_rdbuf ) ;
 }
 void operator[](string s)
 {
  for( int i = 0 ; i < n ; i++ )
  {
   if( s == "restore"  ) s_old_p[i]->rdbuf( s_old_rdbuf[i] );
   if( s == "redirect" ) s_old_p[i]->rdbuf( s_new_rdbuf    );
  }
 }
 void restore(int i)
 {
  if( i < n )
   s_old_p[i]->rdbuf( s_old_rdbuf[i] );
 }
 void operator[](int i)
 {
  if( i < n )
   s_old_p[i]->rdbuf( s_old_rdbuf[i] );
 }
~iostream_redirect()
 {
  for( int i = 0 ; i < n ; i++ )
   s_old_p[i]->rdbuf( s_old_rdbuf[i] );
 }
private:
 int n ;
 streambuf *s_old_rdbuf[2] ;
 streambuf *s_new_rdbuf ;
 ostream   *s_old_p[2], *s_new_p ;
};
///

extern "C"
{

void c_qdpxx_sdb(sdb_validate)    ( char* sdb_file_cstr ) // ===
{

string sdb_file = sdb_file_cstr ;

 // === silence qdp
iostream_redirect dev_null( *new ofstream("/dev/null"), cout, cerr ) ;
///

vector< SDB_KEY   > keys_ ;
vector< SDB_VALUE > data_ ;

// === Slurp in all key/value pairs
{
BinaryStoreDB< SDB_KEY, SDB_VALUE > o ;

 o.open(sdb_file, O_RDONLY, 0644);
 o.keysAndData(keys_,data_);
 o.close() ;

}
///

return ;
}
///
void c_qdpxx_sdb(sdb_spy)         ( char* sdb_file_cstr ) // ===
{

string sdb_file = sdb_file_cstr ;

 // === silence qdp
iostream_redirect dev_null( *new ofstream("/dev/null"), cout, cerr ) ;
///

vector< SDB_KEY   > keys_ ;
vector< SDB_VALUE > data_ ;

// === Slurp in all key/value pairs
{
BinaryStoreDB< SDB_KEY, SDB_VALUE > o ;

 o.open(sdb_file, O_RDONLY, 0644);
 o.keysAndData(keys_,data_);
 o.close() ;

}
///

loop( j,keys_.size()) {

#define DA(_) keys_[j].key()._
#define DB(_) data_[j].data()

 const char *sink[2], *source[2] ;
 int p2cm[32], q[32], mom[32] ;

   sink[0] = DA(snk_name) .c_str() ;
   sink[1] = DA(snk_smear).c_str() ;
 source[0] = DA(src_name) .c_str() ;
 source[1] = DA(src_smear).c_str() ;

 loop( l,DA(src_lorentz).size())    q[l] = DA(src_lorentz)[l] ;
 loop( l,DA(snk_lorentz).size()) p2cm[l] = DA(snk_lorentz)[l] ;
 loop( l,DA(mom)        .size())  mom[l] = DA(mom)        [l] ;

/*

 Original order:

 rep(2,array  ,str,Source Name/Smear,source_p)	// -> source
 rep(1,multi1d,int,Source Lorentz   ,q)		// -> q
 rep(2,array  ,str,Sink   Name/Smear,sink_p)	// -> sink
 rep(1,multi1d,int,Sink  Lorentz    ,p2cm)	// -> p2cm
 rep(1,multi1d,int,Momentum         ,pz)	// -> pz
*/

  printf("# TAG %s_%s_p2cm-%d, %s_%s, %d,", sink[0], sink[1], p2cm[0], source[0], source[1], mom[2] ) ;

  loop( l,DA(src_lorentz).size()) printf(" %d", q[l] ) ; printf("\n") ;

#define Re(_) _.elem().elem().elem().real()
#define Im(_) _.elem().elem().elem().imag()

  VALUE &data = DB() ;

  loop(i,data.size())
   printf("%3d %+1.16E %+1.16E\n",i,Re(data[i]),Im(data[i])) ;

#undef  Re
#undef  Im

  printf("\n\n\n") ;
 }

return ;
}
///
void c_qdpxx_sdb(sdb_dump)        ( char* sdb_file_cstr, C_QDPXX_SDB(SDB_KEY_VALUE_VARARRAY)* result, int verbose ) // ===
{

string sdb_file = sdb_file_cstr ;

 // === silence qdp
iostream_redirect dev_null( *new ofstream("/dev/null"), cout, cerr ) ;
///

vector< SDB_KEY   > keys_ ;
vector< SDB_VALUE > data_ ;

// === Slurp in all key/value pairs
{
BinaryStoreDB< SDB_KEY, SDB_VALUE > o ;

 o.open(sdb_file, O_RDONLY, 0644);
 o.keysAndData(keys_,data_);
 o.close() ;

}
///

if( result )
{
 result->n = keys_.size() ;
 result->_ = (C_QDPXX_SDB(SDB_KEY_VALUE)*)malloc(sizeof(C_QDPXX_SDB(SDB_KEY_VALUE))*result->n) ;
}

loop( j,keys_.size()) {

#define DA(_) keys_[j].key()._

 const char *sink[2], *source[2] ;
 int p2cm[32], q[32], mom[32] ;

if( verbose )
{
   sink[0] = DA(snk_name) .c_str() ;
   sink[1] = DA(snk_smear).c_str() ;
 source[0] = DA(src_name) .c_str() ;
 source[1] = DA(src_smear).c_str() ;

 loop( l,DA(src_lorentz).size())    q[l] = DA(src_lorentz)[l] ;
 loop( l,DA(snk_lorentz).size()) p2cm[l] = DA(snk_lorentz)[l] ;
 loop( l,DA(mom)        .size())  mom[l] = DA(mom)        [l] ;
}

if( result && result->_ )
{

#define rep(snk_name)								\
 result->_[j].key.snk_name.n = DA(snk_name).size()+1 ;				\
 result->_[j].key.snk_name._ = (char*)malloc(result->_[j].key.snk_name.n) ;			\
 strncpy(result->_[j].key.snk_name._, DA(snk_name).c_str(),result->_[j].key.snk_name.n) ;

 rep(snk_name) rep(snk_smear)
 rep(src_name) rep(src_smear)

#undef  rep

#define rep(src_lorentz)								\
 result->_[j].key.src_lorentz.n = DA(src_lorentz).size() ;					\
 result->_[j].key.src_lorentz._ = (int*)malloc(sizeof(int)*result->_[j].key.src_lorentz.n) ;	\
 loop( l,DA(src_lorentz).size()) result->_[j].key.src_lorentz._[l] = DA(src_lorentz)[l] ;

 rep(src_lorentz)
 rep(snk_lorentz)
 rep(mom)

#undef  rep

}

/*

 Original order:

 rep(2,array  ,str,Source Name/Smear,source_p)	// -> source
 rep(1,multi1d,int,Source Lorentz   ,q)		// -> q
 rep(2,array  ,str,Sink   Name/Smear,sink_p)	// -> sink
 rep(1,multi1d,int,Sink  Lorentz    ,p2cm)	// -> p2cm
 rep(1,multi1d,int,Momentum         ,pz)	// -> pz
*/

 if( verbose )
 {
  printf("# TAG %s_%s_p2cm-%d, %s_%s, %d,", sink[0], sink[1], p2cm[0], source[0], source[1], mom[2] ) ;

  loop( l,DA(src_lorentz).size()) printf(" %d", q[l] ) ; printf("\n") ;
 }

#undef  DA

#define Re(_) _.elem().elem().elem().real()
#define Im(_) _.elem().elem().elem().imag()

  VALUE &data = data_[j].data() ;

if( result && result->_ )
{
 result->_[j].value.n = data.size() * 2 ;
 result->_[j].value._ = (double*)malloc(sizeof(double)*result->_[j].value.n) ;
}

 int k = 0 ;
  loop(i,data.size())
  {
   if( verbose )
   {
    printf("%3d %+1.16E %+1.16E\n",i,Re(data[i]),Im(data[i])) ;
   }
   if( result && result->_ )
   {
    result->_[j].value._[k++] = Re(data[i]) ;
    result->_[j].value._[k++] = Im(data[i]) ;
   }
  }

#undef  Re
#undef  Im

 if( verbose )
  printf("\n\n\n") ;
 }

return ;
}
///
void c_qdpxx_sdb(sdb_wipe)        (                      C_QDPXX_SDB(SDB_KEY_VALUE_VARARRAY)* result ) // ===
{

if( ! result || result->n == 0 ) return ;

loop(j,result->n)
{

#define rep(snk_name) if( result->_[j].key.snk_name._ ) free(result->_[j].key.snk_name._) ;

 rep(snk_name) rep(snk_smear)
 rep(src_name) rep(src_smear)

 rep(src_lorentz)
 rep(snk_lorentz)
 rep(mom)

#undef  rep

 if( result->_[j].value._ ) free(result->_[j].value._) ;

}

return ;
}
///
void c_qdpxx_sdb(sdb_pretty_print)(                      C_QDPXX_SDB(SDB_KEY_VALUE_VARARRAY)* result ) // ===
{

if( ! result || result->n == 0 ) return ;

loop(j,result->n)
{

#define DA(__) result->_[j].key.__

 const char* sink[2], *source[2] ;
 int p2cm[32], q[32], mom[32] ;

   sink[0] = DA(snk_name) ._ ;
   sink[1] = DA(snk_smear)._ ;
 source[0] = DA(src_name) ._ ;
 source[1] = DA(src_smear)._ ;

 loop( l,DA(src_lorentz).n)    q[l] = DA(src_lorentz)._[l] ;
 loop( l,DA(snk_lorentz).n) p2cm[l] = DA(snk_lorentz)._[l] ;
 loop( l,DA(mom)        .n)  mom[l] = DA(mom)        ._[l] ;

  printf("# TAG %s_%s_p2cm-%d, %s_%s, %d,", sink[0], sink[1], p2cm[0], source[0], source[1], mom[2] ) ;

  loop( l,DA(src_lorentz).n ) printf(" %d", q[l] ) ; printf("\n") ;

#undef  DA

  C_QDPXX_SDB(SDB_VALUE) &data = result->_[j].value ;

#define Re(data,i) data._[i*2+0]
#define Im(data,i) data._[i*2+1]

  loop(i,data.n/2)
  {
   printf("%3d %+1.16E %+1.16E\n",i,Re(data,i),Im(data,i)) ;
  }

#undef  Re
#undef  Im

  printf("\n\n\n") ;
 }

return ;
}
///

}

