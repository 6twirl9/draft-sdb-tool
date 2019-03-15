def __bootstrap__():

   import re

   __package__ = __name__.replace('.c_qdpxx_sdb','')

   global __bootstrap__, __loader__, __file__

   import sys, pkg_resources, imp

   version = [] # ===
   try:

    import NPLQCD.UTIL.Location

    version = [ NPLQCD.UTIL.Location.identify() ]

   except Exception as e:

    import os
    import re

    module = re.sub('\.','_',__package__)

    if module in os.environ:

     version = [ os.environ[module] ]

#///
   _V      = [] # ===
   try:

    # Utility script to print the python tag + the abi tag for a Python
    # See PEP 425 for exactly what these are, but an example would be:
    #   cp27-cp27mu

    from wheel.pep425tags import get_abbr_impl, get_impl_ver, get_abi_tag
    from setuptools import distutils
    import re

    abi = "{0}{1}-{2}".format(get_abbr_impl(), get_impl_ver(), get_abi_tag())

    platform_ = re.sub('[-.]','_',distutils.util.get_platform())

    _V = [ f'{abi}-{platform_}' ]

   except:

    import platform

    _V = [ platform.python_version() ]

#///

   so = '/'.join( [ '..', 'Cython-shared-library' ] + version + _V + [ 'c_qdpxx_sdb.so' ] )

   __file__ = pkg_resources.resource_filename(__name__,so)

   __loader__ = None; del __bootstrap__, __loader__

   imp.load_dynamic(__name__,__file__)

__bootstrap__()

