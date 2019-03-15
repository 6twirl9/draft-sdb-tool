package NPLQCD::File::Format::SDB::XS;

use 5.023006;
use strict;
use warnings;

BEGIN
{
use Cwd qw/abs_path/ ;

#
# Absolute path to this module.
#
my @path = split "/", abs_path( $INC{ ( ( __PACKAGE__ =~ s|::|\/|rg ) . ".pm" ) } ) ;

#
# Add it to the front of the search path, so we can place the
# shared library file in the same place as the Perl module file.
#
unshift @INC, join("/", @path[0..$#path-1]) ;

my @version ;

 if(eval "use NPLQCD::UTIL::Location ;")
 {
  @version = @{NPLQCD::UTIL::Location::identify([])}
 }
 else
 {
  @version = split "/", ( $ENV{( __PACKAGE__ =~ s|::|_|rg )} || "" ) ;
 }

#
# Pre-compiled libraries for your convenience.
#
unshift @INC, join("/", @path[0..$#path-1], "XS-shared-library", @version, $^V ) ;
print(@INC)
}

require Exporter;

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use NPLQCD::File::Format::SDB::XS ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(
	
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
	
);

our $VERSION = '0.01';

require XSLoader;
XSLoader::load('NPLQCD::File::Format::SDB::XS', $VERSION);

# Preloaded methods go here.

sub validate { return c_qdpxx_sdb_validate(@_) ; }
sub spy      { return c_qdpxx_sdb_spy     (@_) ; }
sub dump     { return c_qdpxx_sdb_dump    (@_) ; }

1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

NPLQCD::File::Format::SDB::XS - Perl extension for blah blah blah

=head1 SYNOPSIS

  use NPLQCD::File::Format::SDB::XS;
  blah blah blah

=head1 DESCRIPTION

Stub documentation for NPLQCD::File::Format::SDB::XS, created by h2xs. It looks like the
author of the extension was negligent enough to leave the stub
unedited.

Blah blah blah.

=head2 EXPORT

None by default.



=head1 SEE ALSO

Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

=head1 AUTHOR

E. Chang, E<lt>changezy@hyak.localE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2016 by E. Chang

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.23.6 or,
at your option, any later version of Perl 5 you may have available.


=cut
