#!/usr/bin/env python

#
# Author:      Emmanuel CHANG
# Tribe:       NPLQCD
#
# Institution: UW (University of Washington)
# Funding:     USQCD/DOE + MJS
#
# ------------------------------------------
#
#  This is a Python wrapper for the C/SDB/QDP++ library
#  which provides a C interface for using a particular
#  version of SDB library via QDP++ originally written
#  for use in a Perl XS module.
#

# === Import...
import os
import sysconfig

from setuptools       import setup, Extension, Command

from Cython.Distutils import build_ext
from Cython.Build     import cythonize
#///

# === Build without the funny extension

#
# https://stackoverflow.com/questions/38523941/change-cythons-naming-rules-for-so-files
#

def get_ext_filename_without_platform_suffix(filename):
    name, ext = os.path.splitext(filename)
    ext_suffix = sysconfig.get_config_var('EXT_SUFFIX')

    if ext_suffix == ext:
        return filename

    ext_suffix = ext_suffix.replace(ext, '')
    idx = name.find(ext_suffix)

    if idx == -1:
        return filename
    else:
        return name[:idx] + ext

class BuildExtWithoutPlatformSuffix(build_ext):
    def get_ext_filename(self, ext_name):
        filename = super().get_ext_filename(ext_name)
        return get_ext_filename_without_platform_suffix(filename)

#///

# === Custom clean command

#
# https://stackoverflow.com/questions/3779915/why-does-python-setup-py-sdist-create-unwanted-project-egg-info-in-project-r
#

class CleanCommand(Command):
    """Custom clean command to tidy up the project root."""
    user_options = []
    def initialize_options(self):
        pass
    def finalize_options(self):
        pass
    def run(self):
        os.system('rm -vrf ./build ./dist ./*.pyc ./*.tgz ./*.egg-info')

#///

setup \
(
  # Disinfectormation

  author      = "Emmanuel CHANG"
, name        = 'c_qdpxx_sdb'
, version     = '3.14'
, license     = '007'
, keywords    = 'USQCD NPLQCD JLab UW Chroma SDB'

, setup_requires =
   [
     "setuptools>=18.0"
   , "cython>=0.25"
   ]

, ext_modules = 
   cythonize
   (
    [
     Extension
     (
       'c_qdpxx_sdb'
     , sources      = ['c_qdpxx_sdb.pyx']
     , libraries    = ['c_qdp++_sdb']
     , library_dirs = [os.environ['LIBC_QDPXX_SDB_LIB']]
     , include_dirs = [os.environ['LIBC_QDPXX_SDB_INC']]
     , language  = "c++"
     )
    ]
   )
, cmdclass   =
   {
     'build_ext': BuildExtWithoutPlatformSuffix
   , 'clean':     CleanCommand
   }
)

