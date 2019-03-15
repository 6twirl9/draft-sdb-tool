#!/usr/bin/env perl
package NPLQCD::File::Format::SDB ;

# === Use ...

use Data::Dump qw/dump/ ;

use Types::Serialiser;
use JSON::XS ;
use YAML::XS ;
use Forks::Super ; # IPC_DIR => 'undef' ;

use Time::HiRes qw/sleep clock_gettime time/ ;
use MIME::Base64::URLSafe ;
use MIME::Base16 ;
use Digest::BLAKE2 qw(blake2b blake2b_hex blake2b_base64 blake2b_base64url blake2b_ascii85);
use Digest::MD5 qw(md5 md5_hex md5_base64);

use Storable qw/freeze thaw/ ;

use strict ;

$::False = \0 ;
$::True  = \1 ;

#///

use Package::Alias
 'c_qdpxx_sdb' => 'NPLQCD::File::Format::SDB::XS'
;

# === Export

require Exporter;

our @ISA = qw(Exporter);

our %EXPORT_TAGS = ( 'all' => [ qw(
	sdb_dump digest canonical_dump
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(

);

#///

# === "Process"

sub process_init     # ===
{
 my $p = shift ;

 $p->{$_} = undef foreach (qw/pid exitcode step/) ;
#$p->{$_} = ""    foreach (qw/stdout stderr/) ;

 $p->{'execute'  } = sub { process_execute  ($p) ; } ; 
 $p->{'success'  } = sub { process_success  ($p) ; } ;

 $p->{'is_alive' } = sub { process_is_alive ($p) ; } ;
#$p->{'terminate'} = sub { process_terminate($p) ; } ;

 return $p ;
}
#///

sub process_success  # ===
{
 ( (shift)->{'exitcode'} == 0 )  ? $::True : $::False ;
}
#///
sub process_execute  # === Process initialization & execution
{
my $p = shift ;

local *STDOUT, *STDERR ;

my $stderr ;
my $stderr_ = {} ;

close STDOUT ;
close STDERR ;

if( $p->{'opt'}->{'redirect'} )
{
 $stderr_ = { 'stderr' => \$stderr } ;
}

my $fork =

 fork
 {
   'sub'      => $p->{'target'}
 , 'args'     => $p->{'args'}
#, 'share'    => [ \@queue ]
#, 'callback' => { finish => sub { return @queue ; } }
 , 'timeout'  => 1
 , 'retires'  => 0

 # These two are my own additions.
 , 'ipc retries'     => 1
 , 'ipc retry pause' => 0

#, 'child_fh'        => 'out,err'

 , %{$stderr_}
 } ;

$p->{'pid'}  = 0 + $fork ;

$p->{'step'} = 0 ;

foreach (0..$p->{'opt'}->{'timeout'}->{'step'})
{
 if( $p->{'is_alive'}->() )
 {
  sleep $p->{'opt'}->{'timeout'}->{'skip'} ;
  $p->{'step'} ++ ;
 }
 else
 {
  goto process_is_dead ;
 }
}

Forks::Super::kill 9, $fork ;

process_is_dead: ;

waitpid $fork, 0 ;

my $waitpid = $? ;
my ($exitcode,$signal) = ($waitpid >> 8,$waitpid & 0xff) ;

$exitcode |= $signal ;

$p->{'exitcode'} = $exitcode ;

$fork->dispose ;

if( $p->{'opt'}->{'redirect'} )
{
#close STDOUT ;
#close STDERR ;
#$p->{'stdout'} = $stdout ;
 $p->{'stderr'} = $stderr ;
}

}
#///

sub process_is_alive # ===
{
 kill 0, (shift)->{'pid'} ;
}
#///

#///

sub dict_slice { my ($d,$s) = @_ ; %$d{@$s} ; }
sub json_dump  { JSON::XS->new->allow_nonref->canonical->encode(shift) ; }
sub yaml_dump  { YAML::XS::Dump(shift) ; }
sub digest     { my ($f,$s) = @_ ; MIME::Base16::encode($f->($s)) ; }

sub canonical_dump # === ensure identical output from Perl and Python
{
my ($data,$format,$prec) = @_ ;

$data     = thaw(freeze($data)) ;
$format //= "json" ;
$prec   //= 15 ;

my $floating_point_value_format =
 sub {
  my ($fmt,$value) = @_ ;
   return sprintf("%%FP(%s)", ( $value == 0. ) ? '0' : sprintf($fmt,$value) ) ;
 }
;

my $ret =
[
 map { my $hash =

  {
   $_->[0] =>
   [
    map {
     {
       'key'   => $_->{'key'}
     , 'value' => [map { $floating_point_value_format->("%.${prec}e",$_) } @{$_->{'value'}}]
     }
    } @{$_->[1]}
   ]
  } ;

  $hash

 } map { [each %$_] } @$data
]
;

$ret = { "json" => \&json_dump, "yaml" => \&yaml_dump }->{$format}->($ret) ;

$ret =~ s|(?<quote>["'])%FP\((?<number>[^\)]*)\)\g{quote}|$+{'number'}|g ;

return $ret ;
}

#///

sub sdb_func_apply # ===
{
my $opt = pop @_ ;
my ($func,$file,@args) = @_ ;

 # === opt default

 $opt //= {} ;

 $opt->{'redirect'} //= 1 ;
 $opt->{'timeout'}  //= {} ;

 $opt->{'timeout'}->{'skip'} //=   0.001 ;
 $opt->{'timeout'}->{'step'} //= 100 ;

#///

my $p = process_init({ 'target' => $func, 'args' => [$file,@args], 'opt' => $opt }) ;

 $p->{'execute'}->() ;

 return
 {
   'file'     => $file
 , 'size'     => ( -s $file )

 , 'valid'    => $p->{'success'}->()
 , 'step'     => $p->{'step'}
 , 'exitcode' => $p->{'exitcode'}

 , 'stdout'   => $p->{'stdout'}
 , 'stderr'   => $p->{'stderr'}
 } ;

}

#///

sub sdb_dump       # ===
{
my $file = shift ;
my %rest = @_ ; 

 $rest{'validate_only'} //= $::False ;
 $rest{'verbose'}       //= $::False ;
 $rest{'hash'}          //= \&md5 ;
#$rest{'opt'}           //= {} ;

my $verbose       = ${$rest{'verbose'}} ;
my $validate_only = ${$rest{'validate_only'}} ;
my $hash          =   $rest{'hash'} ;

my $opt = $rest{'opt'} ;

 # === opt default

 $opt //= {} ;

 $opt->{'redirect'} //= 1 ;
 $opt->{'timeout'}  //= {} ;

 $opt->{'timeout'}->{'skip'} //=   0.001 ;
 $opt->{'timeout'}->{'step'} //= 100 ;

#///

#
# Only check if SDB files can be opened and read
#

my @valid = map { sdb_func_apply \&c_qdpxx_sdb::validate, $_, $opt } sort @$file ;

my $valid_json = json_dump([map { {dict_slice $_, [qw/valid file/]} } @valid]) ;

 if($verbose)
 {
  foreach (@valid)
  {
   printf("%-5s %4d %4d %8d %64s %s\n", ${$_->{'valid'}} ? 'True' : 'False', $_->{'exitcode'}, $_->{'step'}, ( -s $_->{'file'} ), $_->{'file'},$_->{'stderr'}) ;
  }
 }

 if($validate_only)
 {
  return { 'valid' => $valid_json } ;
 }

my @result = map { { $_->{'file'} => c_qdpxx_sdb::dump($_->{'file'}) } } grep { ${$_->{'valid'}} } @valid ;

 return { 'valid' => $valid_json, 'data' => \@result } ;
}
#///
sub sdb_validate   # ===
{
my $file = shift ;
my %rest = @_ ; 

 $rest{'validate_only'} = $::True ;

 return sdb_dump( $file, %rest ) ;
}
#///

#
# Uncomment the "# >> " section, together with, __PACKAGE__->__main__ ... and "sub __main__ { ... }",
# they form an independent test script. You can test this module directly, of course.
#

# >> # === Use ...
# >> 
# >> use strict ;
# >> 
# >> $::False = \0 ;
# >> $::True  = \1 ;
# >> 
# >> use JSON::XS ;
# >> use Data::Dump qw/dump/ ;
# >> use Digest::MD5 ;
# >> use Time::HiRes qw/clock_gettime/ ;
# >> 
# >> #///
# >> 
# >> use Package::Alias
# >>   'SDB'         => 'NPLQCD::File::Format::SDB'
# >> #
# >> # Already aliased from above.
# >> #
# >> #, 'c_qdpxx_sdb' => 'NPLQCD::File::Format::SDB::XS'
# >> ;
# >> 
# >> use SDB qw/sdb_dump digest canonical_dump/ ;
#

__PACKAGE__->__main__ unless caller ;

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

