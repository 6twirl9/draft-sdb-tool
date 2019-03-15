#!/usr/bin/env python

#
# Translated from the original Perl script
#

#from wheel.pep425tags import get_abbr_impl, get_impl_ver, get_abi_tag
#from setuptools import distutils
import platform
import re

#abi = "{0}{1}-{2}".format(get_abbr_impl(), get_impl_ver(), get_abi_tag())

#platform_ = re.sub('[-.]','_',distutils.util.get_platform())

#print(f'{abi}-{platform_}')

#print(distutils.util.get_platform())

#print(platform.python_version())
#print(platform.uname())
#print(dir(platform))

# === Rudolves
#uc(){ echo ${1^^} ; }
#lc(){ echo ${1,,} ; }
#uc(){ echo $1 | tr '[:lower:]' '[:upper:]' ; }
#lc(){ echo $1 | tr '[:upper:]' '[:lower:]' ; }
#_word() { echo "[[:<:]]${1}[[:>:]]" ; }
#string_join()
#{
#local delimiter="$1" ; shift ;
#local collect word
#
# collect=""
# for word in "$@" ; do
#  collect="$collect$delimiter$word"
# done
#
# echo ${collect/$delimiter}
#}
#///

def identify(delimiter='/'):

 sysname, nodename, release, version, machine, processor = platform.uname()

 site = None

 nodename=nodename.upper()

 #
 # These fine on login nodes
 #

 if re.match('hyak'             ,nodename.lower()):

  site = 'Hyak'

 if re.match(r'\bedison[0-9]+\b',nodename.lower()):

  site = Edison

 if site == None and sysname == 'Darwin':

  site = 'MacApple'

 #
 # On the compute nodes ...
 #

 if site != None:

  if sysname == 'Linux' and re.match(b'\bn[0-9]+\b', nodename.lower()):
 
   site = 'Hyak'

  #
  # Inexact, would have matched on both Hopper & Edison
  #
  if sysname == 'Linux' and re.match(b'\bnid[0-9]+\b', nodename.lower()):

   site = 'Edison'

 #my @tag = ( $sysname $site $release )
 #my %tag = ( system => $sysname, site => $site, release => $release ) ;

 #( defined $delimiter and OR( map { ref $delimiter eq $_ } qw/ARRAY HASH/ ) )
 # ? (
 #    {
 #      ARRAY => [@tag]
 #    , HASH  => {%tag}
 #    }
 #     -> {ref($delimiter)}
 #   )
 # : join( $delimiter ||  "::", @tag )
 #;

 tag = [ sysname, site, release ]

 if   isinstance(delimiter,list): return tag
 elif isinstance(delimiter,dict): return { k: v for k, v in zip( ['system', 'site', 'release'], tag ) }
 else:

  return delimiter.join( tag )

#print(identify())
#print(identify(list()))
#print(identify(dict()))
