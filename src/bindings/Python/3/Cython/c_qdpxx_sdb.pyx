cimport cython
cimport c_qdpxx_sdb
import numpy as np

def validate(file): # ===

 c_qdpxx_sdb_validate(file.encode())

#///

def dump(file,verbose=0,numpify=False): # ===

 data = []

 # REQUIRED ! Somehow this forces the compilation to proceed correctly

 cdef double[::1] _double
 cdef    int[::1] _int
 cdef   char[::1] _char

 cdef C_QDPXX_SDB_KEY_VALUE_VARARRAY sdb_kv

 c_qdpxx_sdb_dump(file.encode(), &sdb_kv, verbose )

 for i in range(sdb_kv.n):

  pair = { 'key': {}, 'value': None }

  def value(): # ===

   it = sdb_kv._[i].value

   pair['value'] = np.asarray(<double[:it.n]>it._)

   if not numpify:

    tag = 'value' ; pair[tag] = pair[tag].tolist()

 #///

  value()

  def key(): # ===

   it = sdb_kv._[i].key

   pair['key']['src_lorentz'] = np.asarray(<int[:it.src_lorentz.n]>it.src_lorentz._)
   pair['key']['snk_lorentz'] = np.asarray(<int[:it.snk_lorentz.n]>it.snk_lorentz._)
   pair['key']['mom'        ] = np.asarray(<int[:it.mom        .n]>it.mom        ._)

   if not numpify:

    for tag in ['src_lorentz','snk_lorentz','mom']:

     pair['key'][tag] = pair['key'][tag].tolist()

   # n -1 <-- Ignore the null char at the end

   pair['key']['src_name' ] = it.src_name ._[:it.src_name .n -1].decode('UTF-8')
   pair['key']['snk_name' ] = it.snk_name ._[:it.snk_name .n -1].decode('UTF-8')
   pair['key']['src_smear'] = it.src_smear._[:it.src_smear.n -1].decode('UTF-8')
   pair['key']['snk_smear'] = it.snk_smear._[:it.snk_smear.n -1].decode('UTF-8')

#///

  key()

  data.append(pair)

 return data

#///

class SDB: # ===

 def __init__(self,file):

  self.file = file

  self.data = []

 def validate(self):

  c_qdpxx_sdb_validate(self.file.encode())

 def dump(self,verbose=0,numpify=False):

  # REQUIRED ! Somehow this forces the compilation to proceed correctly

  cdef double[::1] _double
  cdef    int[::1] _int
  cdef   char[::1] _char

  cdef C_QDPXX_SDB_KEY_VALUE_VARARRAY sdb_kv

  c_qdpxx_sdb_dump(self.file.encode(), &sdb_kv, verbose )

  for i in range(sdb_kv.n):

   pair = { 'key': {}, 'value': None }

   def value(): # ===

    it = sdb_kv._[i].value

    pair['value'] = np.asarray(<double[:it.n]>it._)

    if not numpify:

     tag = 'value' ; pair[tag] = pair[tag].tolist()

 #///

   value()

   def key(): # ===

    it = sdb_kv._[i].key

    pair['key']['src_lorentz'] = np.asarray(<int[:it.src_lorentz.n]>it.src_lorentz._)
    pair['key']['snk_lorentz'] = np.asarray(<int[:it.snk_lorentz.n]>it.snk_lorentz._)
    pair['key']['mom'        ] = np.asarray(<int[:it.mom        .n]>it.mom        ._)

    if not numpify:

     for tag in ['src_lorentz','snk_lorentz','mom']:

      pair['key'][tag] = pair['key'][tag].tolist()

    # n -1 <-- Ignore the null char at the end

    pair['key']['src_name' ] = it.src_name ._[:it.src_name .n -1].decode('UTF-8')
    pair['key']['snk_name' ] = it.snk_name ._[:it.snk_name .n -1].decode('UTF-8')
    pair['key']['src_smear'] = it.src_smear._[:it.src_smear.n -1].decode('UTF-8')
    pair['key']['snk_smear'] = it.snk_smear._[:it.snk_smear.n -1].decode('UTF-8')

 #///

   key()

   self.data.append(pair)

  return self.data

#///

