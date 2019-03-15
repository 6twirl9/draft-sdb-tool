
- Perl / Python interface to C/QDP++/SDB library for reading SDB databases.

  . SDBs are used as a storage format for simulation results.
  . SDBs are fragile and must be wrapped up properly to avoid crashes during post-processing.

- C/QDP++/SDB library

  . A minimal version of QDP++ is prepared. QDP++ is a data parallel layer upon which Chroma
    -- Lattice QCD calculation by USQCD -- is built.
  . A particular verion of SDB "bundled" with QDP++ is used since it can read all SDBs encountered so far.
  . A set of C functions are used to translate QDP++ specific data structure to plain C ones so
    it will be easier to access from Perl/Python.

- History:

  . Initially, only the Perl version of the interface.
  . A Python version -- the current one -- was constructed due to popular demand.
  . The current Perl version was built following the structure of the Python version.

- IP

  . All data internal to the collaboration have been removed.
  . This directory only contain a snapshot of the most important files.

