#!/usr/bin/env perl

# === Use ...

use lib '.' ;
use strict ;

$::False = \0 ;
$::True  = \1 ;

use JSON::XS ;
use Data::Dump qw/dump/ ;
use Digest::MD5 ;
use Time::HiRes qw/clock_gettime/ ;

#///

use Package::Alias
  'SDB'         => 'NPLQCD::File::Format::SDB'

#
# Already aliased from above.
#
# , 'c_qdpxx_sdb' => 'NPLQCD::File::Format::SDB::XS'
#
;

use SDB qw/sdb_dump digest canonical_dump/ ;

__PACKAGE__->__main__ ;

#
# Taken from NPLQCD::File::Format::SDB.pm
#

sub __main__ # ===
{
my ($verbose,$validate_only,@file) = @ARGV ;

# === command line args ...

my $opt =
 {
   'redirect' => 0
 , 'timeout'  =>
   {
     'skip' =>   0.001
   , 'step' => 100
   }
 } ;

my $as_bool = sub { { 'True' => $::True, 'False' => $::False }->{(shift)} ; } ;

 $verbose       = $as_bool->($verbose) ;
 $validate_only = $as_bool->($validate_only) ;

#///

my $hash = \&Digest::MD5::md5 ;

my @time ;

push @time, clock_gettime ;

#
# Default options is equivalent to
#
#  my $ret = SDB::sdb_dump( \@file ) ;
#
my $ret = sdb_dump( \@file,'opt' => $opt, 'verbose' => $verbose, 'validate_only' => $validate_only, 'hash' => $hash ) ;

push @time, clock_gettime ;

 printf("%s VALIDITY\n", digest($hash,$ret->{'valid'}) ) ;

 if( not $$validate_only )
 {
  printf("%s DATA     // SDB::sdb_dump     elapsed %8.3f (s)\n", digest($hash,canonical_dump($ret->{'data'},"json")), $time[-1] - $time[-2] ) ;
 }

my %valid =
 map
 {
  $_->{'file'} => $_->{'valid'}
 } @{JSON::XS->new->decode($ret->{'valid'})}
;

#
# If you are certain that the SDB files are free from errors,
# you may access them directly.
#

push @time, clock_gettime ;

my @ret =
 map
 {
  my $hash = { $_ => c_qdpxx_sdb::dump($_) } ;

  $hash

 }
  grep { $valid{$_} }
   @file 
;

push @time, clock_gettime ;

 if( not $$validate_only )
 {
  printf("%s DATA     // c_qdpxx_sdb::dump elapsed %8.3f (s)\n", digest($hash,canonical_dump(\@ret,"json")), $time[-1] - $time[-2] ) ;
 }

}

#///

