package NPLQCD::UTIL::Location ;

use strict ;
#use NPLQCD::UTIL ; # OR/AND
use POSIX ;

sub OR  { $_ && return 1 for @_; 0 }
sub AND { $_ || return 0 for @_; 1 }

sub identify
{
my $delimiter = shift ;
my ($sysname, $nodename, $release, $version, $machine) = uname ;

my $site ;

 $nodename = uc $nodename ;

 #
 # These fine on login nodes
 #

 $site = "Hyak"   if $nodename =~ m|hyak|i ;

 $site = "Edison" if $nodename =~ m|\bedison\d+\b|i ;

 defined $site || ( $sysname eq "Darwin" && ( $site ||= "MacApple" ) ) ;

 #
 # On the compute nodes ...
 #

 if( not defined $site )
 {
  if( $sysname eq 'Linux' and $nodename =~ m|\bn\d+\b|i )
  {
   $site = "Hyak" ;
  }

  #
  # Inexact, would have matched on both Hopper & Edison
  #
  if( $sysname eq 'Linux' and $nodename =~ m|\bnid\d+\b|i )
  {
   $site = "Edison" ;
  }
 }

 my @tag = ( $sysname, $site, $release ) ;
 my %tag = ( system => $sysname, site => $site, release => $release ) ;

 ( defined $delimiter and OR( map { ref $delimiter eq $_ } qw/ARRAY HASH/ ) )
  ? (
     {
       ARRAY => [@tag]
     , HASH  => {%tag}
     }
      -> {ref($delimiter)}
    )
  : join( $delimiter ||  "::", @tag )
 ;
}

1;

