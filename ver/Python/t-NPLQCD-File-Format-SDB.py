#!/usr/bin/env python

# === Import ...
import sys
import hashlib
import time
import json
#///

from NPLQCD.File.Format.SDB import sdb_dump, digest, canonical_dump, c_qdpxx_sdb

#
# Taken from NPLQCD/File/Format/SDB/SDB.py
#

if __name__ == '__main__': # ===

 verbose, validate_only, *files = sys.argv[1:]

 # === command line args ...

 opt = \
 {
   'redirect': True
 , 'timeout' :
   {
     'skip':   0.001
   , 'step': 100
   }
 }

 def as_bool(s): return { 'True': True, 'False': False }[s]

 verbose       = as_bool(verbose)
 validate_only = as_bool(validate_only)

#///

 hash=hashlib.md5

 time_ = []

 time_.append( time.perf_counter() )

 ret = sdb_dump(files,opt=opt,verbose=verbose,validate_only=validate_only,hash=hash)

 time_.append( time.perf_counter() )

 print('{} VALIDITY'.format( digest(hash,ret['valid']) ))
  
 if not validate_only:
  print('{} DATA     // SDB::sdb_dump     elapsed {:8.3f}'.format( digest(hash,canonical_dump(ret['data'],'json')), time_[-1] - time_[-2] ) )

 valid_ = \
 {
  each['file']: each['valid']
   for each in json.loads(ret['valid'])
 }

 time_.append( time.perf_counter() )

 ret_ = \
 [
  { file: c_qdpxx_sdb.dump(file) } 
   for file in files
    if valid_[file]
 ]

 time_.append( time.perf_counter() )

 if not validate_only:
  print('{} DATA     // c_qdpxx_sdb::dump elapsed {:8.3f}'.format( digest(hash,canonical_dump(ret_,'json')), time_[-1] - time_[-2] ) )


#///

