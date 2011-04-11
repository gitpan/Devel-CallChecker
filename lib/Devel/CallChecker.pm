=head1 NAME

Devel::CallChecker - custom parsing attached to subroutines

=head1 SYNOPSIS

	# to generate header prior to XS compilation

	perl -MDevel::CallChecker=callchecker0_h \
		-e 'print callchecker0_h' > callchecker0.h

	# in Perl part of module

	use Devel::CallChecker;

	/* in XS */

	#include "callchecker0.h"

	cv_get_call_checker(cv, &ckfun, &ckobj);
	static OP *my_ckfun(pTHX_ OP *o, GV *namegv, SV *ckobj);
	cv_set_call_checker(cv, my_ckfun, ckobj);

=head1 DESCRIPTION

This module makes some new features of the Perl 5.14.0 C API available
to XS modules running on older versions of Perl.  The features are
centred around the function C<cv_set_call_checker>, which allows XS
code to attach a magical annotation to a Perl subroutine, resulting in
resolvable calls to that subroutine being mutated at compile time by
arbitrary C code.  This module makes C<cv_set_call_checker> and several
supporting functions available.  (It is possible to achieve the effect
of C<cv_set_call_checker> from XS code on much earlier Perl versions,
but it is painful to achieve without the centralised facility.)

This module provides the implementation of the functions at runtime
(on Perls where they are not provided by the core), and also at compile
time supplies the C header file which provides access to the functions.

=cut

package Devel::CallChecker;

{ use 5.006; }
use warnings;
use strict;

our $VERSION = "0.001";

use parent "Exporter";
our @EXPORT_OK = qw(callchecker0_h);

{
	require DynaLoader;
	local our @ISA = qw(DynaLoader);
	local *dl_load_flags = sub { 1 };
	__PACKAGE__->bootstrap($VERSION);
}

=head1 CONSTANTS

=over

=item callchecker0_h

Content of a C header file, intended to be named "C<callchecker0.h>".
It is to be included in XS code, and C<perl.h> must be included first.
When the XS module is loaded at runtime, the C<Devel::CallChecker>
module must be loaded first.  This will result in the Perl API functions
C<rv2cv_op_cv>, C<ck_entersub_args_list>, C<ck_entersub_args_proto>,
C<ck_entersub_args_proto_or_list>, C<cv_get_call_checker>, and
C<cv_set_call_checker>, as defined in the Perl 5.14.0 API, being available
to the XS code.

The C<rv2cv_op_cv> function determines whether the subroutine is
statically identifiable in accordance with the prevailing standards of
the Perl version being used.  It uses the same criteria that the core
uses to determine whether to apply a prototype to a subroutine call.
From version 5.11.2 onwards, the subroutine can be determined from a C<gv>
or C<const> op.  Prior to 5.11.2, only a C<gv> op will do.

=back

=head1 SEE ALSO

L<perlapi/cv_set_call_checker>

=head1 AUTHOR

Andrew Main (Zefram) <zefram@fysh.org>

=head1 COPYRIGHT

Copyright (C) 2011 Andrew Main (Zefram) <zefram@fysh.org>

=head1 LICENSE

This module is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1;
