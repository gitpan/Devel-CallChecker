package t::LoadXS;

use warnings;
use strict;

use DynaLoader ();
use ExtUtils::CBuilder ();
use ExtUtils::ParseXS ();
use File::Spec ();

sub loadable_lib_for_module($) {
	my($modname) = @_;
	# This logic is taken from DynaLoader.	It mixes native directory
	# names from @INC and Unix-style /-separated path syntax.
	# Does this really work everywhere?
	my @modparts = split(/::/,$modname);
	my $modend = $modparts[-1];
	my $modpname = join("/",@modparts);
	my $loadlib = DynaLoader::dl_findfile(
			(map { "-L$_/auto/$modpname" } @INC), $modend)
		or die "Can't locate loadable object ".
			"for module $modname in \@INC";
	return $loadlib;
}

my %linkablelib_finders = (
	MSWin32 => sub {
		if((my $basename = $_[0]) =~ s/\.[Dd][Ll][Ll]\z//) {
			foreach my $suffix (qw(.lib .a)) {
				my $impname = $basename.$suffix;
				return ($impname) if -e $impname;
			}
		}
		die "Can't locate linkable object for $_[0]";
	},
	cygwin => sub { ($_[0]) },
);

sub linkable_lib_for_module($) {
	my $finder = $linkablelib_finders{$^O} or return ();
	my($modname) = @_;
	return $finder->(loadable_lib_for_module($modname));
}

1;
our @todelete;
END { unlink @todelete; }

sub load_xs($$$) {
	my($basename, $dir, $importmods) = @_;
	my $xs_file = File::Spec->catdir("t", "$basename.xs");
	my $c_file = File::Spec->catdir("t", "$basename.c");
	ExtUtils::ParseXS::process_file(
		filename => $xs_file,
		output => $c_file,
	);
	push @todelete, $c_file;
	my $cb = ExtUtils::CBuilder->new(quiet => 1);
	my $o_file = $cb->compile(source => $c_file);
	push @todelete, $o_file;
	my @extra_libs = map { linkable_lib_for_module($_) } @$importmods;
	my($so_file, @so_tmps) = $cb->link(objects => [ $o_file, @extra_libs ],
						module_name => "t::$basename");
	push @todelete, $so_file, @so_tmps;
	my $boot_symbol = "boot_t__$basename";
	@DynaLoader::dl_require_symbols = ($boot_symbol);
	my $so_handle = DynaLoader::dl_load_file($so_file, 0);
	defined $so_handle or die(DynaLoader::dl_error());
	my $boot_func = DynaLoader::dl_find_symbol($so_handle, $boot_symbol);
	defined $boot_func or die "symbol $boot_symbol not found in $so_file";
	my $boot_perlname = "t::${basename}::bootstrap";
	DynaLoader::dl_install_xsub($boot_perlname, $boot_func, $so_file)->();
}

1;
