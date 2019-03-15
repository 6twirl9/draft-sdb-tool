#!/usr/bin/env python
# pakcage NPLQCD.File.Format.SDB

# === Import ...

import os
import sys
import time
import re

import json
import yaml
import hashlib
import base64

#from multiprocessing import Process, Queue
import subprocess
import psutil

#///

from ..SDB import Cython as c_qdpxx_sdb

#
# Left blank intentionally.
#

class Process(): # ===

 def __init__(self,target=None,args=tuple(),opt={},**kwds): # ===

  # === opt default

  opt.setdefault('redirect', False)
  opt.setdefault('timeout' , None )

#///

  self.timeout  = opt['timeout']
  self.redirect = opt['redirect']

  self.target   = target
  self.args     = args
  self.kwds     = kwds

  self.pid      = None
  self.exitcode = None
  self.step     = None

#///

 def execute  (self): # ===

  if self.target == None: return

  self.pid = os.fork()

  if self.pid == 0:

   if self.redirect:

    os.close(1)
    os.close(2)

   self.target(*self.args,**self.kwds)

   self.exitcode = 0

   os._exit(self.exitcode)

  else:

   proc = psutil.Process(self.pid)

   if self.timeout == None:

    exitcode = proc.wait()
    exitcode = abs(exitcode)

   else:

    step = 0

    while step < self.timeout['step']:
     try:
      exitcode = proc.wait(timeout=0)
      if exitcode == None:
       exitcode = -101
      else:
       exitcode = abs(exitcode)
      break
     except psutil.TimeoutExpired:
      step += 1
      time.sleep(self.timeout['skip'])
     except psutil.NoSuchProcess:
      exitcode = -102
      break
    else:
     proc.terminate()
     exitcode = -103

    self.step     = step

   self.exitcode = exitcode

#///
 def success  (self): # ===

  return self.exitcode == 0

#///

 def is_alive (self): # ===

  if self.target == None: return False

  return psutil.pid_exists(self.pid)

#///
 def terminate(self): # ===

  if self.target == None: return

  proc = psutil.Process(self.pid)

  proc.terminate()

#///

#///

def dict_slice(d,s): # ===

 return { k: d[k] for k in d.keys() if k in s }

#///
def json_dump(data): # ===

 # JSON::XS->new->allow_nonref->canonical->encode

 return json.dumps(data,separators=(',',':'),sort_keys=True)

#///
def yaml_dump(data): # ===

 # YAML::XS::Dump

 return yaml.dump(data,default_flow_style=False,explicit_start=True)

#///
def digest(f,s):     # ===

 encoding = 'ASCII'

 return base64.b16encode(f(s.encode(encoding)).digest()).decode(encoding).lower()

#///

def canonical_dump(data,format='json',prec=15): # === ensure identical output from Perl and Python

 floating_point_value_format =  \
  lambda fmt, value :           \
   [ '%FP({})'.format('0' if each == 0. else fmt.format(each)) for each in value ]

 ret = \
 [
  {
   file:
   [
    {
      'key'  : each['key']
    , 'value': floating_point_value_format(f'{{:.{prec}e}}',each['value'])
    }
     for each in data
   ]
     for file, data in each.items()
  }
     for each in data
 ]

 ret = { 'json': json_dump, 'yaml': yaml_dump }[format](ret)

 ret = re.sub(r'(?P<quote>["\'])%FP\((?P<number>[^\)]*)\)(?P=quote)',r'\g<number>',ret)

 return ret

#///
   
def sdb_func_apply(func,file,*args,opt={}): # ===

 # === opt default

 opt.setdefault('redirect', True)
 opt.setdefault('timeout' , {}  )

 if opt['timeout'] != None:

  opt['timeout'].setdefault('skip',  0.001)
  opt['timeout'].setdefault('step',100   )

#///

 p = Process(target=func,args=(file,*args),opt=opt)

 p.execute()

 return \
 {
   'file'    : file
 , 'size'    : os.stat(file).st_size

 , 'valid'   : p.success()
 , 'step'    : p.step
 , 'exitcode': p.exitcode
 }

#///

def sdb_dump    (files,opt={},verbose=False,validate_only=False,hash=hashlib.blake2b): # ===

 # === opt default

 opt.setdefault('redirect', True)
 opt.setdefault('timeout' , {}  )

 if opt['timeout'] != None:

  opt['timeout'].setdefault('skip',  0.001)
  opt['timeout'].setdefault('step',100   )

#///

 valid = [ sdb_func_apply(c_qdpxx_sdb.validate,file,opt=opt) for file in sorted(files) ]

 valid_json = json_dump([dict_slice(each,['valid','file']) for each in valid])

 if verbose:

  for each in valid:

   print(f'{str(each["valid"]):5s} {each["exitcode"]:4d} {str(each["step"]):4s} {each["size"]:8d} {each["file"]}') 

 #print(valid_json)
 #print(digest(hash,valid_json))

 if validate_only:

  return { 'valid': valid_json }

 result = []

 for each in filter(lambda _ : _['valid'], valid):

  file = each['file']

  result.append( { file: c_qdpxx_sdb.dump(file) } )

 return { 'valid': valid_json, 'data': result }

#///
def sdb_validate(files,**kargs): # ===

 kargs['validate_only'] = True

 return sdb_dump(files,**kargs)

#///

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

